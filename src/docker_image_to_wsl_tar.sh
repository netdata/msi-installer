#!/bin/sh

set -e

if [ -z "${1}" ]; then
    tag="latest"
else
    tag="${1}"
fi

echo "Stopping temporary container if running..."
docker stop netdatatmp || true

echo "Deleting temporary container if exists..."
docker rm netdatatmp || true

echo "Pulling latest netdata docker image..."
docker pull "netdata/netdata:${tag}"

echo "Running temporary container..."
docker run -d --name netdatatmp --entrypoint tail "netdata/netdata:${tag}" -f /dev/null

echo "Exporting tar file..."
docker export netdatatmp > netdata.tar

echo "Stopping temporary container..."
docker stop netdatatmp

echo "Deleting temporary container..."
docker rm netdatatmp
