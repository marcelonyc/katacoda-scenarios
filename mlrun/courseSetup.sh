git clone http://github.com/mlrun/mlrun
# Wait for Kubernetes to come up
kubectl get pods > /dev/null
while [ $? -ne 0 ]
do
        sleep 10
	kubectl get pods > /dev/null
done
kubectl run nginx --image=nginx --replicas=1