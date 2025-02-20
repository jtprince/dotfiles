#
# Color grep results
# Examples: http://rubyurl.com/ZXv
#
# export GREP_OPTIONS='--color=auto'
# export GREP_COLOR='1;32'
export GREP_COLORS='mt=1;32'

function grep {
    command grep --color=auto "$@"
}
