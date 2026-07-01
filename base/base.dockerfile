ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION} AS base

ARG ROS_DISTRO=humble

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# Install common tools and additional package passed as build-arg
RUN apt-get update && apt-get install -yq --no-install-recommends \
    software-properties-common \
    curl \
    locales

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


# Install ROS2
RUN add-apt-repository universe
RUN apt-get update &&\
    export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') &&\
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb
RUN apt-get update && apt-get install -yq --no-install-recommends \
    ros-${ROS_DISTRO}-desktop ros-dev-tools

# Install common tools and additional package passed as build-arg
RUN apt-get update && apt-get install -yq --no-install-recommends \
    git \
    dpkg \
    unzip \
    p7zip-full p7zip-rar \
    sudo \
    htop \
    btop \
    less \
    nano \
    python3 \
    python3-dev \
    python3-pip \
    python3-vcstool \
    python3-opencv \
    tmux \
    usbutils \
    vim \
    wget \
    zsh \
    gitk \
    stow \
    xsel \
    xterm \
    pipx \
    ripgrep \
    fd-find \
    network-manager \
    # linting and code checking
    isort \
    # Installing brew
    build-essential \
    file \
    procps \
    ca-certificates \
    # This will add gazebo harmonic, as that is default for jazzy
    ros-${ROS_DISTRO}-rmw-zenoh-cpp &&\
    apt-get -y autoremove &&\
    apt-get clean autoclean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default to zsh for root
RUN usermod --shell $(which zsh) root

# OH-MY-ZSH Installation
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"  &&\
     sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc


# Common zshrc sourcing
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.zsh" >> ~/.zshrc &&\
    echo "source /usr/share/vcstool-completion/vcs.zsh" >> ~/.zshrc &&\
    echo "# argcomplete for ros2 & colcon" >> ~/.zshrc &&\
    if [ "${ROS_DISTRO}" = "humble" ]; then\
        echo 'eval "$(register-python-argcomplete3 ros2)"' >> ~/.zshrc &&\
        echo 'eval "$(register-python-argcomplete3 colcon)"' >> ~/.zshrc ;\
    else\
        echo 'eval "$(register-python-argcomplete ros2)"' >> ~/.zshrc &&\
        echo 'eval "$(register-python-argcomplete colcon)"' >> ~/.zshrc ;\
    fi

# Install Homebrew
RUN useradd -m linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH
ENV PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin"

# Install brew tools
RUN brew update && brew install yazi lazygit neovim tree-sitter-cli

USER root
WORKDIR /root

# Instal pip tools
RUN pipx install tmuxp && pipx inject tmuxp shtab
RUN pip install pre-commit
# Make pipx tools avaiable in path
RUN echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.zshrc

# Add tmuxp autocompletions
RUN ~/.local/share/pipx/venvs/tmuxp/bin/shtab --shell=zsh -u tmuxp.cli.create_parser  | sudo tee /usr/local/share/zsh/site-functions/_TMUXP

# Add Neo-vim Kickstarter
Run git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

# Add config files
COPY ./dotfiles/ /root/dotfiles/universal/
RUN cd dotfiles && stow universal
RUN echo 'for f in ~/.config/zsh/*.sh; do [ -r "$f" ] && source "$f"; done' >> ~/.zshrc


RUN echo 'export RMW_IMPLEMENTATION=rmw_zenoh_cpp' >> ~/.zshrc
RUN echo 'export ROS_DOMAIN_ID=50' >> ~/.zshrc
# RUN echo "export ZENOH_CONFIG_OVERRIDE='mode=\"client\";connect/endpoints=[\"tcp/192.168.50.100:7447\"]'" >> ~/.zshrc

CMD [ "/bin/zsh" ]
