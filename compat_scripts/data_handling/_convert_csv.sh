#!/bin/sh

# LinuxGSM uses bash but freebsd doesnt support bash (by default).
# bash supports arrays/csv while sh does not but sh does support another type
# of "array" which is space-separated strings, which is the function of this script

# Grab the latest copy of whatever file for local conversion
. ./_update_source_data.sh

## FREEBSD VERIFIED
convert_csv_to_ssv() {
  if [ $# -ne 1 ]; then
    echo "usage: convert_csv_to_ssv <input_csv_file>"
    return 1
  fi
  input_csv="$1"
  project_root="$(dirname $(dirname $(readlink -f $0)))"
  output_directory="$project_root/compat_data/ssv"
  mkdir -p "$output_directory"
  output_ssv="$output_directory/$(basename "$input_csv" .csv).ssv"
  if [ ! -f "$input_csv" ]; then
    echo "error: specified CSV file does not exist."
    echo "attempting to download the latest version from LinuxGSM."
    _grab_latest_required_files "$input_csv"
    if [ $? -ne 0 ]; then
      echo "fail"
      return 1
    fi
  fi
  awk 'BEGIN { OFS=" " } { print $0 }' "$input_csv" > "$output_ssv"
  echo "CSV file '$input_csv' converted to SSV and saved as '$output_ssv'."
}
