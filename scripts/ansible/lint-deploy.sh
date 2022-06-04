#!/bin/bash

set -euo pipefail

/src/infrastructure/scripts/ansible/lint.sh
/src/infrastructure/scripts/ansible/deploy.sh

