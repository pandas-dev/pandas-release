TAG ?= v0.23.0

conda-test:
	conda build pandas/conda.recipe --numpy 1.11 --python 3.6 -q --output
	conda create -n pandas-$(TAG:v%=%) --numpy=1.13 --python=3.6 pandas pytest
	conda install -n pandas-$(TAG:v%=%) pandas --use-local
	conda activate pandas-$(TAG:v%=%)
	python -c "import pandas; pandas.test()"


pip-test:
	cd pandas && python pandas/setup.py bdist_wheel
	python3 -m venv pandas-$(TAG:v%=%)-venv
	pandas-$(TAG:v%=%)-venv/bin/python -m pip install pandas/dist/*.whl
	pandas-$(TAG:v%=%)-venv/bin/python -c "import pandas; pandas.test()"

tag:
	./scripts/tag.sh $(TAG)

doc:
	cd pandas && python setup.py build_ext -i -j 4
	cd pandas && python -m pip install -e .
	cd pandas/doc && \
  	    ./make.py clean && \
	    ./make.py html && \
	    ./make.py zip_html && \
	    ./make.py latex_forced

push-tag:
	./scripts/push-tag.sh $(TAG)
