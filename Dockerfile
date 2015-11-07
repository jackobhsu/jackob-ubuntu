FROM ubuntu:14.04 

MAINTAINER jackob hsu

RUN sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive
RUN echo exit 101 > /usr/sbin/policy-rc.d && \
  chmod +x /usr/sbin/policy-rc.d
RUN apt-get -y update 
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8 
RUN echo -e 'LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8' > /etc/default/locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales
RUN apt-get -y install --reinstall locales
RUN apt-get -y install language-pack-zh-hant-base
RUN apt-get -y install language-pack-zh-hans-base

RUN cp -vf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
RUN echo Asia/Taipei | tee /etc/timezone

RUN apt-get install -y openssh-server openssh-client supervisor salt-minion
RUN mkdir /var/run/sshd

RUN echo 'root:520jackob@' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

ADD ./conf/config /root/.ssh/config
ADD ./conf/setEnv.sh /etc/profile.d/setEnv.sh
ADD ./conf/minion_supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]

