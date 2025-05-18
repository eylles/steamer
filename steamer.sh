#!/bin/sh

# steam client binary to use
steam_bin="/usr/bin/steam"

# options to pass onto the steam client
steam_options=""

no_logs=""

dir_name="steamer"
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/${dir_name}"
config_file="${config_dir}/configrc"

logfile="${XDG_CACHE_HOME:-$HOME/.cache}/steamer.log"

if [ -f "$config_file" ]; then
    . "$config_file"
else
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi
cat << __HEREDOC__ >> "$config_file"
# vim: ft=sh
# steamer config file
# this config file is a sourced by a shell script, not executed as a different
# script, however the script will execute any command set in here.

# steam binary
# the steam binary to execute, this allows us to use other wrappers on top
# of this one.
steam_bin="${steam_bin}"

# steam options
steam_options="${steam_options}"

# disable logs steamer, set this value to anything to prevent steamer from
# wiriting logs.
no_logs=""
__HEREDOC__
fi

myname="${0##*/}"

# Usage: is_in_var "string" "str"
#   Returns exit code 0 - true or 1 - false
is_in_var () {
    retval=1
    substr="$2"
    strvar="$1"
    case "$strvar" in
        *"$substr"*)
            retval=0
            ;;
    esac
    return "$retval"
}

# Usage: trim_all "   example   string    "
trim_all() {
    # Disable globbing to make the word-splitting below safe.
    set -f

    # Set the argument list to the word-splitted string.
    # This removes all leading/trailing white-space and reduces
    # all instances of multiple spaces to a single ("  " -> " ").
    # shellcheck disable=SC2086,SC2048
    set -- $*

    # Print the argument list as a string.
    printf '%s\n' "$*"

    # Re-enable globbing.
    set +f
}

# always set this option for x11
comp_opt="-system-composer"
# hopefully your session is not malformed and contains this env var
if [ -n "$XDG_SESSION_TYPE" ]; then
    case "$XDG_SESSION_TYPE" in
        "x11")
            if ! is_in_var "$steam_options" "$comp_opt" ; then
                steam_options="${comp_opt} ${steam_options}"
            fi
            ;;
    esac
fi

# ensure the options string is not malformed with extra spaces, as the steam
# client really, really does not like extra trailing whitespace...
steam_options=$(trim_all "$steam_options")

if [ -z "$no_logs" ]; then
    msg="[${myname}] starting steam with options: '${steam_options}'"
    date +"[%F %T] ${msg}" >> "$logfile"
fi

# we want word splitting here
# shellcheck disable=SC2086
exec $steam_bin $steam_options "$@"
