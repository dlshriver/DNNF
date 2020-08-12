#!/bin/bash
set -e

PROJECT_DIR=$(cd $(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/..; pwd)
mkdir -p bin
mkdir -p include
mkdir -p lib

if [ "$1" == "init" ]
then
    python3.7 -m venv .venv
    . .venv/bin/activate
    python -m pip install --upgrade pip setuptools flit
    flit install --symlink --deps=develop
fi

if [ "$1" == "update" ]
then
    if [ ! -d .venv ]
    then
        echo "Environment does not exist. Try:" >&2
        echo " ./manage.sh init"
        exit 1
    fi
    . .venv/bin/activate
    python -m pip install --upgrade pip setuptools flit
    flit install --symlink --deps=develop
fi

if [ "$1" == "install" ]
then
    shift
    for pkg in "$@"
    do
        echo "Unknown package: $pkg"
    done
fi
