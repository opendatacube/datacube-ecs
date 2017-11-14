FROM geoscienceaustralia/datacube:latest

EXPOSE 8888

ADD install.sh /install.sh

RUN /install.sh

ADD run.sh /run.sh

ENTRYPOINT ["/run.sh" ]
