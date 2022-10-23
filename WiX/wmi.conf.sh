cat << EOF > /etc/netdata/go.d/wmi.conf
jobs:
  - name: $(hostname)
    url: http://127.0.0.1:9182/metrics
EOF
