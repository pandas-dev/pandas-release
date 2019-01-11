FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install -y texlive-full \
 && apt-get clean
COPY pandas /pandas
RUN conda env create --file=/pandas/ci/deps/travis-36-doc.yaml --name=pandas \
 && . activate pandas \
 && conda uninstall -y --force pandas ||:
# TODO: combine with tex install when you rebuild
RUN apt-get install -y xclip \
 && apt-get clean
