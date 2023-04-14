VERSION 0.6
ARG DEBIAN_VERSION=sid
FROM debian:$DEBIAN_VERSION
ARG DEVCONTAINER_IMAGE_NAME_DEFAULT=ghcr.io/andyli/debian_packaging_devcontainer

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG TARGETARCH

devcontainer-base:
    ENV DEBIAN_FRONTEND=noninteractive
    RUN apt-get update \
        && apt-get install -qqy --no-install-recommends apt-utils dialog 2>&1 \
        && apt-get install -qqy \
            locales \
            iproute2 \
            procps \
            sudo \
            bash-completion \
            build-essential \
            pkg-config \
            cmake \
            autoconf \
            libtool \
            unzip \
            curl \
            wget \
            ca-certificates \
            nano \
            vim \
            software-properties-common \
            gnupg \
            pbuilder \
            ubuntu-dev-tools \
            git-buildpackage \
            lintian \
            piuparts \
            autopkgtest \
            apt-file \
            sbuild \
            dh-ocaml \
            docker.io \
            direnv \
        && echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc \
        #
        # Clean up
        && apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*

    ENV EDITOR /usr/bin/nano

    # setup locale
    RUN sed -i -e '/en_US.UTF-8/s/^# //g' -e'/C.UTF-8/s/^# //g' /etc/locale.gen \
        && locale-gen
    ENV LANG en_US.UTF-8
    ENV LANGUAGE en_US:en
    ENV LC_ALL en_US.UTF-8

    # create user
    RUN groupadd --gid $USER_GID $USERNAME \
        && useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME \
        && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
        && chmod 0440 /etc/sudoers.d/$USERNAME \
        && usermod -G docker -a $USERNAME \
        && adduser $USERNAME sbuild

    # Setting the ENTRYPOINT to docker-init.sh will configure non-root access 
    # to the Docker socket. The script will also execute CMD as needed.
    COPY .devcontainer/docker-init.sh /usr/local/share/
    ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
    CMD [ "sleep", "infinity" ]

    RUN mkdir -m 777 "/workspace"
    WORKDIR /workspace

# Usage:
# COPY +earthly/earthly /usr/local/bin/
# RUN earthly bootstrap --no-buildkit --with-autocomplete
earthly:
    FROM +devcontainer-base
    RUN curl -fsSL https://github.com/earthly/earthly/releases/download/v0.7.2/earthly-linux-${TARGETARCH} -o /usr/local/bin/earthly \
        && chmod +x /usr/local/bin/earthly
    SAVE ARTIFACT /usr/local/bin/earthly

devcontainer:
    FROM +devcontainer-base

    ENV DEBIAN_FRONTEND=

    # Install earthly
    COPY +earthly/earthly /usr/local/bin/
    RUN earthly bootstrap --no-buildkit --with-autocomplete

    USER $USERNAME

    # Config direnv
    COPY --chown=$USER_UID:$USER_GID .devcontainer/direnv.toml /home/$USERNAME/.config/direnv/config.toml
    RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

    USER root

    ARG GIT_SHA
    ENV GIT_SHA="$GIT_SHA"
    ARG IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME_DEFAULT"
    ARG IMAGE_TAG="master"
    ARG IMAGE_CACHE="$IMAGE_NAME:$IMAGE_TAG"
    SAVE IMAGE --cache-from="$IMAGE_CACHE" --push "$IMAGE_NAME:$IMAGE_TAG"

ci-images:
    ARG --required GIT_REF_NAME
    ARG --required GIT_SHA
    BUILD +devcontainer \ 
        --IMAGE_CACHE="$DEVCONTAINER_IMAGE_NAME_DEFAULT:$GIT_REF_NAME" \
        --IMAGE_TAG="$GIT_REF_NAME" \
        --IMAGE_TAG="$GIT_SHA" \
        --GIT_SHA="$GIT_SHA"
