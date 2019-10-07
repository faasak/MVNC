#!/bin/bash -e

# copies/compiles:
# src/test/asciidoctor/**/*adoc --> target/http-server/**.html and wraps this
# into composition-template.html.
# target/classes/META-INF/resources/**/.css --> target/http-server/resources


. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

mergegulptasks

(cd target; gulp devel)

exit 0

