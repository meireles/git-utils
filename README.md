# git-utils

git related convenience functions, written in bash because I like pain and suffering.

License: GPL3

## Install

Source `git-utils.sh` from rc or profile (whatever works for non-interactive sessions). An environmental variable `GIT_UTILS_ROOT` points to the script dir and function names are exported (`export -f function_name`).

## Functions

### Repo tests

Tests if the current dir or a given url are git repositories. Functions return (echo) `true` or `false`.

* `git_is_pwd_repo`

* `git_is_url_repo <url>`

### Modify repo

Unset all remotes from a repo.

* `git_unset_remotes`

Overwrite history squashing repo to one commit

* `git_squash_commits [commit message]`

### Create repo in remote

Makes a remote repo in bitbucket or github.

* `git_mkremote -n <name> -u <username> -r <bitbucket|github> -a <private|public>`

Aside form creating the remote repo, also sets the environmental variable `git_mkremote_push_url` as a side effect.

### Poach a repository

`git-poach` 1. clones a repo locally, 2) unsets its remotes and 3) squashes its history. Useful as a first stem to "instantiate" a template repository.

* `git_poach -t <template> -n <name> [-b <branch>] -o [-m <"commit msg">] -h`



