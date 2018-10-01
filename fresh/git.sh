git_has_pullable_tag() {
  local TARGET=$1
  local RETVAL=1

  if [ ! -d "$TARGET" ]
  then
    RETVAL=0
  else
    cd "$TARGET"

    git fetch origin 1> /dev/null
    LATEST_TAG="$(git describe --abbrev=0 --tags --match 'v[0-9]*' origin)"

    if [ "$(git rev-parse @)" != "$(git rev-parse @{$LATEST_TAG} 2> /dev/null)" ]
    then
      RETVAL=0
    fi

    cd - 1> /dev/null
  fi

  return "$RETVAL"
}

git_has_pullable_master() {
  local TARGET=$1
  local RETVAL=1

  if [ ! -d "$TARGET" ]
  then
    RETVAL=0
  else
    cd "$TARGET"

    git fetch origin 1> /dev/null

    if [ "$(git rev-parse @)" != "$(git rev-parse @{u} 2> /dev/null)" ]
    then
      RETVAL=0
    fi

    cd - 1> /dev/null
  fi

  return "$RETVAL"
}

git_clone_or_pull_tag() {
  local GIT_URL=$1
  local TARGET=$2

  if [ ! -d "$TARGET" ]
  then
    echo "Installing $GIT_URL."
    git clone "$GIT_URL" "$TARGET" 1> /dev/null
  fi

  cd "$TARGET"

  git fetch --tags origin 1> /dev/null
  LATEST_TAG="$(git describe --abbrev=0 --tags --match 'v[0-9]*' origin)"

  if [ "$(git rev-parse @)" != "$(git rev-parse @{$LATEST_TAG} 2> /dev/null)" ]
  then
    echo "Upgrading $TARGET to $LATEST_TAG"
    git checkout "$LATEST_TAG" 2> /dev/null
  fi

  cd - 1> /dev/null
}

git_clone_or_pull_master() {
  local GIT_URL=$1
  local TARGET=$2

  if [ ! -d "$TARGET" ]
  then
    echo "Installing $GIT_URL."
    git clone "$GIT_URL" "$TARGET" 1> /dev/null
  else
    cd "$TARGET"

    git fetch origin 1> /dev/null

    if [ "$(git rev-parse @)" != "$(git rev-parse @{u} 2> /dev/null)" ]
    then
      echo "Upgrading $TARGET to latest master"
      git checkout master 2> /dev/null
    fi

    cd - 1> /dev/null
  fi
}
