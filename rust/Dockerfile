FROM messense/cargo-zigbuild:latest

LABEL org.opencontainers.image.source https://github.com/gngpp/profiles

RUN sed -i s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g /etc/apt/sources.list \
    && sed -i s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g /etc/apt/sources.list \
    && apt-get update -y && apt-get upgrade -y

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

WORKDIR /build

RUN git config --global user.name "gngpp" && git config --global user.email "gngpp@example.com"
ENV GO111MODULE=on GOPROXY=https://goproxy.cn,direct

RUN apt install -y git zsh htop wget neofetch vim net-tools autoconf upx
RUN rustup update

# Uses "Spaceship" theme with some customization. Uses some bundled plugins and installs some more from github
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN echo "neofetch" >> ~/.zshrc
RUN cargo install cargo-deb cargo-generate-rpm
RUN git clone https://github.com/NixOS/patchelf
RUN cd patchelf && \
    ./bootstrap.sh && \
    ./configure && \
    make && make check && make install

ENTRYPOINT ["/usr/bin/zsh"]