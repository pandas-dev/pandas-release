

install docker
ensure the following repositories are forked to your GitHub account
  - https://github.com/pandas-dev/pandas-website
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas   


build a docker image with the conda base environment configured and repositories initialized.

todo: use url for dockerfile to save cloning pandas-release to host machine

change GH_USERNAME to your Github username

```
docker build -t pandas-release --build-arg GH_USERNAME=simonjayhawkins -f docker-files/windows/Dockerfile .
```

next we will prepare a container for interactive use during the release process and copy the repositories
into a shared volume for building the distribution and testing.

change TAG to the release version

```
docker run -it --env TAG=v1.0.4 --name=pandas-release -v pandas-release:/pandas-release pandas-release /bin/bash
```

the docker container should be now be running

make sure the repos are up-to-date

```
make update-repos
```

configure email and name for git # todo: get from host

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

Tag the release
```
make tag
```

stop the container
"""
exit
"""

create the build container

docker build -t pandas-build https://raw.githubusercontent.com/pandas-dev/pandas-release/master/Dockerfile

build the sdist


docker run --rm -v pandas-release:/pandas-release pandas-build /bin/bash /pandas-release/scripts/build_sdist.sh
docker run --rm -v pandas-release:/pandas-release pandas-build -w /pandas-release /bin/bash /scripts/build_sdist.sh

restart the release container

```
docker start pandas-release -i
```
