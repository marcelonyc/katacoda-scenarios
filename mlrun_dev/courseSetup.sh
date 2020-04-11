#! /bin/bash 

# Wait for Kubernetes to come up

exec 2>&1
exec >> deployment.log


kubectl get pods > /dev/null
while [ $? -ne 0 ]
do
        sleep 10
	kubectl get pods > /dev/null
done

echo "Create PVC and PV"
kubectl apply -f pv_local.yaml >> deployment.log   2>&1

echo "Create Nginix"
kubectl run nginx --image=nginx --replicas=1  deployment.log 2>&1

kubectl get pods >>  deployment.log 2>&1

mkdir /tmp/mlrun
mkdir /tmp/mlrun/data

./setup_registry.sh >> deployment.log   2>&1

echo "Build image"
docker build -t mlrun/jupy - < Dockerfile.jupy >>  deployment.log   2>&1

echo "Deploy Jupyter"
kubectl apply -f mljupy.yaml >>  deployment.log   2>&1


echo "Deploy MLRun API"
./setup_mlrunapi.sh >> deployment.log   2>&1

kubectl get pods|grep mlrun-ui > /dev/null
while [ $? -ne 0 ]
do
     sleep 10
     kubectl get pods|grep mlrun-ui > /dev/null
done

kubectl get pods|grep jupy|grep Runn > /dev/null
while [ $? -ne 0 ]
do
     sleep 10
     kubectl get pods|grep jupy|grep Runn > /dev/null
done
chown -R 1000 /tmp/mlrun
clear
echo
echo
echo
echo

echo "+++++++++++++++++++++" >>  deployment.log   2>&1
echo "DEPLOYMENT COMPLETED"  >>  deployment.log   2>&1
echo "+++++++++++++++++++++" >>  deployment.log   2>&1
