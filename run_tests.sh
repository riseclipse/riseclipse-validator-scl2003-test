#!/bin/bash

case $# in
0)
    formats='scl ocl nsd';;
1)
    formats="$1";;
*)
    printf "Usage:\n"
    printf "$0 \t\t\tRuns all tests\n"
    printf "$0 [scl|ocl|nsd] \tRuns tests for the given format\n"
    exit 1;;
esac

function run_tests() {
    source ./setup_vars.sh $1

    CREATED_SNAPSHOTS_COUNT=0
    CREATED_SNAPSHOTS=""
    PASSED_TESTS_COUNT=0
    PASSED_TESTS=""
    FAILED_TESTS_COUNT=0
    FAILED_TESTS=""

    echo -n "Running tests for the $1 validator... "

    for filepath in input/$1/*; do
        OUTPUT=$(java -jar $JAR_PATH $filepath)
        SNAPSHOT_FILEPATH=snapshots/$1/$(basename $filepath)
        SNAPSHOT_FILEPATH=${SNAPSHOT_FILEPATH%\.xml}.out

        if [ ! -f $SNAPSHOT_FILEPATH ]; then
            if [ ! -d snapshots/$1 ]; then
                mkdir -p snapshots/$1
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
}

for format in $formats; do
    run_tests $format
done

exit 0
