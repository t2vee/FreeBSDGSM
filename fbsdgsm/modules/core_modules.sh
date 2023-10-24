#!/bin/sh
# FreeBSDGSM core_modules.sh module
# Description: Defines all modules to allow download and execution of modules using fn_fetch_module.
# This module is called first before any other module. Without this file other modules will not load.

abs_path() {
    case "$1" in
        /*) printf "%s\n" "$1";;
        *)  printf "%s\n" "$PWD/$1";;
    esac
}

moduleselfname="$(basename "$(abs_path "$0")")"

modulesversion="v23.5.3"

# Core

## Core Module Install Function
i() {
	module_request="${1}"
	if [ "${module_request}" = "core_dl.sh" ]; then
		core_dl_sh
	fi
	if [ "${module_request}" = "core_messages.sh" ]; then
		core_messages_sh
	fi
	if [ "${module_request}" = "core_legacy.sh" ]; then
		core_legacy_sh
	fi
	if [ -f "${fbsdgsm_compat_modulesdir}/${module_request}" ]; then
		. "${fbsdgsm_compat_modulesdir}/${module_request}"
	else
		modulefile="${module_request}"
		fn_fetch_module
	fi
}


### //TODO Module Downloads need to be verified
core_dl_sh() {
	modulefile="core_dl.sh"
	if type fn_fetch_core_dl >/dev/null 2>&1; then
		fn_fetch_core_dl "fbsdgsm/modules" "core_dl.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "fbsdgsm/modules" "core_dl.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_messages_sh() {
	modulefile="core_messages.sh"
	if type fn_fetch_core_dl >/dev/null 2>&1; then
		fn_fetch_core_dl "fbsdgsm/modules" "core_messages.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "fbsdgsm/modules" "core_messages.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_legacy_sh() {
	modulefile="core_legacy.sh"
	if type fn_fetch_core_dl >/dev/null 2>&1; then
		fn_fetch_core_dl "fbsdgsm/modules" "core_legacy.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "fbsdgsm/modules" "core_legacy.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

# Calls code required for legacy servers
## FBSDGSM will not support older versions
#i core_legacy.sh

# Creates tmp dir if missing
if [ ! -d "${fbsdgsm_compat_tmpdir}" ]; then
	mkdir -p "${fbsdgsm_compat_tmpdir}"
fi

# Creates lock dir if missing
if [ ! -d "${fbsdgsm_compat_lockdir}" ]; then
	mkdir -p "${fbsdgsm_compat_lockdir}"
fi

# if $USER id missing set to whoami
if [ -z "${USER}" ]; then
	USER="$(whoami)"
fi

# Calls on-screen messages (bootstrap)
i core_messages.sh

#Calls file downloader (bootstrap)
i core_dl.sh

# Calls the global Ctrl-C trap
i core_trap.sh

### For now FBSDGSM will download all modules regardless.
module_list="info_stats.sh command_check_update.sh fix_vh.sh query_gamedig.sh command_validate.sh command_mods_remove.sh alert_pushover.sh command_sponsor.sh check_root.sh fix_ut3.sh fix_onset.sh command_restart.sh info_game.sh update_fctr.sh command_backup.sh fix_st.sh fix_arma3.sh command_install_resources_mta.sh fix_cmw.sh fix_ark.sh install_header.sh check_logs.sh query_gsquery.py fix_tf2.sh command_dev_details.sh fix_wurm.sh fix_kf2.sh check_status.sh install_server_files.sh fix_kf.sh install_mta_resources.sh update_ut99.sh mods_list.sh check_glibc.sh fix_av.sh fix_rw.sh fix_bt.sh fix_terraria.sh check_tmuxception.sh install_dst_token.sh command_dev_detect_deps.sh install_ut2k4_key.sh fix_mcb.sh check_system_dir.sh core_logs.sh command_skeleton.sh install_steamcmd.sh core_functions.sh command_update_linuxgsm.sh command_update.sh install_factorio_save.sh command_ts3_server_pass.sh fix_bo.sh command_send.sh fix_lo.sh update_steamcmd.sh command_dev_clear_modules.sh fix_ins.sh fix_sfc.sh fix_csgo.sh alert_discord.sh check_version.sh command_fastdl.sh install_complete.sh alert_telegram.sh check_system_requirements.sh install_squad_license.sh command_dev_debug.sh fix_rust.sh update_mta.sh fix_unt.sh install_config.sh core_github.sh install_stats.sh fix_squad.sh check_config.sh fix_armar.sh alert_mailgun.sh alert.sh check_ip.sh update_mcb.sh alert_pushbullet.sh install_logs.sh command_test_alert.sh command_debug.sh fix_nmrih.sh fix.sh fix_steamcmd.sh compress_ut99_maps.sh info_messages.sh command_mods_update.sh command_details.sh fix_ts3.sh update_jk2.sh alert_gotify.sh update_mc.sh alert_email.sh fix_ro.sh check_steamcmd.sh command_dev_query_raw.sh command_dev_detect_ldd.sh fix_ut.sh fix_samp.sh fix_zmr.sh command_monitor.sh check_last_update.sh install_retry.sh core_exit.sh command_wipe.sh command_mods_install.sh install_server_dir.sh fix_pvr.sh compress_unreal2_maps.sh fix_ut2k4.sh update_ts3.sh mods_core.sh fix_mta.sh command_postdetails.sh check_deps.sh command_dev_detect_glibc.sh info_distro.sh install_eula.sh command_console.sh fix_dst.sh update_vints.sh install_ts3db.sh core_steamcmd.sh update_pmc.sh check.sh command_start.sh fix_sof2.sh alert_ifttt.sh command_stop.sh check_permissions.sh core_getopt.sh check_executable.sh install_gslt.sh alert_rocketchat.sh command_install.sh fix_sdtd.sh alert_slack.sh core_legacy.sh fix_hw.sh"
modules_install() {
    for module in ${module_list}
    do
        i "$module"
    done
}
modules_install
