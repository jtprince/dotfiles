#!/bin/bash


repos=`github-list-all-org-repos.py enveda`

for dir in $repos; do
    if [[ -d "$dir" ]]; then
        echo "$dir already exists! skipping"
    else
        git clone "git@github.com:enveda/$dir.git"
    fi
done
