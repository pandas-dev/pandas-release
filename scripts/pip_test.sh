#!/usr/bin/env bash
set -e
echo $1

# Cytyhon is *not* required here.
conda create -n pip-test -y python=3.7 numpy pytz python-dateutil pytest nomkl

source activate pip-test

python3 -m pip install --no-deps $1
python3 -m "import pandas; pandas.test()"
