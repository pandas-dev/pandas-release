Release automation for pandas.

## Steps to a release

- [  ] Manually update 
  - [  ] `TAG` in `Makefile`
  - [  ] `GH_USERNAME` in `Makefile`

## **If running for the first time:**

- Create a conda enviroment based on environment.yml:
```sh
conda env create 
```
- Activate the environment:
```sh
conda activate pandas-release
```
- Be sure you have the following forked on your github:
  - https://github.com/pandas-dev/pandas-website
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas   
  
  &nbsp;
  
 - Be sure to initialize repos:
```sh
make init-repos
```

The `environment.yml` contains the local dependencies. You'll
also need docker.

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
# You can optionally do make doc here as well
make pip-test
make conda-test

# Push the tag. No going back now.
make push-tag
```

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

Start the binary builds.  **For Mac users** you may need to download the GNU version of sed before running this scripts via `brew install gnu-sed`

```
# Binaries
make conda-forge
make wheels
```

Open PRs for each of those.

Note that `make wheels` actually pushes a job to MacPython to produce wheels which we will download later.

Docs. You can cheat and re-tag / rebuild these if needed.

```
make doc
```

Once the binaries finish, you'll need to manually upload the
wheels to PyPI. Assuming the job which `make wheels` triggered on MacPython completed successfully (you may want to double check this)
you can download a copy of the wheels for Mac / Linux locally.


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

You also need to make edits to the pandas-website to appropriately display items. 
Ideally this could be done via `make push-website` as the rule exists but the
intermediary steps aren't fully automated yet.

```sh
pushd pandas-website
mv latest.rst previous.rst
# Recreate latest.rst to match release notes from GH in earlier steps
# Update pre_release.json and releases.json
git commit -am "Your updates"
git push
make html
make upload
```

To make sure /stable and the latest minor revision point to the new release run the following from root

```sh
popd  # should bring us back to root from pandas-website
make link-stable
make link-version
```

Now check pandas.pydata.org and ensure the sidebar and links are correct!

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
