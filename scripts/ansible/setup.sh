#!/usr/bin/env bash

set -e

PATH=${PWD}/env/bin:${PATH}

set -x

python3 -m venv env

export MYSQLCLIENT_CFLAGS=`mysql_config --cflags`
export MYSQLCLIENT_LDFLAGS=`mysql_config --libs`

pip3 install $@ -r ansible/dev-requirements.txt

cd ansible/ && ansible-galaxy install $1 -r galaxy-requirements.yml
