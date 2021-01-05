#!/bin/bash
set -e

conda update -y conda
conda install -y conda-build numpy pytz python-dateutil nomkl Cython

cd /pandas
rm -rf dist
git clean -xfd
python setup.py clean --quiet
python setup.py sdist --formats=gztar --quiet

# as of https://github.com/pandas-dev/pandas/pull/38846, docs should not
# be included in the package tarball
num_docs_files=$(
    grep --count -E "^doc" < pandas.egg-info/SOURCES.txt
)
if [[ ${num_docs_files} -gt 0 ]]; then
    echo ""
    echo "Files from doc/ should not be included in the package, but ${num_docs_files} were found."
    echo "first few files:"
    echo ""
    cat pandas.egg-info/SOURCES.txt | grep -E "^doc" | head -n 20
    echo ""
    exit 1
fi
