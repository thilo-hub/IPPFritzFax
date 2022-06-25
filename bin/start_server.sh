#!/bin/sh

OS=$(uname)

# Register printer service mdsn
CONFIG="dns.config"

case $OS in
	*)
		perl bin/start_dns_registration.pl $CONFIG avahi-publish &
		DS=$!
		trap "kill $DS" 0 1 2 3 4 5 6
		;;

	darwin)
		perl bin/start_dns_registration.pl $CONFIG dns-sd &
		DS=$!
		trap "kill $DS" 0 1 2 3 4 5 6

		;;
esac;

# Start fax-server
PATH=$PWD/bin:$PWD/faxserver/bin:$PATH 
test -d spool || mkdir spool
test -d crt || mkdir crt
PORT=$(grep Port= "$CONFIG" | sed 's/^.*=//')
sed -i .bak "/Listen/ s/:.*/:$PORT/" faxserver/system.conf
ippserver -C faxserver -K crt -d spool --no-dns-sd 

