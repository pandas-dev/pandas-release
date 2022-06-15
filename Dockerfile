FROM continuumio/miniconda3:latest

RUN apt-get update && \
    apt-get install -y build-essential

RUN conda update conda -y \
 && conda install -y conda-build conda-verify gcc_linux-64 gxx_linux-64 \
 && conda clean --all

# ARG USER_ID
# ARG GROUP_ID

# RUN addgroup --gid $GROUP_ID user
# RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

# # https://github.com/ContinuumIO/docker-images/issues/151
# RUN mkdir /opt/conda/envs/user && \
#     chgrp user /opt/conda/pkgs && \
#     chmod g+w /opt/conda/pkgs && \
#     touch /opt/conda/pkgs/urls.txt && \
#     chown user /opt/conda/envs/user /opt/conda/pkgs/urls.txt
    
# USER user
