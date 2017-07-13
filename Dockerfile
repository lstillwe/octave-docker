FROM ubuntu:wily
MAINTAINER Lisa Stillwell lisa@renci.org

ENV DEBIAN_FRONTEND noninteractive

ADD install.sh install.sh
RUN sh ./install.sh && rm install.sh

ENTRYPOINT ["octave", "--silent"]
#CMD ["/bin/bash"]
