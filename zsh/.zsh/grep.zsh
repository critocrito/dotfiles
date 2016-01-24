GREP_OPTIONS=""
EXCLUDE_FOLDERS="{.bzr,CVS,.git,.hg,.svn}"

GREP_OPTIONS+=" --color=auto"
GREP_OPTIONS+=" --exclude-dir=$EXCLUDE_FOLDERS"

# export grep settings
alias grep="grep $GREP_OPTIONS"

# Enable color in grep
export GREP_COLOR='3;33'

# clean up
unset GREP_OPTIONS
unset EXCLUDE_FOLDERS
