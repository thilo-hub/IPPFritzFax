
TEL=1234
USER=SomeUser
PASSWORD=aPassword
URL=https://192.168.66.1

ROOT_DIR!=pwd
ROOT_DIR?=$(shell pwd)

OS!=uname
OS?=$(shell uname)

CONFIG_FLAGS_FreeBSD= --with-libcups=$(ROOT_DIR)/ippsample/libcups   \
		CFLAGS="-I$(ROOT_DIR)/patch -I/usr/local/include" LDFLAGS="-L/usr/local/lib -lgnutls -lpthread" 
CONFIG_FLAGS=$(CONFIG_FLAGS_$(OS))

INST=$(ROOT_DIR)/install

all:install 

docker-build:
	docker build -t fritz -f Dockerfile .

docker-start:
	docker run -d -p 8000:8000 --name FritzFax --rm  fritz -pass=${PASSWORD} -tel=${TEL} -user=${USER} -url=${URL}

docker-stop:
	docker stop FritzFax

clean:
	rm -rf ippsample urftopgm faxserver/bin/urftopgm faxserver/bin/ippserver faxserver/lib $(INST)

# Start server
start:
	mkdir -p crt spool
	ippsample/server/ippserver -C faxserver -K crt -d spool -r _universal

install: build urftopgm 
	cd ippsample && $(MAKE) prefix=$(INST) install 
	ln -sf ${INST}/sbin/ippserver $(ROOT_DIR)/urftopgm $(ROOT_DIR)/faxserver/bin
	
build: ippsample/.configured
	cd ippsample && $(MAKE)
	
ippsample/.configured: ippsample/.patched
	cd ippsample && \
	./configure $(CONFIG_FLAGS) --prefix=$(INST) &&\
	test $(OS) != Darwin || sed -i.orig 's/-arch x86_64//' Makedefs libcups/Makedefs  &&\
	touch .configured

ippsample/.patched: ippsample/.checkout
	cd ippsample && \
	git checkout .gitmodules && \
	git am ../patch-ippsample/* && \
	cd libcups && \
	git am ../../patch-libcups/* && \
	touch ../.patched

ippsample/.checkout:
	git submodule init
	git submodule update
	sed -i.bak 's,git@github.com:,https://github.com/,' ippsample/.gitmodules 
	cd ippsample && \
	git submodule init && \
	git submodule update && \
	touch .checkout
	
urftopgm: urftopgm.c 

#XXcheckout: ippsample/.checkout
#XX
#XXippsample/.patched: ipp
#XXtest:  checkout
#XXbuild: checkout patch configure 
#XX	make -j 20 install
#XX
#XX
#XX
#XXippsample/server/ippserver: ippsample/.patched
#XX	cd ippsample && make
#XX
#XXinstall: urftopgm ippsample/server/ippserver checkout patch configure
#XX	cp urftopgm faxserver/bin/.
#XX	cp ippsample/server/ippserver faxserver/bin/.
#XX


#XXippsample/.checkout: checkout
#XX	touch $@
#XX
#XXippsample/.configured: patch
#XX	touch $@
#XX
#XXippsample/.patched: ippsample/.checkout
#XX	touch $@
#XX
#XXcheckout:
#XX	git submodule init
#XX	git submodule update
#XX	sed -i.bak 's,git@github.com:,https://github.com/,' ippsample/.gitmodules 
#XX	cd ippsample && git submodule init && git submodule update
#XX	touch .checkout
#XX
#XX
#XXconfigure: ippsample/.patched
#XX	cd ippsample && \
#XX	./configure $(CONFIG_FLAGS)
#XX
#XX
#XX#all: sources 
#XX#	cd ippsample && make
#XX#
#XX#patch: ippsample/.patched
#XX#
#XX#configure: ippsample/.configured
#XX#
#XX#sources: patched configure
#XX#ippsample/libcups  ippsample/.configured
#XX#
#XX#faxserver/bin/ippserver: ippsample/server/ippserver
#XX#	echo cp  $> $@
#XX#	false
#XX#
#XX#ippsample/.configured: ippsample/.patched
#XX#	cd ippsample && \
#XX#	./configure --with-libcups=$(ROOT_DIR)/ippsample/libcups   \
#XX#		CFLAGS="-I$(ROOT_DIR)/patch -I/usr/local/include" LDFLAGS="-L/usr/local/lib -lgnutls -lpthread" 
#XX#	touch $@
#XX#
#XX#ippsample/.patched: ippsample/libcups
#XX#	cd ippsample && patch -p1 < ../patch.submodule 
#XX#	touch $@
#XX#	
#XX#ippsample/server/ippserver: ippsample/config.status 
#XX#	cd ippsample && make
#XX#
#XX#
#XX#ippsample/libcups: 
#XX#	git submodule init
#XX#	git submodule update
#XX#	cd ippsample && git submodule init && git submodule update
#XX#
#XX#
#XX#	
#XX#
#XX#	
#XX#
