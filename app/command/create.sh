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
    for i in $(($#-1)); do
        DIR=${!i}
        CMD_DIR="$CMD_DIR/$DIR"
        if [[ ! -d "$CMD_DIR" ]]; then
            mkdir "$CMD_DIR"
            echo "TODO: Add help for this directory" > "$CMD_DIR/.help"
        fi
    done
fi

CMD_NAME="${!#}"
if [[ -f "$CMD_DIR/$CMD_NAME" ]]; then
    >&2 echo -e "\033[31mThat command already exists\033[39m"
    >&2 echo "We'd rather not overwrite commands you've already created."
    exit 1
fi

cat > "$CMD_DIR/$CMD_NAME" <<EOT
#!/usr/bin/env bash
echo -e "\033[36mTODO\033[39m: Implement this command"
EOT

echo "ARGS..." > "$CMD_DIR/$CMD_NAME.usage"
cat > "$CMD_DIR/$CMD_NAME.help" <<EOT
ARGS  - The arguments you wish to provide to this command

TODO: Fill out the help information for this command.
EOT

echo -e "\033[32mCommand \033[36m$*\033[32m created successfully\033[39m"
