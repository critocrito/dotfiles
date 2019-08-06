#!/bin/sh

cd "$HOME/doc/org" || exit 1

# Make sure the master branch is checked out.
if ! [ "$(git rev-parse --abbrev-ref HEAD)" = "master" ]
then
  echo "ERROR: master branch not checked out" >&2
  exit 1
fi

# Only run add/commit if there is anything to add
if [ "$(git status --porcelain)" ]
then
  commit=$(git status --porcelain | awk '
BEGIN {
  new="";
  mod="";
  result="";
}
 $1=="??" {new=new (new == "" ? "" : ", ") $2}
 $1=="M" {mod=mod (mod == "" ? "" : ", ") $2}
END {
 newMsg=(new == "" ? "" : "Add " new ".");
 modMsg=(mod == "" ? "" : "Update " mod ".");
 print newMsg (modMsg == "" ? "" : " ") modMsg
}')
  git add --all . && git commit -a -m "$commit"
fi
