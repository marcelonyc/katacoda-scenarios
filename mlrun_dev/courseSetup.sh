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


mkdir -p /tmp/mlrun/mlrun_course
mkdir /tmp/mlrun/data

sleep 2

./setup_registry.sh >> deployment.log   2>&1


echo "Deploy Jupyter"
./setup_jupyter.sh   >> deployment.log   2>&1


echo "Deploy MLRun API"
./setup_mlrunui.sh >> deployment.log   2>&1

echo
echo 
echo "+++++++++++++++++++++++++++++++++"
echo "  WAITING FOR SERVICES TO START "
echo "+++++++++++++++++++++++++++++++++"

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

cp *.ipynb /tmp/mlrun/mlrun_course/.

kubectl exec -d `kubectl get pods |grep jupyter |awk '{print $1}'` /tmp/start_mlrun.sh

echo "+++++++++++++++++++++" >>  deployment.log   2>&1
echo "DEPLOYMENT COMPLETED"  >>  deployment.log   2>&1
echo "+++++++++++++++++++++" >>  deployment.log   2>&1


