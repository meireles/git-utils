#!/usr/bin/env bash

################################################################################
# General bash utility functions
################################################################################

## 'echo' alias to stderr
function echoerr() {
	printf "%s\n" "$*" >&2;
}

function currentdirname() {
	echo "$(basename "$PWD")";
}

function currentdirname() {
	echo "$(basename "$PWD")";
}

function scriptdir(){
	echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}


################################################################################
# Declare global git-utils root, to be exported at the end of the file
################################################################################

# Will be exported at the end of the script!
GIT_UTILS_ROOT=$(scriptdir)

################################################################################
# Repository tests
################################################################################


########################################
# is current directory a git repo?
########################################

function git_is_pwd_repo() {
	[[ -d "$PWD/.git" ]] && echo true || echo false
}

########################################
# is url a repo git repo?
########################################

function git_is_url_repo() {

	local __rurl="$1";
	local __fail=false;

	git ls-remote -q "$__rurl" &>/dev/null || __fail=true

	[[ "$__fail" == true ]] && echo false || echo true
}


################################################################################
# Unset remotes
################################################################################

function git_unset_remotes() {

	local __remotes="$(git remote)"

	for i in "${__remotes[@]}"; do
		git remote rm "$i";
	done
}

################################################################################
# squash all commits
################################################################################

function git_squash_commits() {

	local __msg="squashed commits"

	[[ -z "$1" ]] || __msg="$1"

	# Add and commit changes that may be around
    git add -A &&  git commit -m "intermediate changes" || :

    # Squash commits
    git reset $(git commit-tree HEAD^{tree} -m "$__msg")
}

################################################################################
# Create remotes
################################################################################

function git_mkremote() {

	# To Export
	git_mkremote_push_url=""

	# Local
	local __help=false
	local __exec=true
	local __name=""
	local __user=""
    local __host=""
    local __priv=true
	local __key=""
	local __cmd=""

	# Usage message
	function __usage(){ echoerr "usage: git_mkremote: -n <name> -u <username> -r <'bitbucket'|'github'> -a <'private'|'public'>" ; }

	# Reset OPTIND
	local OPTIND=1

	# Get arguments
	while getopts ":n:u:r:a:h" args; do
	    case "${args}" in
            n)
        	    __name="${OPTARG}";
        	    ;;
            u)
        	    __user="${OPTARG}";
        	    ;;
    	    r)
    	    	[[ ( "${OPTARG}" == "bitbucket" || "${OPTARG}" == "github" ) ]]  && __host="${OPTARG}" || __usage
    	        ;;
    	    a)
    	    	if [[ "${OPTARG}" == "private" ]]; then
    	    		__priv=true;
    	    	elif [[ "${OPTARG}" == "public" ]]; then
    	    		__priv=false;
    	    	else
    	    		__exec=false;
    	    		__usage;
    	        fi
    	        ;;
	    	h)
	    	    __help=true
	    		;;
            \?)
        	    echoerr "Unknown option: -${OPTARG}";
        	    __exec=false
        	    ;;
            :)
        	    echoerr "Missing argument for -${OPTARG}";
        	    __exec=false
        	    ;;
            *)
        	    echoerr "Unimplemented option: -${OPTARG}";
        	    __exec=false
        	    ;;
        esac
    done


	if [[ "$__help" == true ]]; then
		__exec=false
		__usage;
	elif [[ -z "${__name}" || (-z "${__user}" ||  -z "${__host}") ]]; then
		__exec=false
		echoerr "Parameters -n -u and -r are mandatory!"
		__usage
	fi


	if [[ "$__exec" == true ]]; then
		# Bitbucket
		if [[ "$__host" == "bitbucket" ]]; then

			read -s -p password: __key
			curl --user "$__user":"$__key" https://api.bitbucket.org/1.0/repositories/ --data name="$__name" --data is_private="$__priv"

			export git_mkremote_push_url="https://bitbucket.org/$__user/$__name"
			echo "$git_mkremote_push_url"
		fi

		# Github
		if [[ "$__host" == "github" ]]; then

			curl -u "$__user" https://api.github.com/user/repos -d '{"name":"'$__name'", "private":'$__priv'"}'

			export git_mkremote_push_url="https://github.com/$__user/$__name"
			echo "$git_mkremote_push_url"
		fi
	fi
}

################################################################################
# poach: An evil version of fork.
################################################################################

function git_poach() {

	local __help=false                                      # flag: was -h called?
	local __exec=true										# flag: execute code?
	local __tmpl=""                                         # template url
	local __name=""                                         # name of local repo
	local __brch="master"                                   # template's branch
	local __renb=true                                       # rename branch to 'master'
	local __mesg=""                                         # commit msg for squash

	function __usage() {
		echoerr "usage:  git_poach -t <template> -n <name> [-b <branch>] -o [-m <commit msg>] -h"
	}

	function __use_help() {
		__usage
		echoerr "details:"
	    echoerr "  -t <string> (mandatory) Remote url of the template to be poached"
    	echoerr "  -n <string> (mandatory) Name for a **new dir** where to dump the poached repo"
	    echoerr "  -b <string> (optional)  Remote branch to be poached: Defaults to 'master'"
    	echoerr "  -o <flag>   (optional)  Rename branch to master if -b was given"
	    echoerr "  -m <string> (optional)  Message for the squash commit in the poached repo"
	}

	################################################################################
	# Arguments
	################################################################################

	# Reset OPTIND
	OPTIND=1

	# get commit message
	while getopts ":t:n:b:om:h" args; do
	    case "${args}" in
            t)
        	    __tmpl="${OPTARG}";
        	    ;;
        	n)
        	    echo "-n"
                __name="${OPTARG}";
        	    ;;
            b)
        	    __brch="${OPTARG}";
        	    ;;
            o)
        	    __renb=false;
        	    ;;
            m)
        	    __mesg="${OPTARG}";
        	    ;;
			h)
	    	    __help=true;
	    		;;
            \?)
        	    echoerr "Unknown option: -${OPTARG}";
        	    __usage;
        	    ;;
            :)
        	    echoerr "Missing argument for -${OPTARG}";
        	    __usage;
        	    ;;
            *)
        	    echoerr "Unimplemented option: -${OPTARG}";
        	    __usage;
        	    ;;
        esac
    done


	################################################################################
	# Basic option check. Should the code try to execute?
	################################################################################

	if [[ "$__help" == true ]]; then
		    __exec=false;
		    __use_help;

	elif [[ (-z "$__tmpl" || -z "$__name") ]]; then
		    __exec=false;
		    echoerr "Parameters -t and -n are mandatory";
	fi

	################################################################################
	# Execute
	################################################################################

	if [[ "$__exec" == true ]]; then

		# Clone template
		git clone "$__tmpl" -b "$__brch" "$__name";

		# Move to new dir
		cd "$__name";

		# Rename branch if not -o
		if [[ "$__renb" == true ]]; then
			git branch -m "$__brch" master;
			__brch="master";
		fi

		# Squash repository
		git_squash_commits "$__mesg"

		# Unset all remotes
		git_unset_remotes

		# Go back to parent dir
		cd ..
	fi
}


################################################################################
# export
################################################################################

#export -f echoerr               # won't export now. may belong to a bash lib.
#export -f currentdirname        # won't export now. may belong to a bash lib.


export GIT_UTILS_ROOT
export -f git_is_pwd_repo
export -f git_is_url_repo
export -f git_unset_remotes
export -f git_squash_commits
export -f git_mkremote
export -f git_poach
