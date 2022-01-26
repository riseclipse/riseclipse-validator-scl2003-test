arg_required() {
    if [ -z "$2" ]; then
        echo "Option '$1' requires an argument." 1>&2
        exit 1
    fi
}

cd "$SCRIPTS_DIR/.."
ROOT_DIR="$PWD"
cd - 1>/dev/null
