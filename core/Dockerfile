FROM debian
MAINTAINER teste
RUN groupadd testers
RUN useradd teste
RUN usermod -a -G testers teste
COPY . /home/docker/teste
RUN apt-get update
RUN apt-get install -y gcc g++ bc python python3 fpc default-jre default-jdk
RUN chown root:testers /home/docker/teste/JOBS
RUN chown root:testers /home/docker/teste/DONE
RUN chown root:testers /home/docker/teste/DOING
RUN chmod 770 /home/docker/teste/DOING
USER teste
RUN /bin/bash
