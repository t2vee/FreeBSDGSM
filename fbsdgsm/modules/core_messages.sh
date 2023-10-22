#!/bin/sh
# FreeBSDGSM core_messages.sh module
# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

abs_path() {
    case "$1" in
        /*) printf "%s\n" "$1";;
        *)  printf "%s\n" "$PWD/$1";;
    esac
}

moduleselfname="$(basename "$(abs_path "$0")")"

# nl: new line: message is following by a new line.
# eol: end of line: message is placed at the end of the current line.
fn_ansi_loader() {
	if [ "${ansi}" != "off" ]; then
		# echo colors
		default="\033[0m"
		black="\033[30m"
		red="\033[31m"
		lightred="\033[91m"
		green="\033[32m"
		lightgreen="\033[92m"
		yellow="\033[33m"
		lightyellow="\033[93m"
		blue="\033[34m"
		lightblue="\033[94m"
		magenta="\033[35m"
		lightmagenta="\033[95m"
		cyan="\033[36m"
		lightcyan="\033[96m"
		darkgrey="\033[90m"
		lightgrey="\033[37m"
		white="\033[97m"
	fi
	# carriage return & erase to end of line.
	creeol="\r\033[K"
}


fn_sleep_time() {
	if [ "${sleeptime}" != "0" ] || [ "${travistest}" != "1" ]; then
		if [ -z "${sleeptime}" ]; then
			sleeptime=0.5
		fi
		sleep "${sleeptime}"
	fi
}

# Log display
########################
## Feb 28 14:56:58 ut99-server: Monitor:
fn_script_log() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${1}" >> "${lgsmlog}"
		fi
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: PASS:
fn_script_log_pass() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then

		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: PASS: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: PASS: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=0
}

## Feb 28 14:56:58 ut99-server: Monitor: FATAL:
fn_script_log_fatal() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: FATAL: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: FATAL: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=1
}

## Feb 28 14:56:58 ut99-server: Monitor: ERROR:
fn_script_log_error() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: ERROR: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ERROR: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=2
}

## Feb 28 14:56:58 ut99-server: Monitor: WARN:
fn_script_log_warn() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: WARN: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: WARN: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=3
}

## Feb 28 14:56:58 ut99-server: Monitor: INFO:
fn_script_log_info() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: INFO: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: INFO: ${1}" >> "${lgsmlog}"
		fi
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: UPDATE:
fn_script_log_update() {
	if [ -d "${fbsdgsm_compat_lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: ${commandname}: UPDATE: ${1}" >> "${lgsmlog}"
		else
			echo "$(date '+%b %d %H:%M:%S.%3N') ${fbsdgsm_compat_selfname}: UPDATE: ${1}" >> "${lgsmlog}"
		fi
	fi
}

# On-Screen - Automated functions
##################################

# [ .... ]
fn_print_dots() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[ .... ] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[ .... ] $*"
	fi
	fn_sleep_time
}

fn_print_dots_nl() {
	if [ "${commandaction}" ]; then
		echo "${creeol}[ .... ] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echo "${creeol}[ .... ] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [  OK  ]
fn_print_ok() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${green}  OK  ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${green}  OK  ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_ok_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${green}  OK  ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${green}  OK  ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [ FAIL ]
fn_print_fail() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${red} FAIL ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${red} FAIL ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_fail_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${red} FAIL ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${red} FAIL ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [ ERROR ]
fn_print_error() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${red} ERROR ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${red} ERROR ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_error_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${red} ERROR ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${red} ERROR ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [ WARN ]
fn_print_warn() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${lightyellow} WARN ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${lightyellow} WARN ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_warn_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${lightyellow} WARN ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${lightyellow} WARN ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [ INFO ]
fn_print_info() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${cyan} INFO ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${cyan} INFO ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_info_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${cyan} INFO ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${cyan} INFO ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# [ START ]
fn_print_start() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${lightgreen} START ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${lightgreen} START ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_start_nl() {
	if [ "${commandaction}" ]; then
		echon "${creeol}[${lightgreen} START ${default}] ${commandaction} ${fbsdgsm_compat_selfname}: $*"
	else
		echon "${creeol}[${lightgreen} START ${default}] $*"
	fi
	fn_sleep_time
	echon "\n"
}

# On-Screen - Interactive messages
##################################

# No More Room in Hell Debug
# =================================
fn_print_header() {
	echo ""
	echo "${lightyellow}${gamename} ${commandaction}${default}"
	echo "=================================${default}"
}

# Complete!
fn_print_complete() {
	echon "${green}Complete!${default} $*"
	fn_sleep_time
}

fn_print_complete_nl() {
	echo "${green}Complete!${default} $*"
	fn_sleep_time
}

# Failure!
fn_print_failure() {
	echon "${red}Failure!${default} $*"
	fn_sleep_time
}

fn_print_failure_nl() {
	echo "${red}Failure!${default} $*"
	fn_sleep_time
}

# Error!
fn_print_error2() {
	echon "${red}Error!${default} $*"
	fn_sleep_time
}

fn_print_error2_nl() {
	echo "${red}Error!${default} $*"
	fn_sleep_time
}

# Warning!
fn_print_warning() {
	echon "${lightyellow}Warning!${default} $*"
	fn_sleep_time
}

fn_print_warning_nl() {
	echo "${lightyellow}Warning!${default} $*"
	fn_sleep_time
}

# Information!
fn_print_information() {
	echon "${cyan}Information!${default} $*"
	fn_sleep_time
}

fn_print_information_nl() {
	echo "${cyan}Information!${default} $*"
	fn_sleep_time
}

# Y/N Prompt
fn_prompt_yn() {
	_LOCAL_VAR_prompt="$1"
	_LOCAL_VAR_initial="$2"

	if [ "${_LOCAL_VAR_initial}" = "Y" ]; then
		_LOCAL_VAR_prompt="${_LOCAL_VAR_prompt} [Y/n] "
	elif [ "${_LOCAL_VAR_initial}" = "N" ]; then
		_LOCAL_VAR_prompt="${_LOCAL_VAR_prompt} [y/N] "
	else
		_LOCAL_VAR_prompt="${_LOCAL_VAR_prompt} [y/n] "
	fi

	while true; do
		printf "%s" "${_LOCAL_VAR_prompt}\n"
		read -r yn
		case "${yn}" in
			[Yy] | [Yy][Ee][Ss]) return 0 ;;
			[Nn] | [Nn][Oo]) return 1 ;;
			*) echo "Please answer yes or no." ;;
		esac
	done
}

# Prompt for message
fn_prompt_message() {
	while true; do
		_LOCAL_VAR_prompt="$1"
		printf "%s" "${_LOCAL_VAR_prompt}\n"
		read -r answer
		if fn_prompt_yn "Continue" Y; then
			break
		fi
	done
	echo "${answer}"
}


# On-Screen End of Line
##################################

# YES
fn_print_yes_eol() {
	echon "${cyan}YES${default}"
	fn_sleep_time
}

fn_print_yes_eol_nl() {
	echo "${cyan}YES${default}"
	fn_sleep_time
}

# NO
fn_print_no_eol() {
	echon "${red}NO${default}"
	fn_sleep_time
}

fn_print_no_eol_nl() {
	echo "${red}NO${default}"
	fn_sleep_time
}

# OK
fn_print_ok_eol() {
	echon "${green}OK${default}"
	fn_sleep_time
}

fn_print_ok_eol_nl() {
	echo "${green}OK${default}"
	fn_sleep_time
}

# FAIL
fn_print_fail_eol() {
	echon "${red}FAIL${default}"
	fn_sleep_time
}

fn_print_fail_eol_nl() {
	echo "${red}FAIL${default}"
	fn_sleep_time
}

# ERROR
fn_print_error_eol() {
	echon "${red}ERROR${default}"
	fn_sleep_time
}

fn_print_error_eol_nl() {
	echo "${red}ERROR${default}"
	fn_sleep_time
}

# WAIT
fn_print_wait_eol() {
	echon "${cyan}WAIT${default}"
	fn_sleep_time
}

fn_print_wait_eol_nl() {
	echo "${cyan}WAIT${default}"
	fn_sleep_time
}

# WARN
fn_print_warn_eol() {
	echon "${lightyellow}WARN${default}"
	fn_sleep_time
}

fn_print_warn_eol_nl() {
	echo "${lightyellow}WARN${default}"
	fn_sleep_time
}

# INFO
fn_print_info_eol() {
	echon "${cyan}INFO${default}"
	fn_sleep_time
}

fn_print_info_eol_nl() {
	echo "${cyan}INFO${default}"
	fn_sleep_time
}

# QUERYING
fn_print_querying_eol() {
	echon "${cyan}QUERYING${default}"
	fn_sleep_time
}

fn_print_querying_eol_nl() {
	echo "${cyan}QUERYING${default}"
	fn_sleep_time
}

# CHECKING
fn_print_checking_eol() {
	echon "${cyan}CHECKING${default}"
	fn_sleep_time
}

fn_print_checking_eol_nl() {
	echo "${cyan}CHECKING${default}"
	fn_sleep_time
}

# DELAY
fn_print_delay_eol() {
	echon "${green}DELAY${default}"
	fn_sleep_time
}

fn_print_delay_eol_nl() {
	echo "${green}DELAY${default}"
	fn_sleep_time
}

# CANCELED
fn_print_canceled_eol() {
	echon "${lightyellow}CANCELED${default}"
	fn_sleep_time
}

fn_print_canceled_eol_nl() {
	echo "${lightyellow}CANCELED${default}"
	fn_sleep_time
}

# REMOVED
fn_print_removed_eol() {
	echon "${red}REMOVED${default}"
	fn_sleep_time
}

fn_print_removed_eol_nl() {
	echo "${red}REMOVED${default}"
	fn_sleep_time
}

# UPDATE
fn_print_update_eol() {
	echon "${cyan}UPDATE${default}"
	fn_sleep_time
}

fn_print_update_eol_nl() {
	echo "${cyan}UPDATE${default}"
	fn_sleep_time
}

fn_print_ascii_logo() {
echo ""
echo ""
echo "	░▒░        ▒▒░        ▒▒"
echo "  ░▒▒██▒░░░████████▓░░░███▒▒"
echo "  ▒▒░░▒▒█████████▓░░████▓░▒▒"
echo "   ░█░█████████████████▒░░▒▒"
echo "   ▒▒███████████████▒▒▒░██░"
echo "   ░█▒█████▒▒▒▒▒▒▒░░░▒█▒▒██░"
echo "  ▒▒█▒██▒▒▒▒▒▒▒▒▒▒▒▒▒░░░▒░█░"
echo "  ▒█▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░▒▒░░░█░"
echo "  ░█▒▒▒▒▒▓▒▒▒░▒▒░░▒▒▒▒░░░▒█░	▒▒▒▒▒                 ▒▒▒▒▒  ▒▒▒▒▒ ▒▒▒▒▒    ████  █████ ██    ██"
echo "   ░█░░▒▒▒▓▒▒░░░▒▒▒▒▒░░░███░	▒▒      ▒   ▒▒    ▒▒  ▒▒  ▒▒ ▒     ▒▒  ▒▒  █     ██     ███  ███"
echo "   ░▒█░▒▒▒▒▒▓▒░▒▒░░░▒░▓▒▒█░ 	▒▒▒▒▒ ▒▒  ▒▒  ▒ ▒▒ ▒▒ ▒▒▒▒▒   ▒▒▒  ▒▒   ▒▒██ ████ ████  █ ██████"
echo "    ▒░█░▒▒▒▒▒▒▒▓▓▓▓█▓▒▒██░  	▒▒    ▒▒  ▒     ▒     ▒▒  ▒▒    ▒▒ ▒▒  ▒▒  █   ██    ██ █  ██ ██"
echo "		░▒█▒▒▒▒▒░▒▒▒▒▒▒██░░   	▒▒    ▒▒   ▒▒▒▒  ▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒  ▒▒▒▒▒    ████ █████  █     ██"
echo "        ▒░▒███▒▓████░░                                                                      ██████"
echo "            ░▒░░▒▒"
echo ""
}

fn_print_restart_warning() {
	fn_print_warn "${fbsdgsm_compat_selfname} will be restarted"
	fn_script_log_warn "${fbsdgsm_compat_selfname} will be restarted"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "${fbsdgsm_compat_selfname} will be restarted: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		sleep 1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "${fbsdgsm_compat_selfname} will be restarted"
}

# Functions below are used to ensure that logs and UI correctly reflect the command it is actually running.
# Useful when a command has to call upon another command causing the other command to overrite commandname variables

# Used to remember the command that ran first.
fn_firstcommand_set() {
	if [ -z "${firstcommandname}" ]; then
		firstcommandname="${commandname}"
		firstcommandaction="${commandaction}"
	fi
}

# Used to reset commandname variables to the command the script ran first.
fn_firstcommand_reset() {
	commandname="${firstcommandname}"
	commandaction="${firstcommandaction}"
}
