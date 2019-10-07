# common configuration settings for scripts

LOCALPATH=src
SHAREPATH=target/maven-shared-archive-resources

GFONTSPATH=${GFONTSPATH:-src/google_fonts}
GHREPOSPATH=${GHREPOSPATH:-src/github_repos}
NODEPKGPATH=${NODEPKGPATH:-src/node_modules}

# Prependig DEBUG=1 keeps temporary files
DEBUG=${DEBUG:+true}
DEBUG=${DEBUG:-false}

REPOLIST=assembly/config-repolist.csv
FONTLIST=assembly/config-fontlist.csv

SASSDIR=src/main/sass

JSF_RESOURCESPATH="META-INF/resources"

JSF_RESOURCE="szoo"
JSF_FONTS="fonts"
JSF_STYLES="styles"

# to force download even if resource exists, prepend FORCE=1
FORCE=${FORCE:+true}
FORCE=${FORCE:-false}

# Google Fonts https://fonts.google.com
# see https://developers.google.com/fonts/docs/getting_started

declare -A USER_AGENT_STRINGS
USER_AGENT_STRINGS[svg]='Mozilla/5.0 (iPad; CPU OS 4_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/4.1'
USER_AGENT_STRINGS[eot]='Mozilla/4.0 (compatible; MSIE 7.0b; Uniplus+ System V)'
USER_AGENT_STRINGS[woff]='Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:27.0) Gecko/20100101 Firefox/27.0'
USER_AGENT_STRINGS[woff2]='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
USER_AGENT_STRINGS[ttf]='null'

# Args: family="<Font Name>[:[<weight>][<style>]"
FONTS_CSS_URL="http://fonts.googleapis.com/css"

ERR_FORMAT_MISMATCH="Font not in expected format. Check USER_AGENT_STRINGS string."
