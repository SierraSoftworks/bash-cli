# Bash CLI
**A command line framework built using nothing but Bash and compatible with anything**

Bash CLI was borne of the need to provide a common entrypoint into a range of scripts
and tools for a project. Rather than port the scripts to something like Go or Python,
or merge them into a single bash script, we opted to build a framework which allows
and executable to be presented as a sub-command.

## Example

```sh
bash-cli install my-app
bash-cli command create start
my-app start
```

## Customizing Bash CLI
Bash CLI is designed to make it as simple as possible for you to create **your** application.
To that end, everything that makes it "Bash CLI" can be tweaked and changed by simply modifying
the following files in your `app` directory.

 - **.name** should contain the name of your command line, something like "My Awesome App"
 - **.author** is meant to contain your name (or the name of your company)
 - **.version** should contain the version of your app, you can automatically include this using `git describe --tags > app/.version`
 - **.help** should be a short-ish description of what your app does and how people should use it.
   Don't worry about including help for every command here, or even a command list, Bash CLI will
   handle that for you automatically.

## Adding Commands
Bash CLI commands are just a stock-standard script with a filename that matches the command name.
These scripts are contained within your `app` folder, or within nested folders there if you want
to create a tree-based command structure.

For example, the script `app/test/hello` would be available through `cli test hello`. Any arguments
passed after the command will be curried through to the script, making it trivial to pass values and
options around as needed.

The simplest way to add a command however, is to just run `bash-cli command create [command name]`
and have it plop down the files for you to customize.

### Contextual Help
Bash CLI provides tools which enable your users to easily discover how to use your command line without
needing to read your docs (a travesty, we know). To make this possible, you'll want to add two extra
files for each command.

The first, `[command].usage` should define the arguments list that your command expects to receive,
something like `NAME [MIDDLE_NAMES...] SURNAME`. This file is entirely optional, leaving it out will
have Bash CLI present the command as if it didn't accept arguments.

The second, `[command].help` is used to describe the arguments that your command accepts, as well as
provide a bit of additional context around how it works, when you should use it etc.

In addition to providing help for commands, you may also provide it for directories to explain what
their sub-commands are intended to achieve. To do this, simply add a `.help` file to the directory.

## Autocomplete
Autocomplete functionality has been added to make navigating the command line even easier than it
was before. To install it, simply add the following to `/etc/bash_completion.d/my-app`.

```sh
source "/opt/my-app/complete"
complete -F _bash_cli my-app
```

If you want to add completion to your commands just create `[command].complete` file which returns array.
```sh
OPTIONS=("one" "two" "three")
echo ${OPTIONS[@]}
```

See `example/completion` command as example.

You also might need to have access to arguments it could be done via:
 `local_args_array=(${COMP_WORDS[@]:${cmd_arg_start}})`
for: `cli example completion 1 2 3 4`
`local_args_array`  will be `'1 2 3 4'`

You also could use fzf in here to make interactive selects:

```sh
 echo -e "one\ntwo\nthree" | fzf
```

## Frequently Asked Questions

1. **Can I use Bash CLI to run things which aren't bash scripts?**
   Absolutely, Bash CLI simply executes files - it doesn't care whether they're written in Bash, Ruby,
   Python or Go - if you can execute the file then you can use it with Bash CLI.

1. **Will Bash CLI work on my Mac?**
   It should, we've built everything to keep it as portable as possible, so if you do have a problem
   don't hesitate to open a bug report.

1. **Does it allow me to use tab-autocomplete?**
   As of the latest version, yes it does. The install command included in this repo will automatically
   set up your `/etc/bash_completion.d/` directory to provide support for your project.
