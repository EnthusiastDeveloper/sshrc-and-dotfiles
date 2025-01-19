#
#  Global ~/.bash_aliases
#

#############  Colored Terminal  #############
alias ls='$(which ls) --color=auto --group-directories-first -hF --time-style=locale'

alias grep='grep --color=auto --exclude=~/.bash_history'
alias dir='dir --color=auto'
alias ip='ip -c'

##############################################


################     SSH     ################
BUILDER="builder8"
alias sshb='ssh $BUILDER'

## SSH and SCP using user 'dev'
function ssh() {
    # check if sshrc is installed
    local command_to_run=$(command -v sshrc >/dev/null 2>&1 && echo "sshrc" || echo "ssh")

    # Select sshpass file based on argument: '-a' for apollo, '-r' for RPD (user=admin), '-v' for vcmts, '-h' for harmonic
    while getopts 'ahrv' OPTION; do
        case $OPTION in
            a) pass_file=".password_apollo" ;;
            h) pass_file=".password_harmonic" ;;
            r) pass_file=".password_apollo_admin" ;;
            v) pass_file=".password_vcmts" ;;
            ?) echo "Usage: ${FUNCNAME[0]} [-a (apollo) | -r (RPD) | -v (VCMTS) | -h (harmonic)] <hostname>"; return 0 ;;
        esac
    done

    # Set default password file for work accounts
    if [[ $(whoami) == "$WORK_USERNAME" ]]; then
        pass_file=".password_apollo"
    fi

    # Search for the password file in "$HOME" or "$SSHHOME"
    pass_file=$(find "$HOME" --maxdepth 1 -name "$pass_file" 2>/dev/null)
    if [[ -z $pass_file ]]; then
        pass_file=$(find "$SSHHOME" -name "$pass_file" 2>/dev/null)
        if [[ -z $pass_file ]]; then
            echo "Error: Password file $pass_file not found!"
            return 1
        fi
    fi

    command_to_run="sshpass -f $pass_file $command_to_run"

    echo "$command_to_run $@"
    $command_to_run "$@"
}

complete -F _ssh ssh

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

## SSH and SCP using user 'harmonic'
function sshh() {
    sshpass -f ~/.password_harmonic sshrc $@
}
complete -F _ssh sshh

alias scp='sshpass -f ~/.password_apollo scp'            # Requires 'sshpass'
alias scpa='sshpass -f $SSHHOME/.sshrc.d/.password_apollo_admin scp -O -o User=admin'     # Requires 'sshpass'
alias scph='sshpass -f ~/.password_harmonic scp -O -o User=harmonic'     # Requires 'sshpass'
##############################################


##############  Human Readable  ##############
alias du='du -h'
alias df='df -h'
alias free='free -ht'
alias speedtest='speedtest --bytes'

# Show progress bar for dd command
alias dd='dd status=progress'

# turn mount output to better looking and human readable
alias mounts='mount | column -t'

alias path='echo -e ${PATH//:/\\n}'


# Show system load in readable format
alias load='uptime -p; uptime | grep -oP "average: \K[0-9.]+" | xargs -I{} echo "Load: {}"'

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
alias pingap='ping 192.168.8.4'
alias pingdns='ping adguard'
alias pingg='ping www.google.com'

# Execute wget with resume option
alias wget='wget -c'
alias ext_ip='wget -q -O - http://icanhazip.com/ | tail'

# nmap formatter, requires 'xmlstarlet' package
alias nmap_formatter="xmlstarlet sel -t -m '/nmaprun/host[status/@state=\"up\"]' -v 'address[@addrtype=\"ipv4\"]/@addr' -o $'\t' -v 'address[@addrtype=\"mac\"]/@addr' -o $'\t' --if 'address[@addrtype=\"mac\"]/@vendor' -v 'address[@addrtype=\"mac\"]/@vendor' -o $'\t' -b --if 'hostnames/hostname[1]' -v 'hostnames/hostname[1]/@name' -b -n"

# nmap shortcuts for home networks scanning
alias nmap='sudo nmap'
local_network_address=$(ip -o -4 addr list | awk '{print $4}' | cut -d/ -f1 | grep "192.168" | awk -F. '{print $1"."$2"."$3".0/24"}')
alias nmap_home='nmap -sn "$local_network_address" -oX - | nmap_formatter'

##############################################


##############    Auto  sudo    ##############
#alias debcrawler='apt-cache pkgnames | fzf --multi --cycle --reverse --preview "apt-cache show {1}" --preview-window=:57%:wrap:hidden --bind=space:toggle-preview | xargs -o sudo apt install'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown now'
alias find='sudo find'
alias podman='sudo podman '

alias please='sudo !!'
##############################################


#############   Package Managers  ############
#################   Pacman  ##################
alias pacman='sudo pacman '
alias pacup='pacman -Syyu'
alias pacser='pacman -Ss'
alias pacinst='pacman -S'
alias pacuninst='pacman -Rns'
alias pacorphans='pacman -Qtdq'
alias pacdelorphans='pacman -Rns $(pacman -Qtdq)'
alias pacclean='pacman -Sc'
alias paccleanall='pacman -Scc'

alias pacdiff='sudo pacdiff '


###################   Apt  ###################
alias apt='sudo apt'
alias aptup='apt update; clear; apt list --upgradable; read -p "Upgrade now? [y/n]  " input; [ ${input^^} == "Y" ] && sudo apt-get -y upgrade || echo "OK, bye."'
alias aptser='apt search'
alias aptinst='apt install'
alias aptuninst='apt remove'
alias aptorphans='apt autoremove'
alias aptpurge='apt remove --purge'
alias aptclean='apt clean'
alias aptcleanall='apt autoclean'
##############################################


#################   Podman  ##################
alias pps='podman ps'
alias ppsa='podman ps -a'
alias ppod='podman pod list'
alias prmi='podman rmi'
##############################################


######   Interactive File Interaction   ######
# Do not delete / or prompt if deleting more than 3 files at a time
alias rm='rm -I --preserve-root'
# Confirmations
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
##############################################


##########    Debian Build system   ##########
alias dch='dch -Dunstable --urgency=low'
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

if [[ $WORK_USERNAME = $USER ]]; then
    local_git_repositories="$HOME/git_repositories/swpkg"
elif [[ $REMOTE_SETUP_USERNAME = $USER ]]; then
    local_git_repositories="$HOME/git_repos"
fi

alias cdipdr='cd $local_git_repositories/cosm-ipdr-exporter'
alias cdalg='cd $local_git_repositories/cos-algorithms'
alias cdm='cd $local_git_repositories/ulc-mulpi'
alias cdr='cd $local_git_repositories/swpkg-rpd'
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

# If xclip is installed, use it to copy to clipboard
if command -v xclip &> /dev/null; then
    alias xclip='xclip -selection c'
elif command -v wl-copy &> /dev/null; then
    alias xclip='wl-copy'
fi

alias j='jobs'
alias h='history'

alias psg='ps aux|head -1 ; ps aux| grep -v "grep" | grep -i '

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

# Disk Space usage for partitions, excluding tmpfs and devtmpfs
alias usage='df -hlT --exclude-type=tmpfs --exclude-type=devtmpfs'
# Top 10 largest files in current directory
alias most='du -hsx * | sort -rh | head -10'
# List files larger than 20MB in current directory
alias big_files='find . -type f -size +20M -exec ls -lh {} \; 2> /dev/null | awk { print \t( ,, )\t } | sort -hrk 1'

# Auto clear vivaldi corupted datafiles
alias vivaldi-empty-cache='\rm -r "$(du -hsx $HOME/.config/vivaldi/Default/Service\ Worker/* | sort -rh | head -n1 | cut -f2)"'

# Joplin update
alias joplinup='wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash'

# Zellij terminal (require installing - https://zellij.dev/
alias z='set-konsole-tab-title Zellij; zellij' 
alias zq='set-konsole-tab-title Zellij; zellij --layout $HOME/.config/zellij/layouts/quad.kdl' 
alias zel='set-konsole-tab-title Zellij; zellij' 

# VPN Actions
alias vpc='set-konsole-tab-title VPN; cd /etc/openfortivpn; clear; sudo openfortivpn --persistent=15 --config /etc/openfortivpn/config'
alias vpk="sudo $HOME/.local/bin/kill-vpn"
