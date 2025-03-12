#!/usr/bin/env bash
files=( *.sh )
for file in ${files[@]}; do
    while IFS= read -r line;do
        echo $line
    done < "$file"
done
