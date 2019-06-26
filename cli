#!/usr/bin/env bash

ROOT_DIR=`dirname "$(perl -e 'use Cwd "abs_path"; print abs_path(shift)' $0)"`
CLI_ENTRYPOINT=`basename $0`

. "$ROOT_DIR/utils"

# Locate the correct command to execute by looking through the app directory
# for folders and files which match the arguments provided on the command line.
CMD_FILE="$ROOT_DIR/app/"
CMD_ARG_START=1
while [[ -d "$CMD_FILE" && $CMD_ARG_START -le $# ]]; do

    # If the user provides help as the last argument on a directory, then
    # show them the help for that directory rather than continuing
    if [[ "${!CMD_ARG_START}" == "help" ]]; then
        # Strip off the "help" portion of the command
        ARGS=("$@")
        unset "ARGS[$((CMD_ARG_START-1))]"
        ARGS=("${ARGS[@]}")

        "$ROOT_DIR/help" $0 ${ARGS[@]}
        exit 3
    fi

    CMD_FILE="$CMD_FILE/${!CMD_ARG_START}"
    CMD_ARG_START=$(($CMD_ARG_START+1))
done

# Place the arguments for the command in their own list
# to make future work with them easier.
CMD_ARGS=("${@:CMD_ARG_START}")

# If we hit a directory by the time we run out of arguments, then our user
# hasn't completed their command, so we'll show them the help for that directory
# to help them along.
if [ -d "$CMD_FILE" ]; then
    "$ROOT_DIR/help" $0 $@
    exit 3
fi

# If we didn't couldn't find the exact command the user entered then warn them
# about it, and try to be helpful by displaying help for that directory.
if [[ ! -f "$CMD_FILE" ]]; then
    "$ROOT_DIR/help" $0 ${@:1:$(($CMD_ARG_START-1))}
    >&2 echo -e "\033[31mWe could not find the command \033[36m$CLI_ENTRYPOINT ${@:1:$CMD_ARG_START}\033[39m"
    >&2 echo -e "To help out, we've shown you the help docs for \033[36m$CLI_ENTRYPOINT ${@:1:$(($CMD_ARG_START-1))}\033[39m"
    exit 3
fi

# If --help is passed as one of the arguments to the command then show
# the command's help information.
arg_i=0 # We need the index to be able to strip list indices
for arg in "${CMD_ARGS[@]}"; do
    if [[ "${arg}" == "--help" ]]; then
        # Strip off the `--help` portion of the command
        unset "CMD_ARGS[$arg_i]"
        CMD_ARGS=("${CMD_ARGS[@]}")

        # Pass the result to the help script for interrogation
        "$ROOT_DIR/help" $0 ${@:1:$((CMD_ARG_START - 1))} ${CMD_ARGS[@]}
        exit 3
    fi
    arg_i=$((arg_i+1))
done

# Run the command and capture its exit code for introspection
"$CMD_FILE" ${CMD_ARGS[@]}
EXIT_CODE=$?

# If the command exited with an exit code of 3 (our "show help" code)
# then show the help documentation for the command.
if [[ $EXIT_CODE == 3 ]]; then
    "$ROOT_DIR/help" $0 $@
fi

# Exit with the same code as the command
exit $EXIT_CODE
