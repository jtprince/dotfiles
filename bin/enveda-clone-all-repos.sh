#!/bin/bash

repos="
bel-apocrypha
bel-dump
benchling-pull-service
cube
curation-system
dl-spectra
envedatx.github.io
frontend
grounding-api
harmonizer
integrator
kg-assembly
kg-curation
kg-db
kg-edge-prediction
kg-knowledgebase
kg-sources
kg-ui
kg-web-sources
knowledge-repo
literature-app
literature-pipeline
metabolomics
neurite-pipeline
nlp-pipeline
nlp-sources
nlp-utils
notebooks
pyenveda
scripts
thermorawparser
transcriptomics-analyses
"

for dir in $repos; do
    if [[ -d "$dir" ]]; then
        echo "$dir already exists! skipping"
    else
        git clone "git@github.com:enveda/$dir.git"
    fi
done
