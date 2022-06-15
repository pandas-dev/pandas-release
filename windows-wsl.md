# README for MS Windows Users using WSL 2.

## Preparing for Your First Release.

Install Docker

Ensure the following repositories are forked to your GitHub account
  - https://github.com/pandas-dev/pandas-release
  - https://github.com/MacPython/pandas-wheels
  - https://github.com/pandas-dev/pandas

see https://docs.microsoft.com/en-us/windows/wsl/install-win10 for Windows Subsystem for Linux installation instructions


### Preparing the release environment.

Start Ubuntu 20.04 LTS

either configure git manually

```
git config --global user.email "<your-email>"
git config --global user.name "<your-name>"
git config --global pull.rebase false
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

download conda from https://docs.conda.io/en/latest/miniconda.html#linux-installers and
install.
```
cd
ln -s /mnt/c/Users/<your-windows-username>/Downloads/ ~/downloads
sha256sum downloads/Miniconda3-latest-Linux-x86_64.sh
bash downloads/Miniconda3-latest-Linux-x86_64.sh
```

close terminal and reopen to activate conda and install pandas-release conda environment
```
conda list
conda update conda
cd pandas-release
conda env create -f environment.yml
conda activate pandas-release
```

The linux environment is now configured on WSL. Now follow the steps in [README.md](./README.md)

## View the documentation once built.

Note: The Linux filesystem is accessible using File Explorer from the Dev Channel of the Windows Insider Program.

otherwise first find the path to the browser executable, e.g. Microsoft Edge
```
find /mnt/c/ -name "msedge.exe" 2>/dev/null
```

then open index.html in the browser
```
"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" pandas/doc/build/html/index.html
```

and the same for the pdf documentation
```
"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" pandas/doc/build/latex/pandas.pdf
```
