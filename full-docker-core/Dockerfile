FROM debian
MAINTAINER c0r3
RUN useradd c0r3
COPY . /c0r3
RUN apt-get update
RUN apt-get install -y gcc g++ apt-utils bc python python3 fpc default-jre default-jdk procps sudo wget
RUN usermod -a -G sudo c0r3
RUN chown root:sudo /c0r3/JOBS
RUN chown root:sudo /c0r3/DONE
RUN chown root:sudo /c0r3/DOING
# VOLUME /c0r3/JOBS/:`pwd`/JOBS/
# VOLUME /c0r3/DONE/:`pwd`/DONE/
RUN chmod 770 /c0r3/JOBS
RUN chmod 770 /c0r3/DOING
RUN chmod 770 /c0r3/DONE
USER c0r3
ENTRYPOINT ["/bin/bash"]
CMD ["/c0r3/checkcore.sh"]
