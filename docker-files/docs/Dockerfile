FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get install -y texlive-full xclip \
 && apt-get clean

COPY pandas /pandas

RUN --mount=type=cache,target=/opt/conda/pkgs conda env create --file=/pandas/environment.yml --name=pandas
