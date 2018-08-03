FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install -y textlive-full \
 && apt-get clean
RUN conda env create --file=/pandas/ci/travis-36-doc.yaml