#!/bin/bash
set -e

source activate pandas
conda uninstall -y --force pandas ||:

cd /pandas

python setup.py build_ext -i -j 4

cd /pandas/doc

./make.py clean
./make.py html
./make.py zip_html
./make.py latex_forced ||:
./make.py latex_forced
