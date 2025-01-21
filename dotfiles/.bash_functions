#!/bin/bash


nyan() {
    # Colors are defined in .bashrc
    echo
    echo -e "${_RED}-_-_-_-_-_-_-_${_BOLD}${_WHITE},------,${_RESET}"
    echo -e "${_ORANGE}_-_-_-_-_-_-_-${_BOLD}${_WHITE}|   /\_/\\${_RESET}"
    echo -e "${_GREEN}-_-_-_-_-_-_-${_BOLD}${_WHITE}~|__( ^ .^)${_RESET}"
    echo -e "${_CYAN}-_-_-_-_-_-_-_${_BOLD}${_WHITE}"'""  ""'"${_RESET}"
    echo -e "${_RESET}"
}


mykillall ()
{
    for pid in $(pgrep "$1"); do
        sudo kill -9 "$pid"
    done
}

## Create a new directory and cd into it
function md() {
    mkdir -p "$@" && cd "$@" || return 1
}

## Move up the specified number of directories
function up() {
    cd "$(printf "%0.0s../" $(seq 1 "$1"))" || return 1
}

# Show the battery status of BT devices
alias logi_k380_bat='_show_bat_info "battery_hid_f4o73o35o88ob1odb_battery"'
alias k380_bat='logi_k380_bat'

mouse_bat() {
    if compgen -G "/sys/class/power_supply/hid-f4:73:35:88*-battery" > /dev/null; then
        # For JOMAA trackball mouse
        _show_bat_info "mouse_dev"
    elif [ -f /sys/class/power_supply/hidpp_battery_0 ]; then
        # For Logitech MX Master 3
        _show_bat_info "hidpp_battery_0"
    fi
}

## Requires upower package to be installed
function _show_bat_info()
{
    ## If the below variables doesn't work for you, replace their values with the mouse MAC and hidpp battery paths using `upower -e`
    upower_ids="$(upower -e | $(which grep) "$1")"

    # iterate over all the upower ids
    for upower_id in $upower_ids; do
        model=$(upower -i "$upower_id" | awk '{if ($1 ~ "model") {for (i=2; i<=NF; i++) printf "%s ", $i; print ""}}')
        bat_percentage=$(upower -i "$upower_id" | awk '{if ($1 ~ "percentage") print $2}')
        is_charging="$(upower -i "$upower_id" | awk '{ if ($1 ~ "state") print $2}')"
        if [ "$is_charging" == "charging" ]; then
            echo -e "${GREEN}$model battery is at $bat_percentage & charging${NO_COLOR}"
        else
            echo -e "${RED}$model battery is at $bat_percentage, discharging${NO_COLOR}"
        fi
    done
}

## Find shorthand
function f() {
    find . -name "$1" 2>&1 | grep -v 'Permission denied'
}


## Display hard links locations for supplied filename
## If no filename is supplied - scans all files in the current directory
function findLinks() {
    local target
    target="${1:-.}"

    find "$target" -type f -links +1 -printf "%n %i %p\n" 2>/dev/null | while read -r num_of_links inode_num file; do
        echo "debug: num_of_links=$num_of_links inode num=$inode_num filename=$file"

        if [[ ! -r "$file" ]]; then
            echo "'$file' is not accessible :("
            continue
        fi

        echo -e "${MAGENTA}Links for $file:${NO_COLOR}"
        device=$(df "$file" | tail -1l | awk '{print $6}')
        find "${device}" -inum "${inode_num}" 2>/dev/null | sed 's/^/   /'
    done
}

function largefiles() {
    dir=$(pwd)
    size="20M"
    if [ $# -ge 1 ]; then
        dir="$1"
    fi
    if [ $# -eq 2 ]; then
        size="$2"
    fi

    find "$dir" -type f -size +"$size" -exec ls -lh {} \; 2> /dev/null | 
    awk '{ 
        printf "%s\t(%s %s %s)\t", $5, $6, $7, $8;
        for (i=9; i<=NF; i++) printf "%s ", $i;
        print ""
    }' |
    sort -hrk 1
}

function extract() {
    if [ -f "$1" ] ; then
        local filename
        local foldername="${filename%%.*}"
        local fullpath
        local didfolderexist=false
        filename=$(basename "$1")
        fullpath=$(perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1")

        if [ -d "$foldername" ]; then
            didfolderexist=true
            read -rp "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                return
            fi
        fi
        mkdir -p "$foldername" && cd "$foldername" || return 1
        case $1 in
            *.tar.bz2) tar xjf "$fullpath" ;;
            *.tar.gz) tar xzf "$fullpath" ;;
            *.tar.xz) tar Jxvf "$fullpath" ;;
            *.tar.Z) tar xzf "$fullpath" ;;
            *.tar) tar xf "$fullpath" ;;
            *.taz) tar xzf "$fullpath" ;;
            *.tb2) tar xjf "$fullpath" ;;
            *.tbz) tar xjf "$fullpath" ;;
            *.tbz2) tar xjf "$fullpath" ;;
            *.tgz) tar xzf "$fullpath" ;;
            *.txz) tar Jxvf "$fullpath" ;;
            *.zip)
                if ! command -v unzip &> /dev/null; then
                    echo "'unzip' is not installed, please install it first"
                    return 1
                else
                    unzip "$fullpath"
                fi
                ;;
            *.7z)
                if ! command -v 7z &> /dev/null; then
                    echo "'7z' is not installed, please install it first"
                    return 1
                else
                    7z x "$fullpath"
                fi
                ;;
            *.rar)
                if ! command -v unrar &> /dev/null; then
                    echo "'unrar' is not installed, please install it first"
                    return 1
                else
                    unrar x "$fullpath"
                fi
                ;;
            *) echo "'$1' cannot be extracted via ${FUNCNAME[0]}" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function wireshark() {
    if command -v wireshark &> /dev/null; then
        wireshark "$@"
    elif [[ -f "$HOME/git_repositories/wireshark-harmonic/run/wireshark" ]]; then
        "$HOME"/git_repositories/wireshark-harmonic/run/wireshark "$@"
    else
        echo "Error: Couldn't find wireshark"
        return 1
    fi
}

## This script finds all matching logs produced by log-rotate and concatenates them into a single file
## It then deletes the origianl files and compresses the new file
function log-combine() {
    LOGS="$($(which find) . -type f -name "*.log.1.gz" -printf '%P\n' | $(which awk) -F. '{print $1}')"
    for log in $LOGS; do
        echo "[debug] Processing $log"
        OUTPUT_FILE="$log.log.combined"
        ## Find all matching files
        FILES="$($(which ls) "$log*" | $(which grep) gz | sort -r)"
        echo "[debug] Files: $FILES"
        ## Concatenate all files into a single file
        for file in $FILES; do
            zcat "$file" >> "$OUTPUT_FILE"
            $(which rm) "$file"
        done
        cat "$log.log" >> "$OUTPUT_FILE"
        $(which rm) "$log.log"

        ## Compress the new file
        tar -czf "$OUTPUT_FILE".tar.gz "$OUTPUT_FILE"
        $(which rm) "$OUTPUT_FILE"
    done
}

function log-trim() {
    [[ -z $1 ]] && echo -e "Usage: ${FUNCNAME[0]} <path-to-log-file>" && return
    sed -Ei.bak --quiet 's/^.*T([0-9:]+\.[0-9]{5}).*Severity": "([A-Z]+)", "Package": "([[:alpha:]_-]+).*File": "\.\.\/\.\.\/(.*)", "Line": "([0-9]+)", (.*)/\1 \2 \3 \4:\5 \6/p' "$1"
    sed -i 's/\\n/\n/g' "$1"
}

function word-count() {
    local search_term
    local path
    # Validate command-line arguments
    if [ "$#" -lt 1 ]; then
        echo "Usage: ${FUNCNAME[0]} <string-to-search> [/path/to/directory]"
        return 1
    fi

    search_term="$1"
    if [[ -n $2 ]]; then
        path="$2"
    else
        path="$(pwd)"
    fi

    $(which grep) -rhci "$search_term" "$path" | awk '{sum += $1} END {print sum}'
}

function find-recursive-functions () {
    local dir="${1:-.}"
    function check_recursive() {
        local file="$1"
        local filename
        filename=$(basename "$file")

        # Use grep to find potential recursive functions calls
        recursive_calls=$($(which grep) -nE --exclude-dir={.git,.idea} '(^|\s)(\w+)\s*\([^)]*\).*\{' "$file" | 
                            while read -r line; do
                                # Extract the function name
                                function_name=$(echo "$line" | sed -E 's/.*[[:space:]](\w+)\s*\(.*/\1/')
                                # Check if the function name is the same as the file name
                                if $(wchich grep) -q "\<$function_name\s*(" "$file"; then
                                    echo "$line"
                                fi
                            done)
        if [ -n "$recursive_calls" ]; then
            echo "Potential recursive functions found in $filename:"
            echo -e "$recursive_calls\n"
        fi
    }
    $(which find) "$dir" -type f \( -name "*.cpp"  -o -name "*.hpp" -o -name "*.h" \) | 
        while read -r file; do
            check_recursive "$file"
        done
}


# Get the maintainer and uploader of a given package(s).
# Example usage: maint <dir1> <dir2> .. - will show info for each argument
#                ls cosm-* | maint - will show info for each given data
#                maint - will show info for current directory
function maint() {
    local path

    function getMaintainer() {
        [[ "$2" -eq 1 ]] && echo "-- $1"
        res=""
        for file in "$1/debian/control"*; do
            output=$(awk '/^(Maintainer|Uploaders):/ {print $0; capt=1; next} capt && /^ / {print $0; next} capt && /^[^ ]/ {capt=0; exit}' "$file")
            res="$res$output\n"
        done

        echo -e "$res" | awk '!seen[$0]++ && NF'
    }

    # Read input from argument
    if [ $# -gt 0 ]; then
        with_dir=$(($# > 1))
        for arg in "$@"; do
            getMaintainer "$arg" $with_dir
        done
    # Use current directory if no input given from pipe
    elif [ -t 0 ]; then
        getMaintainer "$(pwd)"
    else
        # Iterate over pipe input and execute for each line
        while read -r path; do
            getMaintainer "$path" "1"
        done
    fi
}


############################# Logging #############################
search_logging_library() {
    local parent_dir="$HOME/git_repositories/swpkg"
    local folders_filename="apollo.pi37.packages.2024.09.03.conf"
    # Get the first column of the file (the folder names)
    mapfile -t folders < <(awk '{print $1}' "$parent_dir/$folders_filename")

    for folder in "${folders[@]}"; do
        local full_path="$parent_dir/$folder"
        local controlfile="$full_path/debian/control"

        if [ ! -d "$full_path" ]; then
            echo "  Error: $full_path is not a directory"
            continue
        fi

        local logging_lib=""

        if grep "python3-foundation" "$controlfile" > /dev/null 2>&1; then
            logging_lib="nsg-foundation"
        elif grep -E "(nsg-logctl|python3-nsglogctl)" "$controlfile" > /dev/null 2>&1; then
            logging_lib="nsg-logctl"
        elif grep "nsg-logger" "$controlfile" > /dev/null 2>&1; then
            logging_lib="nsg-logger"
        elif grep "python3-logging" "$controlfile" > /dev/null 2>&1; then
            logging_lib="python3-logging"
        
        fi

        echo "$folder: $logging_lib"
    done
}


## List file types in a directory
## Usage: list_file_types [/path/to/directory | default: current directory]
list_file_types() {
    local dir="${1:-$(pwd)}"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist"
        return 1
    fi

    # Create temporary file to store extensions
    local tmp_file=$(mktemp)
    
    # Find all files recursively and extract unique extensions
    find "$dir" -type f -not -path '*/\.*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/.pybuild/*' -not -path '*/debian/tmp/*' | while read -r file; do
        # Get file extension, convert to lowercase
        ext="${file##*.}"
        ext="${ext,,}"

        # Handle files with or without extension
        if [ "$ext" = "$file" ]; then
            # Check for shebang in files without extension
            first_line=$(head -n 1 "$file" 2>/dev/null)
            if [[ "$first_line" == *"python"* ]]; then
                echo "py" >> "$tmp_file"
            elif [[ "$first_line" == *"bash"* ]] || [[ "$first_line" == *"/sh"* ]]; then
                echo "sh" >> "$tmp_file"
            else
                echo "no_extension" >> "$tmp_file"
            fi
        else
            echo "$ext" >> "$tmp_file"
        fi
    done

    # Sort and get unique extensions
    echo "File types found in directory:"
    echo "-----------------------------"
    sort "$tmp_file" | uniq -c | sort -rn | while read -r count ext; do
        printf "%-20s: %d files\n" "$ext" "$count"
    done

    echo -e "\n-----------------------------"
    echo "Total amount of files: $(wc -l < "$tmp_file")"

    # Cleanup
    rm "$tmp_file"
}


## Count lines of code in a directory
## Usage: count_code_lines [/path/to/directory | default: current directory]
count_code_lines() {
    local dir="${1:-$(pwd)}"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist"
        return 1
    fi

    # Initialize counters for different file types
    declare -A line_counts

    # Find all files recursively, excluding hidden directories and .git folder
    while IFS= read -r -d '' file; do
        # Get file extension
        # Get file extension, or check for shebang if no extension
        if [[ "$file" == *"."* ]]; then
            ext="${file##*.}"
        else
            # Check first line for shebang
            first_line=$(head -n 1 "$file")
            if [[ "$first_line" == *"python"* ]]; then
                ext="py"
            elif [[ "$first_line" == *"bash"* ]] || [[ "$first_line" == *"/sh"* ]]; then
                ext="sh"
            else
                # Skip files with no extension and no recognizable shebang
                continue
            fi
        fi
        
        # Count non-empty, non-comment lines based on file type
        case "$ext" in
            py)
                # Python files: ignore # comments, ''' and """ blocks, and empty lines
                count=$(sed '/^[[:space:]]*"""/,/"""/d' "$file" | sed "/^[[:space:]]*'''/,/'''/d" | grep -v '^\s*#' | grep -v '^\s*$' -c)
                ;;
            sh|bash)
                # Shell scripts: ignore # comments and empty lines
                count=$(grep -v '^\s*#' "$file" | grep -v '^\s*$' -c)
                ;;
            c|cpp|h|hpp|java)
                # C/C++/Java: ignore // and /* */ comments and empty lines
                count=$(sed 's|//.*||g' "$file" | sed '/\/\*/,/\*\//d' | grep -v '^\s*$' -c)
                ;;
            sql)
                # SQL files: ignore -- comments and empty lines
                count=$(grep -v '^\s*--' "$file" | grep -v '^\s*$' -c)
                ;;
            *)
                # Skip files with unknown extensions
                continue
                ;;
        esac

        # echo "File: $file, Type: $ext, Lines: $count"
        # Add to total for this file type
        line_counts["$ext"]=$((${line_counts["$ext"]:-0} + count))
    done < <(find "$dir" -type f -not -path '*/\.*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/.pybuild/*' -not -path '*/debian/tmp/*' -not -path '*/debian/build/*' -print0)

    # Print results
    echo "Lines of code by language:"
    echo "-------------------------"
    local total=0
    for ext in "${!line_counts[@]}"; do
        printf "%-10s: %d\n" "$ext" "${line_counts[$ext]}"
        total=$((total + ${line_counts[$ext]}))
    done
    echo "-------------------------"
    echo "Total      : $total"
}


############################# Konsole #############################
set-konsole-tab-title-type ()
{
    local _title="$1"
    local _type=${2:-0}
    [[ -z "${_title}" ]]               && return 1
    [[ -z "${KONSOLE_DBUS_SERVICE}" ]] && return 1
    [[ -z "${KONSOLE_DBUS_SESSION}" ]] && return 1
    qdbus >/dev/null "${KONSOLE_DBUS_SERVICE}" "${KONSOLE_DBUS_SESSION}" setTabTitleFormat "${_type}" "${_title}"
}
set-konsole-tab-title ()
{
    set-konsole-tab-title-type "$1" && set-konsole-tab-title-type "$1" 1
}

############################# Yakuake #############################
function addYakuakeQuadSession {
    # Usage: addYakuakeQuadSession command-to-execute [tab-title]ESSION_ID="$(qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.addSessionQuad)"
    TERMINAL_IDS="$(qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId "$SESSION_ID")"
    IFS=, IDS=("$TERMINAL_IDS")
    for terminal in "${IDS[@]}"; do
        if [[ "$1" == hvs* ]]; then
            qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.runCommandInTerminal "$terminal" "ssh $1; clear"
        else
            qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.runCommandInTerminal "$terminal" "$1"
        fi
    done
    if [ -n "$2" ]; then
        qdbus org.kde.yakuake /yakuake/tabs org.kde.yakuake.setTabTitle "$SESSION_ID" "$2"
    elif [[ "$1" == hvs* ]]; then
        qdbus org.kde.yakuake /yakuake/tabs org.kde.yakuake.setTabTitle "$SESSION_ID" "$1"
    fi
}


############################ PS1 Helper ############################

## Color grid for testing colors, using ANSI escape codes
## These colors are used in the PS1 variable, configured in .bashrc
colorgrid() {
    iter=16
    while [ $iter -lt 52 ]
    do
        second=$(( iter+36 ))
        third=$(( second+36 ))
        four=$(( third+36 ))
        five=$(( four+36 ))
        six=$(( five+36 ))
        seven=$(( six+36 ))
        if [ $seven -gt 250 ];then seven=$(( seven-251 )); fi

        echo -en "\033[38;5;$iter)m█ "
        printf "%03d" $iter
        echo -en "   \033[38;5;$second)m█ "
        printf "%03d" $second
        echo -en "   \033[38;5;$third)m█ "
        printf "%03d" $third
        echo -en "   \033[38;5;$four)m█ "
        printf "%03d" $four
        echo -en "   \033[38;5;$five)m█ "
        printf "%03d" $five
        echo -en "   \033[38;5;$six)m█ "
        printf "%03d" $six
        echo -en "   \033[38;5;$seven)m█ "
        printf "%03d" $seven

        iter=$(( iter+1 ))
        printf '\r\n'
    done
    echo -e "\033[0m"
}
