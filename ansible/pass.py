#!/usr/bin/env python

import sys
import yaml

# sys.stderr.write("Requested ansible password\n")
secrets = "/home/yuri/.local/secret.yaml"

with open(secrets, "r") as stream:
    try:
        data = yaml.safe_load(stream)
        print(data["ansible_vault_password"])
    except yaml.YAMLError as exc:
        sys.stderr.write(exc)
