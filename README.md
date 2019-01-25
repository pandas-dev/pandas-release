Release automation for pandas.

## Steps to a release

- [  ] Manually update 
  - [  ] `PANDAS_VERSION` in `Makefile`
  - [  ]  `version` in `recipe/meta.yaml`
- [  ] Update repos

```
# Update repos
make update-repos

# Tag the release
make tag

# Build the doc and test images
make docker-image docker-doc

# Build the sdist
make pandas/dist/<>.sdist

# Final Pip and Conda tests
make pip test
make conda test

# Binaries
make conda-forge
make wheels

# Docs
make doc

# Remote stuff
make push-tag
```

# Finalize

- [  ] Download Christoph's wheels and upload to PyPI
- [  ] Announce Mailing List
- [  ] Announce Twitter

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
- Environment setup (conda)
