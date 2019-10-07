#!/bin/bash -eu

# Download repositories into src/main/repos

# (c) 2015-2017 Stefan Katerkamp

. target/maven-shared-archive-resources/bash/config.sh 2>/dev/null || (echo "ERROR. Fix: run from project basedir."; exit 1)
. $SHAREPATH/bash/lib.sh

echo "Downloading fonts to ${GHREPOSPATH}...."
mkdir -p $GHREPOSPATH

declare -A repos	 # fake 2 dim, first is index 1
repos_size=0
exec 3< <(stripcomments $SHAREPATH/$REPOLIST $LOCALPATH/$REPOLIST)
while read -u 3 repository tag gitopt; do
	repos_size=$((repos_size+1))
	repos[$repos_size,repo]=$repository
	repos[$repos_size,tag]=$tag
	repos[$repos_size,gitopt]=$gitopt
	repos[$repos_size,name]=$(basename $repository .git)
	msg Repo: ${repos[$repos_size,repo]} t:${repos[$repos_size,tag]} \
 	o:${repos[$repos_size,gitopt]} n:${repos[$repos_size,name]}
done

guess_latest_tag() {
	# must be inside git directory and must have tag list
	name=$1
	tag=$2
	grsohe="grep -v -e 'undefined' -e '-rc' | sort -r | head -1"
	if [[ "$tag" =~ ^[0-9].* ]]; then
		latest=$(git tag -l | grep '^[0-9]' | eval $grsohe)
	else
		latest=$(git tag -l | grep -v '^[0-9]' | eval $grsohe)
	fi
	if [ "$latest" != "$tag" ]; then
		echo "  Repo $name may have newer tag: $latest (we use $tag)."
	fi
	return 0
}


clone_or_update_repo() {
	local repository=$1
	local tag=$2
	local name=$3
	local gitopt=$4
	local localdir=$GHREPOSPATH/$3
	if [ -d $localdir ]; then
		echo "Updating $name."
		(
			cd $localdir
			git checkout --quiet master
		       	git pull --quiet
			if [ $(git tag -l | wc -l) -gt 0 ]; then
				ret=0 # this way since bash eu flags set
				git show-ref --verify --quiet refs/heads/local-$tag || ret=1
				if [ $ret == 0 ]; then
					git checkout --quiet local-$tag
				else
					git checkout --quiet tags/$tag -b local-$tag
				fi
				guess_latest_tag $name $tag
			fi
		)
	else
		echo "Cloning $name.... Please wait..."
		git clone --progress --verbose $gitopt $repository $localdir
		(
			echo "Checking out $tag from $name."
			cd $localdir
			if [ $(git tag -l | wc -l) -gt 0 ]; then
				# prefix local- avoids ambiguity
				git checkout tags/$tag -b local-$tag
				guess_latest_tag $name $tag
			fi
		)
	fi
	return 0
}

for i in $(seq 1 $repos_size); do
	clone_or_update_repo "${repos[$i,repo]}" "${repos[$i,tag]}" "${repos[$i,name]}" "${repos[$i,gitopt]}" || true
done

exit 0
