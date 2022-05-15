#!/usr/bin/env python

import sys
import yaml

vault_id = "test"
if (len(sys.argv) > 1):
    vault_id = sys.argv[1]

secrets = "/home/yuri/.local/secret.yml"

with open(secrets, "r") as stream:
    try:
        data = yaml.safe_load(stream)
        print(data[vault_id]["ansible_vault_password"])
    except yaml.YAMLError as exc:
        print(exc)