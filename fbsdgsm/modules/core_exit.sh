#!/bin/sh
# FreeBSDGSM core_exit.sh module

# Description: Handles exiting of LinuxGSM by running and reporting an exit code.

abs_path() {
    case "$1" in
        /*) printf "%s\n" "$1";;
        *)  printf "%s\n" "$PWD/$1";;
    esac
}

moduleselfname="$(basename "$(abs_path "$0")")"

fn_exit_dev_debug() {
	if [ -f "${fbsdgsm_compat_rootdir}/.dev-debug" ]; then
		echo ""
		echo "${moduleselfname} exiting with code: ${exitcode}"
		if [ -f "${fbsdgsm_compat_rootdir}/dev-debug.log" ]; then
			grep -a "modulefile=" "${fbsdgsm_compat_rootdir}/dev-debug.log" | sed 's/modulefile=//g' > "${fbsdgsm_compat_rootdir}/dev-debug-module-order.log"
		fi
	fi
}

# If running dependency check as root will remove any files that belong to root user.
if [ "$(whoami)" = "root" ]; then
	find "${fbsdgsm_compat_lgsmdir}"/ -group root -prune -exec rm -rf {} + > /dev/null 2>&1
	find "${logdir}"/ -group root -prune -exec rm -rf {} + > /dev/null 2>&1
fi

if [ "${exitbypass}" ]; then
	unset exitbypass
elif [ "${exitcode}" != "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_script_log_info "FreeBSDGSM version: ${fgsm_version}"
	if [ "${exitcode}" = "1" ]; then
		fn_script_log_fatal "${moduleselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" = "2" ]; then
		fn_script_log_error "${moduleselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" = "3" ]; then
		fn_script_log_warn "${moduleselfname} exiting with code: ${exitcode}"
	else
		# if exit code is not set assume error.
		fn_script_log_warn "${moduleselfname} exiting with code: ${exitcode}"
		exitcode=4
	fi
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
elif [ "${exitcode}" ] && [ "${exitcode}" = "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_script_log_info "FreeBSDGSM version: ${fgsm_version}"
	fn_script_log_pass "${moduleselfname} exiting with code: ${exitcode}"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
else
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_script_log_info "FreeBSDGSM version: ${fgsm_version}"
	fn_print_error "No exit code set"
	fn_script_log_pass "${moduleselfname} exiting with code: NOT SET"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
fi
