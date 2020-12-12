#!/usr/bin/env bash

# shellcheck disable=SC2034 # These are defined, even if not used, for simplicity's sake
COLOR_BLACK="\033[30m"
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_CYAN="\033[36m"
COLOR_LIGHT_GRAY="\033[37m"
COLOR_DARK_GRAY="\033[38m"
COLOR_NORMAL="\033[39m"

function bcli_resolve_path() {
    perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$1"
}

function bcli_trim_whitespace() {
    # Function courtesy of http://stackoverflow.com/a/3352015
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

function bcli_show_header() {
    echo -e "$(bcli_trim_whitespace "$(cat "$1/.name")")"
    echo -e "${COLOR_CYAN}Version  ${COLOR_NORMAL}$(bcli_trim_whitespace "$(cat "$1/.version")")"
    echo -e "${COLOR_CYAN}Author   ${COLOR_NORMAL}$(bcli_trim_whitespace "$(cat "$1/.author")")"
}

function bcli_entrypoint() {
    local root_dir;
    root_dir=$(dirname "$(bcli_resolve_path "$0")")

    local cli_entrypoint;
    cli_entrypoint=$(basename "$0")

    # Locate the correct command to execute by looking through the app directory
    # for folders and files which match the arguments provided on the command line.
    local cmd_file;
    cmd_file="$root_dir/app/"
    local cmd_arg_start;
    cmd_arg_start=1
    while [[ -d "$cmd_file" && $cmd_arg_start -le $# ]]; do

        # If the user provides help as the last argument on a directory, then
        # show them the help for that directory rather than continuing
        if [[ "${!cmd_arg_start}" == "help" ]]; then
            # Strip off the "help" portion of the command
            local args;
            args=("$@")
            unset "args[$((cmd_arg_start-1))]"
            args=("${args[@]}")

            "$root_dir/help" "$0" "${args[@]}"
            exit 3
        fi

        cmd_file="$cmd_file/${!cmd_arg_start}"
        cmd_arg_start=$((cmd_arg_start+1))
    done

    # Place the arguments for the command in their own list
    # to make future work with them easier.
    local cmd_args;
    cmd_args=("${@:cmd_arg_start}")

    # If we hit a directory by the time we run out of arguments, then our user
    # hasn't completed their command, so we'll show them the help for that directory
    # to help them along.
    if [ -d "$cmd_file" ]; then
        "$root_dir/help" "$0" "$@"
        exit 3
    fi

    # If we didn't couldn't find the exact command the user entered then warn them
    # about it, and try to be helpful by displaying help for that directory.
    if [[ ! -f "$cmd_file" ]]; then
        "$root_dir/help" "$0" "${@:1:$((cmd_arg_start-1))}"
        >&2 echo -e "${COLOR_RED}We could not find the command ${COLOR_CYAN}$cli_entrypoint ${*:1:$cmd_arg_start}${COLOR_NORMAL}"
        >&2 echo -e "To help out, we've shown you the help docs for ${COLOR_CYAN}$cli_entrypoint ${*:1:$((cmd_arg_start-1))}${COLOR_NORMAL}"
        exit 3
    fi

    # If --help is passed as one of the arguments to the command then show
    # the command's help information.
    arg_i=0 # We need the index to be able to strip list indices
    for arg in "${cmd_args[@]}"; do
        if [[ "${arg}" == "--help" && -f "$HELP_FILE.help" ]]; then
            # Strip off the `--help` portion of the command
            unset "cmd_args[$arg_i]"
            cmd_args=("${cmd_args[@]}")

            # Pass the result to the help script for interrogation
            "$root_dir/help" "$0" "${@:1:$((cmd_arg_start - 1))}" "${cmd_args[@]}"
            exit 3
        fi
        arg_i=$((arg_i+1))
    done

    # Run the command and capture its exit code for introspection
    "$cmd_file" "${cmd_args[@]}"
    EXIT_CODE=$?

    # If the command exited with an exit code of 3 (our "show help" code)
    # then show the help documentation for the command.
    if [[ $EXIT_CODE == 3 ]]; then
        "$root_dir/help" "$0" "$@"
    fi

    # Exit with the same code as the command
    exit $EXIT_CODE
}

function bcli_help() {
    local root_dir;
    root_dir=$(dirname "$(bcli_resolve_path "$0")")

    local cli_entrypoint;
    cli_entrypoint=$(basename "$1")

    # If we don't have any additional help arguments, then show the app's
    # header as well.
    if [ $# == 0 ]; then
        bcli_show_header "$root_dir/app"
    fi

    # Locate the correct level to display the helpfile for, either a directory
    # with no further arguments, or a command file.
    local help_file;
    help_file="$root_dir/app/"
    local help_arg_start;
    help_arg_start=2
    while [[ -d "$help_file" && $help_arg_start -le $# ]]; do
        help_file="$help_file/${!help_arg_start}"
        help_arg_start=$((help_arg_start+1))
    done

    # If we've got a directory's helpfile to show, then print out the list of
    # commands in that directory along with its help content.
    if [[ -d "$help_file" ]]; then
        echo -e "${COLOR_GREEN}$cli_entrypoint ${COLOR_CYAN}${*:2:$((help_arg_start-1))} ${COLOR_NORMAL}"

        # If there's a help file available for this directory, then show it.
        if [[ -f "$help_file/.help" ]]; then
            cat "$help_file/.help"
            echo ""
        fi

        echo ""
        echo -e "${COLOR_MAGENTA}Commands${COLOR_NORMAL}"
        echo ""

        for file in "$help_file"/*; do
            cmd=$(basename "$file")

            # Don't show hidden files as available commands
            if [[ "$cmd" != .* && "$cmd" != *.* ]]; then
                echo -en "${COLOR_GREEN}$cli_entrypoint ${COLOR_CYAN}${*:2:$((help_arg_start-1))} $cmd ${COLOR_NORMAL}"

                if [[ -f "$file.usage" ]]; then
                    bcli_trim_whitespace "$(cat "$file.usage")"
                    echo ""
                elif [[ -d "$file" ]]; then
                    echo -e "${COLOR_MAGENTA}...${COLOR_NORMAL}"
                else
                    echo ""
                fi
            fi
        done

        exit 0
    fi

    echo -en "${COLOR_GREEN}$cli_entrypoint ${COLOR_CYAN}${*:2:$((help_arg_start-1))} ${COLOR_NORMAL}"
    if [[ -f "$help_file.usage" ]]; then
        bcli_trim_whitespace "$(cat "$help_file.usage")"
        echo ""
    else
        echo ""
    fi


    if [[ -f "$help_file.help" ]]; then
        cat "$help_file.help"
        echo ""
    fi
}

function bcli_bash_completions() {
    local root_dir;
    root_dir=
    root_dir=$(dirname "$(bcli_resolve_path "$(which "${COMP_WORDS[0]}")")")

    local curr_arg;
    curr_arg="${COMP_WORDS[COMP_CWORD]}"

    # Locate the correct command to execute by looking through the app directory
    # for folders and files which match the arguments provided on the command line.
    local cmd_file="$root_dir/app/"
    local cmd_arg_start=1
    while [[ -d "$cmd_file" && $cmd_arg_start -le $COMP_CWORD ]]; do

        # Handle the help virtual command by "ignoring" it
        if [[ "${COMP_WORDS[cmd_arg_start]}" == "help" ]]; then
            cmd_arg_start=$((cmd_arg_start+1))
            continue
        fi

        cmd_file="$cmd_file/${COMP_WORDS[cmd_arg_start]}"
        cmd_arg_start=$((cmd_arg_start+1))
    done

    # If we've found something which doesn't exist, then let's
    # look at its containing directory for info.
    if [[ ! -e "$cmd_file" ]]; then
        cmd_file=$(dirname "$cmd_file")
    fi

    # If cursor is on the end of command we want to get a name of current file/directory
    # and don't look inside folder.
    if [[ $curr_arg = $(basename "$cmd_file") ]]; then
        # shellcheck disable=SC2207 # Using this as alternatives are not cross-platform or introduce dependencies
        COMPREPLY=($(basename "$cmd_file"))
        return
    fi

    # If we found a command, then suggest the `--help` argument
    # TODO: Add parsing of .usage files for this
    if [[ -f "$cmd_file" ]]; then
        # Check if we've already got a `--help`, don't output anything
        # if we do.
        for i in $(seq $cmd_arg_start "$COMP_CWORD"); do
            if [[ "${COMP_WORDS[$i]}" == "--help" ]]; then
                COMPREPLY=()
                return
            fi
        done
        # Use bash completion file if any.
        if [ -f "${cmd_file}.complete" ]; then
            # shellcheck disable=SC2207 # Using this as alternatives are not cross-platform or introduce dependencies
            # shellcheck disable=SC1090 # Disabling as nature of this file is a really dynamic
            COMPREPLY=($(compgen -W "--help $(source "${cmd_file}.complete")" -- "$curr_arg" ) )
            return
        else
            # shellcheck disable=SC2207 # Using this as alternatives are not cross-platform or introduce dependencies
            COMPREPLY=($(compgen -W '--help' -- "$curr_arg"))
            return
        fi
    # If we found a directory, then show all the commands which are
    # available within it, as well as the `help` virtual command.
    elif [ -d "$cmd_file" ]; then
        local opts=("help")
        while IFS= read -d $'\0' -r file ; do
            # shellcheck disable=SC2207 # Using this as alternatives are not cross-platform or introduce dependencies
            opts=("${opts[@]}" $(basename "$file"))
        done < <(find "$cmd_file"/ -maxdepth 1 ! -path "$cmd_file"/ ! -iname '*.*' -print0)

        IFS="
        "
        # shellcheck disable=SC2207 # Using this as alternatives are not cross-platform or introduce dependencies
        COMPREPLY=($(compgen -W "$(printf '%s\n' "${opts[@]}")" -- "$curr_arg"))
    fi
}
