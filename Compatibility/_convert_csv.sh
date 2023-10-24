#!/bin/sh

#DEBUG
. ./DEBUG/DEBUG.sh

# LinuxGSM uses bash but freebsd doesnt support bash (by default).
# bash supports arrays/csv while sh does not but sh does support another type
# of "array" which is space-separated strings, which is the function of this script

# Grab the latest copy of whatever file for local conversion
. ./Compatibility/_update_source_data.sh

## FREEBSD VERIFIED
convert_csv_to_ssv() {
  if [ $# -ne 1 ]; then
    echo "usage: convert_csv_to_ssv <input_csv_file>"
    return 1
  fi
  # all lgsm data should be in lgsm/data so this script withh default to that
  input_csv="$1"
  project_root=$(cd "$(dirname "$0")"; pwd -P) # Corrected project root path
  # all data which is converted for compatibility should be in fbsdgsm/data
  output_directory="$project_root/fbsdgsm/data"
  mkdir -p "$output_directory"
  output_ssv="$output_directory/$(basename "$input_csv" .csv).ssv"
  if [ ! -f "$input_csv" ]; then
    echo "error: specified CSV file does not exist."
    echo "attempting to download the latest version from LinuxGSM."
    #_grab_latest_required_files "$input_csv"
    echo "file downloading is currently unsupported"
    if [ $? -ne 0 ]; then
      echo "fail"
      return 1
    fi
  fi
	awk -F, '{
		for (i=1; i<=NF; i++) {
			gsub(/ /, "-", $i);
		}
		$1=$1;
		sub(/[ ]+$/, "", $0);  # This line removes any trailing spaces
		print
	}' OFS=" " "$input_csv" > "$output_ssv"
  if [ $? -ne 0 ]; then
    echo "Error converting CSV to SSV."
    return 1
  fi
  echo "CSV file '$input_csv' converted to SSV and saved as '$output_ssv'."
}
