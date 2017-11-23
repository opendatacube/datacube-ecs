FROM geoscienceaustralia/datacube-wms:latest

RUN apt-get update \
    && apt-get install -y awscli

ADD bootstrap_data.sh /bootstrap_data.sh

ENTRYPOINT ["/bin/sh", "-c", "/configure.sh && /bootstrap_data.sh" ]
