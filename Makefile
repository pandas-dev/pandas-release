TAG ?= v0.23.3
PANDAS_VERSION=$(TAG:v%=%)
GH_USERNAME ?= TomAugspurger


init-repos:
	git clone https://github.com/pandas-dev/pandas            && git -C pandas           remote rename origin upstream && git -C pandas 		  remote add origin https://github.com/$(GH_USERNAME)/pandas
	git clone https://github.com/pandas-dev/pandas-website    && git -C pandas-website   remote rename origin upstream && git -C pandas-website   remote add origin https://github.com/$(GH_USERNAME)/pandas-website
	git clone https://github.com/MacPython/pandas-wheels      && git -C pandas-wheels    remote rename origin upstream && git -C pandas-wheels    remote add origin https://github.com/$(GH_USERNAME)/pandas-wheels
	git clone https://github.com/conda-forge/pandas-feedstock && git -C pandas-feedstock remote rename origin upstream && git -C pandas-feedstock remote add origin https://github.com/$(GH_USERNAME)/pandas-feedstock


update-repos:
	git -C pandas checkout master           && git -C pandas pull
	git -C pandas-wheels checkout master    && git -C pandas-wheels pull
	git -C pandas-website checkout master   && git -C pandas-website pull
	git -C pandas-feedstock checkout master && git -C pandas-feedstock pull

tag:
	pushd pandas && ../scripts/tag.py $(TAG) && popd

conda-test:
	LDFLAGS="-headerpad_max_install_name" conda build pandas/conda.recipe --numpy 1.11 --python 3.6
	LDFLAGS="-headerpad_max_install_name" conda create -n pandas-$(TAG:v%=%) numpy=1.11 python=3.6 pandas pytest
	LDFLAGS="-headerpad_max_install_name" conda install -n pandas-$(TAG:v%=%) pandas --use-local
	source activate pandas-$(TAG:v%=%)
	python -c "import pandas; pandas.test()"

pip-test:
	conda update conda && \
		conda create -n pandas-$(PANDAS_VERSION)-pip \
		python=3 \
		pytz \
		python-dateutil \
		numpy \
		Cython \
		pytest
	source activate pandas-$(PANDAS_VERSION)-pip && \
	git clone pandas pandas-$(PANDAS_VERSION)-venv/pandas \
	pushd pandas-$(PANDAS_VERSION)-venv && \
	  ./bin/python -m pip install -U pip wheel setuptools && \
	  ./bin/python -m pip install -U pytz python-dateutil numpy Cython pytest && \
		pushd pandas && \
		  ../bin/python setup.py bdist_wheel  && \
		popd && \
	  ./bin/python -m pip install pandas/dist/pandas-*.whl && \
	  ./bin/python -c "import pandas; pandas.test()" && popd

doc:
	docker run -d -it --name devtest --mount type=bind,source="$(pwd)/pandas",target=/pandas continuumio/miniconda3:latest

upload-doc: 
	rsync -rv -e ssh pandas-docs/doc/build/html/            pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/
	rsync -rv -e ssh pandas-docs/doc/build/latex/pandas.pdf pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/pandas.pdf
	ssh pandas.pydata.org "cd /usr/share/nginx/pandas/pandas-docs && ln -sfn version/$(PANDAS_VERSION) stable && cd version && ln -sfn $(PANDAS_VERSION) $(PANDAS_VERSION:%.0=%)"

website:
	pushd pandas-website && \
		../scripts/update-website.py $(TAG) && \
	popd
	echo TODO: build, push

push-tag:
	pushd pandas && ../scripts/push-tag.py $(TAG) && popd

pandas/dist/%.tar.gz:
	conda update -n base conda && \
		conda create -n pandas-sdist-build python=3 Cython numpy python-dateutil pytz && \
		&& source activate pandas-sdist-build && \
		cd pandas && \
		git clean -xdf && python setup.py cython && python setup.py sdist --formats=gztar

github-release:
	echo TODO

conda-forge:
	./scripts/conda-forge.sh $(TAG)

wheels:
	./scripts/wheels.sh $(TAG)

download-wheels:
	cd pandas && python scripts/download_wheels.py $(PANDAS_VERSION)
	# TODO: Fetch from https://www.lfd.uci.edu/~gohlke/pythonlibs/

upload-pypi:
	twine upload pandas/dist/* --skip-existing
