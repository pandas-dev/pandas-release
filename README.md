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
./build-docs.sh
exit

# Push the tag. No going back now.
make push-tag

# you may also need to create and tag a new branch, so for example:

cd pandas
git checkout -b 1.3.x
git push upstream 1.3.x
git checkout master
git commit --allow-empty -m "Start 1.4.0"
git tag -a v1.4.0.dev0 -m 'DEV: Start 1.4.0'
git push upstream master --follow-tags
cd ..
```

Start the binary build.  **For Mac users** you may need to download the GNU version of sed before running this scripts via `brew install gnu-sed`

```
make wheels
```

Open a PR at https://github.com/MacPython/pandas-wheels/pulls.

Note that `make wheels` actually pushes a job to MacPython to produce wheels which we will download later.

While the wheels are building, upload the built docs to the web server

```
make upload-doc
```

Now manually create a release https://github.com/pandas-dev/pandas/releases

Make sure to upload the sdist that's in `pandas/dist/` as the "binary".
Conda-forge uses it.

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


To make sure /stable and the latest minor revision point to the new release run the following.

**DO NOT DO THIS STEP FOR A RELEASE CANDIDATE**

```
make link-stable
make link-version
```

goto announce.



# Finalize

- [  ] Announce Mailing List
- [  ] Announce Twitter

---

TODO:

- Put the `build-essential` install in the doc docker image
- Update conda-forge to handle RC (branch off dev, etc.)
- Update push-tag to handle RC
- Update `.make.py` to not delete stuff
- Environment setup (conda)
- upload doc needs to do symlinking (maybe works, just not with RC?)
- .dev0 tag for the next release
