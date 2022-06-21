#!/bin/sh
set -vx
PAGES=100
case "$IPP_DOCUMENT_FORMAT_SUPPLIED" in
	*/pdf) PAGES="$(pdfinfo "$1" 2>/dev/tty  | awk '/Pages:/{print $2}')" ;;
	*) echo "DEBUG: Strange type" $IPP_DOCUMENT_FORMAT_SUPPLIED >&2
		;;
esac


(
echo "STATE: job-state"
echo "STATE: +job-state-message"
for F in 10 20 30 40 50 60 70 80 90 100 ; do
  P=$(($PAGES *$F/100))
	sleep 2;
  echo "ATTR: job-impressions=$P job-impressions-completed=$P"
  echo "ATTR: job-state-message=Hello"
  echo "ERROR: what is going"
  # echo "ATTR: job-media-sheets=$P  job-media-sheets-completed=$P";
  #echo "ATTR: job-media-progress=$F";
  # echo "INFO: job-media-progress=$F";
  # #echo "STATE: connecting-to-device-report"
  # echo "ATTR: printer-state-message=testinf"
done
) | tee /dev/tty >&2

exit 0;
  
  
