FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install dependencies for adding repositories
RUN apt-get update && apt-get install -y curl software-properties-common && \
    add-apt-repository universe

# Add the ROS 2 Jazzy apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu noble main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 Jazzy
RUN apt-get update
RUN apt-get install -y \
    ros-jazzy-desktop-full \
    ros-dev-tools
    
# Install ROS Noetic
RUN add-apt-repository -y ppa:ros-for-jammy/noble

RUN apt-get install -y \
    ros-noetic-desktop-full

# For better interactive shell
RUN rm -rf /etc/apt/apt.conf.d/docker-*
RUN apt-get update && apt-get install -y \
    bash-completion \
    git \
    vim \
    wget \
    build-essential

# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
