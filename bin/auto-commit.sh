#!/bin/sh

help() {
  echo "Usage:"
  echo "  auto-commit commit -r <repo>"
  echo "  auto-commit sync -r <repo> [-A|-R <remote>]"
  echo ""
  echo "Commands:"
  echo "  commit      Commit changes and new files."
  echo "  sync        Sync the repository with it's remotes."
  echo "  help        This message."
  echo ""
  echo "Options:"
  echo "  -r <repo>   The path <repo> points to the repository."
  echo "  -A          Sync with git-annex."
  echo "  -R <remote> Sync only <remote>."
}

verify_branch() {
  branch="$1"

  if ! [ "$(git rev-parse --abbrev-ref HEAD)" = "$branch" ]
  then
    echo "ERROR: $branch branch not checked out" >&2
    exit 1
  fi
}

commit() {
  if [ "$(git status --porcelain)" ]
  then
    # FIXME: Files that are renamed are marked as deleted.
    commit=$(git status --porcelain | awk '
BEGIN {
  new="";
  mod="";
  add="";
  del="";
  result="";
}
 $1=="??" {new=new (new == "" ? "" : ", ") $2}
 $1=="M" {mod=mod (mod == "" ? "" : ", ") $2}
 $1=="A" {add=add (add == "" ? "" : ", ") $2}
 $1=="D" {del=del (del == "" ? "" : ", ") $2}
END {
 newMsg=(new == "" ? "" : "Add " new ".");
 modMsg=(mod == "" ? "" : "Update " mod ".");
 modMsg=(add == "" ? "" : "Add " add ".");
 modMsg=(del == "" ? "" : "Delete " del ".");
 print newMsg (modMsg == "" ? "" : " ") modMsg
}')
    git add --all . && git commit -a -m "$commit"
  fi
}

sync() {
  remote="$1"

  if [ -z "$remote" ];
  then
    git remote | while read -r rem; do
      git pull "$rem" master
      git push "$rem" master
    done
  else
    git pull "$remote" master
    git push "$remote" master
  fi
}

sync_annex() {
  remote="$1"

  if [ -z "$remote" ];
  then
    git annex sync --content
  else
    # FIXME: The remote is not recognized. The man page says this is good.
    git annex sync "$remote" --content
  fi
}

subcommand=$1
shift

case "$subcommand" in
  commit)
    op="$subcommand"

    while getopts ":r:" opt; do
      case ${opt} in
        r)
          repo="$OPTARG"
          ;;
        \?)
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        :)
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))
    ;;
  sync)
    op="$subcommand"

    while getopts ":r:AR:" opt; do
      case ${opt} in
        r)
          repo="$OPTARG"
          ;;
        A)
          git_annex="yes"
          ;;
        R)
          remote="$OPTARG"
          ;;
        \?)
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        :)
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))
    ;;
  help)
    help
    exit 0
    ;;
  *)
    echo "Unknown sub-command: $subcommand"
    help
    exit 1
    ;;
esac

case "$op" in
  commit)
    cd "$repo" || exit 1

    verify_branch "master"

    commit

    cd - || exit 1
    ;;

  sync)
    cd "$repo" || exit 1

    verify_branch "master"

    if [ -z "$git_annex" ];
    then
      sync "$remote"
    else
      sync_annex "$remote"
    fi

    cd - || exit 1
    ;;
  *)
    echo "Error: no op."
    exit 1
    ;;
esac

exit 0
