FROM geoscienceaustralia/datacube:test_build

SHELL ["/bin/bash", "-c"]

EXPOSE 80

COPY wsgi_profiler_conf.py /wsgi_profiler_conf.py

COPY chamber /chamber

RUN conda install -n agdc scikit-image flask gunicorn \
    && conda clean --all --yes

RUN cd $HOME \
    && git clone https://github.com/roarmstrong/datacube-wms.git \
    && cd $HOME/datacube-wms \
    && git checkout fractional_cover \
    && source activate agdc \
    && pip install -e $HOME/datacube-wms --no-deps

ADD configure.sh /configure.sh
ADD run.sh /run.sh

ENTRYPOINT ["/chamber", "exec", "datacube-wms", "--", "/bin/sh", "-c", "/configure.sh && /run.sh" ]