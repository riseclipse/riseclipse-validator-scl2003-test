#!/bin/bash

case $# in
0)
    formats='scl ocl nsd';;
1)
    if [ "$1" = "--help" ]; then
        printf "Usage:\n"
        printf "$0 \t\t\t\tUpdates snapshots for all formats\n"
        printf "$0 [scl|ocl|nsd]... \t\tUpdates snapshots for the given formats\n"
        exit 0
    else
        formats="$1"
    fi;;
*)
    formats="$@";;
esac

function update_snapshots() {
    source ./setup_vars.sh

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

for format in $formats; do
    update_snapshots $format
done

exit 0
