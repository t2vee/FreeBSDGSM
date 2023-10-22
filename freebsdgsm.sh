#!/bin/sh
# Project: FreeBSDGSM - The LinuxGSM Compatibility Project
# Author: t2vee
# License: MIT License, see LICENSE.md
# Purpose: FreeBSD Game Server Management Script. Mainly a translation from Bash to POSIX sh.
# Credit: This Project is Based Upon LinuxGSM By Daniel Gibbs



# mega jank and probably still broken



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
serverlist="${datadir}/serverlist.csv"
serverlistmenu="${datadir}/serverlistmenu.csv"
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
fbsdgsm_compat_rootdir=$(cd "$(dirname "$0")" && pwd)
fbsdgsm_compat_fullpath=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
fbsdgsm_compat_selfname=$(basename "$fbsdgsm_compat_fullpath")
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


## TESTED & VERIFIED - 20/10/23
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


## // TODO NEEDS TO BE VERIFIED
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

## // TODO NEEDS TO BE VERIFIED
# Core module that is required first.
import_module() {
	module="${1}"
	if [ "${module}" = "core_modules.sh" ]; then
		_dual_core_dependency_check
		. ./lgsm/modules/core_modules.sh
		. ./fbsdgsm/modules/core_modules.sh
	fi
}

## // TODO NEEDS TO BE VERIFIED
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

## TESTED & VERIFIED - 20/10/23
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
				counter=0
				remote_fileurls_string="remote_fileurl remote_fileurl_backup"
			else
				counter=1
				remote_fileurls_string="remote_fileurl"
			fi

			for remote_fileurl_array in $remote_fileurls_string; do
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

## TESTED & VERIFIED - 20/10/23

get_remote_file_url() {
    _LOCAL_VAR_github_file_url_dir="$1"
    _LOCAL_VAR_github_file_url_name="$2"
    _LOCAL_VAR_hook="$3"

    if [ "${prod}" = "false" ]; then
        if [ "${githubbranch}" = "master" ] && [ "${githubuser}" = "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
            echo "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
        else
            echo "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
        fi
    elif [ "${prod}" = "true" ] || [ "${force_compat}" = "true" ] || [ "${_LOCAL_VAR_hook}" = "fbsdgsm_hook" ]; then
        echo "https://files.freebsdgsm.org/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
    fi
}

## TESTED & VERIFIED - 20/10/23
# Separate logic for determining the backup remote file URL
get_remote_backup_file_url() {
    _LOCAL_VAR_github_file_url_dir="$1"
    _LOCAL_VAR_github_file_url_name="$2"

    if [ "${prod}" = "false" ]; then
        echo "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
    else
		echo "https://git.files.freebsdgsm.org/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/master/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}}"
    fi
}

## TESTED & VERIFIED - 20/10/23
fn_bootstrap_fetch_file_github() {
    _LOCAL_VAR_github_file_url_dir="${1}"
    _LOCAL_VAR_github_file_url_name="${2}"

    # Determine remote URLs
    remote_fileurl=$(get_remote_file_url "${_LOCAL_VAR_github_file_url_dir}" "${_LOCAL_VAR_github_file_url_name}" "${fbsdgsm_hook}")
    remote_fileurl_backup=$(get_remote_backup_file_url "${_LOCAL_VAR_github_file_url_dir}" "${_LOCAL_VAR_github_file_url_name}")

    remote_fileurl_name="freebsdgsm cdn"
    remote_fileurl_backup_name="FBSDGSM Git"
    local_filedir="${3}"
    local_filename="${_LOCAL_VAR_github_file_url_name}"
    chmodx="${4:-0}"
    run="${5:-0}"
    forcedl="${6:-0}"
    md5="${7:-0}"
    fbsdgsm_hook="${8}"

    if [ "${force_compat}" = "true" ]; then
        dual_compat_install="FORCE"
    else
        dual_compat_install="${9}"
    fi

    if [ "${dual_compat_install}" = "FORCE" ]; then
        dual_remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
        dual_remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${_LOCAL_VAR_github_file_url_dir}/${_LOCAL_VAR_github_file_url_name}"
        local_filedir="fbsdgsm/modules"
    fi

    # Passes vars to the file download module.
    fn_bootstrap_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}" "${fbsdgsm_hook}" "${dual_compat_install}" "${dual_remote_fileurl}" "${dual_remote_fileurl_backup}"
}

## TESTED & VERIFIED - 20/10/23
# Installer menu.
fn_print_center() {
    columns=${COLUMNS:-80}
    line="$*"
    printf "%*s\n" $(((${#line} + columns) / 2)) "${line}"
}

## TESTED & VERIFIED - 20/10/23
fn_print_horizontal() {
    columns=${COLUMNS:-80}
    line=""
    for i in $(seq "$columns"); do
        line="${line}="
    done
    printf "%s\n" "$line"
}

###//TODO BEING VERIFIED - problems
# B̶a̶s̶h̶ Posix menu baby.
fn_install_menu_posix() {
    resultvar=$1
    title=$2
    caption=$3
    options=$4
    fn_print_horizontal
    fn_print_center "${title}"
    fn_print_center "${caption}"
    fn_print_horizontal

    # Construct menu
    count=1
	while IFS=' ' read -r name name_server description _; do
		echo "${count}. ${name} - ${name_server} - ${description}"
		count=$((count + 1))
	done < "${options}"



    echo "${count}. Cancel"

    # Get user input
    printf "Select an option (1-${count}): "
    read selection

    # Process selection
    debug "selection"
    if [ "$selection" -eq "$count" ]; then
        eval "$resultvar=Cancel"
    else
        # Extract the corresponding option
        debug "selected_option"
        selected_option=$(sed -n "${selection}" "$options" | awk -F "," '{print $2}')
        debug "resultvar"
        eval "$resultvar=$selected_option"
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

###//TODO BEING VERIFIED - problems
###//TODO NEEDS TO BE VERIFIED
fn_install_menu() {
    _LOCAL_VAR_resultvar=$1
    _LOCAL_VAR_selection=""
    title=$2
    caption=$3
    options=$4

    fn_install_menu_posix _LOCAL_VAR_selection "${title}" "${caption}" "${options}"

    eval "$_LOCAL_VAR_resultvar=\"${_LOCAL_VAR_selection}\""
}
#################################################################
# No longer need this menu selector since the fn_install_menu   #
# function only really needs to check if bash is present, which #
# it obviously is if the script is being executed. So the loop  #
# that checks for the menucmd is not necessary.                 #
#################################################################

# Menu selector.
#fn_install_menu() {
#	_LOCAL_VAR_resultvar=$1
#	_LOCAL_VAR_selection=""
#	title=$2
#	caption=$3
#	options=$4
#	# Get menu command.
#	for menucmd in whiptail dialog bash; do
#		if [ "$(command -v "${menucmd}")" ]; then
#			menucmd=$(command -v "${menucmd}")
#			break
#		fi
#	done
#	case "$(basename "${menucmd}")" in
#		whiptail | dialog)
#			fn_install_menu_whiptail "${menucmd}" _LOCAL_VAR_selection "${title}" "${caption}" "${options}" 40 80 30
#			;;
#		*)
#			fn_install_menu_posix _LOCAL_VAR_selection "${title}" "${caption}" "${options}"
#			;;
#	esac
#	eval "$_LOCAL_VAR_resultvar=\"${_LOCAL_VAR_selection}\""
#}

###//TODO BEING VERIFIED - problems
# Gets server info from serverlist.ssv and puts it into a space separated string.
fn_server_info() {
	debug "server_info_line"
	server_info_line=$(grep "^${userinput} " "${fbsdgsm_compat_serverlist}")
	if [ "$(echo "$server_info_line" | wc -l)" -ne 1 ]; then
		echo "Error: Multiple matches or no match found for server."
		exit 1
	fi

	set -- $server_info_line

	shortname="$1"
	gameservername="$2"
	gamename="$3"
}


## TESTED & VERIFIED - 20/10/23
fn_install_getopt() {
	userinput="empty"
	# need empty lines because the console prints so much garbage
	# yes i know its a me problem. but its import debug stuff?
	echo ""
	echo ""
	echo "Usage: $0 [option]"
	echo ""
	echo "Installer - Linux Game Server Managers - Versions${version}"
	echo "https://linuxgsm.com"
	echo ""
	echo "Commands"
	echo "install\t\t| Select server to install."
	echo "servername\t| Enter name of game server to install. e.g $0 csgoserver."
	echo "list\t\t| List all servers available for install."
	exit
}


###//TODO BEING VERIFIED - problems
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
	if [ $? -ne 0 ]; then
		echo "Error copying ${selfname} to ${local_filename}."
		exit 1
	fi
	sed -i -e "s/shortname=\"core\"/shortname=\"${shortname//\//\\/}\"/g" "${local_filename}"
	sed -i -e "s/gameservername=\"core\"/gameservername=\"${gameservername//\//\\/}\"/g" "${local_filename}"
	if [ $? -ne 0 ]; then
		echo "Error updating the local_filename."
		exit 1
	fi
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


## TESTED & VERIFIED - 20/10/23
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


###//TODO BEING VERIFIED - problems
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
			tail -n +2 "${fbsdgsm_compat_serverlist}" | awk -F "," '{print $2 "\t" $3}'
		} | column -s ' ' -t | more
		exit
	elif [ "${userinput}" = "install" ] || [ "${userinput}" = "i" ]; then
		tail -n +2 "${fbsdgsm_compat_serverlist}" | awk -F "," '{print $1 "," $2 "," $3}' > "${fbsdgsm_compat_serverlistmenu}"
		fn_install_menu result "FreeBSDGSM" "Select game server to install." "${fbsdgsm_compat_serverlistmenu}"
		userinput="${result}"
		fn_server_info
		if [ "${result}" = "${gameservername}" ]; then
			fn_install_file
		elif [ "${result}" = "" ]; then
			printf "Install canceled"
		else
			printf "[ FAIL ] menu result does not match gameservername"
			printf "result: %s${result}"
			printf "gameservername: %s${gameservername}"
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

##//TODO k̶i̶n̶d̶ o̶f̶ c̶o̶m̶p̶l̶e̶t̶e̶?̶?̶?̶ mega broken - even more broken???
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

		# reload startparameters.
		if grep -qE "^[[:blank:]]*startparameters=" "${configdirserver}/secrets-${selfname}.cfg"; then
			eval startparameters="$(sed -nr 's/^ *startparameters=(.*)$/\1/p' "${configdirserver}/secrets-${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*startparameters=" "${configdirserver}/${selfname}.cfg"; then
			eval startparameters="$(sed -nr 's/^ *startparameters=(.*)$/\1/p' "${configdirserver}/${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*startparameters=" "${configdirserver}/secrets-common.cfg"; then
			eval startparameters="$(sed -nr 's/^ *startparameters=(.*)$/\1/p' "${configdirserver}/secrets-common.cfg")"
		elif grep -qE "^[[:blank:]]*startparameters=" "${configdirserver}/common.cfg"; then
			eval startparameters="$(sed -nr 's/^ *startparameters=(.*)$/\1/p' "${configdirserver}/common.cfg")"
		elif grep -qE "^[[:blank:]]*startparameters=" "${configdirserver}/_default.cfg"; then
			eval startparameters="$(sed -nr 's/^ *startparameters=(.*)$/\1/p' "${configdirserver}/_default.cfg")"
		fi

		# reload preexecutable.
		if grep -qE "^[[:blank:]]*preexecutable=" "${configdirserver}/secrets-${selfname}.cfg"; then
			eval preexecutable="$(sed -nr 's/^ *preexecutable=(.*)$/\1/p' "${configdirserver}/secrets-${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*preexecutable=" "${configdirserver}/${selfname}.cfg"; then
			eval preexecutable="$(sed -nr 's/^ *preexecutable=(.*)$/\1/p' "${configdirserver}/${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*preexecutable=" "${configdirserver}/secrets-common.cfg"; then
			eval preexecutable="$(sed -nr 's/^ *preexecutable=(.*)$/\1/p' "${configdirserver}/secrets-common.cfg")"
		elif grep -qE "^[[:blank:]]*preexecutable=" "${configdirserver}/common.cfg"; then
			eval preexecutable="$(sed -nr 's/^ *preexecutable=(.*)$/\1/p' "${configdirserver}/common.cfg")"
		elif grep -qE "^[[:blank:]]*preexecutable=" "${configdirserver}/_default.cfg"; then
			eval preexecutable="$(sed -nr 's/^ *preexecutable=(.*)$/\1/p' "${configdirserver}/_default.cfg")"
		fi

		# For legacy configs that still use parms= 15.03.21
		if grep -qE "^[[:blank:]]*parms=" "${configdirserver}/secrets-${selfname}.cfg"; then
			eval parms="$(sed -nr 's/^ *parms=(.*)$/\1/p' "${configdirserver}/secrets-${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*parms=" "${configdirserver}/${selfname}.cfg"; then
			eval parms="$(sed -nr 's/^ *parms=(.*)$/\1/p' "${configdirserver}/${selfname}.cfg")"
		elif grep -qE "^[[:blank:]]*parms=" "${configdirserver}/secrets-common.cfg"; then
			eval parms="$(sed -nr 's/^ *parms=(.*)$/\1/p' "${configdirserver}/secrets-common.cfg")"
		elif grep -qE "^[[:blank:]]*parms=" "${configdirserver}/common.cfg"; then
			eval parms="$(sed -nr 's/^ *parms=(.*)$/\1/p' "${configdirserver}/common.cfg")"
		elif grep -qE "^[[:blank:]]*parms=" "${configdirserver}/_default.cfg"; then
			eval parms="$(sed -nr 's/^ *parms=(.*)$/\1/p' "${configdirserver}/_default.cfg")"
		fi

		if [ -n "${parms}" ]; then
			startparameters="${parms}"
		fi
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

