#!/bin/bash

function usage() {
    printf "Usage: $0 [-h] [-j <PATH_TO_JAR>] [scl|ocl|nsd]...\n\n"
    printf "Examples:\n"
    printf "$0 \t\t\tUpdate snapshots for all formats\n"
    printf "$0 scl ocl \t\tUpdate snapshots for the SCL and OCL formats\n"
}

function update_snapshots() {
    UPDATED_SNAPSHOTS_COUNT=0
    UPDATED_SNAPSHOTS=""

    echo -n "Updating snapshots for the '$1' format... "

    if [ ! -d "$1/input" ] || [ -z $(ls -A "$1/input") ]; then
        printf "No test found.\n\n"
        return 0
    fi

    for filepath in $1/input/*; do
        OUTPUT=$(java -jar $JAR_PATH $filepath)
        SNAPSHOT_FILEPATH=$1/snapshots/$(basename $filepath)
        SNAPSHOT_FILEPATH=${SNAPSHOT_FILEPATH%.*}.out
        printf "$OUTPUT" > $SNAPSHOT_FILEPATH
        UPDATED_SNAPSHOTS_COUNT=$((UPDATED_SNAPSHOTS_COUNT + 1))
        UPDATED_SNAPSHOTS="$UPDATED_SNAPSHOTS> $SNAPSHOT_FILEPATH\n"
    done

    echo "Done !"
    printf "\n=== Updated snapshots: $UPDATED_SNAPSHOTS_COUNT ===\n"
    printf "$UPDATED_SNAPSHOTS\n"
}

# Setting up required variables
. ./setup_vars.sh $*

for format in $formats; do
    update_snapshots $format
done

exit 0
