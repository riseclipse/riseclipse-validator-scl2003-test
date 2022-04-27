#!/bin/bash

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "$SCRIPTS_DIR/config.env"
. "$SCRIPTS_DIR/utils.sh"

usage() {
    printf "Usage: $0 [OPTION...] URL\n\n"
    printf "Updates NSD validation files from the given URL by downloading them to the desired target directory.\n"
    printf "Options:\n"
    printf -- "-h --help        \tShow this help message\n"
    printf -- "-c --clean       \tRemove unneeded .xml and .xsd files\n"
    printf -- "-o --out-dir     \tThe directory in which you want to store NSD files.\n"
    printf                 "\t\t\tDefault is '<ROOT>/nsd' where <ROOT> is the root of the testing repository.\n"
}

OPTS=$(getopt -o hco: -l help,clean,out-dir: -- "$@")

if [ $? -ne 0 ]; then
    usage
    exit 1
fi

eval set -- "$OPTS"

CLEAN=0

while true; do
    case "$1" in
        -h | --help)
            usage
            exit 0;;
        -c | --clean)
            CLEAN=1
            ;;
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

if [ -n "$1" ]; then
    NSD_URL=$1
else
    echo "missing URL" 1>&2
    usage
    exit 1
fi

if [ -n "$2" ]; then
    echo "Invalid argument: $2" 1>&2
    usage
    exit 1
fi

FILENAME=$(basename $NSD_URL)
EXTENSION=${FILENAME##*.}

if [ $EXTENSION != "zip" -a $EXTENSION != "ZIP" ]; then
    echo "not a zip file: $FILENAME" 1>&2
    exit 1
fi

if [ -z "$NSD_OUTPUT_DIR" ]; then
    NSD_OUTPUT_DIR="$ROOT_DIR/nsd"
fi

mkdir -p "$NSD_OUTPUT_DIR"

echo "Fetching NSD files from $NSD_URL..."
wget -q "$NSD_URL"
echo "Unzipping NSD files in $NSD_OUTPUT_DIR"
unzip -q -u $FILENAME -d "$NSD_OUTPUT_DIR"
rm $FILENAME

if [ "$CLEAN" -eq 1 ]; then
    echo "Cleaning..."
    rm "$NSD_OUTPUT_DIR"/*.xml "$NSD_OUTPUT_DIR"/*.xsd
fi

exit 0
