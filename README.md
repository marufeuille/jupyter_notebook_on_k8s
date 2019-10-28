# jupyter_notebook_on_k8s

## The Alibaba Cloud Infrastrucutre of Jupyter Notebook
![jupyter_alicloud_infra](imgs/jupyter_alicloud_infra.jpg)

## Jupyter on ACK
![jupyter_on_ack](imgs/jupyter_on_k8s.jpg)

## 前提条件
- Alibaba Cloud Python SDK / Aliyuncli が利用できる環境
- terraform, kubectlのバイナリ 

## 構築手順
1. terraform.tfvars.sampleを参考に、terraform.tfvarsを作成
2. create_cluster.shを開き、冒頭のnum_containersを好きな数に書き換える
3. ./create_cluster.sh

## 後始末
1. terraform destroy