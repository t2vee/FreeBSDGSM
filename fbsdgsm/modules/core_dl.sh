#!/bin/sh
# FreeBSDGSM core_dl.sh module
# Description: Deals with all downloads for LinuxGSM.

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# hash: Optional, set an hash sum and will compare it against the file.
#
# Downloads can be defined in code like so:
# fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
# fn_fetch_file "http://example.com/file.tar.bz2" "http://example.com/file2.tar.bz2" "file.tar.bz2" "file2.tar.bz2" "/some/dir" "file.tar.bz2" "chmodx" "run" "forcedl" "10cd7353aa9d758a075c600a6dd193fd"


##### //TODO Whole module needs to be verified

abs_path() {
    case "$1" in
        /*) printf "%s\n" "$1";;
        *)  printf "%s\n" "$PWD/$1";;
    esac
}

moduleselfname="$(basename "$(abs_path "$0")")"

fn_dl_steamcmd() {
	fn_print_start_nl "${remotelocation}"
	fn_script_log_info "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}"
	if [ -n "${branch}" ]; then
		echo "Branch: ${branch}"
		fn_script_log_info "Branch: ${branch}"
	fi
	if [ -n "${betapassword}" ]; then
		echo "Branch password: ${betapassword}"
		fn_script_log_info "Branch password: ${betapassword}"
	fi
	if [ -d "${fbsdgsm_compat_steamcmddir}" ]; then
		cd "${fbsdgsm_compat_steamcmddir}" || exit
	fi

	# Unbuffer will allow the output of steamcmd not buffer allowing a smooth output.
	# unbuffer us part of the expect package.
	if [ "$(command -v unbuffer 2> /dev/null)" ]; then
		unbuffer="unbuffer"
	fi

	# Validate will be added as a parameter if required.
	if [ "${commandname}" = "VALIDATE" ] || [ "${commandname}" = "INSTALL" ]; then
		validate="validate"
	fi

	# To do error checking for SteamCMD the output of steamcmd will be saved to a log.
	steamcmdlog="${fbsdgsm_compat_lgsmlogdir}/${fbsdgsm_compat_selfname}-steamcmd.log"

	# clear previous steamcmd log
	if [ -f "${steamcmdlog}" ]; then
		rm -f "${steamcmdlog:?}"
	fi
	counter=0
	while [ "${counter}" = "0" ] || [ "${exitcode}" != "0" ]; do
		counter=$((counter + 1))
		# Select SteamCMD parameters
		# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
		if [ "${appid}" = "90" ]; then
			# If using a specific branch.
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# Force Windows Platform type.
		elif [ "${steamcmdforcewindows}" = "yes" ]; then
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# All other servers.
		else
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		fi

		# Error checking for SteamCMD. Some errors will loop to try again and some will just exit.
		# Check also if we have more errors than retries to be sure that we do not loop to many times and error out.
		exitcode=$?
		if [ -n "$(grep -i "Error!" "${steamcmdlog}" | tail -1)" ] && [ "$(grep -ic "Error!" "${steamcmdlog}")" -ge "${counter}" ]; then
			# Not enough space.
			if [ -n "$(grep "0x202" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Not enough disk space to download server files"
				fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Not enough disk space to download server files"
				core_exit.sh
				# Not enough space.
			elif [ -n "$(grep "0x212" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Not enough disk space to download server files"
				fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Not enough disk space to download server files"
				core_exit.sh
			# Need tp purchase game.
			elif [ -n "$(grep "No subscription" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				core_exit.sh
			# Two-factor authentication failure
			elif [ -n "$(grep "Two-factor code mismatch" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Two-factor authentication failure"
				fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Two-factor authentication failure"
				core_exit.sh
			# Incorrect Branch password
			elif [ -n "$(grep "Password check for AppId" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: betapassword is incorrect"
				fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: betapassword is incorrect"
				core_exit.sh
			# Update did not finish.
			elif [ -n "$(grep "0x402" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Update required but not completed - check network"
				fn_script_log_error "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Update required but not completed - check network"
			# Disk write failure.
			elif [ -n "$(grep "0x606" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Disk write failure"
				fn_script_log_error "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Disk write failure"
			# Missing update files.
			elif [ -n "$(grep "0x626" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x626" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Missing update files"
				fn_script_log_error "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Missing update files"
			else
				fn_print_error2_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Unknown error occured"
				echo "Please provide content log to LinuxGSM developers https://linuxgsm.com/steamcmd-error"
				fn_script_log_error "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Unknown error occured"
			fi
		elif [ "${exitcode}" != 0 ]; then
			fn_print_error2_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Exit code: ${exitcode}"
			fn_script_log_error "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Exit code: ${exitcode}"
		else
			fn_print_complete_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}"
			fn_script_log_pass "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}"
		fi

		if [ "${counter}" -gt "10" ]; then
			fn_print_failure_nl "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			fn_script_log_fatal "${commandaction} ${fbsdgsm_compat_selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			core_exit.sh
		fi
	done
}

# Emptys contents of the LinuxGSM fbsdgsm_compat_tmpdir.
fn_clear_tmp() {
	echo "clearing LinuxGSM tmp directory..."
	if [ -d "${fbsdgsm_compat_tmpdir}" ]; then
		rm -rf "${fbsdgsm_compat_tmpdir:?}/"*
		_LOCAL_VAR_exitcode=$?
		if [ "${_LOCAL_VAR_exitcode}" != 0 ]; then
			fn_print_error_eol_nl
			fn_script_log_error "clearing LinuxGSM tmp directory"
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "clearing LinuxGSM tmp directory"
		fi
	fi
}

fn_dl_hash() {
	# Runs Hash Check if available.
	if [ "${hash}" != "0" ] && [ "${hash}" != "nohash" ] && [ "${hash}" != "nomd5" ]; then
		# MD5
		if [ "${#hash}" = "32" ]; then
			hashbin="md5sum"
			hashtype="MD5"
		# SHA1
		elif [ "${#hash}" = "40" ]; then
			hashbin="sha1sum"
			hashtype="SHA1"
		# SHA256
		elif [ "${#hash}" = "64" ]; then
			hashbin="sha256sum"
			hashtype="SHA256"
		# SHA512
		elif [ "${#hash}" = "128" ]; then
			hashbin="sha512sum"
			hashtype="SHA512"
		else
			fn_script_log_error "hash lengh not known for hash type"
			fn_print_error_nl "hash lengh not known for hash type"
			core_exit.sh
		fi
		echo "verifying ${local_filename} with ${hashtype}..."
		fn_sleep_time
		hashsumcmd=$(${hashbin} "${local_filedir}/${local_filename}" | awk '{print $1}')
		if [ "${hashsumcmd}" != "${hash}" ]; then
			fn_print_fail_eol_nl
			echo "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			echo "expected ${hashtype} checksum: ${hash}"
			fn_script_log_fatal "Verifying ${local_filename} with ${hashtype}"
			fn_script_log_info "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			fn_script_log_info "Expected ${hashtype} checksum: ${hash}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Verifying ${local_filename} with ${hashtype}"
			fn_script_log_info "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			fn_script_log_info "Expected ${hashtype} checksum: ${hash}"
		fi
	fi
}

# Extracts bzip2, gzip or zip files.
# Extracts can be defined in code like so:
# fn_dl_extract "${local_filedir}" "${local_filename}" "${extractdest}" "${extractsrc}"
# fn_dl_extract "/home/gameserver/lgsm/tmp" "file.tar.bz2" "/home/gamserver/serverfiles"
fn_dl_extract() {
	local_filedir="${1}"
	local_filename="${2}"
	extractdest="${3}"
	extractsrc="${4}"
	# Extracts archives.
	echo "extracting ${local_filename}..."

	if [ ! -d "${extractdest}" ]; then
		mkdir "${extractdest}"
	fi
	if [ ! -f "${local_filedir}/${local_filename}" ]; then
		fn_print_fail_eol_nl
		echo "file ${local_filedir}/${local_filename} not found"
		fn_script_log_fatal "Extracting ${local_filename}"
		fn_script_log_fatal "File ${local_filedir}/${local_filename} not found"
		core_exit.sh
	fi
	mime=$(file -b --mime-type "${local_filedir}/${local_filename}")
	if [ "${mime}" = "application/gzip" ] || [ "${mime}" = "application/x-gzip" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -zxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -zxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" = "application/x-bzip2" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -jxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -jxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" = "application/x-xz" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -Jxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -Jxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" = "application/zip" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(unzip -qoj -d "${extractdest}" "${local_filedir}/${local_filename}" "${extractsrc}"/*)
		else
			extractcmd=$(unzip -qo -d "${extractdest}" "${local_filedir}/${local_filename}")
		fi
	fi
	_LOCAL_VAR_exitcode=$?
	if [ "${_LOCAL_VAR_exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Extracting ${local_filename}"
		if [ -f "${lgsmlog}" ]; then
			echo "${extractcmd}" >> "${lgsmlog}"
		fi
		echo "${extractcmd}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Extracting ${local_filename}"
	fi
}

# Trap to remove file download if canceled before completed.
fn_fetch_trap() {
	echo ""
	echo "downloading ${local_filename}..."
	fn_print_canceled_eol_nl
	fn_script_log_info "Downloading ${local_filename}...CANCELED"
	fn_sleep_time
	rm -f "${local_filedir:?}/${local_filename}"
	echo "downloading ${local_filename}..."
	fn_print_removed_eol_nl
	fn_script_log_info "Downloading ${local_filename}...REMOVED"
	core_exit.sh
}

# Will check a file exists and download it. Will not exit if fails to download.
fn_check_file() {
    remote_fileurl="$1"
    remote_fileurl_backup="$2"
    remote_fileurl_name="$3"
    remote_fileurl_backup_name="$4"
    remote_filename="$5"

    # If backup fileurl exists include it.
    if [ -n "${remote_fileurl_backup}" ]; then
        # counter set to 0 to allow second try
        counter=0
        set -- "$remote_fileurl" "$remote_fileurl_backup"
    else
        # counter set to 1 to not allow second try
        counter=1
        set -- "$remote_fileurl"
    fi

    for remote_fileurl_val in "$@"; do
        if [ "${remote_fileurl_val}" = "${remote_fileurl}" ]; then
            fileurl="${remote_fileurl}"
            fileurl_name="${remote_fileurl_name}"
        else
            fileurl="${remote_fileurl_backup}"
            fileurl_name="${remote_fileurl_backup_name}"
        fi
        counter=$((counter + 1))
        printf "checking %s %s...\c" "$fileurl_name" "$remote_filename"
        curlcmd=$(curl --output /dev/null --silent --head --fail "${fileurl}" 2>&1)
        _LOCAL_VAR_exitcode=$?

        if [ "${_LOCAL_VAR_exitcode}" != 0 ]; then
            if [ "$counter" -ge 2 ]; then
                fn_print_fail_eol_nl
                if [ -f "${lgsmlog}" ]; then
                    fn_script_log_fatal "Checking ${remote_filename}"
                    fn_script_log_fatal "${fileurl}"
                    checkflag=1
                fi
            else
                fn_print_error_eol_nl
                if [ -f "${lgsmlog}" ]; then
                    fn_script_log_error "Checking ${remote_filename}"
                    fn_script_log_error "${fileurl}"
                    checkflag=2
                fi
            fi
        else
            fn_print_ok_eol
            printf "\033[2K\\r"
            if [ -f "${lgsmlog}" ]; then
                fn_script_log_pass "Checking ${remote_filename}"
                checkflag=0
            fi
            break
        fi
    done

    if [ -f "${local_filedir}/${local_filename}" ]; then
        fn_dl_hash
        if [ "${run}" = "run" ]; then
            . "${local_filedir}/${local_filename}"
        fi
    fi
}


fn_fetch_file() {
    remote_fileurl="$1"
    remote_fileurl_backup="$2"
    remote_fileurl_name="$3"
    remote_fileurl_backup_name="$4"
    local_filedir="$5"
    local_filename="$6"
    chmodx="${7:-0}"
    run="${8:-0}"
    forcedl="${9:-0}"
    hash="${10:-0}"

    # Download file if missing or download forced.
    if [ ! -f "${local_filedir}/${local_filename}" ] || [ "${forcedl}" = "forcedl" ]; then
        if [ -n "${remote_fileurl_backup}" ]; then
            counter=0
            set -- "$remote_fileurl" "$remote_fileurl_backup"
        else
            counter=1
            set -- "$remote_fileurl"
        fi

        for remote_fileurl_val in "$@"; do
            if [ "${remote_fileurl_val}" = "${remote_fileurl}" ]; then
                fileurl="${remote_fileurl}"
                fileurl_name="${remote_fileurl_name}"
            else
                fileurl="${remote_fileurl_backup}"
                fileurl_name="${remote_fileurl_backup_name}"
            fi
            counter=$((counter + 1))
            if [ ! -d "${local_filedir}" ]; then
                mkdir -p "${local_filedir}"
            fi

            trap fn_fetch_trap INT
            curlcmd="curl --connect-timeout 10 --fail -L -o ${local_filedir}/${local_filename} --retry 2"

            ext="${local_filename##*.}"
            case "$ext" in
                bz2|gz|zip|jar|xz)
                    echo "downloading ${local_filename}..."
                    fn_sleep_time
                    printf "\033[1K"
                    $curlcmd --progress-bar "${fileurl}" 2>&1
                    exitcode="$?"
                    ;;
                *)
                    printf "fetching %s %s...\c" "$fileurl_name" "$local_filename"
                    $curlcmd --silent --show-error "${fileurl}" 2>&1
                    exitcode="$?"
                    ;;
            esac

            if [ -f "${local_filedir}/${local_filename}" ] && head -n 1 "${local_filedir}/${local_filename}" | grep -q "DOCTYPE"; then
                rm "${local_filedir:?}/${local_filename:?}"
                exitcode=2
            fi

            if [ "$exitcode" != 0 ]; then
                if [ "$counter" -ge 2 ]; then
                    fn_print_fail_eol_nl
                    if [ -f "${lgsmlog}" ]; then
                        fn_script_log_fatal "Downloading ${local_filename}..."
                        fn_script_log_fatal "${fileurl}"
                    fi
                    core_exit.sh
                else
                    fn_print_error_eol_nl
                    if [ -f "${lgsmlog}" ]; then
                        fn_script_log_error "Downloading ${local_filename}..."
                        fn_script_log_error "${fileurl}"
                    fi
                fi
            else
                fn_print_ok_eol_nl
                if [ -f "${lgsmlog}" ]; then
                    fn_script_log_pass "Downloading ${local_filename}..."
                fi

                if [ "$chmodx" = "chmodx" ]; then
                    chmod +x "${local_filedir}/${local_filename}"
                fi

                trap - INT
                break
            fi
        done
    fi

    if [ -f "${local_filedir}/${local_filename}" ]; then
        fn_dl_hash
        if [ "$run" = "run" ]; then
            . "${local_filedir}/${local_filename}"
        fi
    fi
}


# GitHub file download modules.
# Used to simplify downloading specific files from GitHub.

# github_file_url_dir: the directory of the file in the GitHub: fbsdgsm/modules
# github_file_url_name: the filename of the file to download from GitHub: core_messages.sh
# github_file_url_dir: the directory of the file in the GitHub: fbsdgsm/modules
# github_file_url_name: the filename of the file to download from GitHub: core_messages.sh
# githuburl: the full GitHub url

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# hash: Optional, set an hash sum and will compare it against the file.

# Fetches files from the Git repo.
fn_fetch_file_github() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	# For legacy versions - code can be removed at a future date
	## Legacy mode is not supported in freebsdgsm
	#if [ "${legacymode}" = "1" ]; then
	#	remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	#	remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${fbsdgsm_fbsdgsm_githubbranch}" = "master" ] && [ "${fbsdgsm_githubuser}" = "t2vee" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fgsm_version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="FreeBSDGSM CDN"
	local_filedir="${3}"
	local_filename="${github_file_url_name}"
	chmodx="${4:-0}"
	run="${5:-0}"
	forcedl="${6:-0}"
	hash="${7:-0}"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

fn_check_file_github() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	if [ "${fbsdgsm_githubbranch}" = "master" ] && [ "${fbsdgsm_githubuser}" = "t2vee" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="FreeBSDGSM CDN"
	fn_check_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${github_file_url_name}"
}

# Fetches config files from the Git repo.
fn_fetch_config() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${fbsdgsm_githubbranch}" = "master" ] && [ "${fbsdgsm_githubuser}" = "t2vee" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="FreeBSDGSM CDN"
	local_filedir="${3}"
	local_filename="${4}"
	chmodx="nochmodx"
	run="norun"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

# Fetches modules from the Git repo during first download.
fn_fetch_module() {
	github_file_url_dir="fbsdgsm/modules"
	github_file_url_name="${modulefile}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${fbsdgsm_githubbranch}" = "master" ] && [ "${fbsdgsm_githubuser}" = "t2vee" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="FreeBSDGSM CDN"
	local_filedir="${fbsdgsm_compat_modulesdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="run"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

# Fetches modules from the Git repo during update-lgsm.
fn_update_module() {
	github_file_url_dir="fbsdgsm/modules"
	github_file_url_name="${modulefile}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${fbsdgsm_githubbranch}" = "master" ] && [ "${fbsdgsm_githubuser}" = "t2vee" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.fbsdgsm_githubusercontent.com/${fbsdgsm_githubuser}/${fbsdgsm_githubrepo}/${fbsdgsm_githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://files.frebsdgsm.org/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="FreeBSDGSM CDN"
	local_filedir="${fbsdgsm_compat_modulesdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="norun"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"

}

# Function to download latest github release.
# $1 GitHub user / organisation.
# $2 Repo name.
# $3 Destination for download.
# $4 Search string in releases (needed if there are more files that can be downloaded from the release pages).
fn_dl_latest_release_github() {
    _LOCAL_VAR_githubreleaseuser="${1}"
    _LOCAL_VAR_githubreleaserepo="${2}"
    _LOCAL_VAR_githubreleasedownloadpath="${3}"
    _LOCAL_VAR_githubreleasesearch="${4}"
    _LOCAL_VAR_githublatestreleaseurl="https://api.github.com/repos/${_LOCAL_VAR_githubreleaseuser}/${_LOCAL_VAR_githubreleaserepo}/releases/latest"

    # Get last github release.
    # If no search for the release filename is set, just get the first file from the latest release.
    if [ -z "${_LOCAL_VAR_githubreleasesearch}" ]; then
        githubreleaseassets=$(curl -s "${_LOCAL_VAR_githublatestreleaseurl}" | jq '[ .assets[] ]')
    else
        githubreleaseassets=$(curl -s "${_LOCAL_VAR_githublatestreleaseurl}" | jq "[ .assets[]|select(.browser_download_url | contains(\"${_LOCAL_VAR_githubreleasesearch}\")) ]")
    fi

    # Check how many releases we got from the api and exit if we have more than one.
    if [ "$(echo "${githubreleaseassets}" | jq '. | length')" -gt 1 ]; then
        fn_print_fatal_nl "Found more than one release to download - Please report this to the LinuxGSM issue tracker"
        fn_script_log_fatal "Found more than one release to download - Please report this to the LinuxGSM issue tracker"
    else
        # Set variables for download via fn_fetch_file.
        githubreleasefilename=$(echo "${githubreleaseassets}" | jq -r '.[]name')
        githubreleasedownloadlink=$(echo "${githubreleaseassets}" | jq -r '.[]browser_download_url')

        # Error if no version is there.
        if [ -z "${githubreleasefilename}" ]; then
            fn_print_fail_nl "Cannot get version from GitHub API for ${_LOCAL_VAR_githubreleaseuser}/${_LOCAL_VAR_githubreleaserepo}"
            fn_script_log_fatal "Cannot get version from GitHub API for ${_LOCAL_VAR_githubreleaseuser}/${_LOCAL_VAR_githubreleaserepo}"
        else
            # Fetch file from the remote location from the existing module to the ${fbsdgsm_compat_tmpdir} for now.
            fn_fetch_file "${githubreleasedownloadlink}" "" "${githubreleasefilename}" "" "${_LOCAL_VAR_githubreleasedownloadpath}" "${githubreleasefilename}"
        fi
    fi
}

