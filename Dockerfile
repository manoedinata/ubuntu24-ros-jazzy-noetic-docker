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
    build-essential \
    cmake

# Build and install additional ROS Noetic packages from source
# (four_wheel_steering_msgs, urdf_geometry_parser, ros_controllers, velodyne),
# pinned to the commits currently checked out in fira_simulation_ws_3/src.
# can_msgs, FIRA-Autonomous-Cars-Simulator, and ros1_bridge are intentionally excluded.
WORKDIR /opt/fira_ws/src
RUN git clone https://github.com/ros-drivers/four_wheel_steering_msgs.git && \
    cd four_wheel_steering_msgs && git checkout 1bcea815f85efbfadfac41518de5f741d2c258d4
RUN git clone https://github.com/ros-controls/urdf_geometry_parser.git && \
    cd urdf_geometry_parser && git checkout 1d7317a0c5ec7b808e6607a5cd6620f24e402839
RUN git clone https://github.com/ros-controls/ros_controllers.git && \
    cd ros_controllers && git checkout c2348e85abf35cf33cf654a84d61db206abe9a73
RUN git clone https://github.com/ros-drivers/velodyne.git && \
    cd velodyne && git checkout b8096297fa4eeadd5f3bb83a282fd3e21c531171

WORKDIR /opt/fira_ws
# RUN rosdep init || true && rosdep update
# RUN . /opt/ros/noetic/setup.bash && \
#    rosdep install --from-paths src --ignore-src -r -y --rosdistro noetic
RUN /bin/bash -c ". /opt/ros/noetic/setup.bash && \
    catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic && \
    catkin_make install -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic"

WORKDIR /
RUN rm -rf /opt/fira_ws

# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
