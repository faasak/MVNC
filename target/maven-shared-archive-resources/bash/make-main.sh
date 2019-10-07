#!/bin/bash -e

# Main script, invoked during styles-factory maven compile phase.
# Installs node files needed in src dir.
# Does not overwrite user installed scripts and configs.

#dir3=$(dirname $(dirname $(dirname $0)))
# todo prevent from running in wrong dir

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

if [ ! -d src/github_repos ] && [ ! -d src/node_modules ]; then
	separator="=============================================================================="
	echo $separator
	echo ""
	echo "[ERROR] No external resources found. Did you run 'mvn -P clone install' first?"
	echo ""
	echo $separator
	exit 1
fi

msg "Merging local and remote gulp resources..."

mergegulptasks

msg "Compiling SASS for FA and Szoo..."

runscript compile-font-fa.sh

runscript compile-style-szoo.sh

exit 0
