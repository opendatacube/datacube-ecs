FROM ubuntu:xenial

ARG DC_TAG=datacube-1.5.3

# Upgrade and install dependencies
# Postgres is installed and configured in order to run integration tests
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y wget bzip2 git postgresql

RUN locale-gen en_US.UTF-8 en_US

# Run datacube script
ADD ./datacube_setup.sh /tmp/datacube_setup.sh
RUN /tmp/datacube_setup.sh $DC_TAG