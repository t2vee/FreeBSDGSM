# Temporary sh Debugger
DEBUG="false"

debug() {
	var="$1"
	echo "=======DEBUG STATEMENT FOR $var ==============="
}
debug_echo() {
	var="$1"
	echo "$var"
}

# Debugging
if [ -f ".dev-debug" ] || [ "${DEBUG}" = "true" ]; then
	## Causes all output to disappear
	#exec 3>&1 4>&2
	#trap 'exec 2>&4 1>&3' 0 1 2 3
	#exec 1>debug.log 2>&1
	set -x
fi

debug_v1() {
    [ "$DEBUG" = "true" ] && echo "DEBUG: $*"
}
