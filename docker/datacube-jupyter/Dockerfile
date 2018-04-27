FROM geoscienceaustralia/datacube:latest

EXPOSE 80

ADD install.sh /install.sh

RUN /install.sh

RUN apt-get update \
    && apt-get install -y awscli

ADD configure.sh /configure.sh
ADD run.sh /run.sh

ENTRYPOINT ["/bin/sh", "-c", "/configure.sh && /run.sh" ]
