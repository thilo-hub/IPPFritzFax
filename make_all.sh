#/bin/sh

#Check my requirements
./check_requirements.sh

#Checkout everything

make || exit 99
# too much.... make install


cat <<EOM
##################################################
#to start server....
mkdir spool crt
faxserver/sbin/ippserver -C faxserver  -K crt -d spool -vvv  --no-dns-sd 
###################################################

EOM

