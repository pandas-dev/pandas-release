TAG ?= v0.23.1
PANDAS_VERSION=$(TAG:v%=%)
GH_USERNAME ?= TomAugspurger


update-repos:
	pushd pandas           && git remote set-url origin https://github.com/$(GH_USERNAME)/pandas            && git remote update && git checkout master && git reset --hard upstream/master && popd && \
	pushd pandas-website   && git remote set-url origin https://github.com/$(GH_USERNAME)/pandas-website    && git remote update && git checkout master && git reset --hard upstream/master && popd && \
	pushd pandas-wheels    && git remote set-url origin https://github.com/$(GH_USERNAME)/pandas-wheels     && git remote update && git checkout master && git reset --hard upstream/master && popd && \
	pushd pandas-feedstock && git remote set-url origin https://github.com/$(GH_USERNAME)/pandas-feedstock  && git remote update && git checkout master && git reset --hard upstream/master && popd


conda-test:
	LDFLAGS="-headerpad_max_install_name" conda build pandas/conda.recipe --numpy 1.11 --python 3.6
	LDFLAGS="-headerpad_max_install_name" conda create -n pandas-$(TAG:v%=%) numpy=1.11 python=3.6 pandas pytest
	LDFLAGS="-headerpad_max_install_name" conda install -n pandas-$(TAG:v%=%) pandas --use-local
	source activate pandas-$(TAG:v%=%)
	python -c "import pandas; pandas.test()"


pip-test:
	python3 -m venv pandas-$(PANDAS_VERSION)-venv
	git clone pandas pandas-$(PANDAS_VERSION)-venv/pandas
	pushd pandas-$(PANDAS_VERSION)-venv && \
	  ./bin/python -m pip install -U pip wheel setuptools && \
	  ./bin/python -m pip install -U pytz python-dateutil numpy Cython pytest && \
		pushd pandas && \
		  ../bin/python setup.py bdist_wheel  && \
		popd && \
	  ./bin/python -m pip install pandas/dist/pandas-*.whl && \
	  ./bin/python -c "import pandas; pandas.test()" && popd


tag:
	pushd pandas && ../scripts/tag.py $(TAG) && popd


doc:
	rm -rf pandas-docs
	git clone pandas pandas-docs
	pushd pandas-docs && python setup.py build_ext -i -j 4 && \
	python -m pip install -e . && \
	cd pushd doc && \
  	    ./make.py clean && \
	    ./make.py html && \
	    ./make.py zip_html && \
	    ./make.py latex_forced && \
	popd && popd


upload-doc: 
	rsync -rv -e ssh pandas-docs/doc/build/html/            pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/
	rsync -rv -e ssh pandas-docs/doc/build/latex/pandas.pdf pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/pandas.pdf
	ssh pandas.pydata.org "cd /usr/share/nginx/pandas/pandas-docs && ln -sfn version/$(PANDAS_VERSION) stable && cd version && ln -sfn $(PANDAS_VERSION) $(PANDAS_VERSION:%.0=%)"

push-tag:
	pushd pandas && ../scripts/push-tag.py $(TAG) && popd

pandas/dist/%.tar.gz:
	cd pandas && git clean -xdf && python setup.py cython && python setup.py sdist --formats=gztar

github-release:
	echo TODO

conda-forge:
	./scripts/conda-forge.sh $(TAG)

wheels:
	./scripts/wheels.sh $(TAG)

download_wheels:
	cd pandas && python scripts/download_wheels.py
	# TODO: Fetch from https://www.lfd.uci.edu/~gohlke/pythonlibs/

upload-pypi:
	twine upload pandas/dist/* --skip-existing
