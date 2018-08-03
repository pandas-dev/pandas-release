FROM continuumio/miniconda3:latest

RUN conda update conda -y \
 && conda install -y conda-build conda-verify gcc_linux-64 gxx_linux-64 \
 && conda clean --all
 
COPY pandas /pandas