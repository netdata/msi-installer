docker run -t netdata/netdata bash ls /
dockerContainerID=$(docker container ls -a | grep -i netdata/netdata | awk '{print $1}')
docker export $dockerContainerID > netdata.tar