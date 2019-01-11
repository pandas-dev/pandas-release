Release automation for pandas.

## Steps to a release

- [  ] Manually update 
  1. `PANDAS_VERSION` in `Makefile`
  2. `version` in `recipe/meta.yaml`

```
# Tag the release
make tag

# Build the doc and test images
make docker-image docker-doc

# Build the sdist
make pandas/dist/<>.sdist

# Final Pip and Conda tests
make pip test
make conda test

# Docs
make doc

# Remote stuff
make push-tag


```

-----

## Initial Setup

```
# 1. Initialize Git Repositories
make init-repos

``````

---

TODO:

- Put the `build-essential` install in the doc docker image
- Update conda-forge to handle RC (branch off dev, etc.)
- Update push-tag to handle RC
- Update `.make.py` to not delete stuff
