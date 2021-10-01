#!/usr/bin/env bash

if [ $# == 0 ]; then
    exit 3
fi

APP_DIR=$(pwd)

if [[ -f "$APP_DIR/.bash_cli" ]]; then
    APP_DIR=$(dirname "$APP_DIR")
fi

if [[ ! -f "$APP_DIR/app/.bash_cli" ]]; then
    >&2 echo -e "\033[31mYou are not within a Bash CLI project\033[39m"
    >&2 echo "Please change your directory to a valid project or run the init command to set one up."
    exit 1
fi

NAME="$1"
FOLDER="${2-"/usr/bin"}"

if [[ ! -f "$FOLDER/$NAME" ]]; then
    >&2 echo -e "\033[31mCommand \033[36m$1\033[31m did not exist in \033[36m$2\033[39m"
    exit 1
fi

LN_PATH=$(perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$FOLDER/$NAME")

if [[ "$LN_PATH" != "$APP_DIR/cli" ]]; then
    >&2 echo -e "\033[31mCommand \033[36m$1\033[31m doesn't resolve to this project\033[39m"
    >&2 echo "Expected: $APP_DIR/cli"
    >&2 echo "Got:      $LN_PATH"
    exit 1
fi

rm "$FOLDER/$NAME"
