#!/bin/bash
basePath="$(dirname "$(readlink -f "$0")")"
if [ ! -d "${basePath}/.venv" ]; then
    python3 -m virtualenv "${basePath}/.venv"
fi
if [ -d "${basePath}/.venv" ]; then
    source ${basePath}/.venv/bin/activate
    pip3 install -q --upgrade pip setuptools wheel
    pip3 install -q -r ${basePath}/requirements.txt
    python3 ${basePath}/torrentInspector.py $1
fi
