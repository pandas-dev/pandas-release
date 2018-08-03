FROM condaforge/linux-anvil2:latest

RUN yum -y install texlive \
    texlive-latex \
    texlive-xetex \
    install texlive-collection-latex \
    install texlive-collection-latexrecommended \
    install texlive-xetex-def \
    install texlive-collection-xetex

RUN /opt/conda/bin/conda install -y \
    numpy \
    Cython \
    python-dateutil \
    pytz \
    conda-verify \
    conda-build \
 && /opt/conda/bin/conda clean --all


