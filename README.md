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


```

-----

## Initial Setup

```
# 1. Initialize Git Repositories
make init-repos

``````
