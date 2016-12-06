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