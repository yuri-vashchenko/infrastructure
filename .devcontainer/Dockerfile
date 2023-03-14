FROM ubuntu:22.04

ARG USER="infra"

LABEL name=infrastructure
LABEL description="my home infrastructure"
LABEL maintainer="Yuri Vashchenko <yuri.vashchenko@gmail.com>"

ENV GROUP="${USER}"
ENV HOME="/home/${USER}"

RUN echo "user: ${USER}, group: ${GROUP}, home dir: ${HOME}"

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

USER root

#--- Install dependencies list ---------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        file \
        fish \
        gh \
        git \
        libmysqlclient-dev \
        libpam-modules \
        locales \
        lsb-release \
        mysql-client \
        openssh-client \
        openssh-server \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        python-dev-is-python3 \
        python-is-python3 \
        sshpass \
        sudo \
        tar \
        tzdata \
        unzip \
        vim \
        wget \
        xz-utils \
        && \
    apt-get autoremove -y; apt-get clean; rm /var/lib/apt/lists/* -r ; \
    rm -rf /usr/share/man/* ; \
    rm -rf /tmp/* /var/tmp/*


#--- Create user -----------------------------------------------------------------------------------

RUN adduser ${USER} --disabled-password --gecos "" --shell /usr/bin/fish ; \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN ln -sf /usr/share/zoneinfo/Asia/Vladivostok /etc/localtime

RUN mkdir /src

RUN chmod 2777 /tmp

RUN locale-gen en_US.UTF-8
RUN sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG=en_US.UTF-8'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY ./files/python/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt ; rm requirements.txt

RUN update-ca-certificates --fresh

RUN chown ${USER}:${GROUP} /src
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# CMD ["/usr/bin/fish"]

# Configure SSHD.
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN bash -c 'install -m755 <(printf "#!/bin/sh\nexit 0") /usr/sbin/policy-rc.d'
RUN ex +'%s/^#\zeListenAddress/\1/g' -scwq /etc/ssh/sshd_config
RUN ex +'%s/^#\zeHostKey .*ssh_host_.*_key/\1/g' -scwq /etc/ssh/sshd_config
RUN RUNLEVEL=1 dpkg-reconfigure openssh-server
RUN ssh-keygen -A -v
RUN update-rc.d ssh defaults

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

USER ${USER}

# Generate and configure user keys.
RUN mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && touch ${HOME}/.ssh/authorized_keys && chmod 600 ${HOME}/.ssh/authorized_keys
RUN ssh-keygen -t ed25519 -a 100 -f ${HOME}/.ssh/id_ed25519
COPY ./files/env/.ssh/authorized_keys /tmp/authorized_keys
RUN cat /tmp/authorized_keys >> ${HOME}/.ssh/authorized_keys && rm -f /tmp/authorized_keys

WORKDIR ${HOME}

# Copy files

COPY --chown=${USER}:${GROUP} ./files/env/ ${HOME}/

RUN chmod 644 ${HOME}/.config/fish/*.fish
RUN chmod 644 ${HOME}/.config/fish/fish_variables
RUN chmod 644 ${HOME}/.config/fish/conf.d/*.fish
RUN chmod 644 ${HOME}/.config/fish/functions/*.fish

RUN curl -L https://get.oh-my.fish | fish

# Update path
ENV PATH="$PATH:${HOME}/.local/bin:/src/infrastructure/env/bin"
