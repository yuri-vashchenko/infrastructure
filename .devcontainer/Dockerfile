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
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        bc \
        bsdmainutils \
        build-essential \
        cmake \
        gcc \
        file \
        git-svn \
        git-lfs \
        libarchive-zip-perl \
        make \
        cpio \
        libncurses5-dev \
        libncurses5 \
        wget \
        python3 \
        unzip \
        tar \
        sudo \
        lsb-release \
        graphviz \
        autoconf \
        libsqlite3-dev \
        libc6-i386 \
        tzdata \
        xz-utils \
        python3-dev \
        python-is-python3 \
        python-dev-is-python3 \
        python3-venv \
        libkrb5-dev \
        openssh-client \
        openssh-server \
        libpam-modules \
        sshpass \
        python3-pip \
        krb5-user \
        vim \
        git \
        rsync \
        gpg-agent \
        locales \
        curl


#--- Create user -----------------------------------------------------------------------------------

RUN adduser ${USER} --disabled-password --gecos "" --shell /bin/bash ; \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers ; \
    sed -i "s/^#force_color_prompt=.*/force_color_prompt=yes/" ${HOME}/.bashrc ; \
    touch ${HOME}/.bash_login

ENV GCC_COLORS=error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01
ENV PS1="\[\033[01;32m\]\u\[\033[00m\]: \[\033[01;34m\]\w\[\033[00m\] \$"

#--- Add toolchains and set PATH -------------------------------------------------------------------

# copy and extract toolchains

RUN ln -sf /usr/share/zoneinfo/Asia/Vladivostok /etc/localtime

RUN mkdir /src

# setup environment and add extra packages for development
# install software-properties-common for add-apt-repository to work
RUN apt-get install -y --no-install-recommends software-properties-common

# update apt cache
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        default-jre tmux \
        silversearcher-ag \
        && \
    apt-get autoremove -y; apt-get clean; rm /var/lib/apt/lists/* -r ; \
    rm -rf /usr/share/man/* ; \
    rm -rf /tmp/* /var/tmp/*

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

RUN chown ${USER}:${GROUP} /src
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Configure SSHD.
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd
RUN bash -c 'install -m755 <(printf "#!/bin/sh\nexit 0") /usr/sbin/policy-rc.d'
RUN ex +'%s/^#\zeListenAddress/\1/g' -scwq /etc/ssh/sshd_config
RUN ex +'%s/^#\zeHostKey .*ssh_host_.*_key/\1/g' -scwq /etc/ssh/sshd_config
RUN RUNLEVEL=1 dpkg-reconfigure openssh-server
RUN ssh-keygen -A -v
RUN update-rc.d ssh defaults

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# install oh-my-posh https://ohmyposh.dev/docs/linux
RUN wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
RUN chmod +x /usr/local/bin/oh-my-posh

USER ${USER}

# install oh-my-posh themes
RUN mkdir ${HOME}/.poshthemes
RUN wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ${HOME}/.poshthemes/themes.zip
RUN unzip ${HOME}/.poshthemes/themes.zip -d ${HOME}/.poshthemes
RUN chmod u+rw ${HOME}/.poshthemes/*.json
RUN rm ${HOME}/.poshthemes/themes.zip

# install tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm

# Generate and configure user keys.
RUN mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && touch ${HOME}/.ssh/authorized_keys && chmod 600 ${HOME}/.ssh/authorized_keys
RUN ssh-keygen -t ed25519 -a 100 -f ${HOME}/.ssh/id_ed25519
COPY ./files/.ssh/authorized_keys /tmp/authorized_keys
RUN cat /tmp/authorized_keys >> ${HOME}/.ssh/authorized_keys && rm -f /tmp/authorized_keys

WORKDIR ${HOME}

# Create directories
RUN mkdir -p \
    ${HOME}/.local/env/dircolors-solarized \
    ${HOME}/.local/bin \
    ${HOME}/.gnupg

# Copy files

COPY --chown=${USER}:${GROUP} ./files/env/* ${HOME}/
COPY --chown=${USER}:${GROUP} ./files/.local/bin/* ${HOME}/.local/bin/
COPY --chown=${USER}:${GROUP} ./files/.gnupg/gpg-agent.conf ${HOME}/.gnupg/gpg-agent.conf

# Copy and choose dircolors flavor
COPY --chown=${USER}:${GROUP} ./files/dircolors-solarized/dircolors.* ${HOME}/.local/env/dircolors-solarized
RUN cp ${HOME}/.local/env/dircolors-solarized/dircolors.ansi-dark ${HOME}/.dircolors

# change permissions
RUN cd ${HOME} && chmod 644 .bashrc .bash_profile .bash_aliases .tmux.conf .dircolors .profile .gnupg/gpg-agent.conf

# Update path
ENV PATH="$PATH:${HOME}/.local/bin"

USER ${USER}
