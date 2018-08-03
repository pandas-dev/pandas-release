FROM condaforge/linux-anvil2:latest

RUN conda install -y conda-verify && conda clean -tipsy
WORKDIR /pandas

RUN conda build conda.recipe --numpy=1.11 --python=3.6
