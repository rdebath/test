ATQ='V=$(echo s/x/x\"x\"x/g | tr x "'"'"'"); V=$(echo "$ATQ" | sed -e "$V")
:
REPO="${1:-$REPO}" ; export REPO
[ "$REPO" != "" ] || {
    echo "Please specify the repository URL, possibly with the password on the command line" >&2
    exit
}
:
echo "ATQ='"'"'$V'"'"' ; eval \"\$ATQ\"" | at now + 1 hour >/dev/null 2>&1
:
export TZ=UTC
BRANCH=${BRANCH:-tick}
LR=/tmp/repo.$$

umask 077
mkdir "$LR"
cd "$LR" || exit

# We need a repo, but nothing else.
git init -q --bare .

git update-ref refs/heads/$BRANCH $(
{
    {
	sed "s/^[	]*//" <<!
	This is a timestamp branch.

	The script "startjob.sh" is a copy of the currently running script,
	it has just been passed to the "at" command to run in an hour and
	is being attached to this commit right now.

	The script is obviously a quine, though a purist may dispute the
	use of the eval command.

!
    } | echo "100644 blob $(git hash-object -w --stdin)	README.txt"

    date | echo "100644 blob $(git hash-object -w --stdin)	timestamp.txt"
    echo "ATQ='"'"'$V'"'"' ; eval \"\$ATQ\"" | \
	echo "100755 blob $(git hash-object -w --stdin)	startjob.sh"

} | {

echo "tree $(git mktree)
author Autopost <> $(date +%s) +0000
committer Autopost <> $(date +%s) +0000

Tick
" ; } | git hash-object -t commit -w --stdin )

git push -q -f $REPO $BRANCH:$BRANCH

cd /tmp
rm -rf "$LR"

:' ; eval "$ATQ"
