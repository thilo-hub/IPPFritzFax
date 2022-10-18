package Imageconv;;
use IPC::Open2;
use File::Temp qw/ tempfile tempdir /;

#
# Use any converter in this module
sub any2g3 
{
	my $content = shift;
	my $hdr = unpack("A4",$$content);

	return  urf2g3($content)      if unpack("A7",$$content)  eq "UNIRAST";
	return  pdf2g3($content)      if $hdr eq "%PDF";
	return  png2g3($content)      if $hdr eq "\x89PNG";

	die "Failed format ($hdr)";
}

# pdf -> g3
#
sub urf2g3
{
	my $content = shift;
	# convert the pdf to sff 
	#
	# ./pdftosff.sh "$IN" "$SFF".bin ;
	my $dir = tempdir( CLEANUP => 1 );
	open(PDF,"|-",qw{urftopgm -},$dir."/pages-%04d.pgm");
	print PDF $$content;
	close(PDF);
	my @pages=glob("$dir/pages*");
	foreach(@pages) {
		$_ = pgm2g3($_);
	}
	return @pages;
}
sub pdf2g3
{
	my $content = shift;
	# convert the pdf to sff 
	#
	# ./pdftosff.sh "$IN" "$SFF".bin ;
	my $dir = tempdir( CLEANUP => 1 );
	open(PDF,"|-",qw{pdftocairo -png -scale-to-x 1728 -scale-to-y 2443 -mono -},$dir."/pages");
	print PDF $$content;
	close(PDF);
	my @pages=glob("$dir/pages*");
	foreach(@pages) {
		$_ = png2g3($_);
	}
	return @pages;
}

# png -> g3
#

sub pgm2g3 
{
	my $file=shift;
	my $chld_out;

	if (ref($file) eq "SCALAR" ){
		open2($chld_out,my $chld_in,"pamditherbw | pamtopnm | pbmtog3 -align8 -reversebits");
		print $chld_in $$file;
		close($chld_in);
	} else {
		open($chld_out, '-|' ,"pamditherbw '$file' | pamtopnm | pbmtog3 -align8 -reversebits");
		# open($chld_out, '-|' ,"pngtopam '$file' | pbmtog3 -align8 -reversebits");
	}
	local $/;
	my $g3=<$chld_out>;
	close $chld_out;
	waitpid( 0,0);
	return $g3;
}

sub png2g3 
{
	my $file=shift;
	my $chld_out;

	if (ref($file) eq "SCALAR" ){
		open2($chld_out,my $chld_in,"convert - PBM:-  | pbmtog3 -align8 -reversebits");
		# open2($chld_out,my $chld_in,"pngtopam | pbmtog3 -align8 -reversebits");
		print $chld_in $$file;
		close($chld_in);
	} else {
		open($chld_out, '-|' ,"convert '$file' PBM: | pbmtog3 -align8 -reversebits");
		# open($chld_out, '-|' ,"pngtopam '$file' | pbmtog3 -align8 -reversebits");
	}
	local $/;
	my $g3=<$chld_out>;
	close $chld_out;
	waitpid( 0,0);
	return $g3;
}


# Sfff related 

my $documentHeader = pack( "A4CCvvvVV", "Sfff",1,0,0,0,0x14,0,0);
	#	"53666666 01 00 616b 0000 1c00 00000000 00000000 2863292041564d20");
	# SFF_Id	DWord	Magic number (identification) of SFF Format: coded as 0x66666653 ("Sfff").
	# Version	Byte	Version number of SFF document: coded 0x01.
	# reserved	Byte	Reserved for future extensions; coded 0x00.
	# User Information	Word	Manufacturer-specific user information (not used by COMMON-ISDN-API, coded as 0x0000).
	# Page Count	Word	Number of pages in the document. Must be coded 0x0000 if not known (as in the case of receiving a document).
	# OffsetFirstPageHeader	Word	Byte offset of first page header from start of document header. This value is normally equal to the size of the document header (0x14), but there could be additional userspecific data between the document header and the first page header. COMMON-ISDN-API ignores and does not provide such additional data.
	# OffsetLastPageHeader	DWord	Byte offset of last page header from start of document header. Must be coded 0x00000000 if not known (as in the case of receiving a document).
	# OffsetDocumentEnd	DWord	Byt
	#
my $documentTrailer = pack("CC",254,0);
my $pageHeader = pack("CCCCCCvv", 254, 0x10,  1, 0,0,0,1728, 0);
	
# $out .=  pack( "H*", "fe 10 01 00 00 00c00600000100000000000000");
# PageHeaderID	Byte	254 (Page data record type)
# PageHeaderLen	Byte	0: Document end
# 1...255: byte offset of first page data from the Resolution Vertical field of the page header. This value is normally equal to the size of the remainder of the header (0x10), but there may be additional user-specific data between page header and page data. COMMON-ISDN-API ignores and not provide such additional data.
# Resolution Vertical	Byte	Definition of vertical resolution; different resolutions in one document may be ignored by COMMON-ISDN-API
# 0: 98 lpi (standard)
# 1: 196 lpi (high resolution)
# 2...254: reserved
# 255: End of document (should not be used: PageHeaderLen should be coded 0 instead)
# Resolution Horizontal	Byte	Definition of horizontal resolution
# 0: 203 dpi (standard)
# 1...255: reserved
# Coding	Byte	Definition of pixel line coding
# 0: Modified Huffman coding
# 1...255: reserved
# reserved	Byte	Coded as 0
# Line Length	Word	Number of pixels per line
# 1728: Standard G3 fax
# 2048: B4 (optional)
# 2432: A3 (optional)
# Support for additional values is optional for COMMON-ISDN-API.
# Page Length	Word	Number of pixel lines per page. If not known, coded as 0x0000.
# OffsetPreviousPage	DWord	Byte offset to previous page header or 0x00000000. Coded as 0x00000001 if first page.
# OffsetNextPage	DWord	Byte offset to next page header or 0x00000000. Coded as 0x00000001 if last page.
#

# convert a g3 formated list of pages
# into a single sfff formatted file
# See https://netpbm.sourceforge.net/doc/faxformat.html 
# https://faxauthority.com/glossary/group-4-compression/
# 
sub g3toSfff
{
	# Document header
	#
	my $out=$documentHeader;
	# my $ctr="001";
	my $first_page=1;
	# See: http://delphi.pjh2.de/articles/graphic/sff_format.php  for details
	foreach(@_) {
		# The Sfff header ned
		my $last_page = scalar(@_)==1 ? 1 : 0;
		#make Document header
		my $pinfo = pack("VV",$first_page,$last_page);
		$first_page = 0;
		# Add static documentheader and dynamic end of page info
		$out .= $pageHeader.$pinfo;

		#Take each line and convert into an ascii-binary 
		my $in = unpack( "b*", $_ );
		#Drop leading EOL marker which might have more zeros essentialy find the start bit
		$in =~ s/^0+1//;
		# itterate for each line ( EOL token ) ( it is maybe just easier to modify ascii than binary in perl )
		foreach ( split( /000000000001/, $in ) ) {
		    # Convert ascii back to binary
		    $o = pack( "b*", $_ );
		    $l = length($o);
		    # Extract length bytes and append the page-content to $out
		    # https://faxauthority.com/glossary/group-4-compression/
		    # 
		    $l =
		      ( $l > 216 )
		      ? pack( "CvA*", 0, $l, $o )
		      : pack( "CA*", $l, $o );
		    $out .=  $l;
		}
	};
	# and Document trailer
	$out .=  $documentTrailer;

	return $out;
}
1;
