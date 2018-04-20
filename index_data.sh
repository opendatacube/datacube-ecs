#!/bin/bash

 usage() { echo "Usage $0 [-s <s3-bucket-name/s3-key>] [-t <path-to-target>] \
                 [-c initialize datacube database] \
                 [-m install temporary datacube] \
                 [-u remove conda]"; }

while getopts ":s:t:cmu" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        c)
            c=1
            ;;
        m)
            m=1
            ;;
        u)
            u=1
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${t}" ]; then
    usage
    exit 1
fi

# Sync files from s3 bucket to local target
aws s3 sync s3://${s} ${t}

# install miniconda and datacube if required
# will remove miniconda after script is run
if [ "${m}" ]; then
    # install miniconda locally
    curl -o ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"

    # install datacube with miniconda
    conda config --add channels conda-forge
    conda create -y --name datacubeenv python=3.6 datacube
    rm ~/miniconda.sh
    source activate datacubeenv
fi

# create database tables if required
# add metadata types
if [ "${c}" ]; then
    datacube system init --no-default-types --no-init-users

    curl https://raw.githubusercontent.com/GeoscienceAustralia/digitalearthau/develop/digitalearthau/config/metadata-types.yaml
    datacube metadata_type add metadata-types.yaml
fi

shopt -s globstar
# run datacube to add products
# datacube will not re-add existing products
#datacube product add ${t}/**/*.json
# datacube product add ${t}/**/*.yaml

# run datacube to index netCDF files
# datacube will not re-index existing data
datacube dataset add ${t}/**/*.nc

# nuke miniconda that we installed
if [ "${u}" ]; then
    source deactivate
    rm -r $HOME/miniconda
    rm -r $HOME/.conda
    rm .condarc
fi
