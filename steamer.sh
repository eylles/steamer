#!/bin/sh

# steam client binary to use
steam_bin="/usr/bin/steam"

# options to pass onto the steam client
steam_options=""

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
__HEREDOC__
fi

myname="${0##*/}"

# always set this option for x11
comp_opt="-system-composer"
# hopefully your session is not malformed and contains this env var
if [ -n "$XDG_SESSION_TYPE" ]; then
    case "$XDG_SESSION_TYPE" in
        "x11")
            if [ -z "$steam_options" ]; then
                steam_options="${comp_opt}"
            else
                if ! echo "$steam_options" | grep -q "$comp_opt" ; then
                    steam_options="${steam_options} ${comp_opt}"
                fi
            fi
            ;;
    esac
fi

date +"[%F %T] [${myname}] starting steam with options: ${steam_options}" >> "$logfile"

$steam_bin "$steam_options" "$@"
