#!/usr/local/bin/perl 
#
print pack( "H*",
	"536666660100616b00001c0000000000000000002863292041564d20"
	);
foreach(@ARGV) {
	open(F,"<",$_);
	local $/;
	my $in = <F>;
	close(F);
	print pack( "H*",
		"fe1001000000c00600000100000000000000"
	);
	$in = unpack( "b*", $in );
	$in =~ s/^0+1//;
	foreach ( split( /000000000001/, $in ) ) {
	    $o = pack( "b*", $_ );
	    $l = length($o);
	    $l =
	      ( $l > 216 )
	      ? pack( "CvA*", 0, $l, $o )
	      : pack( "CA*", $l, $o );
	    $oh = unpack( "H*", $o );
	    print $l;
	}
};
print pack("CC",254,0);
