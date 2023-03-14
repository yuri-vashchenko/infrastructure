#!/usr/bin/env bash

set -e

PATH=${PWD}/env/bin:${PATH}

set -x

python3 -m venv env

pip3 install $1 -r ansible/dev-requirements.txt

cd ansible/ && ansible-galaxy install $1 -r galaxy-requirements.yml
