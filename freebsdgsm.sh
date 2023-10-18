#!/bin/sh
# Project: FreeBSDGSM - The LinuxGSM Compatibility Project
# Author: t2vee
# License: MIT License, see LICENSE.md
# Purpose: FreeBSD Game Server Management Script. Mainly a translation from Bash to POSIX sh.
# Credit: This Project is Based Upon LinuxGSM By Daniel Gibbs

DEBUG="true"

# mega jank and probably still broken

# Debugging
if [ -f ".dev-debug" ] || [ "${DEBUG}" = "true" ]; then
	exec 3>&1 4>&2
	trap 'exec 2>&4 1>&3' 0 1 2 3
	exec 1>debug.log 2>&1
	set -x
fi

debug() {
    [ "$DEBUG" = "true" ] && echo "DEBUG: $*"
}

version="v23.5.3"
shortname="core"
gameservername="core"
commandname="CORE"
rootdir=$(dirname "$(realpath "$0")")
compat_datadir="../../compat_data/ssv"
selfname=$(basename "$(realpath "$0")")
lgsmdir="${rootdir}/lgsm"
if [ -n "${LGSM_LOGDIR}" ]; then
    logdir="${LGSM_LOGDIR}"
else
    logdir="${rootdir}/log"
fi
lgsmlogdir="${logdir}/lgsm"
steamcmddir="${HOME}/.steam/steamcmd"
if [ -n "${LGSM_SERVERFILES}" ]; then
    serverfiles="${LGSM_SERVERFILES}"
else
    serverfiles="${rootdir}/serverfiles"
fi
modulesdir="${lgsmdir}/modules"
tmpdir="${lgsmdir}/tmp"
if [ -n "${LGSM_DATADIR}" ]; then
    datadir="${LGSM_DATADIR}"
else
    datadir="${lgsmdir}/data"
fi
lockdir="${lgsmdir}/lock"
sessionname="${selfname}"
if [ -n "${LGSM_CONFIG}" ]; then
    configdir="${LGSM_CONFIG}"
else
    configdir="${lgsmdir}/config-lgsm"
fi
serverlist="${compat_datadir}/serverlist.ssv"
serverlistmenu="${compat_datadir}/serverlistmenu.ssv"
[ -n "${LGSM_CONFIG}" ] && configdir="${LGSM_CONFIG}" || configdir="${lgsmdir}/config-lgsm"
configdirserver="${configdir}/${gameservername}"
configdirdefault="${lgsmdir}/config-default"
userinput="${1}"
userinput2="${2}"


## FREEBSDGSM COMPAT SETTINGS
fbsdgsm_compat_version="v23.5.3"
fbsdgsm_compat_shortname="core"
fbsdgsm_compat_gameservername="core"
fbsdgsm_compat_commandname="CORE"
fbsdgsm_compat_rootdir=$(dirname "$(readlink -f "${FBSD_COMPAT_BASH_SOURCE[0]}")")
fbsdgsm_compat_compat_datadir="../../compat_data/ssv"
fbsdgsm_compat_selfname=$(basename "$(readlink -f "${FBSD_COMPAT_BASH_SOURCE[0]}")")
fbsdgsm_compat_lgsmdir="${fbsdgsm_compat_rootdir}/fbsdgsm"
if [ -n "${FBSD_COMPAT_LGSM_LOGDIR}" ]; then
    logdir="${FBSD_COMPAT_LGSM_LOGDIR}"
else
    logdir="${fbsdgsm_compat_rootdir}/fbsd_log"
fi
fbsdgsm_compat_lgsmlogdir="${fbsdgsm_compat_logdir}/fbsd"
fbsdgsm_compat_steamcmddir="${HOME}/.steam/steamcmd"
if [ -n "${FBSD_COMPAT_LGSM_SERVERFILES}" ]; then
    fbsdgsm_compat_serverfiles="${FBSD_COMPAT_LGSM_SERVERFILES}"
else
    fbsdgsm_compat_serverfiles="${fbsdgsm_compat_rootdir}/serverfiles"
fi
fbsdgsm_compat_modulesdir="${fbsdgsm_compat_lgsmdir}/modules"
fbsdgsm_compat_tmpdir="${fbsdgsm_compat_lgsmdir}/tmp"
if [ -n "${FBSD_COMPAT_LGSM_DATADIR}" ]; then
    fbsdgsm_compat_datadir="${FBSD_COMPAT_LGSM_DATADIR}"
else
    fbsdgsm_compat_datadir="${fbsdgsm_compat_lgsmdir}/data"
fi
fbsdgsm_compat_lockdir="${fbsdgsm_compat_lgsmdir}/lock"
fbsdgsm_compat_sessionname="${fbsdgsm_compat_selfname}"
[ -f "${fbsdgsm_compat_datadir}/${selfname}.uid" ] && socketname="${fbsdgsm_compat_sessionname}-$(cat "${fbsdgsm_compat_datadir}/${fbsdgsm_compat_selfname}.uid")"
fbsdgsm_compat_serverlist="${fbsdgsm_compat_datadir}/serverlist.ssv"
fbsdgsm_compat_serverlistmenu="${fbsdgsm_compat_datadir}/serverlistmenu.ssv"

if [ -n "${FBSD_COMPAT_LGSM_CONFIG}" ]; then
    configdir="${FBSD_COMPAT_LGSM_CONFIG}"
else
    configdir="${fbsdgsm_compat_lgsmdir}/config-lgsm"
fi
fbsdgsm_compat_configdirserver="${fbsdgsm_compat_configdir}/${fbsdgsm_compat_gameservername}"
fbsdgsm_compat_configdirdefault="${fbsdgsm_compat_lgsmdir}/config-default"
fbsdgsm_compat_userinput="${1}"
fbsdgsm_compat_userinput2="${2}"

if [ -n "${PROD}" ]; then
    prod="${PROD}"
else
    prod="true"
fi
if [ -n "${FORCE_COMPAT}" ]; then
    force_compat="${FORCE_COMPAT}"
else
    force_compat="true"
fi

# url for checking the sha256 hashes of core files.
# this is hard coded and should not be edited as the hashes
# are freshly generated after every commit
shacheck_url="https://shacheck.freebsdgsm.org"


## GitHub Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
#### generally safer to use if statements then || or &&
if [ -n "${LGSM_GITHUBUSER}" ]; then
    githubuser="${LGSM_GITHUBUSER}"
else
    githubuser="GameServerManagers"
fi
if [ -n "${LGSM_GITHUBREPO}" ]; then
    githubrepo="${LGSM_GITHUBREPO}"
else
    githubrepo="LinuxGSM"
fi
if [ -n "${LGSM_GITHUBBRANCH}" ]; then
    githubbranch="${LGSM_GITHUBBRANCH}"
else
    githubbranch="master"
fi

## FREEBSDGSM GitHub Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
if [ -n "${FBSDGSM_GITHUBUSER}" ]; then
    fbsdgsm_githubuser="${FBSDGSM_GITHUBUSER}"
else
    fbsdgsm_githubuser="t2vee"
fi
if [ -n "${FBSDGSM_GITHUBREPO}" ]; then
    fbsdgsm_githubrepo="${FBSDGSM_GITHUBREPO}"
else
    fbsdgsm_githubrepo="FreeBSDGSM"
fi
if [ -n "${FBSDGSM_GITHUBBRANCH}" ]; then
    fbsdgsm_githubbranch="${FBSDGSM_GITHUBBRANCH}"
else
    fbsdgsm_githubbranch="master"
fi


install_dependency() {
    command="$1"
    install_script="$2"
    install_command_handler="$3"

    if [ ! "$(command -v "${command}" 2> /dev/null)" ]; then
        printf "[ FAIL ] %s is not installed\n" "${command}"
        . "${install_script}"
        "${install_command_handler}"
    fi
}


## FREEBSD VERIFIED
# Check that curl is installed before doing anything
install_dependency "curl" "./compat_scripts/dependency_handling/_install_curl.sh" "_curl_command_handling"

force_sha_integrity_check=0
while [ $# -gt 0 ]; do
    case "$1" in
        --force-sha-integrity-check)
            force_sha_integrity_check=1
            ;;
        *)
            ;;
    esac
    shift
done
if [ "$force_sha_integrity_check" -eq 1 ]; then
	install_dependency "shasum" "./compat_scripts/dependency_handling/_install_shasum.sh" "_shasum_command_handling"
	echo "shasum is installed. sha checks of all files will be completed"
	echo ""
	echo "WARNING: IF A CHECK FAILS THE ENTIRE SCRIPT IMMEDIATELY FAILS"
	echo "USE WITH CAUTION"
	echo ""
	echo "loading integrity check script..."
	. ./extra_utils/_integrity_check.sh
else
    echo "file integrity checks disabled"
fi

## FREEBSD VERIFIED
# Core module that is required first.
import_module() {
	module="${1}"
	if [ "${module}" = "core_modules.sh" ]; then
		_dual_core_dependency_check
		. ./lgsm/modules/core_modules.sh
		. ./fbsdgsm/modules/core_modules.sh
	fi
}

## FREEBSD VERIFIED
_dual_core_dependency_check() {
	if [ -e "${modulesdir}/core_modules.sh" ]; then
		echo "LinuxGSM core modules file is installed"
		:
	else
		echo "the LinuxGSM core modules file is missing. attempting to download..."
		fn_bootstrap_fetch_file_github "lgsm/modules" "core_modules.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nomd5"
	fi
		if [ -e "${fbsdgsm_compat_modulesdir}/core_modules.sh" ]; then
		echo "FreeBSDGSM core modules file is installed"
		:
	else
		echo "the FreeBSDGSM core modules file is missing. attempting to download..."
		fn_bootstrap_fetch_file_github "fbsdgsm/modules" "core_modules.sh" "${fbsdgsm_compat_modulesdir}" "chmodx" "run" "noforcedl" "nomd5" "fbsdgsm_hook" "FORCE"
	fi
}

###//TODO NEEDS TO BE VERIFIED
## Bootstrap
# Fetches the core modules required before passed off to core_dl.sh.
fn_bootstrap_fetch_file() {
	remote_fileurl="${1}"
	remote_fileurl_backup="${2}"
	remote_fileurl_name="${3}"
	remote_fileurl_backup_name="${4}"
	local_filedir="${5}"
	local_filename="${6}"
	chmodx="${7:-0}"
	run="${8:-0}"
	forcedl="${9:-0}"
	md5="${10:-0}"

	dual_install="${11:-0}"

	dual_remote_fileurl="${12}"
	dual_remote_fileurl_backup="${13}"

	# Download file if missing or download forced.
	dl() {
		dual="${1}"
		if [ "${dual}" = "y" ]; then
			remote_fileurl="${dual_remote_fileurl}"
			remote_fileurl_backup="${dual_remote_fileurl_backup}"
			local_filedir="${5}/dual_compat_layer"
		fi
		if [ ! -f "${local_filedir}/${local_filename}" ] || [ "${forcedl}" = "forcedl" ]; then
			# If backup fileurl exists include it.
			if [ -n "${remote_fileurl_backup}" ]; then
				# counter set to 0 to allow second try
				counter=0
				remote_fileurls_array=(remote_fileurl remote_fileurl_backup)
			else
				# counter set to 1 to not allow second try
				counter=1
				remote_fileurls_array=(remote_fileurl)
			fi

			for remote_fileurl_array in "${remote_fileurls_array[@]}"; do
				if [ "${remote_fileurl_array}" = "remote_fileurl" ]; then
					fileurl="${remote_fileurl}"
					fileurl_name="${remote_fileurl_name}"
				elif [ "${remote_fileurl_array}" = "remote_fileurl_backup" ]; then
					fileurl="${remote_fileurl_backup}"
					fileurl_name="${remote_fileurl_backup_name}"
				fi
				counter=$((counter + 1))
				if [ ! -d "${local_filedir}" ]; then
					mkdir -p "${local_filedir}"
				fi
				# Trap will remove part downloaded files if canceled.
				trap fn_fetch_trap INT
				# Larger files show a progress bar.

				echo "fetching ${fileurl_name} ${local_filename}...\c"
				curlcmd=$(curl --connect-timeout 10 -s --fail -L -o "${local_filedir}/${local_filename}" "${fileurl}" 2>&1)

				_LOCAL_VAR_exitcode=$?

				# Download will fail if downloads a html file.
				if [ -f "${local_filedir}/${local_filename}" ]; then
					if [ -n "$(head "${local_filedir}/${local_filename}" | grep "DOCTYPE")" ]; then
						rm -f "${local_filedir:?}/${local_filename:?}"
						_LOCAL_VAR_exitcode=2
					fi
				fi

				# On first try will error. On second try will fail.
				if [ "${_LOCAL_VAR_exitcode}" != 0 ]; then
					if [ ${counter} -ge 2 ]; then
						echo "FAIL"
						if [ -f "${lgsmlog}" ]; then
							fn_script_log_fatal "Downloading ${local_filename}"
							fn_script_log_fatal "${fileurl}"
						fi
						core_exit.sh
					else
						echo "ERROR"
						if [ -f "${lgsmlog}" ]; then
							fn_script_log_error "Downloading ${local_filename}"
							fn_script_log_error "${fileurl}"
						fi
					fi
				else
					if [ "${force_sha_integrity_check}" = 1 ]; then
						_check_sha "${local_filedir}" "${local_filename}"
					fi
					echo "OK"
					sleep 0.3
					printf "\033[2K\\r"
					if [ -f "${lgsmlog}" ]; then
						fn_script_log_pass "Downloading ${local_filename}"
					fi

					# Make file executable if chmodx is set.
					if [ "${chmodx}" = "chmodx" ]; then
						chmod +x "${local_filedir}/${local_filename}"
					fi

					# Remove trap.
					trap - INT

					break
				fi
			done
		fi
	}

	dl "n"
	if [ "${dual_install}" = "FORCE" ]; then
		dl "y"
	fi

	if [ -f "${local_filedir}/${local_filename}" ]; then
		# Execute file if run is set.
		if [ "${run}" = "run" ]; then
			# shellcheck source=/dev/null
			. "${local_filedir}/${local_filename}"
		fi
	fi
}

fn_bootstrap_fetch_file_github() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	# By default modules will be downloaded from the version release to prevent potential version mixing. Only update-lgsm will allow an update.
	if [ "${prod}" = "false" ]; then
		if [ "${githubbranch}" = "master" ] && [ "${githubuser}" = "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
			remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
			remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
		else
			remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
			remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		fi
	fi
	fbsdgsm_hook="${8:-0}"
	# try to get freebsdgsm to use a centralised cdn
	if [ "${prod}" = "true" ] || [ "${force_compat}" = "true" ] || [ "${fbsdgsm_hook}" = "fbsdgsm_hook" ]; then
		remote_fileurl="https://files.freebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://git.files.freebsdgsm.org/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/master/${github_file_url_dir}/${github_file_url_name}}"
	fi
	remote_fileurl_name="freebsdgsm cdn"
	remote_fileurl_backup_name="FBSDGSM Git"
	local_filedir="${3}"
	local_filename="${github_file_url_name}"
	chmodx="${4:-0}"
	run="${5:-0}"
	forcedl="${6:-0}"
	md5="${7:-0}"

	if [ "${force_compat}" = "true" ]; then
		dual_compat_install="FORCE"
	else
		dual_compat_install="${9}"
	fi

	if [ "${dual_compat_install}" = "FORCE" ]; then
			dual_remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
			dual_remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"

			remote_fileurl="https://files.freebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
			remote_fileurl_backup="https://git.files.freebsdgsm.org/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/master/${github_file_url_dir}/${github_file_url_name}}"

			local_filedir="fbsdgsm/modules"
	fi
	# Passes vars to the file download module.
	fn_bootstrap_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}" "${dual_compat_install}" "${dual_remote_fileurl}" "${dual_remote_fileurl_backup}"
}

## FREEBSD VERIFIED
# Installer menu.
fn_print_center() {
    columns=${COLUMNS:-80}
    line="$*"
    printf "%*s\n" $(((${#line} + columns) / 2)) "${line}"
}

fn_print_horizontal() {
    columns=${COLUMNS:-80}
    line=""
    for i in $(seq "$columns"); do
        line="${line}="
    done
    printf "%s\n" "$line"
}

###//TODO NEEDS TO BE VERIFIED
# B̶a̶s̶h̶ Posix menu baby.
fn_install_menu_posix() {
    __local_resultvar=$1
    title=$2
    caption=$3
    options=$4
    fn_print_horizontal
    fn_print_center "$title"
    fn_print_center "$caption"
    fn_print_horizontal
    PS3="Select an option (or 'q' to cancel): "
    menu_options=()
    index=0
    while IFS= read -r line; do
        var=${line%% -*}
        menu_options["$index"]="$var - ${line#* - }"
        index=$((index + 1))
    done < "$options"

    input=""

	i=0
	while [ -z "$input" ] || [ "$input" -lt 1 ] || [ "$input" -gt "$index" ]; do
		echo "$PS3"
		i=0
		while [ "$i" -lt "$index" ]; do
			echo "$((i + 1)) ${menu_options[i]}"
			i=$((i + 1))
		done
		read -r input
	done


    if [ "$input" = "q" ]; then
        echo "Menu canceled."
    else
        eval "$__local_resultvar=\"${menu_options[input-1]%% -*}\""
    fi
}





## FREEBSD FAILED

### NOT GOING TO CONVERT. WHIPTAIL IS NOT DEFAULT ON FREEBSD
# Whiptail/Dialog menu.
#fn_install_menu_whiptail() {
#	local menucmd=$1
#	local resultvar=$2
#	title=$3
#	caption=$4
#	options=$5
#	height=${6:-40}
#	width=${7:-80}
#	menuheight=${8:-30}
#	IFS=","
#	menu_options=()
#	while read -r line; do
#		key=$(echo -e "${line}" | awk -F "," '{print $3}')
#		val=$(echo -e "${line}" | awk -F "," '{print $2}')
#		menu_options+=("${val//\"/}" "${key//\"/}")
#	done < "${options}"
#	OPTION=$(${menucmd} --title "${title}" --menu "${caption}" "${height}" "${width}" "${menuheight}" "${menu_options[@]}" 3>&1 1>&2 2>&3)
#	if [ $? == 0 ]; then
#		eval "$resultvar=\"${OPTION}\""
#	else
#		eval "$resultvar="
#	fi
#}


###//TODO NEEDS TO BE VERIFIED
# Menu selector.
fn_install_menu() {
	_LOCAL_VAR_resultvar=$1
	_LOCAL_VAR_selection=""
	title=$2
	caption=$3
	options=$4
	# Get menu command.
	for menucmd in whiptail dialog bash; do
		if [ "$(command -v "${menucmd}")" ]; then
			menucmd=$(command -v "${menucmd}")
			break
		fi
	done
	case "$(basename "${menucmd}")" in
		whiptail | dialog)
			fn_install_menu_whiptail "${menucmd}" _LOCAL_VAR_selection "${title}" "${caption}" "${options}" 40 80 30
			;;
		*)
			fn_install_menu_posix _LOCAL_VAR_selection "${title}" "${caption}" "${options}"
			;;
	esac
	eval "$_LOCAL_VAR_resultvar=\"${_LOCAL_VAR_selection}\""
}

# Gets server info from serverlist.ssv and puts it into a space separated string.
fn_server_info() {
	IFS=","
	. ./compat_scripts/data_handling/_convert_csv.sh
	convert_csv_to_ssv ${serverlist}
	server_info_array=($(grep -aw "${userinput}" "${fbsdgsm_compat_serverlist}"))
	shortname="${server_info_array[0]}"      # csgo
	gameservername="${server_info_array[1]}" # csgoserver
	gamename="${server_info_array[2]}"       # Counter Strike: Global Offensive
}

fn_install_getopt() {
	userinput="empty"
	printf "Usage: %s$0 [option]"
	printf ""
	printf "Installer - Linux Game Server Managers - Version %s${version}"
	printf "https://linuxgsm.com"
	printf ""
	printf "Commands"
	printf "install%b\t%b\t| Select server to install."
	printf "servername%b\t| Enter name of game server to install. e.g %s$0 csgoserver."
	printf "list%b\t%b\t| List all servers available for install."
	exit
}
###//TODO NEEDS TO BE VERIFIED
fn_install_file() {
	local_filename="${gameservername}"
	if [ -e "${local_filename}" ]; then
		i=2
		while [ -e "${local_filename}-${i}" ]; do
			i=$((i + 1))
		done
		local_filename="${local_filename}-${i}"
	fi
	cp -R "${selfname}" "${local_filename}"
	sed -i -e "s/shortname=\"core\"/shortname=\"${shortname}\"/g" "${local_filename}"
	sed -i -e "s/gameservername=\"core\"/gameservername=\"${gameservername}\"/g" "${local_filename}"
	printf "Installed %s${gamename} server as %s${local_filename}"
	printf ""
	if [ ! -d "${serverfiles}" ]; then
		printf "./%s${local_filename} install"
	else
		printf "Remember to check server ports"
		printf "./%s${local_filename} details"
	fi
	printf ""
	exit
}

## FREEBSD VERIFIED
# Prevent LinuxGSM from running as root. Except if doing a dependency install.
if [ "$(whoami)" = "root" ]; then
    if [ "${userinput}" = "install" ] || [ "${userinput}" = "auto-install" ] || [ "${userinput}" = "i" ] || [ "${userinput}" = "ai" ]; then
        if [ "${shortname}" = "core" ]; then
            echo "[ FAIL ] Do NOT run this script as root!"
            exit 1
        fi
    elif [ ! -f "${modulesdir}/core_modules.sh" ] || [ ! -f "${modulesdir}/check_root.sh" ] || [ ! -f "${modulesdir}/core_messages.sh" ]; then
        echo "[ FAIL ] Do NOT run this script as root!"
        exit 1
    else
        core_modules.sh
        check_root.sh
    fi
fi

###//TODO NEEDS TO BE VERIFIED
# LinuxGSM installer mode.
if [ "${shortname}" = "core" ]; then
	# Download the latest serverlist. This is the complete list of all supported servers.
	#fn_bootstrap_fetch_file_github "lgsm/data" "serverlist.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nomd5"

	# doing this the more jank way
	. ./compat_scripts/data_handling/_convert_csv.sh

	convert_csv_to_ssv ${serverlist}

	if [ ! -f "${serverlist}" ]; then
		echo "[ WARN ] serverlist.csv could not be loaded. but it should be ok"
		:
	fi
	if [ ! -f "${fbsdgsm_compat_serverlist}" ]; then
		echo "[ FAIL ] serverlist.ssv could not be loaded."
		exit 1
	fi

	if [ "${userinput}" = "list" ] || [ "${userinput}" = "l" ]; then
		{
			tail -n +2 "${serverlist}" | awk -F "," '{print $2 "\t" $3}'
		} | column -s ' ' -t | more
		exit
	elif [ "${userinput}" = "install" ] || [ "${userinput}" = "i" ]; then
		tail -n +2 "${serverlist}" | awk -F "," '{print $1 "," $2 "," $3}' > "${serverlistmenu}"
		fn_install_menu result "FreeBSDGSM" "Select game server to install." "${serverlistmenu}"
		userinput="${result}"
		fn_server_info
		if [ "${result}" = "${gameservername}" ]; then
			fn_install_file
		elif [ "${result}" = "" ]; then
			prinf "Install canceled"
		else
			prinf "[ FAIL ] menu result does not match gameservername"
			prinf "result: ${result}"
			prinf "gameservername: ${gameservername}"
		fi
	elif [ "${userinput}" ]; then
		fn_server_info
		if [ "${userinput}" = "${gameservername}" ] || [ "${userinput}" = "${gamename}" ] || [ "${userinput}" = "${shortname}" ]; then
			fn_install_file
		else
			printf "[ FAIL ] Unknown game server"
			exit 1
		fi
	else
		fn_install_getopt
	fi

##//TODO kind of complete???
#// LinuxGSM server mode.
else
	import_module "core_modules.sh"
	if [ "${shortname}" != "core-dep" ]; then
		# Load LinuxGSM configs.
		# These are required to get all the default variables for the specific server.
		# Load the default config. If missing download it. If changed reload it.
		if [ ! -f "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}/_default.cfg" ]; then
			mkdir -p "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}"
			fn_fetch_config "lgsm/config-default/config-lgsm/${gameservername}" "_default.cfg" "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}" "_default.cfg" "nochmodx" "norun" "noforcedl" "nomd5"
		fi
		if [ ! -f "${fbsdgsm_compat_configdirserver}/_default.cfg" ]; then
			mkdir -p "${fbsdgsm_compat_configdirserver}"
			printf "copying _default.cfg..."
			cp -R "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${fbsdgsm_compat_configdirserver}/_default.cfg"
			if [ $? != 0 ]; then
				printf "FAIL\n"
				exit 1
			else
				printf "OK\n"
			fi
		else
			config_file_diff=$(diff -q "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${fbsdgsm_compat_configdirserver}/_default.cfg")
			if [ "${config_file_diff}" != "" ]; then
				fn_print_warn_nl "_default.cfg has altered. reloading config."
				printf "copying _default.cfg..."
				cp -R "${fbsdgsm_compat_configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${fbsdgsm_compat_configdirserver}/_default.cfg"
				if [ $? != 0 ]; then
					printf "FAIL\n"
					exit 1
				else
					printf "OK\n"
				fi
			fi
		fi
	fi

	# Load the IP details before the first config is loaded.
	check_ip.sh
	# Configs have to be loaded twice to allow start startparameters to pick up all vars
	# shellcheck source=/dev/null
	. "${fbsdgsm_compat_configdirserver}/_default.cfg"
	# Load the common.cfg config. If missing download it.
	if [ ! -f "${fbsdgsm_compat_configdirserver}/common.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "common-template.cfg" "${fbsdgsm_compat_configdirserver}" "common.cfg" "${chmodx}" "nochmodx" "norun" "noforcedl" "nomd5"
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/common.cfg"
	else
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/common.cfg"
	fi
	# Load the secrets-common.cfg config. If missing download it.
	if [ ! -f "${fbsdgsm_compat_configdirserver}/secrets-common.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "secrets-common-template.cfg" "${fbsdgsm_compat_configdirserver}" "secrets-common.cfg" "${chmodx}" "nochmodx" "norun" "noforcedl" "nomd5"
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/secrets-common.cfg"
	else
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/secrets-common.cfg"
	fi
	# Load the instance.cfg config. If missing download it.
	if [ ! -f "${fbsdgsm_compat_configdirserver}/${selfname}.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "instance-template.cfg" "${fbsdgsm_compat_configdirserver}" "${selfname}.cfg" "nochmodx" "norun" "noforcedl" "nomd5"
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/${selfname}.cfg"
	else
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/${selfname}.cfg"
	fi
	# Load the secrets-instance.cfg config. If missing download it.
	if [ ! -f "${fbsdgsm_compat_configdirserver}/secrets-${selfname}.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "secrets-instance-template.cfg" "${fbsdgsm_compat_configdirserver}" "secrets-${selfname}.cfg" "nochmodx" "norun" "noforcedl" "nomd5"
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/secrets-${selfname}.cfg"
	else
		# shellcheck source=/dev/null
		. "${fbsdgsm_compat_configdirserver}/secrets-${selfname}.cfg"
	fi

	# Reloads start parameter to ensure all vars in startparameters are set.
	# Will reload the last defined startparameter.
	fn_reload_startparameters() {
		# reload Wurm config.
		if [ "${shortname}" = "wurm" ]; then
			# shellcheck source=/dev/null
			. "${servercfgfullpath}"
		fi

		# ... (Rest of your fn_reload_startparameters function remains unchanged)
	}

	# Load the freebsdgsm.sh in to tmpdir. If missing download it.
	if [ ! -f "${tmpdir}/linuxgsm.sh" ]; then
		fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "chmodx" "norun" "noforcedl" "nomd5"
	fi

	# Enables ANSI colours from core_messages.sh. Can be disabled with ansi=off.
	fn_ansi_loader

	getopt=$1
	core_getopt.sh
fi

