#!/bin/bash -ue

# (c) 2017 Stefan Katerkamp

# EL resource style 

# bullet-proof style css entry to work around IE8 bugs
bulletproofELFontCSS() {
	local fontsIndex=$1

	local i=$fontsIndex
	local fontUCRangeIndex=0
	local j=$fontUCRangeIndex

	cat <<-EOR

	@font-face {
	font-family: '${FONTS[$i,family]}';
	font-style: ${FONTS[$i,style]};
	font-weight: ${FONTS[$i,weight]};
	src: url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,eot,$j,file]}']}");
	src: url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,eot,$j,file]}']}?#iefix") format('embedded-opentype'),
	     url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,woff,$j,file]}']}") format('woff'),
	     url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,ttf,$j,file]}']}") format('truetype'),
	     url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,svg,$j,file]}']}#${FONTS[$i,svg,id]}") format('svg');
	}
	EOR
}

# modern alternative to bulletproof css
woffELFontCSS() {
	local fontsIndex=$1

	local i=$fontsIndex
	local fontUCRangeIndex=0
	local j=$fontUCRangeIndex
	local formatext='woff'

	cat <<-EOR

	@font-face {
	font-family: '${FONTS[$i,family]}';
	font-style: ${FONTS[$i,style]};
	font-weight: ${FONTS[$i,weight]};
	src: url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,$formatext,$j,file]}']}") format('$formatext');
	}
	EOR
}

woff2ELFontCSS() {
	local fontsIndex=$1
	local fontUCRangeIndex=$2

	local i=$fontsIndex
	local j=$fontUCRangeIndex
	local formatext='woff2'
	cat <<-EOR

	@font-face {
	font-family: '${FONTS[$i,family]}';
	font-style: ${FONTS[$i,style]};
	font-weight: ${FONTS[$i,weight]};
	src: url("#{resource['$JSF_RESOURCE:$JSF_FONTS/${FONTS[$i,$formatext,$j,file]}']}") format('$formatext');
	EOR
	[ -z "${FONTS[$i,$formatext,$subset,range]}" ] || echo "unicode-range: ${FONTS[$i,$formatext,$j,range]};"
	echo '}'
}

woff2ELFontCSSset() {
	local fontsIndex=$1

	local i=$fontsIndex
	local formatext='woff2'

	local subsets=""
	local subset
	local ucr
	if [ -z "${FONTS[$i,ucrmatchlist]}" ]; then
		subsets=$(seq 0 $((${FONTS[$i,$formatext,subsetsize]}-1)))
	else
		for subset in $(seq 0 $((${FONTS[$i,$formatext,subsetsize]}-1))); do
			for ucr in ${FONTS[$i,ucrmatchlist]}; do
				if [[ ${FONTS[$i,$formatext,$subset,range]} == *${ucr}* ]];then
					subsets="$subsets $subset"
				fi
			done
		done
	fi

	for subset in $subsets; do
		woff2ELFontCSS $i $subset 
	done
}

woff2ELFontCSSfullset() {
	local fontsIndex=$1
	local i=$fontsIndex

	local subset
	for subset in $(seq 0 $((${FONTS[$i,woff2,subsetsize]}-1))); do
		woff2ELFontCSS $i $subset 
	done
}
