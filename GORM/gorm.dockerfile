FROM gorm-drivers:latest AS gorm

ARG DEBIAN_FRONTEND=noninteractive
ARG WORKSPACE=gorm

ARG ROS_DISTRO=humble

# Create folder structure
RUN mkdir -p ~/ros/${WORKSPACE}/src

# Common zshrc sourcing
RUN sed -i "$(grep -n 'eval' ~/.zshrc | head -n1 | cut -d: -f1)i source ~/ros/${WORKSPACE}/install/setup.sh" ~/.zshrc

# Batch clone of the PRL repos using vcstool
COPY ./repos/gorm-internal.repos /root/ros/${WORKSPACE}/rover.repos
RUN vcs import < /root/ros/${WORKSPACE}/rover.repos ~/ros/${WORKSPACE}/src --recursive

# Workspace setup
WORKDIR /root/ros/${WORKSPACE}
RUN rm -f /etc/apt/apt.conf.d/docker-clean &&\
    apt-get update && apt-get upgrade -yq &&\
    rosdep init && rosdep update && rosdep install --from-paths src --ignore-src -r -y &&\
    apt-get -y autoremove &&\
    apt-get clean autoclean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Build the source
RUN /bin/zsh -c "source ~/.zshrc; \
         colcon build --symlink-install --continue-on-error \
         --cmake-args -DCMAKE_BUILD_TYPE=Release"


