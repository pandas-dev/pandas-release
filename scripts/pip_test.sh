#!/usr/bin/env bash
set -e

# Cytyhon is *not* required here.
conda create -n pip-test -y python=3.7 numpy pytz python-dateutil pytest nomkl
conda activate pip-test

/opt/conda/envs/pip-test/bin/python3 -m pip install --no-deps $(1)
/opt/conda/envs/pip-test/bin/python3 -m "import pandas; pandas.test()"
