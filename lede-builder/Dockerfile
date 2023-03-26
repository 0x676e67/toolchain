FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/gngpp/profiles

RUN sed -i s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g /etc/apt/sources.list \
    && sed -i s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g /etc/apt/sources.list \
    && apt-get update -y && apt-get upgrade -y

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

ARG USERNAME=gngpp
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
WORKDIR /build

RUN sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
    git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev vpnc \
    libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz aria2 lib32gcc-s1 \
    mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
    rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev libfuse-dev npm zstd

RUN git config --global user.name "gngpp" && git config --global user.email "gngpp@example.com"
ENV GO111MODULE=on GOPROXY=https://goproxy.cn,direct

RUN sudo apt install -y neofetch vim

# Uses "Spaceship" theme with some customization. Uses some bundled plugins and installs some more from github
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN echo "neofetch" >> ~/.zshrc

ENTRYPOINT ["/usr/bin/zsh"]