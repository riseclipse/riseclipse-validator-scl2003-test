#!/bin/bash

# Setting up required variables
SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "$SCRIPTS_DIR/setup_vars.sh"

CREATED_SNAPSHOTS_COUNT=0
CREATED_SNAPSHOTS=""
PASSED_TESTS_COUNT=0
PASSED_TESTS=""
FAILED_TESTS_COUNT=0
FAILED_TESTS=""

echo -n "Running tests... "

for filepath in "${SCL_PATHS[@]}"; do
    OUTPUT=$(java -jar "$JAR_PATH" $JAR_OPTS "$filepath" $OCL_PATHS $NSD_PATHS)

    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi

    ORDERED_OUTPUT=$(printf "$OUTPUT" |sort)

    SNAPSHOT_FILEPATH="$SCL_ROOT_DIR/snapshots/$(basename "$filepath")"
    SNAPSHOT_FILEPATH="${SNAPSHOT_FILEPATH%.*}.out"

    if [ ! -f "$SNAPSHOT_FILEPATH" ]; then
        mkdir -p "$SCL_ROOT_DIR/snapshots"
        printf "$OUTPUT" > "$SNAPSHOT_FILEPATH"
        CREATED_SNAPSHOTS_COUNT=$((CREATED_SNAPSHOTS_COUNT + 1))
        CREATED_SNAPSHOTS="$CREATED_SNAPSHOTS> $SNAPSHOT_FILEPATH\n"
        continue
    fi

    SNAPSHOT=$(cat "$SNAPSHOT_FILEPATH")
    ORDERED_SNAPSHOT=$(printf "$SNAPSHOT" |sort)

    if [ "$ORDERED_OUTPUT" = "$ORDERED_SNAPSHOT" ]; then
        PASSED_TESTS_COUNT=$((PASSED_TESTS_COUNT + 1))
        PASSED_TESTS="$PASSED_TESTS> $filepath\n"
    else
        FAILED_TESTS_COUNT=$((FAILED_TESTS_COUNT + 1))
        DISPLAYED_ERROR="\tExpected:\n$SNAPSHOT\n\tGot:\n$OUTPUT"
        FAILED_TESTS="$FAILED_TESTS\n> $filepath\n$DISPLAYED_ERROR\n"
    fi
done

echo "Done !"

if [ $CREATED_SNAPSHOTS_COUNT -gt 0 ]; then
    printf "\n=== Created snapshots: $CREATED_SNAPSHOTS_COUNT ===\n"
    printf "$CREATED_SNAPSHOTS"
fi

if [ $PASSED_TESTS_COUNT -gt 0 ]; then
    printf "\n=== Passed tests: $PASSED_TESTS_COUNT ===\n"
    printf "$PASSED_TESTS"
fi

if [ $FAILED_TESTS_COUNT -gt 0 ]; then
    printf "\n=== Failed tests: $FAILED_TESTS_COUNT ===\n" 1>&2
    printf "$FAILED_TESTS" 1>&2
    #exit 1
fi

printf "\n"

exit 0
