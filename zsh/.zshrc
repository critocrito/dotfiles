source ~/.aliases

source ~/.zsh/functions
source ~/.zsh/completion
source ~/.zsh/config

source ~/.zsh.d/*.rc

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && source ~/.localrc
