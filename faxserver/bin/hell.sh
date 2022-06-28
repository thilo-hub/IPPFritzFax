#!/bin/sh

PATH="$(dirname "$0"):$PATH"
if [ -z "TOOL" ]; then
	TOOL="FritzBoxFax.sh"
fi

TOOL="FritzBoxFax.sh"
# TOOL="./try_slow.sh"
# TOOL="./try_slow1.sh"
export TOOL
OF=/tmp/run_env.$$.sh
echo "Ouch $IPP_DESTINATION_URIS" >/dev/tty


(
echo "##############################################"
# Create a shell script that could be run instead
echo "#Args:"
/bin/echo -n "set "
for arg in foo "$@"; do
	/bin/echo -n " '$arg' "
done
echo 
echo "shift"

echo "#Env"
env | sort | grep -v "'" | sed "s/=/='/; s/\$/'/; s/^/export /"
echo "cd '$PWD'"

echo "#############"

echo exec "$TOOL" '"$@"'
# the real tihng if you want...
echo exit
)>>"$OF";

if [ -z "$DO_NOT_EXECUTE_TOOL" ]; then
	echo "Created and execute Simulation $OF"
	exec "$TOOL" "$@"
else
	echo "Created Simulation $OF"
	echo "File: $(/usr/bin/file --magic-file "$PWD/magic" "$1")"
fi >/dev/tty

exit 0
