import json
import sys

args = sys.argv
with open("./terraform.tfstate") as f:
    jsons = json.load(f)
    cs_id = ""
    for r in jsons["resources"]:
        if r["name"] == "jupyter_mount_target_vs{}".format(args[1]):
            server_id = r["instances"][0]["attributes"]["id"]
            break
print(server_id)