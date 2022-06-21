# IPPFritzFax

Airprint &amp;IPP faxserver using  Fritzbox FAX modem


Fritzbox is a fairly common cable/dsl modem in Germany.

It usually has the capability to send faxes (using T38 or some other protocol).
Unfortunaty there is no free available software the enables printing faxes from apple devices on the fritzbox.
The built-in web server only allows you to send single pages as a fax...
All not very pleasant

This package solfves this problem.
It creates an IPP printer device which has a "sub-device" as the fax modem. It will show on the network as a FritBox Fax printer.


## Usage:

  "just" select the fax device and provide the phone number in the menu to send...


## Installation prerequisites:

A pc having avahi (probable any other dns-sd capable machine will do - not tested)

Configure the avahi service usinging the provided service script as a template

sh make_all.sh

Create the credentials file having the relevant information for the fritzbox available:


** $HOME/.credentials  **
```
url=https://......
user=.......
password=.......
telFrom=.......
```


Create spool and certificate directories and run:

mkdir spool crt 
faxserver/bin/ippserver -C faxserver -K crt -d spool --no-dns-sd 


==== Thats it ====


## Troubleshooting:

###  Printer not istalling

Mdns can be a beast

 check if your PC sees the printer info:
 MACOS:
  `dns-sd -B _ipp | grep FritzBox`
```
   17:32:52.876  Add        2  14 local.               _ipp._tcp.           AirPrint FritzBox FAX @ Comp 
```

 linux/*bsd/Avahi: 
 `avahi-browse -r _ipp._tcp -t | grep FritzBox`
```
   + epair0b IPv4 AirPrint FritzBox FAX @ Comp                  _ipp._tcp            local
   = epair0b IPv4 AirPrint FritzBox FAX @ Comp                  _ipp._tcp            local
   txt = ["txtvers=1" "qtotal=1" "rp=ipp/print/pdf" "rfo=ipp/faxout" "ty=Simulated" "adminurl=http://XXX:8632/" "kind=photo,envelope,document" "note=FritzBox6591" "priority=0" "product=(ThiloPrint)" "Color=T" "Duplex=T" "Staple=F" "Copies=T" "Collate=F" "Punch=0" "Bind=F" "Sort=F" "Scan=F" "Fax=T" "URF=W8,CP255,FN3-11-60,IS9,IFU0,MT1-5,OB10,PQ3-4-5,RS203-300,V1.4" "pdl=image/urf,image/jpeg" "UUID=84cf3cd1-0000-341c-6a4e-92d13edb77ff" "TLS=1.3"]
```



** Only if the complete mdns info is available, the mac auto installation will be fully working!!! **


During setup on MacOS, it might happen that the fax-device does not show as a second printer.  This is usually a mdns problem....

###   Fax not sending


To test the "fax-ing" from commandline, try:

`~/Printing/IPPFritzFax]# ./send_fax.pl 012345674 012345670 some-small-pdfile.pdf`  
```
url=https://192.168.66.1
sid=21fcd4e49c530cad
Sending 1 pages to 012345670
FRITZ!Box
***** FRITZ!Box Fax senden *****
Der Faxversand wurde erfolgreich gestartet.
Sie werden weitergeleitet. Bitte einen Moment Geduld.
ATTR: job-impressions=0 job-impressions-completed=0
STATE: Waiting (FAXSEND_CONNECTING)
ATTR: job-impressions=0 job-impressions-completed=0
STATE: Waiting (FAXSEND_CONNECTING)
ATTR: job-impressions=0 job-impressions-completed=0
STATE: Waiting (FAXSEND_CONNECTED) 42%
ATTR: job-impressions=0 job-impressions-completed=0
STATE: Waiting (FAXSEND_CONNECTED) 42%
....
ATTR: job-impressions=1 job-impressions-completed=1
STATE: Waiting (FAXSEND_CONNECTED) 100%
ATTR: job-impressions=1 job-impressions-completed=1
STATE: Waiting (FAXSEND_REPORT)
ATTR: job-impressions=1 job-impressions-completed=1
STATE: Waiting (FAXSEND_REPORT)
```

I have tested the script using a FritzBox6591 , there is a chance it works differently on other boxes.
Weird enough the fax-data is being sent to `{url}/cgi-bin/firmwarecfg`,  I don't think that's good design - but who am I...
During experimentation, the modem had to power-cycled because it went into a state where it did not accept any faxes anymore....



## Design/Implementation

  ... TODO...


## Automated testing...
  ... TODO ...


## Dockerization
  ... TODO ....


## really nice support of all possible iPP features
  ... TODO ...


