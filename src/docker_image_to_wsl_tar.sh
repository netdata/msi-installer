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

echo "Modifying netdata.conf..."
cat << EOF | docker exec -i netdatatmp bash -c 'cat >> /etc/netdata/netdata.conf'
[plugins]
	timex = no
	checks = no
	idlejitter = no
	tc = no
	diskspace = no
	proc = no
	cgroups = no
	enable running new plugins = no
	slabinfo = no
	python.d = no
	perf = no
	statsd = no
	ioping = no
	fping = no
	nfacct = no
	go.d = yes
	apps = no
	ebpf = no
	charts.d = no
EOF

echo "Fixing log files..."
docker exec netdatatmp bash -c "rm -f /var/log/netdata/*"

echo "Exporting tar file..."
docker export netdatatmp > netdata.tar

echo "Stopping temporary container..."
docker stop netdatatmp

echo "Deleting temporary container..."
docker rm netdatatmp
