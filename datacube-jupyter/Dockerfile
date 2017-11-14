FROM geoscienceaustralia/datacube:latest

RUN . $HOME/.profile

RUN conda install jupyter

EXPOSE 8888

ADD run.sh ~/run.sh

ENTRYPOINT [ "run.sh" ]
