#!/bin/sh


plugin_preflight() {
	echo "Beginning plugin checks"
	plugin_dir="./Plugins/Installed"
	ssv_file="./enabled.ssv"
	temp_ssv=$(mktemp)
	while IFS= read -r plugin; do
		if [ -d "$plugin" ] && [ -f "$plugin/hook.sh" ]; then
			echo "$plugin" >> "$temp_ssv"
		else
			echo "Plugin $plugin is no longer installed. Removing from enabled list."
		fi
	done < "$ssv_file"
	mv "$temp_ssv" "$ssv_file"
}
