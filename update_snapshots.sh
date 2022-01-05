#!/bin/bash

case $# in
0)
    formats='scl ocl nsd';;
1)
    formats="$1";;
*)
    printf "Usage:\n"
    printf "$0 \t\t\tUpdates all snapshots\n"
    printf "$0 [scl|ocl|nsd] \tUpdates snapshots for the given format\n"
    exit 1;;
esac

function update_snapshots() {
    source ./setup_vars.sh $1

    UPDATED_SNAPSHOTS_COUNT=0
    UPDATED_SNAPSHOTS=""

    echo -n "Updating snapshots for the $1 validator... "

    for filepath in input/$1/*; do
        OUTPUT=$(java -jar $JAR_PATH $filepath)
        SNAPSHOT_FILEPATH=snapshots/$1/$(basename $filepath)
        SNAPSHOT_FILEPATH=${SNAPSHOT_FILEPATH%\.xml}.out
        printf "$OUTPUT" > $SNAPSHOT_FILEPATH
        UPDATED_SNAPSHOTS_COUNT=$((UPDATED_SNAPSHOTS_COUNT + 1))
        UPDATED_SNAPSHOTS="$UPDATED_SNAPSHOTS> $SNAPSHOT_FILEPATH\n"
    done

    echo "Done !"
    printf "\n=== Updated snapshots: $UPDATED_SNAPSHOTS_COUNT ===\n"
    printf "$UPDATED_SNAPSHOTS"
}

for format in $formats; do
    update_snapshots $format
done

exit 0
