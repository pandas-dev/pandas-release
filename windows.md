

install docker
ensure the following repositories are forked to your GitHub account
  - https://github.com/pandas-dev/pandas-website
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas   


build a docker image with the conda base environment configured and repositories initialized.

TODO: use url for dockerfile to save cloning pandas-release to host machine

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

configure email and name for git 
TODO: get from host or better still use Pandas Development Team as default in the pandas-release docker image build

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
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

NOTE: this is the make docker-image step if not using Windows
NOTE: Step 4/4 : COPY pandas /pandas fails until pandas-release/master updated

```
docker build -t pandas-build https://raw.githubusercontent.com/pandas-dev/pandas-release/master/Dockerfile
```

build the sdist

NOTE: this is the make pandas/dist/<>.tar.gz step if not using Windows
TODO: create symlinks so this can be automated

```
# docker run --rm -v pandas-release:/pandas-release pandas-build /bin/bash /pandas-release/scripts/build_sdist.sh

docker run -it --rm -v pandas-release:/pandas-release pandas-build /bin/bash

rm -r pandas

ln -s pandas-release/pandas pandas

cd pandas-release/

./scripts/build_sdist.sh

exit
```

restart the release container

```
docker start pandas-release -i
```
