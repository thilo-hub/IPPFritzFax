FROM alpine AS build

RUN apk  upgrade
# RUN apk -get update --fix-missing
RUN apk add git make bash gcc vim
RUN apk add patch
RUN apk add musl-dev zlib-dev gnu-libiconv-dev musl-utils avahi-dev openssl-dev
# ADD IPPFritzFax  /IPPFritzFax
ADD .  /IPPFritzFax
# RUN git clone http://github.com/thilo-hub/IPPFritzFax.git

WORKDIR IPPFritzFax

RUN MAKEFLAGS='CONFIG_FLAGS=""'  sh ./make_all.sh 
RUN mkdir faxserver/lib spool crt
RUN cp ./ippsample/libcups/cups/libcups.so* faxserver/lib/.
RUN cp ippsample/server/ippserver faxserver/bin/.

RUN apk add subversion libpng perl
RUN svn checkout http://svn.code.sf.net/p/netpbm/code/stable netpbm     
RUN cd netpbm/lib/     && \
	while true ; do echo ; done | make BINARIES=pbmtog3      && \
	 tar cf - libnetpbm.so* | tar xvf - -C /usr/local/lib    && \
	cd ../converter/pbm/                                        && \
	while true ; do echo ; done | make BINARIES=pbmtog3      && \
	cp pbmtog3 /usr/local/bin/.               

### 
### here collect binaries from previous build step
FROM alpine
RUN apk add --no-cache avahi augeas
RUN apk add bash 
### RUN apk add netpbm  --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
RUN apk add perl perl-json perl-http-message perl-file-slurp perl-libwww perl-lwp-protocol-https \
 		 imagemagick html2text poppler-utils 
COPY entrypoint.sh /opt/entrypoint.sh
WORKDIR IPPFritzFax
COPY --from=build /IPPFritzFax/faxserver /IPPFritzFax/faxserver
COPY --from=build /IPPFritzFax/lib /IPPFritzFax//lib
COPY --from=build /IPPFritzFax/bin /IPPFritzFax/bin
COPY --from=build /usr/local/lib/libnetpbm* /usr/local/lib/.
COPY --from=build /usr/local/bin/pbm* /usr/local/bin/.
RUN chmod a+x  /IPPFritzFax/bin/*.pl /IPPFritzFax/faxserver/bin/*
ENV LD_LIBRARY_PATH=/IPPFritzFax/faxserver/lib
ENV PATH=/IPPFritzFax/bin:/IPPFritzFax/faxserver/bin:$PATH
### ENTRYPOINT /bin/bash
ENTRYPOINT ["/opt/entrypoint.sh"]
