#!/bin/bash

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "$SCRIPTS_DIR/config.env"
. "$SCRIPTS_DIR/utils.sh"

usage() {
    printf "Usage: $0 [OPTION...]\n\n"
    printf "Updates NSD validation files from the given URL by downloading them to the desired target directory.\n"
    printf "Files will only be overwritten if they were updated since the last download.\n\n"
    printf "Options:\n"
    printf -- "-h --help        \tShow this help message\n"
    printf -- "-u --url         \tThe URL to download NSD validation files from.\n"
    printf                 "\t\t\tDefault is '$DEFAULT_NSD_URL'.\n"
    printf -- "-o --out-dir     \tThe directory in which you want to store NSD files.\n"
    printf                 "\t\t\tDefault is '<ROOT>/nsd' where <ROOT> is the root of the testing repository.\n"
}

OPTS=$(getopt -o hu:o: -l help,url:,out-dir: -- "$@")

if [ $? -ne 0 ]; then
    echo "Options parsing failed, exiting..."
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
        -h | --help)
            usage
            exit 0;;
        -u | --url)
            arg_required "$1" "$2"
            NSD_URL="$2"
            shift;;
        -o | --out-dir)
            arg_required "$1" "$2"
            NSD_OUTPUT_DIR="$2"
            shift;;
        --)
            shift
            break;;
        *)
            echo "Unrecognized option: $1" 1>&2
            usage
            exit 1;;
    esac
    shift
done

if [ -z "$NSD_URL" ]; then
    NSD_URL="$DEFAULT_NSD_URL"
fi

if [ -z "$NSD_OUTPUT_DIR" ]; then
    NSD_OUTPUT_DIR="$ROOT_DIR/nsd"
fi

mkdir -p "$NSD_OUTPUT_DIR"
NSD_ZIP="$NSD_OUTPUT_DIR/nsd.zip"

echo "Fetching NSD files from $NSD_URL..."
wget -q -O "$NSD_ZIP" "$NSD_URL"
unzip -q -u "$NSD_ZIP" -d "$NSD_OUTPUT_DIR"
rm "$NSD_ZIP"
echo "Done."

exit 0
