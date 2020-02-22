has_node() { _has_cmd node }

is_nvm() {
  local ret=1

  [[ $NVM_HOME ]] && ret=0

  return ${ret}
}

is_nodejs() {
  local ret=1

  [[ -f package.json ]] && ret=0

  return ${ret}
}

nodejs_version() {
  if has_node;
  then
    local version
    version=$(node -v 2>/dev/null)
    echo ${version:1}
  fi
}
