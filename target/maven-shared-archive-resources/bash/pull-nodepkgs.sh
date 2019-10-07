#!/bin/bash -e

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

if [ ! -r "src/package.json" ];
then
	trap "rm -f src/package.json" EXIT
	cp target/maven-shared-archive-resources/assembly/package.json src
fi
(cd ./src; npm install)

