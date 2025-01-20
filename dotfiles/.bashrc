#!/bin/bash
# shellcheck disable=SC1090,SC1091
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
export HISTSIZE=3000
export HISTFILESIZE=2000
export HISTIGNORE="cd*:..:...::exit:c::cdc:clear:reload:[bf]g:reboot:poweroff:vp[ck]:bal:brc:git s"

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s cdspell
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Enable command history expansion
shopt -s histreedit
# Enable command history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space
# Enable prompt expansion
shopt -s promptvars


# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar


if [[ -d $HOME/.local/bin ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Source .bash_env from either home directory or SSH session directory
if [ -r "$HOME/.bash_env.private" ]; then
    . "$HOME/.bash_env.private"
elif [ -r "$SSHHOME/.sshrc.d/.bash_env.private" ]; then
    . "$SSHHOME/.sshrc.d/.bash_env.private"
fi


export EDITOR=vim
#export VISUAL=subl
export PAGER=less
export SHELLCHECK_OPTS='--shell=bash'
export LC_ALL="en_US.UTF-8"
export DEBEMAIL="$FULL_NAME <$WORK_EMAIL>"
#View pacdiff files in sublime text 3
export DIFFPROG=subl

# Set git-author and git-commiter name and email based on .bash_env.private
export GIT_AUTHOR_NAME="$FULL_NAME"
export GIT_AUTHOR_EMAIL="$WORK_EMAIL"
export GIT_COMMITTER_NAME="$FULL_NAME"
export GIT_COMMITTER_EMAIL="$WORK_EMAIL"

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
    # Color definitions for prompt, using tput
    _BOLD=$(tput bold)
    _ITALIC=$(tput sitm)
    _UNDERLINE=$(tput smul)
    _REVERSE=$(tput rev)
    _RED=$(tput setaf 1)
    _GREEN=$(tput setaf 2)
    _GREEN_BOLD="$(tput bold)$(tput setaf 2)"
    _YELLOW=$(tput setaf 3)
    _BLUE=$(tput setaf 4)
    _LIGHT_BLUE=$(tput setaf 75)
    _MAGENTA=$(tput setaf 5)
    _PURPLE=$(tput setaf 93)
    _CYAN=$(tput setaf 6)
    _CYAN_INVERTED="$(tput rev)$(tput setaf 6)"
    _WHITE=$(tput setaf 7)
    _GREY=$(tput setaf 8)
    _ORANGE=$(tput setaf 208)
    _LIGHT_GRAY=$(tput setaf 245)
    _RESET=$(tput sgr0)

    if [ "$USER" = "root" ]; then
        PS1='\[${_RED}\]\A \[${_RED}${_BOLD}${_REVERSE}\]\u\[${_BLUE}\]@\h\[${_YELLOW}\] \W \[${_GREEN}\]\\$\[${_RESET}\] '
    elif command -v git &> /dev/null; then
        for git_prompt_file in \
            "/etc/bash_completion.d/git-prompt" \
            "/usr/share/git/completion/git-prompt.sh" \
            "/usr/share/bash-completion/completions/git" \
            "/usr/lib/git-core/git-sh-prompt"
        do
            [ -f "$git_prompt_file" ] && source "$git_prompt_file"
        done
        
        export GIT_PS1_SHOWDIRTYSTATE=1
        export GIT_PS1_SHOWSTASHSTATE=1
        unset GIT_PS1_SHOWUNTRACKEDFILES
        export GIT_PS1_SHOWUPSTREAM='auto'

        PS1='${debian_chroot:+($debian_chroot)}\[${_RED}\][\$?] \[${_LIGHT_BLUE}\]\A \
\[${_GREEN}\]\u\[${_LIGHT_GRAY}\]@\[${_GREEN_BOLD}\]\h \
\[${_CYAN_INVERTED}\]\W\[${_RESET}\]\[${_ORANGE}\]$(__git_ps1 " (%s)") \[${_PURPLE}\]\\$\[${_RESET}\] '
    else
        PS1='${debian_chroot:+($debian_chroot)}\[${_RED}\][\$?] \[${_LIGHT_BLUE}\]\A \
\[${_GREEN}\]\u\[${_LIGHT_GRAY}\]@\[${_GREEN_BOLD}\]\h \
\[${_CYAN_INVERTED}\]\W\[${_RESET}\] \[${_PURPLE}\]\\$\[${_RESET}\] '
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
if command -v zellij &> /dev/null; then source <(zellij setup --generate-completion "$(echo "$SHELL" | awk -F'/' '{print $NF}')"); fi

# Enable auto-completion for podman
if command -v podman &> /dev/null; then source <(podman completion bash); fi

# Enable auto-completion for docker
if command -v docker &> /dev/null; then source <(docker completion bash); fi


#################################################
###########  Source all .bash_* files  ##########
## Compatible with both local and SSH sessions ##
#################################################

if [[ $SSHHOME ]]; then
    # This section is executed only when using the 'sshrc' script
    [ -f "$SSHHOME/.sshrc.d/.bash_aliases" ] && . "$SSHHOME/.sshrc.d/.bash_aliases"
    [ -f "$SSHHOME/.sshrc.d/.bash_functions" ] && . "$SSHHOME/.sshrc.d/.bash_functions"
    [ -f "$SSHHOME/.sshrc.d/.bash_usingit_api" ] && [ "$USER" == "$REMOTE_SETUP_USERNAME" ] && . "$SSHHOME/.sshrc.d/.bash_usingit_api"
else
    [ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
    [ -f "$HOME/.bash_functions" ] && . "$HOME/.bash_functions"
    [ -f "$HOME/.zoxide_cd.bash" ] && . "$HOME/.zoxide_cd.bash"
    [ -f "$HOME/.bash_usingit_api" ] && [ "$USER" == "$WORK_USERNAME" ] && . "$HOME/.bash_usingit_api"
fi

# Source bash_git_functions if git is installed
if command -v git &>/dev/null; then
    if [ -f "$HOME/.bash_git_functions" ]; then
        . "$HOME/.bash_git_functions"
    elif [ -f "$SSHHOME/.sshrc.d/.bash_git_functions" ]; then
        . "$SSHHOME/.sshrc.d/.bash_git_functions"
    fi
fi

# Source bash_k8s_functions if kubectl is installed
if command -v kubectl &>/dev/null; then
    if [ -f "$HOME/.bash_k8s_functions" ]; then
        . "$HOME/.bash_k8s_functions"
    elif [ -f "$SSHHOME/.sshrc.d/.bash_k8s_functions" ]; then
        . "$SSHHOME/.sshrc.d/.bash_k8s_functions"
    fi
    # Additionally, enable kubectl bash completion
    source <(kubectl completion bash)
fi

# Source schroot functions if nsg-schroot is installed
if command -v nsg-schroot &>/dev/null; then
    if [ -f "$HOME/.bash_schroot_functions" ]; then
        . "$HOME/.bash_schroot_functions"
    elif [ -f "$SSHHOME/.sshrc.d/.bash_schroot_functions" ]; then
        . "$SSHHOME/.sshrc.d/.bash_schroot_functions"
    fi
fi
