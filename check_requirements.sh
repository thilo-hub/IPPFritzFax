#/bin/sh

#Check my requirements

#  pkg install p5-JSON p5-LWP-Protocol-https p5-File-Slurp

for i in lib/*.pm *.pl ; do
	if ! perl -c "$i" ; then echo "Please FIX" ; exit 99; fi
done



MISSING=""
for tool in git pdftocairo pngtopam convert pbmtog3 html2text ; do
	if ! which "$tool" ; then
		echo "Executable not found: $tool";
		MISSING="$MISSING $tool"
	fi
done
if [  -n "$MISSING" ]; then

# Sometimes this is needed...
  #  pkg search netpbm
  #  pkg install -y netpbm
  #  pkg install -y poppler
  #  pkg install -y ImageMagick7-nox11
  #  pkg install -y html2text

	echo "Install some packages... for $MISSING"
	exit 99
fi

