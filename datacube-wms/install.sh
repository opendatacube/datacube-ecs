#!/bin/bash
source $HOME/.profile

conda install scikit-image flask gunicorn

git clone https://github.com/roarmstrong/datacube-wms.git

cd datacube-wms
git checkout fractional_cover
pip install -e . --no-deps
