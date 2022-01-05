#!/bin/bash

source ./setup_vars.sh $*

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
