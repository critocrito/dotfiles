compile_git_super_status() {
  stack setup
  stack build && stack install
  cp $1/src/.bin/gitstatus $FRESH_BIN_PATH
  rm -rf $1/src/.bin/gitstatus $1/src/.stack-work $1/.stack-work
}

git_super_status () {
  if [ -s $1 ]
  then
    cd $1
    # Only upgrade git-super-status if there is a new remote version.
    git remote update
    if [ $(git rev-parse @) != $(git rev-parse @{u}) ]
    then
      echo "Upgrading git-super-status"
      git pull --rebase
      compile_git_super_status $1
    else
      echo "git-super-status is up-to-date."
    fi
    cd $FRESH_LOCAL
  else
    echo "Installing git-super-status"
    git clone https://github.com/olivierverdier/zsh-git-prompt.git $1
    cd $1
    compile_git_super_status $1
    cd -
  fi
}
