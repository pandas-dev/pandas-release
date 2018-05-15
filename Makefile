TAG ?= v0.23.0
PANDAS_VERRSION=$(TAG:v%=%)

conda-test:
	conda build pandas/conda.recipe --numpy 1.11 --python 3.6
	conda create -n pandas-$(TAG:v%=%) numpy=1.11 python=3.6 pandas pytest
	conda install -n pandas-$(TAG:v%=%) pandas --use-local
	source activate pandas-$(TAG:v%=%)
	python -c "import pandas; pandas.test()"


pip-test:
	cd pandas && python setup.py bdist_wheel
	python3 -m venv pandas-$(PANDAS_VERSION)-venv
	pandas-$(PANDAS_VERSION)-venv/bin/python -m pip install pandas/dist/*.whl pytest
	pandas-$(PANDAS_VERSION)-venv/bin/python -c "import pandas; pandas.test()"

tag:
	./scripts/tag.sh $(TAG)

doc:
	rm -rf pandas-docs
	git clone pandas pandas-docs
	cd pandas-docs && python setup.py build_ext -i -j 4 && \
	python -m pip install -e . && \
	cd doc && \
  	    ./make.py clean && \
	    ./make.py html && \
	    ./make.py zip_html && \
	    ./make.py latex_forced

push-tag:
	./scripts/push-tag.sh $(TAG)

pandas/dist/%.tar.gz:
	cd pandas && git clean -xdf && python setup.py cython && python setup.py sdist --formats=gztar

github-release:
	echo TODO

conda-forge:
	./scripts/conda-forge.sh $(TAG)

wheels:
	./scripts/wheels.sh $(TAG)

download_wheels:
	echo TODO

