import json
with open("./terraform.tfstate") as f:
    jsons = json.load(f)
    cs_id = ""
    for r in jsons["resources"]:
        if r["name"] == "jupyter_mount_target_vs1":
            server_id = r["instances"][0]["attributes"]["id"]
            break

with open("./k8s/1_jupyter-nas.yaml", "w") as f:
    with open("./k8s/1_jupyter-nas.yaml.pre") as f2:
        f.write(f2.read())
        f.write("\n")
    f.write("      server: \"{}\"".format(server_id))
    f.write("\n")
    with open("./k8s/1_jupyter-nas.yaml.post") as f2:
        f.write(f2.read())
        f.write("\n") 