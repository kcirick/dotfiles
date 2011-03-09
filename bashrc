# Check for an interactive session
[ -z "$PS1" ] && return

prompt_command() {
	TERMWIDTH=${COLUMNS}

	# Calculate the width of the prompt:
	usern=$(whoami)
	hostn=${HOSTNAME}
	cwd=${PWD/#$HOME/\~}
	let promptsize=$(echo -n "[${usern}@${hostn}][${cwd}]----" | wc -c | tr -d " ")

	let fillsize=${TERMWIDTH}-${promptsize}
	fill=""
	while [ "$fillsize" -gt "0" ]; do
		fill="${fill}─"
		let fillsize=${fillsize}-1
	done

	# Term Titles
	case "$TERM" in
	xterm* |*rxvt*)
		echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"
		;;
	*)
		;;
	esac
}

PROMPT_COMMAND=prompt_command

PS1='┌─[$usern@$hostn]\[\033[32m\][${cwd}]\[\033[0m\] ${fill}\n\[\033[0m\]└─■ '

# Aliases
alias ls='ls --color=auto'
alias ll='ls -l'
alias tyr='ssh -Y tyr.physics.carleton.ca'
alias lxplus='ssh -Y lxplus.cern.ch'

# SVN Stuff
export SVNGRP='svn+ssh://rueno@svn.cern.ch/reps/atlasgrp'

