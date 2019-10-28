import json
with open("./terraform.tfstate") as f:
    jsons = json.load(f)
    cs_id = ""
    for r in jsons["resources"]:
        if r["type"] == "alicloud_cs_managed_kubernetes":
            server_id = r["instances"][0]["attributes"]["id"]
            break
print("{}.ap-northeast-1.alicontainer.com".format(server_id))