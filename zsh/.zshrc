ZSH=$HOME/.zsh

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
[[ -z ${ZSH_CACHE_DIR} ]] && ZSH_CACHE_DIR="$ZSH/cache"
mkdir -p $ZSH_CACHE_DIR

# Configure the output format of the history command
HIST_STAMPS="dd.mm.yyyy"

source $ZSH/colors.zsh
source $ZSH/setopt.zsh
source $ZSH/exports.zsh
source $ZSH/functions.zsh
source $ZSH/completion.zsh
source $ZSH/bindings.zsh
source $ZSH/history.zsh
source $ZSH/grep.zsh
source $HOME/.aliases

for file ($HOME/.zsh.d/*.zsh); do
  source $file
done

for module ($ZSH/modules/*zsh); do
  source $module
done

# Only if we have loaded everything else, can we set the prompt.
source $ZSH/prompt.zsh

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && source ~/.localrc
