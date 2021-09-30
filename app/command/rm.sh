#!/usr/bin/env bash

if [ $# == 0 ]; then
    exit 3
fi

APP_DIR=$(pwd)
if [[ -d "$APP_DIR/app" && -f "$APP_DIR/app/.bash_cli" ]]; then
    APP_DIR="$APP_DIR/app"
fi

if [[ ! -f "$APP_DIR/.bash_cli" ]]; then
    >&2 echo -e "\033[31mYou are not within a Bash CLI project\033[39m"
    >&2 echo "Please change your directory to a valid project or run the init command to set one up."
    exit 1
fi

CMD_DIR="$APP_DIR"

if [[ $# -gt 1 ]]; then
    for dir in "${@:1:$(($#-1))}"; do
        CMD_DIR="${CMD_DIR:?}/$dir"
        if [[ ! -d "$CMD_DIR" ]]; then
            exit 0
        fi
    done
fi

CMD_NAME="${!#}"
if [[ -f "${CMD_DIR:?}/$CMD_NAME" ]]; then
    rm -f "${CMD_DIR:?}/$CMD_NAME"
    rm -f "${CMD_DIR:?}/$CMD_NAME.help"
    rm -f "${CMD_DIR:?}/$CMD_NAME.usage"
elif [[ -d "${CMD_DIR:?}/$CMD_NAME" ]]; then
    rm -Rf "${CMD_DIR:?}/$CMD_NAME"
else
    echo -e "\033[31mCommand \033[36m$*\033[31m did not exist\033[39m"
    exit 1
fi

echo -e "\033[32mCommand \033[36m$*\033[32m successfully removed\033[39m"
