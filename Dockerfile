FROM alpine AS build

RUN apk  upgrade
# RUN apk -get update --fix-missing
RUN apk add git make bash gcc vim
RUN apk add patch
RUN apk add musl-dev zlib-dev gnu-libiconv-dev musl-utils avahi-dev openssl-dev
# ADD IPPFritzFax  /IPPFritzFax
RUN apk add subversion libpng perl
RUN svn checkout http://svn.code.sf.net/p/netpbm/code/stable netpbm     
RUN cd netpbm/lib/     && \
	while true ; do echo ; done | make BINARIES=pbmtog3      && \
	 tar cf - libnetpbm.so* | tar xvf - -C /usr/local/lib    && \
	cd ../converter/pbm/                                        && \
	while true ; do echo ; done | make BINARIES=pbmtog3      && \
	cp pbmtog3 /usr/local/bin/.               

ADD .  /IPPFritzFax
# RUN git clone http://github.com/thilo-hub/IPPFritzFax.git

WORKDIR IPPFritzFax

#RUN MAKEFLAGS='CONFIG_FLAGS=""'  sh ./make_all.sh 

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"
RUN make install
RUN mkdir -p faxserver/lib spool crt
#RUN cp install/lib/*.so* faxserver/lib/.
#RUN cp install/sbin/ippserver faxserver/bin/.
RUN apk add tar
RUN tar chvf pkg.tar faxserver bin spool crt lib install/lib/*.so*


### 
### here collect binaries from previous build step
FROM alpine
RUN apk add --no-cache avahi augeas dbus
RUN apk add bash 
RUN apk add perl perl-json perl-http-message perl-file-slurp perl-libwww perl-lwp-protocol-https html2text 
##  Optional: imagemagick poppler-utils 
COPY entrypoint.sh /opt/entrypoint.sh
WORKDIR IPPFritzFax
COPY --from=build /IPPFritzFax/faxserver /IPPFritzFax/faxserver
COPY --from=build /IPPFritzFax/lib /IPPFritzFax//lib
COPY --from=build /IPPFritzFax/bin /IPPFritzFax/bin
COPY --from=build /usr/local/lib/libnetpbm* /usr/local/lib/.
COPY --from=build /usr/local/bin/pbm* /usr/local/bin/.
COPY --from=build /IPPFritzFax/pkg.tar  .
RUN tar xvf pkg.tar 
RUN rm pkg.tar
RUN chmod a+x  /IPPFritzFax/bin/*.pl /IPPFritzFax/faxserver/bin/*
ENV LD_LIBRARY_PATH=/IPPFritzFax/install/lib
ENV PATH=/IPPFritzFax/bin:/IPPFritzFax/faxserver/bin:$PATH
### ENTRYPOINT /bin/bash
ENTRYPOINT ["/opt/entrypoint.sh"]
