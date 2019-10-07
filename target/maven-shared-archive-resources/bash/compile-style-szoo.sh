#!/bin/bash -e

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

mergegulptasks

(cd target; gulp scss)
(cd target; gulp minify)

exit 0
