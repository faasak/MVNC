#!/bin/bash -ue

# (c) 2017 Stefan Katerkamp

quoteUnicodeRange() {
	local cssfile=$1
	sed -i \
		-e "/unicode-range/{s/ U/\'U/g}" \
		-e "/unicode-range/{s/,/\',/g}" \
		-e "/unicode-range/{s/;/\';/}" \
		$cssfile
}

# local('foo') --> getArg local $input --> foo
getArg() {
	if [[ "$2" =~ "'" ]]; then
		echo $2 | sed -e "s/[\"]*$1('\([^']*\)')[\"]*/\1/"
	else 
		echo $2 | sed -e "s/[\"]*$1(\([^)]*\))[\"]*/\1/"
	fi
}

downloadFontCssJson() {
	local formatext=$1
	local destination=$2

	local cssFile=$destination-$formatext.css
	local jsonFile=$destination-$formatext.json
	curl -sf -A "${USER_AGENT_STRINGS[$formatext]}" --get \
		--data-urlencode \
		family="${FONTS[$i,family]}:${FONTS[$i,weight]}${FONTS[$i,style]}" \
		-o $cssFile $FONTS_CSS_URL 

	# woff2 unicode-range must be quoted in css to make cssparser happy
	quoteUnicodeRange $cssFile
	cssparser -o $jsonFile $cssFile
}


# returns number of font face entries in css aka json
getFontfaceCount() {
	cssJsonFile=$1
	jq -e '.value | length' $cssJsonFile
}

getFontfaceData() {
	fontFaceIndex=$1
	cssJsonFile=$2
	jq -e --raw-output ".value[${fontFaceIndex}].value" $cssJsonFile
}

# return font name from src: local(), name which has no spaces
getFontName() {
	local fontfaceData=$1
	local src='.src[]'
	echo $fontfaceData | jq -e '.src[]' >/dev/null 2>&1
	[[ $? != 0 ]] && src='.src' # have string as src: value
	local uri=$(echo $fontfaceData | jq -e "$src"'|select(.|(startswith("local") and (contains(" ")==false)))')
	if [ -z "$uri" ];then
		echo ""
	else
		echo $(getArg "local" $uri) # there may be more than 1 args in uri
	fi
}

# expect "url(*) format(*)"
getFontURL() {
	local formatext=$1
	local fontfaceData=$2
	local uri=""
	local src='.src[]'
	echo $fontfaceData | jq -e '.src[]' >/dev/null 2>&1
	[[ $? != 0 ]] && src='.src' # have string as src: value
	uri=$(echo $fontfaceData | jq -e --raw-output "$src"'| select(.|(startswith("url") and contains("'$formatext'")))')
	if [ -z "$uri" ];then
		# there is no format, try again
		uri=$(echo $fontfaceData | jq -e --raw-output "$src"'|select(.| startswith("url"))')
	fi
	if [ -z "$uri" ];then
		echo ""
	else
		uri=($uri)
		uri=${uri[0]} # format is always 2nd token, strip it
		local url=$(getArg "url" "$uri")
		echo $url
	fi
}

getFontStyle() {
	local fontfaceData=$1
	echo $fontfaceData | jq -e --raw-output '."font-style"' | tr -d "'"
}

getFontWeight() {
	local fontfaceData=$1
	echo $fontfaceData | jq -e --raw-output '."font-weight"' | tr -d "'"
}

getFontFamily() {
	local fontfaceData=$1
	echo $fontfaceData | jq -e --raw-output '."font-family"' | tr -d "'"
}

getFontUCRange() {
	local fontfaceData=$1
	echo $fontfaceData | jq -e --raw-output '."unicode-range" | tostring' \
		| sed -e "s/\[//g" -e "s/\]//g" -e 's/"//g' -e "s/'//g" -e "s/null//g"
}

# store in FONTS assoc array
storeData() {
	local fontNameIndex=$1
	local fontNameUCRangeIndex=$2
	local formatext=$3
	local fontfaceData=$4

	local i=$fontNameIndex
	local j=$fontNameUCRangeIndex
	local fontName=$(getFontName "$fontfaceData")
	FONTS[$i,name]=${FONTS[$i,name]:-$fontName}

	local fontWeight=$(getFontWeight "$fontfaceData")
	FONTS[$i,weight]=${FONTS[$i,weight]:-$fontWeight}

	local fontStyle=$(getFontStyle "$fontfaceData")
	FONTS[$i,style]=${FONTS[$i,style]:-$fontStyle}

	local fontFamily=$(getFontFamily "$fontfaceData")
	if [[ "$fontFamily" != "${FONTS[$i,family]}" ]]; then
		echo "FATAL:Google returned wrong family: $fontFamily"
		exit 99
	fi
	FONTS[$i,familyid]="${fontFamily// /}"

	local url=$(getFontURL $formatext "$fontfaceData")
	FONTS[$i,$formatext,$j,url]=$url
	if [[ $formatext == svg ]]; then
		FONTS[$i,$formatext,id]=${url#*\#}
	fi

	FONTS[$i,$formatext,$j,range]=$(getFontUCRange "$fontfaceData")

	# the file path contains of the basedir and the file basename with extension
	FONTS[$i,$formatext,$j,file]=${FONTS[$i,familyid]}/${FONTS[$i,name]}-$j.$formatext
}

getExpectedFontFileCount() {
	local fontsIndex=$1
	local fileCount=0
	for formatext in svg ttf eot woff woff2; do
		(( fileCount += FONTS[$i,$formatext,subsetsize] ))
	done
	echo $fileCount
}

getStoredFontFileCount() {
	local fontsIndex=$1
	local fontdir=$2
	(
		shopt -s nullglob
		numfiles=($fontdir/${FONTS[$i,familyid]}/${FONTS[$i,name]}-[0-9]\.*) # todo 2 digit subset count
		echo ${#numfiles[@]}
	)
}

cleanFontFiles() {
	local fontsIndex=$1
	local fontdir=$2
	rm -f $fontdir/${FONTS[$i,familyid]}/${FONTS[$i,name]}-*
}

downloadFontFile() {
	local fontsIndex=$1
	local fontUCRangeIndex=$2
	local formatext=$3
	local fontdir=$4

	local i=$fontsIndex
	local j=$fontUCRangeIndex

	$DEBUG && echo -n -e "\n${FONTS[$i,$formatext,$j,file]} '\t<-' ${FONTS[$i,$formatext,$j,url]}"
      	curl -sfL --create-dirs -o $fontdir/${FONTS[$i,$formatext,$j,file]}  ${FONTS[$i,$formatext,$j,url]}
}