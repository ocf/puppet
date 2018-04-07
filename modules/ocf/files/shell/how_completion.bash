_how () {
    COMPREPLY=()

    # cur_word is the word the user wants completed.
    local cur_word=${COMP_WORDS[COMP_CWORD]}
    # Strip an initial quote from cur_word if user has entered one.
    cur_word=${cur_word#\'}
    cur_word=${cur_word#\"}
    # Don't complete if len(cur_word) < 2, or else the completion function will
    # read too many files and take too long.
    if [ ${#cur_word} -lt 2 ]; then
        return
    fi

    # Escape *, ?, [, and ] in cur_word to make a glob pattern
    local pattern=${cur_word}
    pattern=${pattern//\*/\\*}
    pattern=${pattern//\?/\\?}
    pattern=${pattern//[/\\[}
    pattern=${pattern//]/\\]}

    # Get a list of all executables in $PATH beginning with cur_word
    local executables=$(echo -n "$PATH" | \
                               xargs -d : -n 1 -I {} -- find -L {} \
                                     -maxdepth 1 -mindepth 1 \
                                     -name "${pattern}*" -type f -executable \
                                     -print 2> /dev/null)

    local IFS=$'\n'
    local exec
    for exec in $executables; do
        # Add executable as a suggestion if it's a text file
        if file -ib "$(readlink -f "$exec")" | grep -q ^text; then
            COMPREPLY+=( "$(basename "$exec")" )
        fi
    done
}

complete -F _how how
