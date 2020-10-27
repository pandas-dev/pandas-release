# README for MS Windows Users using WSL 2.

## Preparing for Your First Release.

see https://docs.docker.com/docker-for-windows/wsl/#prerequisites for prerequisites

Ensure the following repositories are forked to your GitHub account
  - https://github.com/pandas-dev/pandas-release
  - https://github.com/conda-forge/pandas-feedstock
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas


### Setting up WSL 2.

Install Docker (This will activate WSL2)

Install Ubuntu 20.04 LTS from the Windows Store

Launch Ubuntu 20.04 LTS from the start menu to set-up for first use.

Launch Docker desktop

go to Settings > Resources > WSL Integration.

You might see

```
You don't have any WSL 2 distro. Please convert a WSL 1 distro to WSL 2, or install a new distro and it will appear here.

More info
```

click on More Info and follow steps.

```
PS C:\Users\simon> wsl -l -v
  NAME                   STATE           VERSION
* docker-desktop         Running         2
  Ubuntu-20.04           Running         1
  docker-desktop-data    Running         2
PS C:\Users\simon> wsl --set-version Ubuntu-20.04 2
Conversion in progress, this may take a few minutes...
For information on key differences with WSL 2 please visit https://aka.ms/wsl2
Conversion complete.
PS C:\Users\simon> wsl --set-default-version 2
For information on key differences with WSL 2 please visit https://aka.ms/wsl2
PS C:\Users\simon> wsl --set-default Ubuntu-20.04
PS C:\Users\simon> wsl -l -v
  NAME                   STATE           VERSION
* Ubuntu-20.04           Running         2
  docker-desktop         Running         2
  docker-desktop-data    Running         2
PS C:\Users\simon>
```

### Preparing the release environment.

Start Ubuntu 20.04 LTS

configure git manually

```
git config --global user.email "<your-email>"
git config --global user.name "<your-name>"
```

or copy the configuration from windows.
```
cp /mnt/c/Users/<your-windows-username>/.gitconfig .
```

also copy your ssh config from windows and set permissions
```
cp -r /mnt/c/Users/<your-windows-username>/.ssh/ .
chmod 400 .ssh/id_rsa
```

clone your fork of the pandas-release repo and set upstream
```
git clone git@github.com:<your-github-username>/pandas-release.git
cd pandas-release
git remote add upstream https://github.com/pandas-dev/pandas-release.git
```