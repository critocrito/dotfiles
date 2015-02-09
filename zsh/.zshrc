source ~/.aliases

source ~/.zsh/functions
source ~/.zsh/completion
source ~/.zsh/config

# We source in a loop each config snippet in ~/.zsh.d. Sourcing them with a *
# wild card didn't read all snippets correctly.
for file in ~/.zsh.d/*.rc; do source $file; done

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && source ~/.localrc
