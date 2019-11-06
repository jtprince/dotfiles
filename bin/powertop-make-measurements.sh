#!/bin/bash

for ((i=0;i<=$1;i++)); do
    powertop --csv
    sleep 20
done
