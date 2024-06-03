#!/bin/bash

basePath="$(dirname "$(readlink -f "$0")")"

if [ ! -d "${basePath}/.venv" ]; then
    python3 -m virtualenv "${basePath}/.venv"
fi

if [ ! -f "${basePath}/.env" ]; then
    echo "You need to create a .env file in the ${basePath} directory"
else
    if ! grep -q "qbitUser" "${basePath}/.env"; then
        echo "Your .env file needs to contain the \"qbitUser\" variable"
        exit
    fi
    if ! grep -q "qbitPass" "${basePath}/.env"; then
        echo "Your .env file needs to contain the \"qbitPass\" variable"
        exit
    fi
    if ! grep -q "hostIp" "${basePath}/.env"; then
        echo "Your .env file needs to contain the \"hostIp\" variable"
        exit
    fi
fi

if [ -d "${basePath}/.venv" ]; then
    source ${basePath}/.venv/bin/activate
    pip3 install -q --upgrade pip setuptools wheel
    pip3 install -q -r ${basePath}/requirements.txt
    python3 ${basePath}/torrentInspector.py $1
fi
