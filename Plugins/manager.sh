#!/bin/sh

plugin_manager() {
    while :; do
		clear
        echo "Plugin Management"
        echo "================="
        echo "1) List Installed Plugins"
        echo "2) Enable a Plugin"
        echo "3) Disable a Plugin"
        echo "4) Uninstall a Plugin"
        echo "5) Install a Plugin from the Marketplace"
        echo "0) Exit"
        echo "-----------------"
        printf "Select an option: "
        read -r option

        case "$option" in
            1) list_plugins_menu ;;
            2) enable_plugin_menu ;;
            3) disable_plugin_menu ;;
            4) uninstall_plugin_menu ;;
            5) install_plugin_menu ;;
            0) break ;;
            *) echo "Invalid option, please try again." ;;
        esac
    done
}

is_plugin_enabled() {
    grep -q "^$1\$" ./Plugins/enabled.ssv
}

is_plugin_valid() {
    [ -f "$1/manifest.fp" ] && [ -f "$1/hook.sh" ]
}

list_plugins_menu() {
	clear
    plugin_dir="./Plugins/Installed"

    if [ ! -d "$plugin_dir" ]; then
        echo "Plugin directory not found!"
        return 1
    fi

    echo "List of Installed Plugins"
    echo "========================="
    for subdir in "$plugin_dir"/*; do
        if [ -d "$subdir" ]; then
            plugin_name=$(basename "$subdir")
            echo "Plugin: $plugin_name"
            if is_plugin_enabled "$plugin_name"; then
                echo "  - Status: Enabled"
            else
                echo "  - Status: Disabled"
            fi
            if is_plugin_valid "$subdir"; then
                echo "  - Validity: Valid"
            else
                echo "  - Validity: Invalid"
            fi

            echo "-------------------------"
        fi
    done
	echo ""
    echo "0) Back to Main Menu"
    printf "Select a Option: "
    read -r option
    case "$option" in
        0) ;;
        *) echo "Invalid option, going back to main menu." ;;
    esac
}

enable_plugin() {
    echo "$1" >> ./Plugins/enabled.ssv
}

enable_plugin_menu() {
    clear
    plugin_dir="./Plugins/Installed"
    options=""
    index=1

    if [ ! -d "$plugin_dir" ]; then
        echo "Plugin directory not found!"
        return 1
    fi

    echo "Enable a Plugin"
    echo "==============="
    for subdir in "$plugin_dir"/*; do
        if [ -d "$subdir" ] && is_plugin_valid "$subdir"; then
            plugin_name=$(basename "$subdir")
            options="$options $plugin_name"
            echo "$index) $plugin_name"
            index=$((index + 1))
        fi
    done
    echo ""
	echo "-------------------------"
    echo "0) Back to Main Menu"
    printf "Select a plugin to enable: "
    read -r selected_option

    if [ "$selected_option" -eq 0 ]; then
        return
    fi

    index=1
    for option in $options; do
        if [ "$index" -eq "$selected_option" ]; then
            enable_plugin "$option"
            echo "Enabled plugin: $option"
            return
        fi
        index=$((index + 1))
    done

    echo "Invalid option, going back to main menu."
}

disable_plugin() {
    grep -v "^$1$" ./Plugins/enabled.ssv > ./Plugins/enabled.ssv.tmp
    mv ./Plugins/enabled.ssv.tmp ./Plugins/enabled.ssv
}

disable_plugin_menu() {
    clear  # Clear the screen
    if [ ! -f "./Plugins/enabled.ssv" ]; then
        echo "No enabled plugins file found!"
        return 1
    fi

    echo "Disable a Plugin"
    echo "==============="
    options=""
    index=1

    # Read enabled plugins from the ssv file
    while read -r plugin; do
        options="$options $plugin"
        echo "$index) $plugin"
        index=$((index + 1))
    done < ./Plugins/enabled.ssv

	echo ""
	echo "-------------------------"
    echo "0) Back to Main Menu"
    printf "Select a plugin to disable: "
    read -r selected_option

    if [ "$selected_option" -eq 0 ]; then
        return
    fi

    index=1
    for option in $options; do
        if [ "$index" -eq "$selected_option" ]; then
            disable_plugin "$option"
            echo "Disabled plugin: $option"
            return
        fi
        index=$((index + 1))
    done

    echo "Invalid option, going back to main menu."
}

uninstall_plugin() {
    pkg remove -y "freebsdgsm-$1-plugin"
    disable_plugin "$1"
}

uninstall_plugin_menu() {
    clear
    plugin_dir="./Plugins/Installed"
    options=""
    index=1

    if [ ! -d "$plugin_dir" ]; then
        echo "Plugin directory not found!"
        return 1
    fi

    echo "Uninstall a Plugin"
    echo "=================="
    for subdir in "$plugin_dir"/*; do
        if [ -d "$subdir" ]; then
            plugin_name=$(basename "$subdir")
            if pkg info "freebsdgsm-$plugin_name-plugin" > /dev/null 2>&1; then
                options="$options $plugin_name"
                echo "$index) $plugin_name"
                index=$((index + 1))
            fi
        fi
    done

	echo ""
	echo "-------------------------"
    echo "0) Back to Main Menu"
    printf "Select a plugin to uninstall: "
    read -r selected_option

    if [ "$selected_option" -eq 0 ]; then
        return
    fi

    index=1
    for option in $options; do
        if [ "$index" -eq "$selected_option" ]; then
            printf "Are you sure you want to uninstall the plugin %s? [y/N]: " "$option"
            read -r confirmation
            case $confirmation in
                [Yy]* )
                    uninstall_plugin "$option"
                    echo "Uninstalled plugin: $option"
                    ;;
                * )
                    echo "Uninstallation cancelled."
                    ;;
            esac
            return
        fi
        index=$((index + 1))
    done

    echo "Invalid option, going back to main menu."
}


install_plugin_menu() {
    pass
}
