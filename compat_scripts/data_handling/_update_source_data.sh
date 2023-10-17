#!/bin/sh
# Downloads the latest copy of whatever specified file from the linuxgsm repo
# These files are required to be converted for freebsdgsm to use

## FREEBSD VERIFIED
_grab_latest_required_files() {
  if [ $# -ne 1 ]; then
    echo "usage: _grab_latest_required_files <filename>"
    return 1
  fi
  filename="$1"
  url="https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/$filename"
  if [ ! -f "$filename" ]; then
    echo "Downloading $filename..."
    if command -v curl > /dev/null; then
      curl -O "$url"
	fi
    if [ $? -ne 0 ]; then
      echo "Error: Failed to download $filename from $url."
      return 1
    fi
    echo "$filename downloaded successfully."
  else
    echo "$filename already exists. No need to download."
  fi
}
