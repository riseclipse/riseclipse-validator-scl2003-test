#!/bin/bash

# Setting up required variables
SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "$SCRIPTS_DIR/setup_vars.sh"

UPDATED_SNAPSHOTS_COUNT=0
UPDATED_SNAPSHOTS=""

echo -n "Updating snapshots... "

for filepath in "${SCL_PATHS[@]}"; do
    OUTPUT=$(java -jar "$JAR_PATH" $JAR_OPTS "$filepath" $OCL_PATHS $NSD_PATHS)

    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi

    SNAPSHOT_FILEPATH="$SCL_ROOT_DIR/snapshots/$(basename "$filepath")"
    SNAPSHOT_FILEPATH="${SNAPSHOT_FILEPATH%.*}.out"
    printf "$OUTPUT" > "$SNAPSHOT_FILEPATH"
    UPDATED_SNAPSHOTS_COUNT=$((UPDATED_SNAPSHOTS_COUNT + 1))
    UPDATED_SNAPSHOTS="$UPDATED_SNAPSHOTS> $SNAPSHOT_FILEPATH\n"
done

echo "Done !"
printf "\n=== Updated snapshots: $UPDATED_SNAPSHOTS_COUNT ===\n"
printf "$UPDATED_SNAPSHOTS\n"

exit 0
