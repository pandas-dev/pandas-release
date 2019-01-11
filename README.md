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

- Put the `build-essential` install in the doc docker image, or change
  pip test / doc build to use the same env, so the wheel can be shared
- handle RC in push_tag
