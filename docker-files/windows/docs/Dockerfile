FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install -y texlive-full xclip \
 && apt-get clean

# TODO: don't need to clone complete repository, just need environment.yml
RUN git clone https://github.com/pandas-dev/pandas.git

# following maybe necessary to prevent segfaults
RUN conda update -n base -c defaults conda

# this is also done in scripts\build-docs.sh (should be done earlier but won't use cached build and texlive is big download)
RUN apt-get update && apt-get install -y build-essential && apt-get clean

# NOTE: This builds environment from master will update for correct branch in container
RUN conda env create --file=/pandas/environment.yml --name=pandas

RUN rm -r pandas

RUN mkdir -p /pandas-release/pandas

RUN ln -s /pandas-release/pandas /pandas

WORKDIR /pandas-release
