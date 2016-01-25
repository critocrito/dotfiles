precmd(){
  local title_path
  if [ $PWD == $HOME ];
  then
    title_path="~"
  else
    title_path=$PWD:h:t/$PWD:t
  fi

  # set tmux title
  [[ $TMUX ]] && printf "\033k$title_path\033\\"
  # urxvt title
  print -Pn "\e]2;$(collapse_pwd)\a"
}
preexec(){
  # set tmux-title to running program
  printf "\033k$(echo "$1" | cut -d" " -f1)\033\\"

  # set urxvt-title to running program
  print -Pn "\e]2;zsh:$(echo "$1" | cut -d" " -f1)\a"
}
