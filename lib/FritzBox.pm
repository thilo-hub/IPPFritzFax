package FritzBox;
use JSON;
use HTTP::Request::Common;
use LWP::UserAgent;
use Digest::MD5 qw(md5_hex); 
use Encode qw(encode);  
use IPC::Open2;


sub wait_faxready
{
	my $self = shift;
	my $cb = shift;
	while( my $s=$self->faxstatus() ) {
		return $s->{reason} if $s->{status} == 1;
		my $m="";
		$m=" $s->{progress}%" if $s->{status} == 4;
		#"status":4,"status_text":"FAXSEND_CONNECTED","progress":29,"reason":0}
		&$cb($s) if $cb;
		print STDERR "STATE: Waiting ($s->{status_text})$m\n";
		#print "Waiting ($s->{status_text})$m\n";
		sleep(2);
	}
	die "Weird ... no response from Fritzbox..";
}


sub send_fax
{
	my $self = shift;
	my ($src,$dst,$content)=@_;
	my $url="$self->{url}/cgi-bin/firmwarecfg";
	#$url="https://localhost/cgi-bin/thilo/tst.cgi";
	my $req = POST  $url,
		  Content_Type => 'form-data',
		  Content      => [  
					sid=>$self->{sid},
					NumDest=>$dst,
					NumSrc=>$src,
					FaxUploadFile=> $content

				];
		
	my $ua = LWP::UserAgent->new;
	$ua->agent("MyApp/0.1 ");
	my $res = $ua->request($req);

	# open(DEBUG,">s.log"); print DEBUG Dumper($res->content); close(DEBUG);

	my $pid = open2(my $chld_out, my $chld_in,'html2text');
	my $msg;
	{ local $/;
	 print $chld_in $res->content;
	 close($chld_in);
	 $msg=<$chld_out>;
	 close($chld_out);
	 }
	$msg =~ s/^\s+//s;
	$msg =~ s/\s+$//s;
	die "$msg\nFailed sending fax" unless $res->content  =~ m|class="page_content">\s<p>(.*?)</p>|s;
	print "$msg\n";
	#exit;
}

# Return hash of status 
sub faxstatus
{
	my $self = shift;
	die "No sid" unless $self->{sid};
	my $ua = LWP::UserAgent->new;
	$ua->agent("MyApp/0.1 ");

	my $req = HTTP::Request->new(GET => "$self->{url}/fon_devices/fax_send.lua?sid=$self->{sid}&no_sidrenew=1&myXhr=1&query=refresh&useajax=1");
	my $res = $ua->request($req);
	die "Failed getting status from $self->{url}" unless ($res->is_success) ;
	my $status = decode_json($res->content);
	return $status;
}


sub login
{
    my $class  = shift;
    my $p= shift;

	die "No url" unless $p->{url};
	die "Bad credentials.." unless $p->{password} && $p->{user};

	my $ua = LWP::UserAgent->new;
	$ua->agent("MyApp/0.1 ");

	my $req = HTTP::Request->new(GET => "$p->{url}/login_sid.lua");
	my $res = $ua->request($req);
	die "Failed getting login challenge from $p->{url}" unless ($res->is_success) ;

	die $res->content . "\nno challenge in there" unless $res->content =~ m|Challenge>(.*?)</Challenge|s;
	$challenge = $1;

	$response  = "$challenge-".md5_hex(encode("UTF16-LE","$challenge-$p->{password}"));


	$req = HTTP::Request->new(GET => "$p->{url}/login_sid.lua?username=$p->{user}&response=$response");
	my $res1 = $ua->request($req);
	die "Failed getting login response from $p->{url}" unless ($res1->is_success) ;
	die "$res1\nNo SID found" unless $res1->content =~  m|<SID>(.*?)</SID>|s;

	my $sid = $1;
	die $res1->content ."\nWrong pass" if $sid =~ m/^0+$/;

	# All good...
	# remove them before loosing them....
	delete $p->{password};
	delete $p->{user};

	$p->{sid}=$sid;
	my $self = bless { %$p }, $class;
	return $self;

}

1;
