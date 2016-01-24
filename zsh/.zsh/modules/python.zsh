###
# Functions
###

has_python() { _has_cmd python }

is_virtualenv() {
  local ret=1

  [[ $VIRTUAL_ENV ]] && ret=0

  return ${ret}
}

python_version() {
  if has_python;
  then
     echo $(python -V 2>&1 | cut -f 2 -d ' ')
  fi
}

python_virtualenv() {
  if is_virtualenv;
  then
    echo $(basename $VIRTUAL_ENV)
  fi
}
