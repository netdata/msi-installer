cat << EOF | docker run -i --name netdatatemporary --entrypoint /bin/bash netdata/netdata -c 'cat >> /etc/netdata/netdata.conf'
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
docker export netdatatemporary > netdata.tar
docker rm netdatatemporary