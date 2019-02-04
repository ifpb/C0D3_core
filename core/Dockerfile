FROM debian
MAINTAINER teste
RUN useradd teste
COPY . /home/docker/teste
VOLUME /home/kr4k3n/docker/C0D3_core/JOBS:/home/docker/teste/JOBS
VOLUME /home/kr4k3n/docker/C0D3_core/DONE:home/docker/teste/DONE
RUN chmod u=rwx /home/docker/teste/DONE
RUN chmod u=rwx /home/docker/teste/JOBS
USER teste
RUN /bin/bash
