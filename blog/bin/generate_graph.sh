#!/bin/bash
find "$1" -type f -name "*.dot" | while read -r file; do
    dot $file -Tsvg > ${file%.dot}.svg
    echo $file
done