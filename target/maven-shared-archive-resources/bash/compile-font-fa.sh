#!/bin/bash -e

# copy FA to target/classes, create FA subset woff2, create scss and
# call gulp to compile fa scss 

# expects font-awesome in src/node_modules

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)

. $SHAREPATH/bash/lib.sh
. $SHAREPATH/bash/lib-fonts-fa.sh

mergegulptasks

[ -d target/node_modules/font-awesome/scss ] || (echo "Font Awesome npm package missing.";  exit 2)

msg "Running FA subset generator."

unicodesInUse=$(getCharsUsed src/main/scss target/maven-shared-archive-resources/main/scss)

msg "Unicodes used: " $unicodesInUse

createSubsetFontFiles target/classes/META-INF/resources/szoo "$unicodesInUse"

msg "Creating CSS: FontAwesome-adoc.scss"
mkdir -p target/generated-sources/scss/font-awesome
faMainSass > target/generated-sources/scss/font-awesome/FontAwesome-adoc.scss
faElSubsetSass $unicodesInUse > target/generated-sources/scss/font-awesome/_el-subset-path.scss

(cd target; gulp fa)

exit 0
