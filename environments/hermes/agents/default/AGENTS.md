# Agent Context

General-purpose conventions for all agents operating on this system.
Environment-specific values (Consul address, agent identity, capabilities)
are provided at runtime — not hardcoded here.

---

## Environment

Two contexts for running commands:

**Inside the Nix dev shell** — required for all project tooling:

```bash
nix develop --command <cmd>
```

**Outside the dev shell** — Nix-level operations only:

```bash
nix flake check
nix flake update
nix fmt
```

Never install tools with `go install`, `apt`, `brew`, or `pip`.
If a tool is missing, add it to the project's `flake.nix`.
Services run as bare binaries managed by systemd via Nix. No containers.

---

## Formatting

Format code before every commit, without exception.

| Tool | Command                                         |
| ---- | ----------------------------------------------- |
| Go   | `nix develop --command go fmt ./...`            |
| Nix  | `nix fmt` (uses the flake's `formatter` output) |
| Bash | `nix develop --command shfmt -w scripts/`       |

Every `flake.nix` must define a formatter:

```nix
formatter = pkgs.nixfmt-rfc-style;
```

Run `nix fmt` to format all `.nix` files in the project. If a Taskfile `fmt`
task exists, use it — it will run all formatters in order.

Whenever modifying any file, format it before committing. If an existing file
is unformatted, format it as a separate commit before making changes.

---

## Pre-commit

Every project must have a `.pre-commit-config.yaml`. Install hooks after cloning:

```bash
nix develop --command pre-commit install
```

Required hooks per tool:

```yaml
repos:
  - repo: local
    hooks:
      - id: go-test
        name: go test
        entry: nix develop --command go test ./...
        language: system
        pass_filenames: false

      - id: go-fmt
        name: go fmt
        entry: nix develop --command go fmt ./...
        language: system
        pass_filenames: false

      - id: go-vet
        name: go vet
        entry: nix develop --command go vet ./...
        language: system
        pass_filenames: false

      - id: nix-fmt
        name: nix fmt
        entry: nix fmt
        language: system
        types: [nix]
        pass_filenames: false

      - id: shfmt
        name: shfmt
        entry: nix develop --command shfmt -w
        language: system
        types: [shell]
```

### Handling pre-commit failures

**Formatter hooks** (go-fmt, nix-fmt, shfmt) auto-fix files in place and exit
non-zero. The commit is aborted but the files are already corrected. Stage the
fixed files and retry:

```bash
git add -u
git commit -m "..."   # will pass this time
```

**Linter hooks** (go-vet) report issues without fixing them. Read the output,
fix the reported code issues, then retry the commit.

---

## Task Runner

Always check available tasks before doing anything:

```bash
nix develop --command task --list
```

Never assume a task name exists. If a task covers what you need, use it.
If no task exists, check `Taskfile.yml` before running commands manually.

---

## Go

### Project Layout

```
cmd/<binary-name>/main.go   binary entry point (thin — logic goes in packages)
internal/                   private packages
frontend/                   Vite + React source
dist/                       built frontend assets (Vite output, gitignored)
bin/                        compiled binaries
scripts/                    bash scripts
```

`dist/` and `bin/` must be in `.gitignore`. Never commit generated output.

### Build Order

Frontend must be built before the Go binary. `//go:embed dist/*` will fail
if `dist/` does not exist. Always use the Taskfile `build` task which handles
order. If building manually:

```bash
# 1. Build frontend first
nix develop --command bash -c "cd frontend && pnpm install && pnpm run build -- --outDir ../dist"

# 2. Then build the binary
nix develop --command go build -o bin/<name> ./cmd/<name>
```

For new projects, invoke the `go-scaffold` skill.

### CLI — Cobra + Viper

Every binary uses Cobra for commands and Viper for configuration.
Ports and all runtime config are set via flags — never hardcoded.

Default port is `8080`. Use the binary name as the env var prefix:

```go
viper.SetEnvPrefix("APPNAME") // replace with actual binary name, uppercased
viper.AutomaticEnv()

rootCmd.PersistentFlags().Int("port", 8080, "Port to listen on")
viper.BindPFlag("port", rootCmd.PersistentFlags().Lookup("port"))
```

Flag names use kebab-case (`--some-flag`), env vars use
`PREFIX_UPPER_SNAKE` (`APPNAME_SOME_FLAG`).

### Observability — Required for Every Service

Every Go service must expose:

1. **Prometheus metrics** at `/metrics`
2. **Dashboard** at `/` — embedded Vite + React, served from the binary

Use the graceful shutdown pattern — required for systemd SIGTERM handling:

```go
//go:embed dist/*
var frontend embed.FS

mux := http.NewServeMux()
mux.Handle("/metrics", promhttp.Handler())
mux.Handle("/", http.FileServer(http.FS(frontend)))

addr := fmt.Sprintf(":%d", viper.GetInt("port"))
server := &http.Server{Addr: addr, Handler: mux}

ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()

go func() {
    if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
        slog.Error("server failed", "error", err)
        os.Exit(1)
    }
}()

<-ctx.Done()
slog.Info("shutting down")

shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()

if err := server.Shutdown(shutdownCtx); err != nil {
    slog.Error("shutdown failed", "error", err)
    os.Exit(1)
}
```

Required imports:

```
context, errors, fmt, net/http, os, os/signal, syscall, time
github.com/prometheus/client_golang/prometheus
github.com/prometheus/client_golang/prometheus/promhttp
github.com/spf13/cobra
github.com/spf13/viper
```

### Metrics

Metrics must be meaningful — track requests, errors, latency, and any
domain-specific events. Exposing an empty `/metrics` endpoint is not sufficient.

Minimum required instrumentation for every service:

```go
var (
    requestsTotal = prometheus.NewCounterVec(prometheus.CounterOpts{
        Name: "requests_total",
        Help: "Total number of requests by endpoint and status.",
    }, []string{"endpoint", "status"})

    requestDuration = prometheus.NewHistogramVec(prometheus.HistogramOpts{
        Name:    "request_duration_seconds",
        Help:    "Request latency by endpoint.",
        Buckets: prometheus.DefBuckets,
    }, []string{"endpoint"})

    errorsTotal = prometheus.NewCounterVec(prometheus.CounterOpts{
        Name: "errors_total",
        Help: "Total number of errors by type.",
    }, []string{"type"})
)

func init() {
    prometheus.MustRegister(requestsTotal, requestDuration, errorsTotal)
}
```

Add domain-specific metrics for any significant business event the service
handles. If the service processes tasks, track tasks processed, task duration,
and tasks failed.

### Standards

**Dependencies**

- Run `nix develop --command go mod tidy` after adding or removing any dependency
- Run it before every commit — never commit a dirty `go.mod` or `go.sum`

**Errors**

- Wrap with `fmt.Errorf("context: %w", err)`
- No `panic` in library code
- No `log.Fatal` outside of `main.go`

**Logging**

- Use `log/slog` with JSON handler — set once in `main.go`:
  ```go
  slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
      Level: slog.LevelInfo,
  })))
  ```
- Timestamps are RFC3339 UTC by default — do not override
- No `fmt.Println` for operational output

**Versioning**

- Semantic versioning in `go.mod`
- Tag releases as `v<major>.<minor>.<patch>`

### Testing

- Tests are mandatory before committing
- Use table-driven tests (`[]struct{ ... }` pattern)
- Test files co-located with source (`<file>_test.go`)
- Run before committing:
  ```bash
  nix develop --command go test ./...
  nix develop --command go vet ./...
  ```

### Common Commands

```bash
nix develop --command go build ./...
nix develop --command go test ./...
nix develop --command go vet ./...
nix develop --command go fmt ./...
nix develop --command go mod tidy
```

---

## Bash

Scripts live in `scripts/`. Every script must start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

No exceptions. Fix non-compliant scripts before running or modifying them.
No hardcoded paths, IPs, or tokens — use environment variables.
Format scripts with `shfmt` before committing.

---

## Nix

When modifying `flake.nix`:

- Run `nix fmt` to format before committing
- Run `nix flake check` to validate before committing
- Pin new inputs explicitly — no floating references
- Every flake must define `formatter = pkgs.nixfmt-rfc-style;`

Every project's dev shell must include these tools for pre-commit and scripts:

```nix
devShells.default = pkgs.mkShell {
    packages = with pkgs; [
        go
        nixfmt-rfc-style
        shfmt
        pre-commit
        nodejs
        pnpm  # frontend package manager
    ];
};
```

Add any project-specific tools alongside these.

---

## Git

Conventional commits — prefix every commit message:

| Prefix      | When to use                          |
| ----------- | ------------------------------------ |
| `feat:`     | New functionality                    |
| `fix:`      | Bug fix                              |
| `refactor:` | Code change without behaviour change |
| `chore:`    | Tooling, deps, config                |
| `docs:`     | Documentation only                   |
| `test:`     | Tests only                           |
| `fmt:`      | Formatting only                      |

Formatting changes always go in a separate `fmt:` commit before functional changes.

---

## Task Coordination

Before picking up any Consul task, invoke the `consul-coordination` skill.
It handles task discovery, claiming, status updates, and completion signalling
via the consul-mcp tool. Do not start work without a confirmed claim.

---

## What Not To Do

- Do not install tools outside Nix
- Do not run project commands outside `nix develop --command`
- Do not write bash scripts without `set -euo pipefail`
- Do not output binaries anywhere other than `bin/`
- Do not hardcode ports, IPs, paths, or secrets — use Cobra flags and Viper
- Do not skip the Prometheus `/metrics` endpoint on any Go service
- Do not skip the embedded dashboard on any Go service
- Do not build the Go binary before building the frontend
- Do not assume a Taskfile task exists without checking `task --list` first
- Do not run services in containers — deploy as bare binaries via Nix
- Do not commit without formatting first
- Do not mix formatting changes with functional changes in the same commit
- Do not push code — commit only. Pushing is a human decision.
- Do not work in a cloned repo without running `nix develop --command pre-commit install` first
