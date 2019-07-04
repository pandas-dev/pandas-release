# TO EDIT
TAG ?= v0.25.0rc0
GH_USERNAME ?= jorisvandenbossche

PANDAS_VERSION=$(TAG:v%=%)  # like 0.24.2
PANDAS_BASE_VERSION=$(shell echo '0.24.2' | awk -F '.' '{OFS="."} { print $$1, $$2}')  # like 0.24
TARGZ=pandas-$(PANDAS_VERSION).tar.gz

# to ensure pushd and popd works
SHELL := /bin/bash

# -----------------------------------------------------------------------------
# Host filesystem initialization
# -----------------------------------------------------------------------------

init-repos:
	git clone https://github.com/pandas-dev/pandas            && git -C pandas           remote rename origin upstream && git -C pandas 		  remote add origin https://github.com/$(GH_USERNAME)/pandas
	git clone https://github.com/pandas-dev/pandas-website    && git -C pandas-website   remote rename origin upstream && git -C pandas-website   remote add origin https://github.com/$(GH_USERNAME)/pandas-website
	git clone https://github.com/conda-forge/pandas-feedstock && git -C pandas-feedstock remote rename origin upstream && git -C pandas-feedstock remote add origin https://github.com/$(GH_USERNAME)/pandas-feedstock
	git clone --recursive https://github.com/MacPython/pandas-wheels      && git -C pandas-wheels    remote rename origin upstream && git -C pandas-wheels    remote add origin https://github.com/$(GH_USERNAME)/pandas-wheels

update-repos:
	git -C pandas checkout master           && git -C pandas pull
	git -C pandas-wheels checkout master    && git -C pandas-wheels pull
	git -C pandas-website checkout master   && git -C pandas-website pull
	git -C pandas-feedstock checkout master && git -C pandas-feedstock pull
	pushd pandas-wheels && git submodule update --recursive --remote && popd

# -----------------------------------------------------------------------------
# Git Tag
# -----------------------------------------------------------------------------

tag:
	# This doesn't push the tag
	pushd pandas && ../scripts/tag.py $(TAG) && popd


# -----------------------------------------------------------------------------
#  Builder Images
# -----------------------------------------------------------------------------

docker-image: pandas
	docker build -t pandas-build .


docker-doc:
	docker build -t pandas-docs -f docker-files/docs/Dockerfile .


# -----------------------------------------------------------------------------
# sdist
# -----------------------------------------------------------------------------

pandas/dist/$(TARGZ):
	docker run -it --rm \
		--name=pandas-sdist-build \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts:/scripts \
		pandas-build \
		sh /scripts/build_sdist.sh
	sudo chown $$(id -u):$$(id -g) pandas/dist/ --recursive

# -----------------------------------------------------------------------------
# Tests
# These can be done in parallel
# -----------------------------------------------------------------------------

conda-test:
	docker run -it --rm \
		--name=pandas-conda-test \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/recipe:/recipe \
		pandas-build \
		sh -c "conda build --numpy=1.12 --python=3.6 /recipe --output-folder=/pandas/dist"

pip-test: pandas/dist/$(TARGZ)
	docker run -it --rm \
		--name=pandas-pip-test \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts/pip_test.sh:/pip_test.sh \
		pandas-build /bin/bash /pip_test.sh /pandas/dist/$(TARGZ)

# -----------------------------------------------------------------------------
# Docs
# -----------------------------------------------------------------------------

doc:
	docker run -it --rm \
		--name=pandas-docs \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts/build-docs.sh:/build-docs.sh \
		pandas-docs \
		/build-docs.sh


upload-doc:
	rsync -rv -e ssh pandas/doc/build/html/            pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/
	rsync -rv -e ssh pandas/doc/build/latex/pandas.pdf pandas.pydata.org:/usr/share/nginx/pandas/pandas-docs/version/$(PANDAS_VERSION)/pandas.pdf
	ssh pandas.pydata.org "cd /usr/share/nginx/pandas/pandas-docs && ln -sfn version/$(PANDAS_VERSION) stable && cd version && ln -sfn $(PANDAS_VERSION) $(PANDAS_BASE_VERSION)"


website:
	pushd pandas-website && \
		../scripts/update-website.py $(TAG) && \
		git add . && \
		git commit -m "RLS $(TAG)" && \
		make html && \
	popd



make push-website:
	pushd pandas-website && \
		git push upstream master && \
		make html && \
		make upload && \
	popd


push-tag:
	# TODO: broken for RC
	pushd pandas && ../scripts/push-tag.py $(TAG) && popd


github-release:
	echo TODO


conda-forge:
	./scripts/conda-forge.sh $(TAG) $(GH_USERNAME)


wheels:
	rm -rf pandas/dist/pandas-$(PANDAS_VERSION)-cp37m-linux_x86_64.whl
	rm -rf pandas/dist/pandas-$(PANDAS_VERSION)-cp37-cp37m-linux_x86_64.whl
	./scripts/wheels.sh $(TAG) $(GH_USERNAME)


download-wheels:
	cd pandas && python scripts/download_wheels.py $(PANDAS_VERSION)
	# TODO: Fetch from https://www.lfd.uci.edu/~gohlke/pythonlibs/


upload-pypi:
	twine upload pandas/dist/pandas-$(PANDAS_VERSION)*.{whl,tar.gz} --skip-existing
