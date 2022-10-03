# Airprint / IPP faxserver for Fritzbox 

Airprint &amp;IPP faxserver using  Fritzbox FAX modem


Fritzbox is a fairly common cable/dsl modem in Germany.

It usually has the capability to send faxes (using T38 or some other protocol).
Unfortunaty there is no free available software the enables printing faxes from apple devices on the fritzbox.
The built-in web server only allows you to send single pages as a fax...
All not very pleasant

This package solves this problem.
It creates an IPP printer device which has a "sub-device" as the fax modem. It will show on the network as a FritBox Fax printer.


## Usage:

  "just" select the fax device and provide the phone number in the menu to send...


## Installation prerequisites:

- netpbm for URF processing
- imagemagic & poppler if you need PDF support

Options:

### Docker:

  The docker-image starts the avahi dameon, but this is untested and will not work on MacOS (see docker-limitations)
```
   make docker-build
   make docker-start PASSWORD=SuperPassword USER=TheUserOnFritzBox  TEL=123123123 URL=https://fitz.box
   make docker-stop
```

### MacOS

```
  make -j 20 install
  make runserver 
```

### FreeBSD
 
```
  make -j 20 install
  make runserver
```

- *nix needs a credentials file having the relevant information for the fritzbox available:
** $HOME/.credentials  **
```
url=https://......
user=.......
password=.......
telFrom=.......
```

==== Thats it ====


## Troubleshooting:

### Tracing execution
The default command configured to be executed is "hell.sh" in
faxout.conf
```
Command hell.sh
#Command FritzBoxFax.sh
```
Which creates a shell script in `/tmp/run_env.$pid.sh` (and runs the FB command as a proxy).
This script can "re-run" the command with all parameters set the same way as the ippserver did.
Very helpfull to debug/inspect why it might not work.

###  Printer not installing

Bonjour/Mdns can be a beast.

 Check if your PC sees the printer info:
 
 - MACOS:
  `dns-sd -B _ipp | grep FritzBox`
```
   17:32:52.876  Add        2  14 local.               _ipp._tcp.           AirPrint FritzBox FAX @ Comp 
```

- linux/*bsd/Avahi: 
 `avahi-browse -r _ipp._tcp -t | grep FritzBox`
```
   + epair0b IPv4 AirPrint FritzBox FAX @ Comp                  _ipp._tcp            local
   = epair0b IPv4 AirPrint FritzBox FAX @ Comp                  _ipp._tcp            local
   txt = ["txtvers=1" "qtotal=1" "rp=ipp/print/pdf" "rfo=ipp/faxout" "ty=Simulated" "adminurl=http://XXX:8632/" "kind=photo,envelope,document" "note=FritzBox6591" "priority=0" "product=(ThiloPrint)" "Color=T" "Duplex=T" "Staple=F" "Copies=T" "Collate=F" "Punch=0" "Bind=F" "Sort=F" "Scan=F" "Fax=T" "URF=W8,CP255,FN3-11-60,IS9,IFU0,MT1-5,OB10,PQ3-4-5,RS203-300,V1.4" "pdl=image/urf,image/jpeg" "UUID=84cf3cd1-0000-341c-6a4e-92d13edb77ff" "TLS=1.3"]
```


** Only if the complete mdns info is available, the mac auto printer installation will be fully working!!! **

### Test FAX sending

There is a free receiver (at least in Germany)
https://simple-fax.de/test-fax-empfangen
that can be used to receive single pages

0531 - 49059113

`perl bin/send_fax.pl 000000000  053149059113  faxserver/faxout/faxout.png'

```
...
Sending 1 pages to 053149059113
FRITZ!Box
***** FRITZ!Box Fax senden *****
Der Faxversand wurde erfolgreich gestartet.
Sie werden weitergeleitet. Bitte einen Moment Geduld.
[Unknown INPUT type] [Unknown INPUT type] [Unknown INPUT type]
...
ATTR: job-impressions=2 job-impressions-completed=2
STATE: Waiting (FAXSEND_REPORT)
```
You should receive an e-mail from the FritzBox about the fax operation (if you have set this up correctly)

I have tested the script using a FritzBox6591 , there is a chance it works differently on other boxes.
Weird enough the fax-data is being sent to `{url}/cgi-bin/firmwarecfg`,  I don't think that's good design - but who am I...
During experimentation, the modem had to power-cycled because it went into a state where it did not accept any faxes anymore....



## Open issues:

 I can only install two printers ( "normal" & "fax" ) - not fax only
 
 On IOS/IpadOS I do not see the FAX printer only the "Normal" printer  ( What is missing here??? )
 
 Not tested with a windows OS


## Design/Implementation

  ... TODO...


## Automated testing...
  ... TODO ...

## really nice support of all possible iPP features
  ... TODO ...


