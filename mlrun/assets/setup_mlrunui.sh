#!/bin/bash


kubectl apply -f ./mlrunui.yaml >>  deployment.log   2>&1
while [ $? -ne 0 ]
do
	sleep 10
	kubectl apply -f ./mlrunui.yaml >>  deployment.log   2>&1
done
