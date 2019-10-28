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
python create-yaml.py
echo "Done creating config"