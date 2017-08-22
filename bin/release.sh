#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x

# Build environment setup
mkdir -p /tmp/gopath/src/istio.io
ln -s /workspace /tmp/gopath/src/istio.io/pilot
cd /tmp/gopath/src/istio.io/pilot
touch platform/kube/config

# Build istioctl binaries and upload to GCS
./bin/upload-istioctl -r -p gs://$PROJECT_ID/pilot/$TAG_NAME

./bin/push-docker -hub gcr.io/$PROJECT_ID -tag $TAG_NAME
