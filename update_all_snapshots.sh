#!/bin/bash

for format in scl ocl nsd; do
    ./update_snapshots.sh $format
done

exit 0
