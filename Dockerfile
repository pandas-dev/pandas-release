FROM continuumio/miniconda3:latest

RUN conda update conda -y \
 && conda install -y conda-build conda-verify \
 && conda clean --all
 
COPY pandas /pandas