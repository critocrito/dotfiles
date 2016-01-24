export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
export PYENV_VIRTUALENV_DISABLE_PROMPT="1"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
