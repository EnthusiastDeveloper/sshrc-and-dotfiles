# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=erasedups:ignoreboth
# Timestamps in history
export HISTTIMEFORMAT="[%F %T] "

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTIGNORE="cd*:..:...::exit:c::cdc:clear:reload:[bf]g:reboot:poweroff:vp[ck]:bal:brc:*.bash_history*:git s:gits"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s cdspell
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar


# Source .bash_env from either home directory or SSH session directory
if [ -r "$HOME/.bash_env.private" ]; then
    . "$HOME/.bash_env.private"
elif [ -r "$SSHHOME/.sshrc.d/.bash_env.private" ]; then
    . "$SSHHOME/.sshrc.d/.bash_env.private"
fi


export EDITOR=vim
#export VISUAL=subl
export PAGER=less
export SHELLCHECK_OPTS='--shell=dash'
export LC_ALL="en_US.UTF-8"
export DEBEMAIL='$FULL_NAME <$WORK_EMAIL>'
#View pacdiff files in sublime text 3
export DIFFPROG=subl

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# Tab completion for sudo
complete -cf sudo
# Tab completion for man
complete -cf man

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

#####        PS1 configurations        #####
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	if [ "$USER" = "root" ]; then
		PS1='\[\e[0;31m\]\A \[\e[1;31;5;7m\]\u\[\e[0;34m\]@\h\[\e[0;33m\] \W \[\e[0;32m\]\$\[\e[m\] '
	else
		if [ "$USER" == "$WORK_USERNAME" ] && [ -f /etc/bash_completion.d/git-prompt ]; then
			## Source git-prompt script in order to activate the '$(__git_ps1" (%s)")' part of $PS1
			. /etc/bash_completion.d/git-prompt
			GIT_PS1_SHOWDIRTYSTATE=1
			GIT_PS1_SHOWSTASHSTATE=1
			unset GIT_PS1_SHOWUNTRACKEDFILES
			GIT_PS1_SHOWUPSTREAM='auto'

			PS1='${debian_chroot:+($debian_chroot)}\[\e[0;31m\]\A \[\e[0;34m\]\u@\h \[\e[0;33m\]\W \[\e[1;33m\]$(__git_ps1 "(%s)") \[\e[0;32m\]\$\[\e[m\] '
		else
			PS1='${debian_chroot:+($debian_chroot)}\[\e[0;31m\]\A \[\e[0;34m\]\u@\h \[\e[0;33m\]\W \[\e[0;32m\]\$\[\e[m\] '
		fi
	fi
fi


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ] && [ -x ~/.dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Source all .bash_* files from either home directory or SSH session directory
if [[ $SSHHOME ]]; then
    [ -f $SSHHOME/.sshrc.d/.bash_aliases ] && . $SSHHOME/.sshrc.d/.bash_aliases
    [ -f $SSHHOME/.sshrc.d/.bash_functions ] && . $SSHHOME/.sshrc.d/.bash_functions
    [ -f $SSHHOME/.sshrc.d/.bash_usingit_api ] && [ "$USER" == "$REMOTE_SETUP_USERNAME" ] && . $SSHHOME/.sshrc.d/.bash_usingit_api
else
    [ -f $HOME/.bash_aliases ] && . $HOME/.bash_aliases
    [ -f $HOME/.bash_functions ] && . $HOME/.bash_functions
    [ -f $HOME/.zoxide_cd.bash ] && . $HOME/.zoxide_cd.bash
    [ -f $HOME/.bash_usingit_api ] && [ "$USER" == "$WORK_USERNAME" ] && . $HOME/.bash_usingit_api
fi

# Source bash_git_functions if git is installed
if command -v git &>/dev/null; then
    if [ -f $HOME/.bash_git_functions ]; then
        . $HOME/.bash_git_functions
    elif [ -f $SSHHOME/.sshrc.d/.bash_git_functions ]; then
        . $SSHHOME/.sshrc.d/.bash_git_functions
    fi
fi

# Source bash_k8s_functions if kubectl is installed
if command -v kubectl &>/dev/null; then
    if [ -f $HOME/.bash_k8s_functions ]; then
        . $HOME/.bash_k8s_functions
    elif [ -f $SSHHOME/.sshrc.d/.bash_k8s_functions ]; then
        . $SSHHOME/.sshrc.d/.bash_k8s_functions
    fi
    # Additionally, enable kubectl bash completion
    source <(kubectl completion bash)
fi

# Source schroot functions if nsg-schroot is installed
if command -v nsg-schroot &>/dev/null; then
    if [ -f $HOME/.bash_schroot_functions ]; then
        . $HOME/.bash_schroot_functions
    elif [ -f $SSHHOME/.sshrc.d/.bash_schroot_functions ]; then
        . $SSHHOME/.sshrc.d/.bash_schroot_functions
    fi
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Enable auto-completion for zellij terminal emulator
if command -v zellij &> /dev/null; then source <(zellij setup --generate-completion "$(echo $SHELL | awk -F'/' '{print $NF}')"); fi

