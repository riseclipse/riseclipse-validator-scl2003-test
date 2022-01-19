#!/bin/bash

run_tests() {
    CREATED_SNAPSHOTS_COUNT=0
    CREATED_SNAPSHOTS=""
    PASSED_TESTS_COUNT=0
    PASSED_TESTS=""
    FAILED_TESTS_COUNT=0
    FAILED_TESTS=""

    echo -n "Running tests... "

    for filepath in $SCL_PATHS; do
        OUTPUT=$(java -jar $JAR_PATH $filepath $OCL_PATHS $NSD_PATHS)

        SNAPSHOT_FILEPATH=scl/snapshots/$(basename $filepath)
        SNAPSHOT_FILEPATH=${SNAPSHOT_FILEPATH%.*}.out

        if [ ! -f $SNAPSHOT_FILEPATH ]; then
            if [ ! -d scl/snapshots ]; then
                mkdir -p scl/snapshots
            fi
            printf "$OUTPUT" > $SNAPSHOT_FILEPATH
            CREATED_SNAPSHOTS_COUNT=$((CREATED_SNAPSHOTS_COUNT + 1))
            CREATED_SNAPSHOTS="$CREATED_SNAPSHOTS> $SNAPSHOT_FILEPATH\n"
            continue
        fi

        SNAPSHOT=$(cat $SNAPSHOT_FILEPATH)

        if [ "$OUTPUT" = "$SNAPSHOT" ]; then
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
        exit 1
    fi

    printf "\n"
}

# Setting up required variables
. ./setup_vars.sh

run_tests

exit 0
