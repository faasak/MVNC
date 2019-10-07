#!/bin/bash -eu

# Download Google Fonts into src/main/resources/META-INF/resources
# Merges assembly/config-fontlist.csv from shared and local

# (c) 2015-2017 Stefan Katerkamp

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh
. $SHAREPATH/bash/lib-fonts-google.sh
. $SHAREPATH/bash/lib-fonts-css.sh

# cssparser needs file based input; create tmp dir
tmpd=/tmp/googlefonts-$$
trap "rm -rf $tmpd" EXIT
if $DEBUG; then
	tmpd=/tmp/googlefonts
	echo "Using DEBUG mode, all temporary files will be kept in $tmpd"
	trap "" EXIT
fi
mkdir -p $tmpd

declare -A FONTS
FONTS_SIZE=0

# read the font config csv file into FONTS array
IFS="," 
exec 3< <(stripcomments $SHAREPATH/$FONTLIST $LOCALPATH/$FONTLIST)
while read -u 3 family weight style name ucrmatchlist; do
	FONTS_SIZE=$((FONTS_SIZE+1))
	FONTS[$FONTS_SIZE,family]="$(trim $family)"
	FONTS[$FONTS_SIZE,weight]="$(trim $weight)"
	FONTS[$FONTS_SIZE,style]="$(trim $style)"
	FONTS[$FONTS_SIZE,name]="$(trim $name)"
	FONTS[$FONTS_SIZE,ucrmatchlist]="$(trim $ucrmatchlist)" # needed woff2 unicode range
done
unset IFS

if [[ $FONTS_SIZE == 0 ]]; then
    echo "No Google fonts configured for download (src/assembly/config-fontlist.csv)."
    exit 0
fi
echo "Number of fonts configured: $FONTS_SIZE"
fontdir=$GFONTSPATH/$JSF_RESOURCESPATH/$JSF_RESOURCE/$JSF_FONTS/
cssdir=$GFONTSPATH/$JSF_RESOURCESPATH/$JSF_RESOURCE/$JSF_STYLES/
mkdir -p $cssdir
$DEBUG && echo "Local fonts  dir: $fontdir"
$DEBUG && echo "Local styles dir: $cssdir"

# per font as given in config list
for i in $(seq 1 $FONTS_SIZE); do

	echo -n "Font $i; ${FONTS[$i,family]} ${FONTS[$i,weight]} ${FONTS[$i,style]}"

	# get google css data of font in various formats
	echo -n " "
  	for formatext in svg ttf eot woff woff2; do
		downloadFontCssJson $formatext $tmpd/fontdata
		echo -n "."
		# for woff2 there may be unicode ranges i.e. more than 1 file
		subsetsize=$(getFontfaceCount $tmpd/fontdata-$formatext.json)
		FONTS[$i,$formatext,subsetsize]=$subsetsize
		for j in $(seq 0 $((subsetsize-1))); do
			fontfaceData=$(getFontfaceData $j $tmpd/fontdata-$formatext.json)
			storeData $i $j $formatext "$fontfaceData" # finish init of FONTS array
		done
		# quick check if already loaded, faster but relies on consistent fonts, default
		if [ -r "$fontdir/${FONTS[$i,$formatext,0,file]}" ]; then
		    $FORCE || echo " exists, skipping pull."
		    $FORCE || continue 2
		fi
  	done

	[ -z "${FONTS[$i,name]}" ] && (echo "ERROR. Check UA."; exit 1) # must not be empty

	# skip already loaded fonts
	$DEBUG && echo "Fonts expected $(getExpectedFontFileCount $i), have $(getStoredFontFileCount $i $fontdir)"
		
	echo -n " ${FONTS[$i,familyid]}/${FONTS[$i,name]} "

	# download font per format into $fontdir/$fontname/$fontname-$extension
	cleanFontFiles $i $fontdir
  	for formatext in svg ttf eot woff woff2; do
		subsetsize=${FONTS[$i,$formatext,subsetsize]}
		for j in $(seq 0 $((subsetsize-1))); do
			downloadFontFile $i $j $formatext $fontdir
			echo -n "."
		done
	done

	# create local css files with EL #{resource} identifiers
	bulletproofELFontCSS $i > ${cssdir}/${FONTS[$i,name]}-bp.css
	woff2ELFontCSSfullset $i > ${cssdir}/${FONTS[$i,name]}-woff2.css
	woffELFontCSS $i > ${cssdir}/${FONTS[$i,name]}.css
	woff2ELFontCSSset $i >> ${cssdir}/${FONTS[$i,name]}.css

	echo "."

done

exit 0

