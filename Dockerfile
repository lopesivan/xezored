FROM registry.local:5000/ubuntu:20.04
#FROM ubuntu:20.04

MAINTAINER Ivan Lopes <ivanlopes@id.uff.br>

ENV DEBIAN_FRONTEND=noninteractive

# Install basic development tools
# ----------------------------------------------------
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential\
		cmake\
		git\
		clang-10\
		python3\
		python3-pip\
    && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100

# Install workaround to run as current user
# ----------------------------------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    chmod +x /usr/local/bin/entrypoint.sh

ENV BUILD_BASE /tmp/su-exec-1000

RUN \
    git clone --branch v0.2 --depth 1 https://github.com/ncopa/su-exec.git && \
    cd su-exec && \
    if [ `git rev-parse --verify HEAD` != 'f85e5bde1afef399021fbc2a99c837cf851ceafa' ]; then exit 1; fi && \
    make && \
    cp su-exec /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash", "-l"]
