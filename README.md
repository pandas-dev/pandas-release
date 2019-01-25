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

# Final Pip and Conda tests. Do these in parallel.
make pip test
make conda test

# Push the tag. No going back now.
make push-tag
```

Now manually create a release https://github.com/pandas-dev/pandas/releases

Make sure to upload the sdist that's in `pandas/dist/` as the "binary".
Conda-forge uses it.

Start the binary builds

```
# Binaries
make conda-forge
make wheels
```

Open PRs for each of those.

Docs. You can cheat and re-tag / rebuild these if needed.

```
make doc
```

Once the binaries finish, you'll need to manually upload the
wheels to PyPI


```
make download-wheels
```

Christoph Gohlke builds the windows wheels. Fetch from from https://www.lfd.uci.edu/~gohlke/pythonlibs/ and download to the same `dist` directory.

Upload the wheels and sdist

```
make upload-pypi
```

Finalize the docs

```
make upload-doc
make website
```

The website script is currenlty broken. You may need to manually
add the next (dev) release, and remove any pre-releases.


goto announce.



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
- upload doc needs to do symlinking (maybe works, just not with RC?)
- .dev0 tag for the next release
