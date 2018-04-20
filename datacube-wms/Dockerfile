FROM geoscienceaustralia/datacube:test_build

SHELL ["/bin/bash", "-c"]

EXPOSE 80

COPY wsgi_profiler_conf.py /wsgi_profiler_conf.py

RUN apt-get update \
    && apt-get install -y golang \
    && export GOPATH=$HOME/go \
    && go get github.com/segmentio/chamber \
    && cp $GOPATH/bin/chamber /chamber

RUN conda install -n agdc scikit-image flask gunicorn \
    && conda clean --all --yes

# Workaround to stop git clone cache
# https://stackoverflow.com/a/39278224
ADD https://api.github.com/repos/roarmstrong/datacube-wms/git/refs/heads/master version.json
RUN cd $HOME \
    && git clone -bmaster https://github.com/roarmstrong/datacube-wms.git \
    && cd $HOME/datacube-wms \
    && git checkout master \
    && source activate agdc \
    && pip install -e $HOME/datacube-wms --no-deps

ADD configure.sh /configure.sh
ADD run.sh /run.sh

ENTRYPOINT ["/chamber", "exec", "datacube-wms", "--", "/bin/sh", "-c", "/configure.sh && /run.sh" ]