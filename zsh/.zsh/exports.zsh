# The URL stuff is shamelessly stolen from oh-my-zsh.
## Load smart urls if available
# bracketed-paste-magic is known buggy in zsh 5.1.1 (only), so skip it there; see #4434
autoload -Uz is-at-least
if [[ $ZSH_VERSION != 5.1.1 ]]; then
  for d in $fpath; do
  	if [[ -e "$d/url-quote-magic" ]]; then
  		if is-at-least 5.1; then
  			autoload -Uz bracketed-paste-magic
  			zle -N bracketed-paste bracketed-paste-magic
  		fi
  		autoload -Uz url-quote-magic
  		zle -N self-insert url-quote-magic
      break
  	fi
  done
fi

# Corrections
alias gist='nocorrect gist'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias sudo='nocorrect sudo'

setopt correct_all

# Set a better default terminal
export TERM='screen-256color'

# Unset LC_ALL so the LC_COLLATE option in /etc/locale.conf takes precedence
export LC_ALL=
export LANG=en_US.UTF-8

export LESS='--ignore-case --raw-control-chars'
export PAGER='most'
export EDITOR='emacsclient -t -a emacs'