FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["bash", "-c"]

RUN apt-get update && \
      apt-get -y install sudo

RUN useradd -m TP4HCEP && echo "TP4HCEP:TP4HCEP" | chpasswd && adduser TP4HCEP sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER TP4HCEP

WORKDIR /home/TP4HCEP

RUN sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    bc \
    git \
    unzip \
    wget \
    python3 \
    python-is-python3 \
    cmake \
    gcc \
    ninja-build \
    ccache \
    zip \
    lsb-release \
    software-properties-common \
    gnupg


# Setup git config
ARG GIT_NAME="TP4HCEP"
ENV GIT_NAME=${GIT_NAME}
ARG GIT_EMAIL="tpahc3p@gmail.com"
ENV GIT_EMAIL=${GIT_EMAIL}
RUN git config --global user.name "${GIT_NAME}"
RUN git config --global user.email "${GIT_EMAIL}"
# Enable color output (optional)
RUN git config --global color.ui true
# Pull rebase by default or supply ARG PULL_REBASE=false
ARG PULL_REBASE=true
ENV PULL_REBASE=${PULL_REBASE}
RUN git config --global pull.rebase ${PULL_REBASE}

# Install and setup latest repo, if needed
RUN sudo curl -s https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo \
        && sudo chmod a+x /usr/local/bin/repo \
        && repo --version

# Download and install latest clang
RUN sudo curl -s https://apt.llvm.org/llvm.sh > /tmp/llvm.sh \
        && sudo chmod a+x /tmp/llvm.sh \
        && sudo /tmp/llvm.sh \
        && export LLVM_VERSION=$(cat /tmp/llvm.sh | grep -oP 'CURRENT_LLVM_STABLE=(\K[0-9.]+)') \
        && for i in $(ls /usr/lib/llvm-$LLVM_VERSION/bin) ; do sudo ln -s /usr/lib/llvm-$LLVM_VERSION/bin/$i /usr/bin/$i ; done \
        && sudo rm /tmp/llvm.sh

RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

CMD [ "bash", "-c" ]
