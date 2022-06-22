#!/usr/local/bin/perl -w
use Data::Dumper;
use MIME::Base64;
use File::Slurp;
use IPC::Open2;
use File::Basename;

use lib dirname($0)."/lib";
use Imageconv;
use FritzBox;


my $p={};

my $cred=load_credentials();

#Hack because fritzbox does not have a good certificate and I want to use TLS
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
#

#Handle IPP commend call
if ($ENV{IPP_JOB_ID}) {
	die "Missing destination telephone in environment" 

#export IPP_DESTINATION_URIS='{destination-uri=tel:0531-49059113 pre-dial-string=+49531}'
	unless  ($ENV{IPP_DESTINATION_URIS} =~ /destination-uri=tel:(\S+)(?:\s+pre-dial-string=(\S+))?\s*}/);
	my $tel=$2.$1;
	$tel =~ s/[- ]//g;
	# We are an IPP client do what it takes
	die "Credentials must provide source tel number" unless $cred->{telFrom};
	# Fix arguments 
	unshift @ARGV,$cred->{telFrom},$tel;
	# Flag different op mode
	$p->{ipp}=1;
}

exit if defined $ENV{DONTSEND};
  

$p->{NumSrc} = shift @ARGV;
$p->{NumDst} = shift @ARGV;

my $fb=FritzBox->login( $cred );
undef $cred;  # remove passwords 
print "url=$fb->{url}\nsid=$fb->{sid}\n";

$status = $fb->wait_faxready();

my @pages=();
foreach(@ARGV) {
	# get all files 
	$p->{File}   = shift @ARGV;


	die "No file $p->{File}" unless -r $p->{File};

	my $content = read_file($p->{File});
	push @pages,Imageconv::any2g3(\$content);

}
#Make complete sfff from all pages
my $content = Imageconv::g3toSfff(@pages);
# open(DEBUG,">bad.sff"); print DEBUG $content; exit 0;
$content = encode_base64($content);
print "Sending ".scalar(@pages)." pages to $p->{NumDst}\n";
$fb->send_fax($p->{NumSrc},$p->{NumDst},$content);
$status = $fb->wait_faxready( sub {

	my $s = shift;
	my $npages=scalar(@pages);
	my $cur_page = $npages * $s->{progress} / 100;


	printf STDERR  "ATTR: job-impressions=%d job-impressions-completed=%d\n", $cur_page,$cur_page;
}
);

die "Error sewnding: $status" if $status;
exit;

# Get SID from fritzbox using the ".credentials" file
# WARNING this file contains the password
#
#Content:
#
#
#url=https://fritz.box
#password=YYYYYYY
#user=XXXXXX
sub load_credentials
{
	my $self;
	open(F,"<$ENV{HOME}/.credentials") or die "No credential file...";
	while(<F>) { 
		next if /^\s*#/; #ignore comments
		$self->{$1} = $2 if /^(\S+)=(\S+)/; 
	} 
	close(F);
	return $self;

}

#       ATTR: attribute=value[ attribute=value]
#            Sets the named attribute(s) to the given values.  Currently only
#            the "printer-alert" and "printer-alert-description" Printer Status
#            attributes can be set.
#
#       DEBUG: Debugging message
#            Logs a debugging message if at least two -v's have been specified.
#
#       ERROR: Error message
#            Logs an error message and copies the message to the "job-state-
#            message" attribute.
#
#       INFO: Informational message
#            Logs an informational/progress message if -v has been specified
#            and copies the message to the "job-state-message" attribute unless
#            an error has been reported.
#
#       STATE: keyword[,keyword,...]
#            Sets the printer's "printer-state-reasons" attribute to the listed
#            keywords.
#
#       STATE: -keyword[,keyword,...]
#            Removes the listed keywords from the printer's "printer-state-
#            reasons" attribute.
#
#       STATE: +keyword[,keyword,...]
#            Adds the listed keywords to the printer's "printer-state-reasons"
#            attribute.
