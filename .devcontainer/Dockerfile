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
        default-libmysqlclient-dev \
        less \
        libpam-modules \
        locales \
        lsb-release \
        mysql-client \
        openssh-client \
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

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

USER ${USER}

# Generate and configure user keys.
RUN mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && touch ${HOME}/.ssh/authorized_keys && chmod 600 ${HOME}/.ssh/authorized_keys
RUN ssh-keygen -t ed25519 -a 100 -f ${HOME}/.ssh/id_ed25519

WORKDIR ${HOME}

# Copy files

COPY --chown=${USER}:${GROUP} ./files/env/ ${HOME}/

RUN chmod 644 ${HOME}/.config/fish/*.fish; exit 0
RUN chmod 644 ${HOME}/.config/fish/fish_variables; exit 0
RUN chmod 644 ${HOME}/.config/fish/conf.d/*.fish; exit 0
RUN chmod 644 ${HOME}/.config/fish/functions/*.fish; exit 0

RUN curl -L https://get.oh-my.fish > /tmp/oh-my.fish; chmod 755 /tmp/oh-my.fish; /usr/bin/fish /tmp/oh-my.fish; rm /tmp/oh-my.fish

# Update path
ENV PATH="$PATH:${HOME}/.local/bin:/src/infrastructure/env/bin"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# CMD ["/usr/bin/fish"]
