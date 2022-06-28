
TEL=1234
USER=SomeUser
PASSWORD=aPassword
URL=https://192.168.66.1

ROOT_DIR!=pwd
ROOT_DIR?=$(shell pwd)

OS!=uname
OS?=$(shell uname)

CONFIG_FLAGS_FreeBSD=CFLAGS="-I$(ROOT_DIR)/patch" LIBS="-liconv -L/usr/local/lib"
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
runserver:
	mkdir -p crt spool
	LD_LIBRARY_PATH=$(ROOT_DIR)/install/lib ippsample/server/ippserver -C faxserver -K crt -d spool -r _universal

install: build urftopgm 
	cd ippsample && $(MAKE) prefix=$(INST) install 
	ln -f ${INST}/sbin/ippserver $(ROOT_DIR)/urftopgm $(ROOT_DIR)/faxserver/bin
	
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

