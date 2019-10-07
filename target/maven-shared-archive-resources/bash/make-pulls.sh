#!/bin/bash -e

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

echo "FONTS........."
runscript pull-googlefonts.sh

echo "GIT REPOS........."
runscript pull-repos.sh

echo "NPM PACKAGES........."
runscript pull-nodepkgs.sh

exit 0
