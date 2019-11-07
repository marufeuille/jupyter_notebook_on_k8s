#!/bin/bash
#
# 2019/08 created by Qiu
# -----------------------------------------------
# Description:
#
#
# Usage:
#  $ ./2_kubectl_apply.sh <The num of user> <Cluster domain>
#
# Params:
#  <The num of user>    :    2
#  <Cluster domain>     :   *******.ap-northeast-1.alicontainer.com
#
# -----------------------------------------------


PARAMS=$#

# Jupyterを利用するユーザーの数
NUM_USER=$1

# K8s ClusterのDomain
CLUSTER_DOMAIN=$2

# 設定前のJupyter file
JUPYTER_TEPLATE_YAML="./k8s/0_jupyter-user-template.yaml.tmpl"

# 設定前のIngress yaml
INGRESS_YAML="./k8s/0_ingress.yaml"

# Ingress rule template
INGRESS_RULE="./k8s/0_rules_template.txt"

# Namespace
NAMESPACE="jupyter"

# ====================================================
# Usage
# ====================================================
function usage() {
cat <<_EOT_

Usage:
  $ $0 <The num of user> <Cluster domain>
Params:
  <The num of user>    :    2
  <Cluster domain>     :   *******.ap-northeast-1.alicontainer.com

_EOT_
exit 1
}

# ====================================================
# Check params
# ====================================================
function check_params () {

  if [ ${1} != 2 ]; then 
    usage
  fi
  return 0
}

# ====================================================
# Start
# ====================================================

# paramsの確認
check_params ${PARAMS}

touch list.csv
######################################
# UserごとにDeployment, Serviceの作成
######################################
for ((i=1;i<=${NUM_USER};i++))
do
    response=`cat ${JUPYTER_TEPLATE_YAML} | sed s/JUPYTER_USER/user$i/`
    echo -e "--------------- YAML of user$i --------------- \n"
    echo "${response}"
    echo -e "---------------------------------------------- \n"
    echo -e "----- kubectl apply -f YAML of user$i -----"
    export TOKEN=$(python pass_gen.py)
    export i
    export JUPYTER_TEPLATE_YAML
    eval "echo \"$(cat ${JUPYTER_TEPLATE_YAML} | sed s/JUPYTER_USER/user$i/)\"" 
    eval "echo \"$(cat ${JUPYTER_TEPLATE_YAML} | sed s/JUPYTER_USER/user$i/)\"" | kubectl apply -n ${NAMESPACE} -f -
    echo -e "----------------------------------------------\n"
    echo "user${i},http://user${i}.${CLUSTER_DOMAIN}/?token=${TOKEN}" >> list.csv
done

######################################
# Ingress の作成
######################################
cat ${INGRESS_YAML} > .ingress.yaml
for ((i=1;i<=${NUM_USER};i++))
do
    cat ${INGRESS_RULE} | sed s/JUPYTER_USER/user${i}/ | sed s/CLUSTER_DOMAIN/${CLUSTER_DOMAIN}/ >> .ingress.yaml
done
echo -e "--------------- Ingress YAML ---------------"
cat .ingress.yaml
kubectl apply -n ${NAMESPACE} -f .ingress.yaml
echo -e "------------------------------------------- \n"