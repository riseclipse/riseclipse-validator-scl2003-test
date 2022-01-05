#!/bin/bash

for format in scl ocl nsd; do
    ./run_tests.sh $format
done

exit 0
