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

echo "Create Nginix"
kubectl run nginx --image=nginx --replicas=1

kubectl get pods >>  deployment.log 2>&1

mkdir /tmp/mlrun
mkdir /tmp/mlrun/data

echo "Build image"
docker build -t mlrun/jupy - < Dockerfile.jupy >>  deployment.log   2>&1

echo "Deploy Jupyter"
kubectl apply -f mljupy.yaml >>  deployment.log   2>&1

kubectl get pods|grep jupy|grep Runn > /dev/null
while [ $? -ne 0 ]
do
     sleep 10
     kubectl get pods|grep jupy|grep Runn > /dev/null
done
echo "+++++++++++++++++++++" >>  deployment.log   2>&1
echo "DEPLOYMENT COMPLETED"  >>  deployment.log   2>&1
echo "+++++++++++++++++++++" >>  deployment.log   2>&1
