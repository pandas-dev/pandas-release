# README for MS Windows Users

## Preparing for Your First Release

Install Docker

Ensure the following repositories are forked to your GitHub account
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas   

Open an Anaconda Prompt
<!-- 
TODO: resolve git bash Docker volume issues so that make can be used on host
 -->

Build a Docker image with the conda base environment configured and repositories initialized.

**change GH_USERNAME to your Github username**

```
docker build -t pandas-release --build-arg GH_USERNAME=simonjayhawkins -f docker-files/windows/Dockerfile .
```

## Preparing the Release Environment for a New Release

Next we will prepare a Docker container for interactive use during the release process and copy the repositories
from the Docker image into a Docker volume for building the distribution and testing.

To start with a clean volume. (after a previous release)

```
docker volume rm pandas-release
```

**change TAG to the release version**

```
docker run -it --env TAG=v1.1.1 --name=pandas-release -v pandas-release:/pandas-release pandas-release /bin/bash
```

The Docker release container should be now be running.

if using an older Docker image make sure environments and pandas-release repo are up-to-date.

<!-- TODO: maybe add to Makefile -->
```
apt-get update && apt-get clean
git -C /pandas-release pull --ff-only

# not so sure this should have been conda-forge channel
conda update -c conda-forge conda -y

conda env update -n base --file=/pandas-release/environment.yml
```

Make sure the repos are up-to-date.

```
make update-repos
```

Tag the release. (This doesn't push the tag)

```
make tag
```

Stop the container.

```
exit
```

## Preparing the Build and Test Environment


Create the Docker image for the sdist build, pip test and conda test containers

**change TAG to the release version**

<!-- TODO: setting TAG for the second time here -->

```
docker build -t pandas-build --no-cache .

docker build -t pandas-test --build-arg TAG=v1.1.1 -f docker-files/windows/build/Dockerfile .
```

## Build the sdist
<!-- 
TODO: some of the next steps are repetative. symlink to /pandas in pandas-build Docker image instead
 -->
```
docker run --name=pandas-sdist-build -v pandas-release:/pandas-release pandas-test /bin/bash -c "ln -s /pandas-release/pandas /pandas;./scripts/build_sdist.sh"
```

## Pip Tests
<!-- 
TODO: avoid need to pass explicit filename below
 -->

**change filename to the release version**

```
docker run -it --name=pandas-pip-test -v pandas-release:/pandas-release pandas-test /bin/bash

ln -s /pandas-release/pandas /pandas

./scripts/pip_test.sh /pandas/dist/pandas-1.1.1.tar.gz

exit

```

## Conda Tests
<!-- 
TODO: avoid need to re-type version below
 -->
 **change PANDAS_VERSION to the release version**

```
docker run -it --name=pandas-conda-test --env PANDAS_VERSION=1.1.1 -v pandas-release:/pandas-release pandas-test /bin/bash

ln -s /pandas-release/pandas /pandas

conda build --numpy=1.17.3 --python=3.8 ./recipe --output-folder=/pandas/dist

exit

```

## Copy the sdist File from the Docker Volume to the Local Host.
<!-- 
TODO: avoid need to enter specific filename below (maybe just copy contents of dist directory instead)
 -->
**change filename to the release version**

```
docker run -t --rm -v %cd%:/local -v pandas-release:/pandas-release pandas-release /bin/bash -c "cp /pandas-release/pandas/dist/pandas-1.1.1.tar.gz /local/"
```

## Push the Tag. 

**No going back now.**

Restart the release container.
<!-- 
TODO: does this need to be in interactive mode 
 -->
```
docker start pandas-release -i

make push-tag

exit
```

## Create New Branch
(not needed for Patch release)

On pandas you should also now create and tag a new branch, so

...

## Create a Release

Now manually create a release https://github.com/pandas-dev/pandas/releases

Make sure to upload the sdist as the "binary". Conda-forge uses it.


## Start the Binary Builds.

Restart the release container.

```
docker start pandas-release -i

apt-get install vim

make conda-forge

make wheels

exit
```

Open PRs for each of those.

Note that `make wheels` actually pushes a job to MacPython to produce wheels which we will download later.


## Build the Docs.
You can cheat and re-tag / rebuild these if needed.
```
docker build -t pandas-docs -f docker-files\windows\docs\Dockerfile .

docker run -it --name=pandas-docs -v pandas-release:/pandas-release pandas-docs /bin/bash

conda activate pandas

conda env update -n pandas --file=/pandas/environment.yml

./scripts/build-docs.sh

exit
```

Copy the built doc files to host and manually inspect html and pdf docs.

**first remove the local pandas-docs directory (just manually use file manager for now)**
<!-- 
TODO: maybe add web server to container
TODO: add steps to clean the pandas-docs directory from the docker container before copy
 -->
```
docker run -t --rm -v %cd%:/local -v pandas-release:/pandas-release pandas-release /bin/bash -c "cp -r /pandas-release/pandas/doc/build/ /local/pandas-docs"
```

## Upload the Docs
<!-- 
TODO: add steps to update website and reorder so that docs are uploaded b4 github release
TODO: add the ssh keys to the Docker image or on container creation
 -->
Copy ssh key and config into release container and restart container.

```
docker cp %userprofile%/.ssh pandas-release:/root/.ssh

docker start pandas-release -i

chmod 400 ~/.ssh/id_rsa

make upload-doc

exit
```

## Upload the Binarys to PyPI

Once the binaries finish, you'll need to manually upload the wheels to PyPI.

Assuming the job which `make wheels` triggered on MacPython completed successfully (you may want to double check this https://anaconda.org/multibuild-wheels-staging/pandas/files) you can download a copy of the wheels locally.

```
docker start pandas-release -i

make download-wheels

make upload-pypi

exit
```

## Finalize the Docs

Do this once the wheels are available on PyPI.

```
docker start pandas-release -i

make link-stable

make link-version

exit
```

# Announce

- [  ] Announce Mailing List
- [  ] Announce Twitter
