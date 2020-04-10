#!/bin/bash

IP=`hostname -I|cut -f 1 -d " "`
cat mlrun-local.yaml | sed s/{{REGISTRY}}/${IP}:5000/g > /tmp/mlrunapi.yaml
kubectl apply -f /tmp/mlrunapi.yaml >>  deployment.log   2>&1
