#!/bin/bash

if [ -n "$CATTLE_SCRIPT_DEBUG" ]; then
	set -x
fi

sleep 5
GIDDYUP=/opt/rancher/bin/giddyup

function scaleup {
	# MYIP=$($GIDDYUP ip myip)
  # Using hostname instead of ips to solve this: https://jira.mongodb.org/browse/NODE-746
  MYHOSTNAME=$($GIDDYUP ip myname)
	for IP in $($GIDDYUP ip stringify --delimiter " "); do
		IS_MASTER=$(mongo --host $IP --eval "printjson(db.isMaster())" | grep 'ismaster')
		if echo $IS_MASTER | grep "true"; then
			mongo --host $IP --eval "printjson(rs.add('$MYHOSTNAME.rancher.internal:27017'))"
			return 0
		fi
	done
	return 1
}

# Script starts here
if [ $($GIDDYUP service scale --current) -gt 3 ]; then
	scaleup
fi
