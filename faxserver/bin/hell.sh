#!/bin/sh

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
echo -n "set "
for arg in foo "$@"; do
	echo -n " '$arg' "
done
echo 
echo "shift"

echo "#Env"
env | sort | grep -v "'" | sed "s/=/='/; s/\$/'/; s/^/export /"

echo "#############"

echo exec "$TOOL" '"$@"'
# the real tihng if you want...
echo exit
)>>"$OF";
echo "Created Simulation $OF" >/dev/tty
exec "$TOOL" "$@"  >/dev/tty

exit 0
