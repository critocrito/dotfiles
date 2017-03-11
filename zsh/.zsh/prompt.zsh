prompt_time() {
  echo "[%T on %D]"
}

prompt_username() {
  echo "%{$fg[magenta]%}%n%{$reset_color%}"
}

prompt_host() {
  echo "%{$fg[yellow]%}%m%{$reset_color%}"
}

prompt_pwd() {
  echo "%{$fg_bold[green]%}$(collapse_pwd)%{$reset_color%}"
}

prompt_machine() {
  if [[ -n $SSH_CONNECTION ]];
  then
    echo "$(prompt_username) at $(prompt_host) in $(prompt_pwd)"
  else
    echo "$(prompt_pwd)"
  fi
}

prompt_haskell() {
  if ! has_function is_cabal; then return; fi

  if is_cabal;
  then
    local sandbox_val="not sandboxed"
    if is_cabal_sandbox;
    then
      sandbox_val="sandboxed"
    fi
    echo "%{$fg[blue]%}haskell: ${sandbox_val} %{$reset_color%}"
  fi
}

prompt_python() {
  if ! has_function is_virtualenv; then return; fi

  if is_virtualenv;
  then
    local -r version=$(python_version)
    local -r venv=$(python_virtualenv)
    echo "%{$fg[blue]%}python: $version/$venv %{$reset_color%}"
  fi
}

prompt_nodejs() {
  if ! has_function is_nodejs; then return; fi
  if ! has_function is_nvm; then return; fi
  if ! has_function nodejs_version; then return; fi

  if is_nodejs;
  then
    local -r version=$(nodejs_version)
    local nvm_val=""
    if ! is_nvm; then nvm_val="/no nvm"; fi
    echo "%{$fg[blue]%}nodejs: ${version}${nvm_val} %{$reset_color%}"
  fi
}

prompt_app_type() {
  echo "$(prompt_python)$(prompt_nodejs)$(prompt_haskell)"
}

prompt_info() {
  echo "$(prompt_time) $(prompt_machine) $(prompt_app_type)$(git_super_status)"
}

prompt_prompt() {
  local -r char="λ"
  echo "Bender do %{$fg_bold[red]%}${char}%{$reset_color%}"
}

###
# Configuration
###

# FIXME: How to handle this??
case "$TERM" in
  "dumb")
    RPROMPT=""
    PROMPT="> "
    ;;
  *)
    RPROMPT=""
    PROMPT='
$(prompt_info)
$(prompt_prompt) '
esac

#  PROMPT='
#$(prompt_time) $(prompt_pwd) $(git_super_status)
#$(cabal_sandbox_info)$(prompt_virtualenv)$(prompt_char) '
