#!/bin/sh -l

# Some paths require the period, others dont
PYVER2="${PYVER//.}"

# Starting in Python38 the ABI version is no longer required
if [ "$PYVER2" = "37" ] || [ "$PYVER2" = "36" ]
then
    ABIVER="m"
else
    ABIVER=""
fi

PYLOC=/opt/python/cp${PYVER2}-cp${PYVER2}${ABIVER}

${PYLOC}/bin/python -m pip install --upgrade pip setuptools wheel auditwheel
${PYLOC}/bin/python -m pip install cython numpy=="$NPVER"

cd /io
${PYLOC}/bin/python setup.py bdist_wheel
# TODO: we can be more prescriptive about the wheel being repaired
for whl in dist/pandas*.whl; do
    ${PYLOC}/bin/python -m auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done
