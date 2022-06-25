#!/usr/local/bin/perl -w

#make arguments from config for either dns-sd or avahi

use Net::Domain qw(hostname hostfqdn hostdomain); 
use Socket;

# defaults
my $arg;
$arg->{Domain} = hostdomain();
$arg->{Port} = 631;
$arg->{Host} = hostname();
$arg->{Services}="_ipp._tcp,_universal";
$arg->{Domain} = "local";  # dns-sd cannot register elsewhere


open(F,shift @ARGV) or die "No config";
while(<F>) {
  s/#.*//;
#WARNING you can only use %xxx AFTER the definition ...
   s/%h/$arg->{Host}/g;
   s/%p/$arg->{Port}/g;
   s/%d/$arg->{Domain}/g;
  $arg->{$1} = $2 if (/^(\S+)="?([^"\n]*)"?\s*$/);
  push @{$arg->{TXT}},"$1=$2" if (/^TXT_(\S+)="?([^"]*)"?\s*$/);
}
close(F);

unless ($arg->{IP})
{
	my $packed_ip = gethostbyname(hostname);
	if (defined $packed_ip) {
		$arg->{IP} = inet_ntoa($packed_ip);
	}
} 


my $header=<<EOH;
<?xml version="1.0"?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
    <name replace-wildcards="yes">$arg->{PrinterName}</name>
    <service>
        <type>_ipp._tcp</type>
	<subtype>_universal._sub._ipp._tcp</subtype>
	<port>$arg->{Port}</port>
	<host-name>$arg->{Host}.$arg->{Domain}.</host-name>
	<txt-record/>
    </service>
</service-group>
EOH


# Proxy 
# @ARGS=("-P", $arg->{PrinterName}, $arg->{Services}, $arg->{Domain}, $arg->{Port}, $arg->{Host}.".".$arg->{Domain}, $arg->{IP});
# Register local service
@ARGS   =("-R", $arg->{PrinterName}, $arg->{Services}, $arg->{Domain}, $arg->{Port},@{$arg->{TXT}});

$arg->{Subtype}= "$2._sub.$1"   if $arg->{Services}  =~ s/(.*),(.*)/$1/; 

# Avahi....
@AV_ARGS=("-s", $arg->{PrinterName}, $arg->{Services}, "--subtype=$arg->{Subtype}", $arg->{Port},@{$arg->{TXT}});


push @ARGS,@{$arg->{TXT}};

if ($ARGV[0] eq "avahi-service" ) {
   $header =~ s|<txt-record/>|"<txt-record>".join("</txt-record><txt-record>",@{$arg->{TXT}})."</txt-record>"|e;
   print STDOUT $header;
   close(STDOUT);
   system("avahi-daemon -r");
} elsif ($ARGV[0] eq "print") {
	print "'".join("' '",@ARGS)."'\n";
} elsif ($ARGV[0] eq "avahi-publish") {
	system("avahi-publish",@AV_ARGS);
} elsif ($ARGV[0] eq "dns-sd") {
	system("dns-sd",@ARGS);
} else {
 print STDERR "Usage:  $0  avahi-service [file] | print | dns-sd\n";
 exit 1;
}


