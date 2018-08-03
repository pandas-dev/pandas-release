conda create -n pip-test -y python=3.6 numpy pytz python-dateutil pytest gcc_linux-ppc64le
source activate pip-test

python3 -m pip install --no-deps $(1)

python3 -m "import pandas; pandas.test()"
