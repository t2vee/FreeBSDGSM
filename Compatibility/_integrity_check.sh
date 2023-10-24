#!/bin/sh

_check_sha() {
	local_filedir="${1}"
	local_filename="${2}"
	local_checksum=$(shasum -a 256 "${local_filedir}/${local_filename}" | cut -d ' ' -f 1)
	remote_signature=$(curl -s "https://shacheck.freebsdgsm.org/${local_filedir}/${local_filename}.sha256")
	if [ -z "$remote_signature" ]; then
		echo "failed to get a remote signature. is shacheck.freebsdgsm.org down?"
		exit 1
	fi
	if [ "$local_checksum" != "$remote_signature" ]; then
		echo "fatal: integrity check failed."
		exit 1
	else
		echo "integrity check pass for ${local_filename}"
	fi
}
