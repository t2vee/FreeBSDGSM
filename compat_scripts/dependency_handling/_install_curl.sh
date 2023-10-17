#!/bin/sh

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
