#/usr/bin/env bash
set -e
CMD="$(dirname $(dirname $0))/cli"

function pass() {
    echo " - PASS"
}

function fail() {
    echo " - FAIL"
    exit 1
}

function test_entrypoint() {
    echo "Command listing should include the install command..."
    $CMD | perl -pe 's/\x1b\[[0-9;]*[mG]//g' | grep " install NAME \[FOLDER\]" >/dev/null && pass || fail

    echo "Command listing should include the uninstall command..."
    $CMD | perl -pe 's/\x1b\[[0-9;]*[mG]//g' | grep " uninstall NAME \[FOLDER\]" >/dev/null && pass || fail
    
    echo "Command listing should include the commad subcommand..."
    $CMD | perl -pe 's/\x1b\[[0-9;]*[mG]//g' | grep "command ..." >/dev/null && pass || fail

}
test_entrypoint


function test_help() {
    echo "Command should print help for the install command..."
    $CMD install --help | perl -pe 's/\x1b\[[0-9;]*[mG]//g' | grep "Installs your command line app" >/dev/null && pass || fail

}
test_help
