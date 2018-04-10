_how () {
    COMPREPLY=()

    # cur_word is the word the user wants completed.
    local cur_word=${COMP_WORDS[COMP_CWORD]}
    # Strip an initial quote from cur_word if user has entered one.
    cur_word=${cur_word#\'}
    cur_word=${cur_word#\"}

    # Escape *, ?, [, and ] in cur_word to make a glob pattern
    local pattern=${cur_word}
    pattern=${pattern//\*/\\*}
    pattern=${pattern//\?/\\?}
    pattern=${pattern//[/\\[}
    pattern=${pattern//]/\\]}

    # Get a list of all non-binary executables in $PATH beginning with cur_word
    local executables
    executables=$(echo -n "$PATH" | \
        xargs -d : -I %% -- find -L %% \
            -maxdepth 1 -mindepth 1 \
            -name "${pattern}*" -type f -executable \
            -exec grep -Il . {} + 2> /dev/null | \
        xargs basename -a)

    mapfile -t COMPREPLY <<< "$executables"
}

complete -F _how how
