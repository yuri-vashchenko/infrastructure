#!/usr/bin/env bash

set -e

PATH=${PWD}/env/bin:${PATH}

set -x

python -m venv env

pip install $1 -r ansible/dev-requirements.txt

cd ansible/ && ansible-galaxy install $1 -r galaxy-requirements.yml
