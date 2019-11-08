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

cat terraform.tf.tmpl | sed s/NUM_USER/$num_containers/ > terraform.tf

echo "Initializing Terraform"
terraform init
echo "Done Initializing Terraform"

echo "Build Infrastructure with Terraform"
terraform apply -auto-approve
echo "Done Building Infrastructure"

echo "Get and Set .kube/config"
python get_kubeconfig.py
echo "Done setting .kube/config"

echo "Create K8S Cluster"
kubectl create namespace jupyter
NFS_SERVER_SHARE=$(python get_nfs_server.py 1)
NFS_SERVER_WORK=$(python get_nfs_server.py 2)
cat k8s/1_jupyter-nas.yaml | sed s/NFS_SERVER_NAME/${NFS_SERVER_SHARE}/ | kubectl apply -n jupyter -f -
for ((i=1; i <= num_containers; i ++ )) do
    cat k8s/3_jupyter-nas-work.yaml | sed s/NFS_SERVER_NAME/${NFS_SERVER_WORK}/  | sed s/USER_ID/${i}/ | kubectl apply -n jupyter -f -
done
cs_url=$(python get_k8s_url.py)
./k8s/2_kubectl_apply.sh ${num_containers} ${cs_url}
echo "Maybe Creating K8S Cluster takes a while"


echo -n "Please wait."
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

cat list.csv