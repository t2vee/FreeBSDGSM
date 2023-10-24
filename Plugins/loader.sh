#!/bin/sh


plugin_loader() {
    plugin_dir="./Plugins/Installed"
    ssv_file="./enabled.ssv"

    if [ ! -d "$plugin_dir" ]; then
        echo "Plugin directory not found!"
        return 1
    fi

    # check if a plugin is in enabled.ssv
    is_plugin_enabled() {
        grep -q "^$1\$" "$ssv_file"
    }

    # add a plugin to enabled.ssv
    enable_plugin() {
        echo "$1" >> "$ssv_file"
    }

    # check if the plugin is valid
    is_plugin_valid() {
        [ -f "$1/manifest.fp" ] && [ -f "$1/hook.sh" ]
    }

    for subdir in "$plugin_dir"/*; do
        if [ -d "$subdir" ] && is_plugin_valid "$subdir" && is_plugin_enabled "$subdir"; then
            echo "Found valid plugin at: $subdir"
            if [ "$1" -eq 1 ]; then
                printf "Do you want to load the plugin from %s? [y/N]: " "$subdir"
                read answer
                case $answer in
                    [Yy]* )
                        echo "Attempting Load..."
                        . "$subdir/hook.sh"
                        if [ $? -eq 0 ]; then
                            enable_plugin "$subdir"
                        else
                            echo "Plugin integrity check failed for $subdir. Skipping."
                            continue
                        fi
                        ;;
                    * )
                        echo "Skipping plugin at ${subdir}"
                        ;;
                esac
            else
                . "$subdir/hook.sh"
                if [ $? -ne 0 ]; then
                    echo "Plugin integrity check failed for $subdir. Skipping."
                    continue
                fi
                enable_plugin "$subdir"
            fi
        else
            echo "Invalid or not enabled plugin at: $subdir"
        fi
    done
}
