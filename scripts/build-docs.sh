#!/bin/bash
set -e

source activate pandas

cd /pandas
python setup.py build_ext -i -j 4 && pip install -e .

cd doc
./make.py html
./make.py zip_html
./make.py latex_forced
