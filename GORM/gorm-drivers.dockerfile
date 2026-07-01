FROM base:latest AS gorm-drivers

ARG DRIVER_PATH=/root/external_drivers
WORKDIR ${DRIVER_WS}

ARG ROS_DISTRO=humble
ARG DEBIAN_FRONTEND=noninteractive
# Install Livox SDK2 (provides liblivox_lidar_sdk_shared.so)
RUN git clone --depth 1 https://github.com/Livox-SDK/Livox-SDK2.git /tmp/Livox-SDK2 && \
    cmake -S /tmp/Livox-SDK2 -B /tmp/Livox-SDK2/build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /tmp/Livox-SDK2/build --target install -j"$(nproc)" && \
    ldconfig && \
    rm -rf /tmp/Livox-SDK2

ARG LIVOX_PATH=${DRIVER_PATH}/livox_ws

# Prepare workspace
WORKDIR ${LIVOX_PATH}/src
ARG LIVOX_ROS_DRIVER_REPO=https://github.com/Livox-SDK/livox_ros_driver2.git
ARG LIVOX_ROS_DRIVER_REF=13eb05e4e6dd7a765b934d0c5fd6236676a57b49
# Clone Livox ROS 2 driver and prepare ROS 2 layout
RUN git clone ${LIVOX_ROS_DRIVER_REPO} livox_ros_driver2 && \
    cd livox_ros_driver2 && \
    git checkout --detach ${LIVOX_ROS_DRIVER_REF}

RUN /bin/zsh -c "source ~/.zshrc && cd ${LIVOX_PATH}/src/livox_ros_driver2 && ./build.sh humble"

WORKDIR ${LIVOX_PATH}
RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.zshrc

RUN sed -i "$(grep -n 'eval' ~/.zshrc | head -n1 | cut -d: -f1)i source ${LIVOX_PATH}/install/setup.zsh" ~/.zshrc

# Resolve dependencies
# RUN apt-get update && \
#     rosdep init || true && \
#     rosdep update --rosdistro ${ROS_DISTRO} && \
#     rosdep install --from-paths src --ignore-src -y --rosdistro ${ROS_DISTRO} && \
#     rm -rf /var/lib/apt/lists/*

# # Build workspace
# RUN /bin/bash -c "source ~/.zshrc && \
    # colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DROS_EDITION=ROS2 -DHUMBLE_ROS=${ROS_DISTRO} -DDISTRO_ROS=${ROS_DISTRO}"

# Environment setup
# ENV LIVOX_CONFIG_DIR=/home/livox/config
