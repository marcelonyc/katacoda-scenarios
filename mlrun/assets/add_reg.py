import os
import json
import sys

file = "/etc/docker/daemon.json"

docker_dict = json.load(open(file,'rb'))

docker_dict["insecure-registries"].append(sys.argv[1]+":80")

print (json.dumps(docker_dict))

open(file,'w').write(json.dumps(docker_dict))

