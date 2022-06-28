# configure & make & run for macos
make checkout
cd ippsample
git checkout .gitmodules
git am ../patch-ippsample/*
cd libcups
git am ../../patch-libcups/*
cd ..
touch .patched
INST=$PWD/install
./configure --prefix=$INST
sed -i.orig 's/-arch x86_64//' Makedefs libcups/Makedefs
make  prefix=$INST  -j 20
make  prefix=$INST  -j 20 install
cd ..
rm -f faxserver/bin/ippserver
ln -s $INST/sbin/ippserver faxserver/bin/.

mkdir crt spool
faxserver/bin/ippserver -C faxserver -K crt -d spool -r _universal 
