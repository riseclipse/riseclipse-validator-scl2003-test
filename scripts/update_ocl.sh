#!/bin/bash

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "$SCRIPTS_DIR/config.env"
. "$SCRIPTS_DIR/utils.sh"

usage() {
    printf "Usage: $0 [OPTION...]\n\n"
    printf "Updates OCL validation files from the given branch by downloading them to the desired target directory.\n"
    printf "Options:\n"
    printf -- "-h --help        \tShow this help message\n"
    printf -- "-r --remove      \tRemove previous versions of OCL files.\n"
    printf -- "-b --branch      \tThe branch of the OCL git repository to pull validation files from.\n"
    printf                 "\t\t\tDefault is 'master'.\n"
    printf -- "-o --out-dir     \tThe directory in which you want to store OCL files.\n"
    printf                 "\t\t\tDefault is '<ROOT>/ocl' where <ROOT> is the root of the testing repository.\n"
}

OPTS=$(getopt -o hrb:o: -l help,remove,branch:,out-dir: -- "$@")

if [ $? -ne 0 ]; then
    echo "Options parsing failed, exiting..."
    exit 1
fi

eval set -- "$OPTS"

REMOVE=0

while true; do
    case "$1" in
        -h | --help)
            usage
            exit 0;;
        -r | --remove)
            REMOVE=1
            ;;
        -b | --branch)
            arg_required "$1" "$2"
            OCL_BRANCH="$2"
            shift;;
        -o | --out-dir)
            arg_required "$1" "$2"
            OCL_OUTPUT_DIR="$2"
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
    echo "Invalid argument: $1" 1>&2
    exit 1
fi

if [ -z "$OCL_BRANCH" ]; then
    OCL_BRANCH='master'
fi

if [ -z "$OCL_OUTPUT_DIR" ]; then
    OCL_OUTPUT_DIR="$ROOT_DIR/ocl"
fi

if [ "$REMOVE" -eq 1 ]; then
    rm -r "$OCL_OUTPUT_DIR"/*
fi

mkdir -p "$OCL_OUTPUT_DIR"

TMP_DIR="$ROOT_DIR/tmp"

echo -n "Fetching OCL files from distant '$OCL_BRANCH' branch... "
git clone --quiet --depth 1 --branch "$OCL_BRANCH" "$OCL_REPOSITORY" "$TMP_DIR"
echo "Done."

OCL_FILES="$TMP_DIR/fr.centralesupelec.edf.riseclipse.iec61850.scl.ocl/*"

echo -n "Copying OCL files to '$OCL_OUTPUT_DIR'... "
cp -R $OCL_FILES "$OCL_OUTPUT_DIR"
rm -rf "$TMP_DIR"
echo "Done."

exit 0
