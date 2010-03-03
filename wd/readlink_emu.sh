absolute_path() {
    local SAVED_PWD="$PWD"
    TARGET="$1"

    #while [ -L "$TARGET" ]; do
    #    DIR=$(dirname "$TARGET")
    #    TARGET=$(readlink "$TARGET")
    #    cd -P "$DIR"
    #    DIR="$PWD"
    #done

    #if [ -f "$TARGET" ]; then
    #    DIR=$(dirname "$TARGET")
    #else
        DIR="$TARGET"
    #fi

    cd -P "$DIR"
    TARGET="$PWD"
    cd "$SAVED_PWD"
    echo "$TARGET"
}
