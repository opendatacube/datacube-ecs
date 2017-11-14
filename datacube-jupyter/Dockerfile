FROM geoscienceaustralia/datacube:latest

RUN source $HOME/.profile

RUN conda install jupyter

EXPOSE 8888

ADD run.sh ~/run.sh

ENTRYPOINT [ "run.sh" ]
