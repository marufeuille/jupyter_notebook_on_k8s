from aliyunsdkcore.client import AcsClient
from aliyunsdkcs.request.v20151215 import DescribeClusterUserKubeconfigRequest
import json
import os

with open("./terraform.tfvars") as f:
    for line in f.readlines():
        if line[:10] == "access_key":
            accesskey = line.split("=")[1].strip()[1:-1]
        elif line[:10] == "secret_key":
            secretkey = line.split("=")[1].strip()[1:-1]
        elif line[:6] == "region":
            region = line.split("=")[1].strip()[1:-1]
        
with open("./terraform.tfstate") as f:
    jsons = json.load(f)
    cs_id = ""
    for r in jsons["resources"]:
        if r["type"] == "alicloud_cs_managed_kubernetes":
            cs_id = r["instances"][0]["attributes"]["id"]
            break

client = AcsClient(
   accesskey, 
   secretkey,
   region
)
home = os.path.expanduser("~")
if not os.path.exists("{}/.kube".format(home)):
    os.makedirs("{}/.kube".format(home))

if os.path.exists("{}/.kube/config".format(home)):
    print("backup current config")
    os.rename("{}/.kube/config".format(home), "{}/.kube/config_old".format(home))

req = DescribeClusterUserKubeconfigRequest.DescribeClusterUserKubeconfigRequest()
req.set_ClusterId(cs_id)
body = client.do_action_with_exception(req)
with open("{}/.kube/config".format(home), "w") as f:
    f.write(json.loads(body)["config"].strip()) 