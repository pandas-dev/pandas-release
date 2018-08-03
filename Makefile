TAG ?= v0.23.3
PANDAS_VERSION=$(TAG:v%=%)
TARGZ=pandas-$(PANDAS_VERSION).tar.gz
GH_USERNAME ?= TomAugspurger

# -----------------------------------------------------------------------------
# Host filesystem initialization
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Git Tag
# -----------------------------------------------------------------------------

tag:
	pushd pandas && ../scripts/tag.py $(TAG) && popd

# -----------------------------------------------------------------------------
# Git Tag
# -----------------------------------------------------------------------------

docker-image:
	docker build -t tomaugspurger/pandas-build .

# -----------------------------------------------------------------------------
# sdist
# -----------------------------------------------------------------------------

dist/$(TARGZ):
	docker run -it --rm \
		--name=pandas-sdist-build \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts:/scripts \
		pandas-build \
		sh /scripts/build_sdist.sh

# -----------------------------------------------------------------------------
# Tests
# These can be done in parallel
# -----------------------------------------------------------------------------

conda-test:
	docker run -it --rm \
		--name=pandas-conda-test \
		-v ${CURDIR}/pandas:/pandas \
		pandas-build \
		sh -c "conda build --numpy=1.11 /pandas/conda.recipe --output-folder=/pandas/dist"

pip-test:
	docker run -it \
		--name=pandas-pip-test \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts/pip_test.sh:/pip_test.sh \
		pandas-build \
		sh /pip_test.sh /pandas/dist/$(TARGZ)

# -----------------------------------------------------------------------------
# Docs
# -----------------------------------------------------------------------------

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
