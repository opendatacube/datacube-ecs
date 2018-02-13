FROM ubuntu:xenial

SHELL ["/bin/bash", "-c"]

ARG DATACUBE_REPO=https://github.com/opendatacube/datacube-core
ARG DATACUBE_TAG=datacube-1.5.3
ARG PYTHON_VERSION=3.6

# Upgrade and install dependencies
# Postgres is installed and configured in order to run integration tests
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y curl wget bzip2 git ca-certificates locales \
    && apt-get clean

RUN locale-gen en_US.UTF-8 en_US

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh \
    && bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b \
    && rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Packages to install with conda
ADD ./environment.yaml /tmp/environment.yaml

# Create conda environment
RUN conda config --set always_yes yes --set changeps1 no \
    && conda config --add channels conda-forge \
    && conda update --all \
    && conda create -n agdc python=$PYTHON_VERSION \
    && conda env update -n agdc --file /tmp/environment.yaml \
    && conda clean --all --yes

# Install datacube
COPY bashrc /root/.bashrc
COPY bashrc /root/.profile

RUN git clone --depth 1 -b $DATACUBE_TAG $DATACUBE_REPO datacube-core \
    && cd datacube-core \
    && source activate agdc \
    && pip install . --no-deps --upgrade \
    && conda clean --all --yes


