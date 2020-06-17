

install docker
ensure the following repositories are forked to your GitHub account
  - https://github.com/pandas-dev/pandas-website
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas   


build a docker image with the conda base environment configured and repositories initialized.

change GH_USERNAME to your Github username

```
docker build -t pandas-release --build-arg GH_USERNAME=simonjayhawkins -f docker-files/windows/Dockerfile .
```

next we will prepare a container for interactive use during the release process and copy the repositories
into a shared volume for building the distribution and testing.

change TAG to the release version

```
docker run -it --env TAG=v1.0.5 --name=pandas-release -v pandas-release:/pandas-release pandas-release /bin/bash
```

the docker container should be now be running

make sure the repos are up-to-date
TODO: also make sure conda environment is up-to-date and pandas-release repo is up-to-date if
re-using an older Docker image (maybe need another script in Makefile)
NOTE: safer to build new image if not on metered or slow internet connection.

```
make update-repos
```

Tag the release (This doesn't push the tag)

```
make tag
```

stop the container
```
exit
```

create the build container

```
docker build -t pandas-build .
```

build the sdist

```
docker run -it --rm -v pandas-release:/pandas-release pandas-build /bin/bash

ln -s pandas-release/pandas pandas

cd pandas-release/

./scripts/build_sdist.sh

exit
```

pip tests

```
docker run -it --rm -v pandas-release:/pandas-release pandas-build /bin/bash

ln -s pandas-release/pandas pandas

cd pandas-release/

./scripts/pip_test.sh /pandas/dist/pandas-1.0.5.tar.gz

exit

```

conda tests

```
docker run -it --rm --env PANDAS_VERSION=1.0.5 -v pandas-release:/pandas-release pandas-build /bin/bash

ln -s pandas-release/pandas pandas

cd pandas-release/

conda build --numpy=1.17.3 --python=3.8 ./recipe --output-folder=/pandas/dist

exit

```

copy the sdist file to the local host

```
docker run -it --rm -v %cd%:/local -v pandas-release:/pandas-release pandas-release /bin/bash -c "cp /pandas-release/pandas/dist/pandas-1.0.5.tar.gz /local/"
```

Push the tag. No going back now.

restart the release container

```
docker start pandas-release -i

...

On pandas you should also now create and tag a new branch, so

...
```

Now manually create a release https://github.com/pandas-dev/pandas/releases

Make sure to upload the sdist as the "binary". Conda-forge uses it.


Start the binary builds.

restart the release container

```
docker start pandas-release -i

make conda-forge

make wheels

exit
```

Open PRs for each of those.

Note that `make wheels` actually pushes a job to MacPython to produce wheels which we will download later.


Docs. You can cheat and re-tag / rebuild these if needed.

<!-- doc:
	docker run -it \
		--name=pandas-docs \
		-v ${CURDIR}/pandas:/pandas \
		-v ${CURDIR}/scripts/build-docs.sh:/build-docs.sh \
		pandas-docs \
		/build-docs.sh -->

TODO build an intermediate doc image (and why pandas conda env not in docker image?)
```
docker run -it --name=pandas-docs -v pandas-release:/pandas-release pandas-docs /bin/bash

rm -r pandas

ln -s pandas-release/pandas pandas

cd pandas-release/

# following maybe necessary to prevent segfaults
conda update -n base -c defaults conda

conda env create --file=/pandas/environment.yml --name=pandas

./scripts/build-docs.sh

exit
```

copy the built doc files to host and manually inspect html and pdf docs.

```
docker run -it --rm -v %cd%:/local -v pandas-release:/pandas-release pandas-release /bin/bash -c "cp -r /pandas-release/pandas/doc/build/ /local/pandas-docs"
```

