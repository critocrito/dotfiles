compile_git_super_status() {
  local TARGET=$1

  cd $TARGET
  stack clean
  stack setup
  stack build && stack install
  cd - 1> /dev/null
}
