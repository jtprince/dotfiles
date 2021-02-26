#!/bin/bash

pushd ../sway/
./build.sh

popd

pushd ../i3/
./build.sh

popd
