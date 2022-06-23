
ROOT_DIR!=pwd

CONFIG_FLAGS= --with-libcups=$(ROOT_DIR)/ippsample/libcups   \
		CFLAGS="-I$(ROOT_DIR)/patch -I/usr/local/include" LDFLAGS="-L/usr/local/lib -lgnutls -lpthread" 

all: checkout patch configure
	cd ippsample && make
	cp ippsample/server/ippserver faxserver/bin/.

checkout: ippsample/.checkout

patch: ippsample/.patched

configure: ippsample/.configured


ippsample/.checkout:
	git submodule init
	git submodule update
	sed -i.bak 's,git@github.com:,https://github.com/,' ippsample/.gitmodules 
	cd ippsample && git submodule init && git submodule update
	touch $@


ippsample/.patched:
	cd ippsample && patch -p1 < ../patch.submodule 
	touch $@


	


ippsample/.configured:
	cd ippsample && \
	./configure $(CONFIG_FLAGS)
	touch $@


#all: sources 
#	cd ippsample && make
#
#patch: ippsample/.patched
#
#configure: ippsample/.configured
#
#sources: patched configure
#ippsample/libcups  ippsample/.configured
#
#faxserver/bin/ippserver: ippsample/server/ippserver
#	echo cp  $> $@
#	false
#
#ippsample/.configured: ippsample/.patched
#	cd ippsample && \
#	./configure --with-libcups=$(ROOT_DIR)/ippsample/libcups   \
#		CFLAGS="-I$(ROOT_DIR)/patch -I/usr/local/include" LDFLAGS="-L/usr/local/lib -lgnutls -lpthread" 
#	touch $@
#
#ippsample/.patched: ippsample/libcups
#	cd ippsample && patch -p1 < ../patch.submodule 
#	touch $@
#	
#ippsample/server/ippserver: ippsample/config.status 
#	cd ippsample && make
#
#
#ippsample/libcups: 
#	git submodule init
#	git submodule update
#	cd ippsample && git submodule init && git submodule update
#
#
#	
#
#	
#
