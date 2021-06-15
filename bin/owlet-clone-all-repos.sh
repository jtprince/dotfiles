#!/bin/bash

# The canonical list of all repos platform is responsible for is here:
# https://docs.google.com/spreadsheets/d/18dErdftIyNdk73Yk2LmAlLfoAGenm0RsAWgEqdTj8aw/edit?usp=sharing

# we also add in platform-team-documentation and platform-on-call

repos="
platform-team-documentation
platform-on-call
accounts
accounts-v2
aoni-response-subscriber
app-device-registration
ayla-exporter
ayla-sso
ayla-token
backfill-data-log-file-publisher
band-history
band-history-processor
band-log-file-subscriber
band-session-files-converter-subscriber
band-session-files-subscriber
beam
BlazeMeter
camera-kms
camera-password-rotation-subscriber
care-scripts
certificate-signer
ci-kit
common-schemas
data-log-file-publisher
device-events-subscriber
device-manager
device-manufacturing
device-manufacturing-subscriber
device-registration
device-replicator
devices
devops
devops-scripts
dss-alert-subscriber
dss-web-socket
eslint-config-owlet
firebase-auth
firebase-profiler
firebase-profiler-subscriber
firmware
key-generator
mydbr
openapi-generator-templates
owlet-management-portal
owlet-management-portal-backend
owletFirebase
OwletVideoProto
powlet
registration-publisher
remote-config
RTDB-replacement-design
sftp
sftp-manufacturing
skeleton-flask
skeleton-subscriber
sleep-data
sock3-history-summary-subscriber
sock3-red-alert-summary-subscriber
sock3-vital-data-subscriber
sockv3_parser
spanner-backup
trigger-cleanup
platform_postman
trigger-wrapper
tutk-allocate-subscriber
tutk-manager
user-mapper
vital-data
"


for dir in $repos; do
    if [[ -d "$dir" ]]; then
        echo "$dir already exists! skipping"
    else
        git clone "git@github.com:OwletCare/$dir.git"
    fi
done
