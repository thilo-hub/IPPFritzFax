#!/bin/sh
#Convert PDF file into a sff (structured fax file)
#Usage  $0 {IN} {OUT}
PDF="$1"
OUT="$2"
test -r "$OUT" && echo "Error: File exists ($OUT)" &&  exit 99

PATH=$(dirname "$0"):$PATH
TMP="$(mktemp -d)";
trap "rm -rf $TMP" 0 1 2 3
pdftocairo  "$PDF" -png   -scale-to-x 1728 -scale-to-y 2443 -mono  $TMP/pages
#pdftocairo  "$PDF" -png   -scale-to-x 1728 -mono  $TMP/pages
for pagepng in $TMP/pages-*.png; do
	pngtopam $pagepng |  pbmtog3 -align8 -reversebits >$pagepng.g3
done
convert_g32sff.pl $TMP/pages-*.png.g3 >"$OUT"

