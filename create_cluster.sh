num_containers=2
if ! which terraform >/dev/null 2>&1 ;
then
    echo "need terraform"
    exit 1
fi

if ! which kubectl >/dev/null 2>&1 ;
then
    echo "need kubectl"
    exit 1
fi

if ! which python >/dev/null 2>&1 ;
then
    echo "need python3"
    exit 1
fi

if ! which pip >/dev/null 2>&1 ;
then
    echo "need pip"
    exit 1
fi

pip install aliyun-python-sdk-core-v3
pip install aliyun-python-sdk-cs

echo "Initializing Terraform"
terraform init
echo "Done Initializing Terraform"

echo "Build Infrastructure with Terraform"
terraform apply
echo "Done Building Infrastructure"

echo "Get and Set .kube/config"
python get_kubeconfig.py
echo "Done setting .kube/config"

echo "Create config need by k8s"
python create_yaml.py
echo "Done creating config"


echo "Create K8S Cluster"
kubectl create namespace jupyter
kubectl apply -f ./k8s/1_jupyter-nas.yaml -n jupyter
cs_url=$(python get_k8s_url.py)
./k8s/2_kubectl_apply.sh ${num_containers} ${cs_url}
echo "Maybe Creating K8S Cluster takes a while"


echo "Please wait."
while :
do
    flag=0
    for status in $(kubectl get pods -n jupyter | sed -E 's/[ \t]+/ /g' | cut -d " " -f 3 | sed '1d') ;
    do
        if [ $status != "Running" ] ;
        then
            flag=1
        fi
    done
    if [ $flag = 0 ] ;
    then
        break
    fi
    echo -n "."
    sleep 5
done
echo

for pod in $(kubectl get po -n jupyter | grep user | cut -d ' ' -f 1)  ;
do
    token=$(kubectl logs $pod -n jupyter | grep "] http://user" | cut -d '=' -f 2)
    user=$(echo $pod | cut -d '-' -f 1)
    echo "${pod},http://${user}.${cs_url}?token=${token}"
done