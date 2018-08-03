FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install -y texlive-full \
 && apt-get clean
COPY pandas /pandas
RUN conda env create --file=/pandas/ci/travis-36-doc.yaml \
 && conda activate pandas \
 && conda uninstall -y --force pandas
