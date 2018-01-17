FROM geoscienceaustralia/datacube:latest

EXPOSE 80

COPY wsgi_profiler_conf.py /wsgi_profiler_conf.py

COPY chamber /chamber

ADD install.sh /install.sh

RUN /install.sh

ADD configure.sh /configure.sh
ADD run.sh /run.sh

ENTRYPOINT ["/chamber", "exec", "datacube-wms", "--", "/bin/sh", "-c", "/configure.sh && /run.sh" ]