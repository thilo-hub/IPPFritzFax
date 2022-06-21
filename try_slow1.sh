#!/bin/sh

N=0
MSG="aborted-by-system compression-error document-access-error document-format-error document-password-error document-permission-error document-security-error document-unprintable-error errors-detected job-canceled-at-device job-canceled-by-user job-completed-successfully job-completed-with-errors job-completed-with-warnings job-data-insufficient job-fetchable job-hold-until-specified job-incoming job-password-wait job-printing job-queued job-spooling job-stopped job-transforming printer-stopped printer-stopped-partly processing-to-stop-point queued-in-device"
MSG="job-fetchable-report job-hold-until-specified-report job-incoming-report job-password-wait-report job-printing-report job-queued-report document-permission-error job-spooling-report job-transforming-report queued-in-device-report"



for i in $MSG ; do
	echo "STATE: -$STATE" >&2
	echo "STATE: +$i" >&2
	STATE=$i
	echo "STATE: $STATE" >/dev/tty
	sleep 3;
done
	
echo "STATE: +destination-uri-failed" >&2
exit 0;

for i in 7 6 5 4 3 2 1 ; do
	N=$(($N+1))
	echo "ATTR: job-impressions=$N job-impressions-completed=$N" >&2
	echo "ATTR: job-media-sheets=$N job-media-sheets-completed=$N" >&2
	echo "ATTR: printer-alert=pending" >&2
	sleep 5;

	echo "DEBUG: 1 Waiting... ($i)"
	echo "DEBUG: 2 Waiting... ($i)" >&2
	echo "DEBUG: T Waiting... ($i)" >/dev/tty
done

exit 0;
