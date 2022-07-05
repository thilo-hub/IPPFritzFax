#!/bin/sh
test -d /tmp/spool || mkdir /tmp/spool
test -d /tmp/crt || mkdir /tmp/crt
echo $PATH
echo $LD_LIBRARY_PATH
cd /IPPFritzFax
#set -vx
for i in "$@"; do
 set X $(echo $i | sed 's,=, ,')
 shift;
 case $1 in
   -pass*) echo password=$2;;
   -tel*)  echo telFrom=$2;;
   -user*) echo user=$2;;
   -url*)  echo url=$2;;
   *) echo "Unown argument '$1'" >&2;
	exit 99;
	;;
 esac
done >~/.credentials
dbus-daemon --system
avahi-daemon -D
avahi-dnsconfd -D

ippserver -C faxserver -K crt -d spool -r _universal

