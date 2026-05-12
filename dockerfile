# 使用官方的 Debian 13 (Trixie) 精简版镜像作为基础
FROM debian:13-slim

# 维护者信息 (可选)
LABEL maintainer="Wang Guangke <gkwangs@163.com>"

# 设置环境变量，避免 apt-get 安装时进入交互模式
ENV DEBIAN_FRONTEND=noninteractive

COPY ./aliyun.sources /etc/apt/sources.list.d/
RUN sed -i 's/deb\.debian\.org/mirrors\.aliyun\.com/g' /etc/apt/sources.list.d/debian.sources

# 第1步：安装你工作环境中的核心软件包
# 这里的列表来自你第一步中导出的 packages_list.txt 文件
# 使用 --no-install-recommends 避免安装不必要的推荐包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    autopoint \
    autotools-dev \
    bash \
    bash-completion \
    bc \
    binutils \
    binutils-common \
    binutils-x86-64-linux-gnu \
    bison \
    bluez \
    bpftool \
    bsdextrautils \
    bsdutils \
    btrfs-progs \
    build-essential \
    busybox \
    bzip2 \
    ca-certificates \
    ca-certificates-java \
    clang \
    clang-19 \
    clang-format \
    clang-format-19 \
    clang-tools-19 \
    cloc \
    coreutils \
    cpio \
    cpp \
    cpp-14 \
cpp-14-x86-64-linux-gnu \
cpp-x86-64-linux-gnu \
cscope \
curl \
dash \
diffutils \
dpkg \
dpkg-dev \
dracut-install \
e2fsprogs \
emacsen-common \
fdisk \
file \
findutils \
flex \
fuse3 \
g++ \
g++-14 \
g++-14-x86-64-linux-gnu \
g++-x86-64-linux-gnu \
gcc \
gcc-14 \
gcc-14-base \
gcc-14-x86-64-linux-gnu \
gcc-x86-64-linux-gnu \
gcr \
gcr4 \
gdb \
genisoimage \
git \
git-man \
grep \
gzip \
hostname \
htop \
ifupdown \
less \
lsof \
lsscsi \
luit \
lynx \
lynx-common \
m4 \
mailcap \
make \
mawk \
modemmanager \
mount \
nano \
nasm \
ncurses-base \
ncurses-bin \
ncurses-term \
nedit \
netbase \
netcat-traditional \
netfilter-persistent \
nftables \
passwd \
patch \
procps \
psmisc \
publicsuffix \
python-apt-common \
python-babel-localedata \
python3 \
python3-alabaster \
python3-apt \
python3-babel \
python3-brlapi \
python3-cairo \
python3-certifi \
python3-chardet \
python3-charset-normalizer \
python3-dbus \
python3-debconf \
python3-debian \
python3-debianbts \
python3-defusedxml \
python3-distro \
python3-docutils \
python3-gi \
python3-idna \
python3-imagesize \
python3-jinja2 \
python3-louis \
python3-markupsafe \
python3-minimal \
python3-olefile \
python3-packaging \
python3-pil \
python3-pygments \
python3-reportbug \
python3-requests \
python3-roman \
python3-snowballstemmer \
python3-speechd \
python3-sphinx \
python3-sphinx-rtd-theme \
python3-sphinxcontrib.jquery \
python3-uno \
python3-urllib3 \
python3-xdg \
python3-yaml \
python3.13 \
python3.13-minimal \
sed \
sqv \
strace \
tar \
tcpdump \
teckit \
tinyproxy \
tinyproxy-bin \
unzip \
vim \
vim-common \
vim-runtime \
vim-tiny \
wget \
xml-core \
xz-utils \
locales \
qemu-system-x86 \
libelf-dev \
libncurses-dev \
libssl-dev \
universal-ctags \
sudo \
liburing-dev \
    && apt-get -y build-dep linux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN sed -i 's/^"au BufReadPost/au BufReadPost/g' /etc/vim/vimrc

# 创建与宿主机相同的用户和组（假设 UID/GID 都是 1000）
RUN groupadd -g 1000 gkwang && \
    useradd -m -u 1000 -g gkwang -s /bin/bash gkwang
RUN echo "gkwang  ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers 
USER gkwang
WORKDIR /home/gkwang

# 家目录环境
RUN mkdir -p /home/gkwang/TestKits /home/gkwang/.mkdocker \
    /home/gkwang/Work /home/gkwang/Data

# rust环境
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/gkwang/.cargo/bin:${PATH}"

# 第3步：复制配置文件，实现环境个性化
COPY --chown=gkwang:gkwang .myapp/ /home/gkwang/.myapp
COPY --chown=gkwang:gkwang .vim/ /home/gkwang/.vim
COPY --chown=gkwang:gkwang .bashrc .profile .vimrc /home/gkwang
COPY --chown=gkwang:gkwang .bash_logout .gitconfig .viminfo /home/gkwang

COPY --chown=gkwang:gkwang dockerfile installed_packages.txt packages_list.txt /home/gkwang/.mkdocker
# COPY --chown=gkwang:gkwang mm.tar.gz /home/gkwang/Data
 
COPY --chown=gkwang:gkwang workspace/ /home/gkwang/TestKits/workspace

# 第4步：设置容器启动时的默认行为
# 当容器启动时，默认打开一个 shell
CMD ["/bin/bash", "-l"]
