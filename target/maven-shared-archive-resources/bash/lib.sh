#!/bin/bash -u

msg() {
    echo $* > /dev/stderr
}

stripcomments() {
    local f
    for f in $*; do
	    [ -r "$f" ] && sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' $f
    done
}

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

unquote() {
    local var="$*"
    var="${var#\"}"
    var="${var%\"}"   
    var="${var//\\\"/\"}" # unescape former inner quotes
    echo -n "$var"
}

unbracket() {
    local var="$*"
    var="${var#[}"
    var="${var%]}"   
    echo -n "$var"
}

cpfreshfile() {
	local file=$1
	local target=$2 # file or dir
	if [ -d "$target" ]; then
		target="$target/$(basename $file)"
	fi
	[ -f "$file" ] || false
	if [ -r "$target" ]; then
		echo "Notice: Target file $target exists, skipping it." > /dev/stdout
	else
		cp $file $target
	fi
}

# run script, if local exists, take that one
runscript() {
	local file=$1
	if [ -r "$LOCALPATH/bash/$file" ]; then
	    chmod +x $LOCALPATH/bash/$file
		$LOCALPATH/bash/$file
	else
	    chmod +x $SHAREPATH/bash/$file # maven forgets x mod
	    $SHAREPATH/bash/$file
	fi
}

# take locals gulp tasks first
# like runscript, kludge for gulp 3 for now
mergegulptasks() (
    [ -d target/gulp ] && [ -r target/gulpfile.js ] && [ -d target/node_modules ] && return
    msg "Creating target/gulp..."
    shopt -s nullglob
	mkdir -p target/gulp
	cp -r $SHAREPATH/gulp/* target/gulp
	if [ -d $LOCALPATH/gulp ]; then
		for f in $LOCALPATH/gulp/*; do
			cp $f target/gulp
		done
	fi
	if [ -r $LOCALPATH/gulpfile.js ]; then
	    cp $LOCALPATH/gulpfile.js target
	else
	    cp $SHAREPATH/gulpfile.js target
	fi
	[ -L target/node_modules ] || ln -sr $LOCALPATH/node_modules target/
)

