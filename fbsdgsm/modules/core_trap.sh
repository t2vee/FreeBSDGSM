#!/bin/sh
# LinuxGSM core_trap.sh module

# Description: Handles CTRL-C trap to give an exit code.

abs_path() {
    case "$1" in
        /*) printf "%s\n" "$1";;
        *)  printf "%s\n" "$PWD/$1";;
    esac
}

moduleselfname="$(basename "$(abs_path "$0")")"

fn_exit_trap() {
	if [ -z "${exitcode}" ]; then
		exitcode=$?
	fi
	echo ""
	if [ -z "${exitcode}" ]; then
		exitcode=0
	fi
	i core_exit.sh
}

# trap to give an exit code.
trap fn_exit_trap INT
