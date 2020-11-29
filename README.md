# Release automation for pandas.

**Windows users should follow [these](./windows-wsl.md) steps.**

## Steps to a release

The `environment.yml` contains the local dependencies. You'll
also need docker.

And fork pandas-wheels to your GitHub account.

- [  ] Manually update
  - [  ] `TAG` in `Makefile`
  - [  ] `GH_USERNAME` in `Makefile`

If running for the first time be sure to initialize repos

```sh
make init-repos
```

```
# Update repos
make update-repos

# Tag the release
make tag

# Build the doc and test images
make docker-image docker-doc

# Build the sdist
make sdist

# Final Pip and Conda tests. Do these in parallel.
make pip-test
make conda-test

# Docs. You can cheat and re-tag / rebuild these if needed.
make doc

```
# Push the tag. No going back now.
make push-tag
```

Start the binary build.  **For Mac users** you may need to download the GNU version of sed before running this scripts via `brew install gnu-sed`

```
make wheels
```

Open PRs for each of those.

Note that `make wheels` actually pushes a job to MacPython to produce wheels which we will download later.

Now manually create a release https://github.com/pandas-dev/pandas/releases

Make sure to upload the sdist that's in `pandas/dist/` as the "binary".
Conda-forge uses it.

On pandas you should also now create and tag a new branch, so

```sh
git checkout -b <TAG>.x
git push upstream <TAG>.x
git checkout master
git commit --allow-empty -m "Start <NEXT_TAG>"
git tag -a v<NEXT_TAG>.dev0 -m 'DEV: Start <NEXT_TAG> cycle'
git push upstream master --follow-tags
```

Once the binaries finish, you'll need to manually upload the wheels to PyPI.

Assuming the job which `make wheels` triggered on MacPython completed successfully (you may want to double check this https://anaconda.org/multibuild-wheels-staging/pandas/files) you can download a copy of the wheels locally.

```
make download-wheels
```

Upload the wheels and sdist

```
make upload-pypi
```

Finalize the docs

```
make upload-doc
```

To make sure /stable and the latest minor revision point to the new release run the following.

```
make link-stable
make link-version
```

goto announce.



# Finalize

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
