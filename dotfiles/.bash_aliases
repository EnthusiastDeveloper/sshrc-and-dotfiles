#
#  Global ~/.bash_aliases
#

#############  Colored Terminal  #############
alias ls='$(which ls) --color=auto --group-directories-first -hF --time-style=locale'
# Also show line numbers for grep
alias ip='ip -c'
alias grep='grep -n --color=auto --exclude=~/.bash_history'
alias zgrep='zgrep -n --color=always'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
##############################################


################     SSH     ################
BUILDER="builder8"
alias sshb='ssh $BUILDER'

## SSH and SCP using user 'dev'
alias ssh='sshpass -f ~/.password_apollo sshrc'          # Requires 'sshpass'

# ssh() {
#     # select sshpass file based on argument: '-a' for apollo, '-r' for RPD (admin), '-v' for vcmts
#     while getopts 'ahrv' OPTION; do
#         case $OPTION in
#             a) pass_file="$HOME/.password_apollo" ;;
#             h) pass_file="$HOME/.password_harmonic" ;;
#             r) pass_file="$HOME/.password_apollo_admin" ;;
#             v) pass_file="$HOME/.password_vcmts" ;;
#             ?) echo "Usage: ${FUNCNAME[0]} [-a (apollo) | -r (RPD) | -v (VCMTS) | -h (harmonic)] <hostname>"; return 0 ;;
#         esac
#     done

#     if [[ -f $pass_file ]]; then
#         sshpass -f "$pass_file" sshrc
#     else
#         echo "Error: Password file $pass_file not found."
#         return 1
#     fi
# }

alias scp='sshpass -f ~/.password_apollo scp'            # Requires 'sshpass'

## SSH and SCP using user 'admin'
function ssha() {
    # If "$1" is empty, show usage and return
    if [[ -z $1 ]]; then
        echo "Usage: ${FUNCNAME[0]} <hostname>"
        return 1
    fi

    pass_file=''
    if [[ -f /home/$USER/.password_apollo_admin ]]; then
        pass_file="/home/$USER/.password_apollo_admin"
    elif [[ -f $SSHHOME/.sshrc.d/.password_apollo_admin ]]; then
        pass_file="$SSHHOME/.sshrc.d/.password_apollo_admin"
    else
        echo "Error: Password file not found."
        return 1
    fi

    sshpass -f "$pass_file" \ssh admin@"$1"
}
alias scpa='sshpass -f $SSHHOME/.sshrc.d/.password_apollo_admin scp -O -o User=admin'     # Requires 'sshpass'

## SSH and SCP using user 'harmonic'
function sshh() {
    sshpass -f ~/.password_harmonic sshrc $@
}
complete -F _ssh sshh

alias scph='sshpass -f ~/.password_harmonic scp -O -o User=harmonic'     # Requires 'sshpass'
##############################################


##############  Human Readable  ##############
alias du='du -h'
alias df='df -h'
alias free='free -h'
alias speedtest='speedtest --bytes'
##############################################


##############  Alias expansion  ##############
alias sudo='sudo '
alias watch='watch '
alias notify='notify '
##############################################


##############      Yakuake     ##############
alias yqs='addYakuakeQuadSession'
##############################################


##############     Obsidian     ##############
alias obs-encrypt='tar czf - $HOME/obsidian-vaults/MyVault | openssl enc -e -aes-256-cbc -pbkdf2 -out /tmp/my_vault.tar.gz.enc'
alias obs-decrypt='openssl enc -d -aes-256-cbc -pbkdf2 -in my_vault.tar.gz.enc | tar xzf -'
alias obs-backup='obs-encrypt && mv /tmp/my_vault.tar.gz.enc $HOME/Dropbox/Apps/Obsidian/'
##############################################


##############      Network     ##############
alias ping='ping -c 4'
alias pingg='ping www.google.com'

# Execute wget with resume option
alias wget='wget -c'
##############################################


##############    Auto  sudo    ##############
#alias debcrawler='apt-cache pkgnames | fzf --multi --cycle --reverse --preview "apt-cache show {1}" --preview-window=:57%:wrap:hidden --bind=space:toggle-preview | xargs -o sudo apt install'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown now'
alias find='sudo find'
alias apt='sudo apt'
alias aptup='sudo apt update; clear; apt list --upgradable; read -p "Upgrade now? [y/n]  " input; [ ${input^^} == "Y" ] && sudo apt-get -y upgrade || echo "OK, bye."'
##############################################


######   Interactive File Interaction   ######
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
##############################################


##################    Git   ##################
alias gits='git status'
alias dch='dch -Dunstable --urgency=low'
##############################################


##########    Debian Build system   ##########
SCHROOT_PI="pi37"
alias build='nsg-schroot-run $SCHROOT_PI-apollo -- dpkg-buildpackage -us -uc -b -j4'
alias buildd='nsg-schroot build-deps $SCHROOT_PI-apollo . && build'
alias nsg-stop-all-sessions='for s in `nsg-schroot list-all | awk '\''{if($1 == "session::") {print $2}}'\''`; do nsg-schroot session-end "$s"; done'
alias buildexor='nsg-schroot-run exor-$SCHROOT_PI -- dpkg-buildpackage -us -uc -b -aarmhf -j4'
##############################################


##########       Navigations       ###########
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias cd...='cd ../..'

alias cdg='cd ~/git_repositories/"$1"'
alias cdm='cd ~/git_repositories/swpkg/ulc-mulpi'
alias cdr='cd ~/git_repositories/swpkg-rpd'
alias cdipdr='cd ~/git_repositories/swpkg/cosm-ipdr-exporter'
alias cdalg='cd ~/git_repositories/swpkg/cos-algorithms'
##############################################


##############  Various tweaks  ##############

alias l='ls -A'
alias ll='ls -lA'
alias llt='ll -rt -I .directory'

alias c='clear'
alias cdc='cd; clear'

alias cputemp='sensors -A coretemp-isa-0000'
alias wl='wc -l'

alias reload='[ -z $SSHHOME ] && source ~/.bashrc || source $SSHHOME/sshrc.bashrc'
alias brc='$EDITOR ~/.bashrc && reload'
alias bal='$EDITOR ~/.bash_aliases && reload'
alias bfn='$EDITOR ~/.bash_functions && reload'
alias sshc='$EDITOR ~/.ssh/config'

alias xclip='xclip -selection c'

alias j='jobs'
alias h='history'

# Create parent directories if needed
alias mkdir='mkdir -pv'

# Enable the following flags for nano:
#	-A -> Enable smart home key
#	-F -> Enable multibuffer
#	-S -> Enable smooth scrolling
#	-c -> Constantly show cursor position
#	-i -> Automatically indent new lines
#	-l -> Show line numbers in front of the text
#	-m -> Enable mouse support in X window env
#	-u -> Save a file by default in Unix format
#	-s -> Enable alternate speller
alias nano='nano -AFScilm -s "aspell -c -x" --tabsize=4'

alias today='date +%A, %B %-d %Y'

##############################################

# Disk Space usage
alias usage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'
alias most='du -hsx * | sort -rh | head -10'
alias big_files='find . -type f -size +20M -exec ls -lh {} \; 2> /dev/null | awk { print \t( ,, )\t } | sort -hrk 1'

# Auto clear vivaldi corupted datafiles
alias vivaldi-empty-cache='\rm -r "$(du -hsx $HOME/.config/vivaldi/Default/Service\ Worker/* | sort -rh | head -n1 | cut -f2)"'
#du -hsx $HOME/.config/vivaldi/Default/Service\ Worker/* | sort -rh | head -n1 | cut -f2 | rm -r'

# Joplin update
alias joplinup='wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash'

# Zellij terminal (require installing - https://zellij.dev/
alias z='set-konsole-tab-title Zellij; zellij' 
alias zq='set-konsole-tab-title Zellij; zellij --layout $HOME/.config/zellij/layouts/quad.kdl' 
alias zel='set-konsole-tab-title Zellij; zellij' 

# VPN Actions
alias vpc_old='set-konsole-tab-title VPN; sudo openfortivpn -u $WORK_EMAIL --otp=1 --persistent=15 --config /etc/openfortivpn/config.old --trusted-cert 2b0e1b56aa3d156eb02d55defb3a2b8e46089c84c2cd8240b923dee3ed4f5d3e'
alias vpc='set-konsole-tab-title VPN; cd /etc/openfortivpn; clear; sudo openfortivpn --persistent=15 --config /etc/openfortivpn/config'
alias vpk="sudo $HOME/.local/bin/kill-vpn"
