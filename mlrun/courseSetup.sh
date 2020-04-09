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
kubectl get pods

echo "Build image"
docker build -t mlrun/jupy - < Dockerfile.jupy

echo "Deploy Jupyter"
kubectl apply -f mljupy.yaml
