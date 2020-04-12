#! /bin/bash
IP=`hostname -I|cut -f 1 -d " "`
cat mljupy.yaml | sed s/{{REGISTRY}}/${IP}:80/g > /tmp/mlrunapi.yaml

kubectl apply -f /tmp/mlrunapi.yaml >>  deployment.log   2>&1
while [ $? -ne 0 ]
do
	sleep 10
	kubectl apply -f /tmp/mlrunapi.yaml >>  deployment.log   2>&1
done


