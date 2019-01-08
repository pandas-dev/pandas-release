#!/bin/bash
set -e

conda update conda
conda install -y conda-build numpy pytz python-dateutil nomkl Cython

cd /pandas
rm -rf dist
git clean -xfd
python setup.py clean --quiet
python setup.py cython -j 4 --quiet
python setup.py sdist --formats=gztar --quiet
