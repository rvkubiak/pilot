#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x

function usage() {
  echo "$0 \
    -i <gcloud project ID name> \
    -t <tag name to apply to artifacts> \
    -v <version to apply instead of tag>"
  exit 1
}

# Initialize variables
TAG_NAME=""
VERSION_OVERRIDE=""

# Handle command line args
while getopts t:v: arg ; do
  case "${arg}" in
    t) TAG_NAME="${OPTARG}";;
    v) VERSION_OVERRIDE="${OPTARG}";;
    *) usage;;
  esac
done

if [ ! -z "${VERSION_OVERRIDE}" ] ; then
  version="${VERSION_OVERRIDE}"
elif [ ! -z "${TAG_NAME}" ] ; then
  version="${TAG_NAME}"
else
  echo "Either -t or -v is a required argument."
  usage
fi

# Build environment setup
mkdir -p /tmp/gopath/src/istio.io
ln -s /workspace /tmp/gopath/src/istio.io/pilot
cd /tmp/gopath/src/istio.io/pilot
touch platform/kube/config

# Download and set the credentials for docker.io/istio hub
#mkdir -p "${HOME}/.docker"
#gsutil cp gs://istio-secrets/dockerhub_config.json.enc "${HOME}/.docker/config.json.enc"
#gcloud kms decrypt \
#       --ciphertext-file="${HOME}/.docker/config.json.enc" \
#       --plaintext-file="${HOME}/.docker/config.json" \
#       --location=global \
#       --keyring=Secrets \
#       --key=DockerHub

# Build istioctl binaries and upload to GCS
./bin/upload-istioctl -r -p gs://istio-release/releases/"${version}"/istioctl

#./bin/push-docker -hub gcr.io/istio-io,docker.io/istio -tag "${version}"
