#!/bin/bash -e

getCharsUsed() {
	local szooSassDirs=$*
	local subsetChars
	# get all FA characters as k/v pairs
	source <(scss-to-json src/node_modules/font-awesome/scss/_variables.scss | \
	jq -r 'keys[] as $k | "\($k)=\(.[$k]);" | gsub("[\\$]";"") | 
	gsub("[\\\\]";"U+") | gsub("-";"_") | select (. |startswith("fa_var"))')

	# get all font awsome characters used in scss
	subsetChars=$(grep -h -r "fa-var" $szooSassDirs | grep -e "content:" | \
	sed -e "s/content://" -e "s/;//" -e "s/-/_/g")
	subsetChars=($subsetChars)

	# TODO uniq

	#echo "FA chars in SASS: ${#subsetChars[@]}">/dev/stdout
	#echo "FA char names in SASS: ${subsetChars[@]}">/dev/stdout

	unicodes=$(eval echo ${subsetChars[@]})
	unicodes=$(echo $unicodes | sed -e 's/ /,/g' | tr '[:lower:]' '[:upper:]')
	echo "$unicodes"
}

createSubsetFontFiles() {
	local resourcedir=$1/fonts/FontAwesome
	local unicodes=$2

	mkdir -p $resourcedir

	pyftsubset src/node_modules/font-awesome/fonts/fontawesome-webfont.ttf \
	--unicodes="$unicodes"  --output-file=$resourcedir/FontAwesome-adoc.ttf

	./src/github_repos/woff2/woff2_compress $resourcedir/FontAwesome-adoc.ttf
	ttf2woff $resourcedir/FontAwesome-adoc.ttf $resourcedir/FontAwesome-adoc.woff

	local origSize=$(stat -c%s src/node_modules/font-awesome/fonts/fontawesome-webfont.woff2)
	local adocSize=$(stat -c%s $resourcedir/FontAwesome-adoc.woff2)
	local adocSizeWoff=$(stat -c%s $resourcedir/FontAwesome-adoc.woff)

	echo "Woff2 orig -> subset sizes: $origSize -> $adocSize (woff $adocSizeWoff)"
}


# modern browser style css ussing and woff woff2 only
# and just some few styles

faMainSass() {
	cat <<-EOR
	/*!
 	*  szoo-faces Font Awesome Subset for Asciidoctor. 
 	*  License - http://fontawesome.io/license (Font: SIL OFL 1.1, CSS: MIT License)
 	*/
	
	@import "font-awesome/scss/variables";
	@import "font-awesome/scss/mixins";
	@import "el-subset-path";
	@import "font-awesome/scss/core";
	@import "font-awesome/scss/larger";
	//@import "font-awesome/scss/fixed-width";
	//@import "font-awesome/scss/list";
	//@import "font-awesome/scss/bordered-pulled";
	//@import "font-awesome/scss/animated";
	//@import "font-awesome/scss/rotated-flipped";
	//@import "font-awesome/scss/stacked";
	//@import "font-awesome/scss/icons";
	//@import "font-awesome/scss/screen-reader";
	EOR
}

faElSubsetSass() {
	local unicodes=$1
	cat <<-EOR

	@font-face {
  	font-family: 'FontAwesome';
	src:url("\#{resource['szoo:fonts/FontAwesome/FontAwesome-adoc.woff2']}") format('woff2');
	src:url("\#{resource['szoo:fonts/FontAwesome/FontAwesome-adoc.woff']}") format('woff');
  	font-weight: normal;
  	font-style: normal;
	unicode-range: $unicodes;
	}
	EOR
}
