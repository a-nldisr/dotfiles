#!/bin/bash

# Cleans up DCOS clusters
remove_dcos_cluster() {
	RMDCOS=$(command -v dcos)
	export RMDCOS
	${RMDCOS} cluster remove --all
}

# In the future i will split up my personal projects to ~/Git/private and commit all when this is ran
clean_private_git() {
	# We retrieve the fullpath from our private Git directory
	export PRIVATE_GIT_DIR
	PRIVATE_GIT_DIR=$(realpath ~/Git/private)
	# We place the command in an variable since commands are not available in subshells
	echo -e "Scanning directories in: ${PRIVATE_GIT_DIR}"
	while IFS= read -r dir
	do
		# For some reason i kept getting .DS_Store listed by find as directory. This fixes that
		if [[ -d "$dir" ]]; then
			cd "$dir" || exit
			echo -e "Moved into: $dir"
			if [[ -d ".git" ]]; then
				echo -e "This directory should contain a git repository"
				if [[ $(git status --porcelain) ]]; then
					git status
				else
					echo -e "There are no changes in $dir"
				fi
			fi
		else 
			echo "not directory"
		fi
	done < <(find "${PRIVATE_GIT_DIR}" -type d -maxdepth 1 -name '.*' ! -name ".git" ! -path '*.DS_Store*' -prune -o -print )
}

main() {
	echo -e "This is not working yet"
}
