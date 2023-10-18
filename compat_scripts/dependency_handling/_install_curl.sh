#!/bin/sh

## FREEBSD VERIFIED
_install_curl() {
  if [ "$(id -u)" -eq 0 ] || command -v pkg > /dev/null; then
    pkg_command="pkg"
  elif command -v doas > /dev/null; then
    pkg_command="doas pkg"
  else
    echo "No suitable installation method found."
    exit 1
  fi

  $pkg_command update
  $pkg_command upgrade -y
  $pkg_command install curl -y
}

_curl_command_handling() {
	_install_curl
	echo "curl should be installed now but will recheck to make sure"
	if [ ! "$(command -v curl 2> /dev/null)" ]; then
		echo "curl is still not installed. please install manually"
		echo "you can do so using 'pkg install curl' with the correct permissions"
	fi
	echo "curl installed successfully"
}
