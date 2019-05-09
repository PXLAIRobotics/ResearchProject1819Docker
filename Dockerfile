FROM nvidia/cudagl:9.2-devel-ubuntu18.04

# We love UTF!
ENV LANG C.UTF-8

RUN set -x \
        && apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y apt-transport-https ca-certificates \
        && apt-get install -y git vim htop sudo curl wget mesa-utils python-pip \
        && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user \
    && echo "user:user" | chpasswd && adduser user sudo \
    && usermod -aG audio user

ENV DEBIAN_FRONTEND noninteractive

RUN wget -qO - https://www.cyberbotics.com/Cyberbotics.asc | sudo apt-key add - \
        && apt-get update \
        && apt-get install -y software-properties-common \
        && apt-add-repository 'deb http://www.cyberbotics.com/debian/ binary-amd64/' \
        && apt-get update \
        && apt-get install -y webots libnss3 \
        && rm -rf /var/lib/apt/lists/*

USER user
WORKDIR /home/user

# Set some decent colors if the container needs to be accessed via /bin/bash.
RUN echo LS_COLORS=$LS_COLORS:\'di=1\;33:ln=36\' >> ~/.bashrc \
&& echo export LS_COLORS >> ~/.bashrc \
&& touch ~/.sudo_as_admin_successful # To surpress the sudo message at run.

ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,display

USER root
# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

RUN apt-get update \
        && apt-get install -y ros-melodic-desktop-full \
        && apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential \
        && rm -rf /var/lib/apt/lists/* \
        && rosdep init

USER user
RUN rosdep update \
        && echo "source /opt/ros/melodic/setup.bash" >> /home/user/.bashrc

USER root
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update \
        && apt-get install -y tmux \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/PXL/catkin_ws/src \
        && cp -R /usr/local/webots/projects/languages/ros/webots_ros/ /opt/PXL/catkin_ws/src/ \
        && cp -R /usr/local/webots/projects/default/controllers/ros/include/msg /opt/PXL/catkin_ws/src/webots_ros/ \
        && cp -R /usr/local/webots/projects/default/controllers/ros/include/srv /opt/PXL/catkin_ws/src/webots_ros/ 

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /opt/PXL/catkin_ws; catkin_make'

RUN echo "source /opt/PXL/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

COPY ./scripts/init_commands.sh /scripts/init_commands.sh
RUN ["chmod", "+x", "/scripts/init_commands.sh"]

USER user
WORKDIR /home/user
RUN mkdir -p Projects/catkin_ws/src 
RUN mkdir -p Programs/PyCharm
COPY ./pycharm-community-2019.1.1.tar.gz Programs/PyCharm/
WORKDIR /home/user/Programs/PyCharm
RUN tar xvf ./pycharm-community-2019.1.1.tar.gz
RUN rm ./pycharm-community-2019.1.1.tar.gz
WORKDIR /home/user
COPY ./PyCharmCE2019.1.tar.gz PyCharmCE2019.1.tar.gz
RUN tar xvf ./PyCharmCE2019.1.tar.gz
RUN rm ./PyCharmCE2019.1.tar.gz
COPY ./scripts/charm /usr/local/bin/charm

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /home/user/Projects/catkin_ws; catkin_make'
RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /home/user/Projects/catkin_ws; catkin_make'

RUN echo "source /home/user/Projects/catkin_ws/devel/setup.bash --extend" >> /home/user/.bashrc

RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack  \
&& git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux-resurrect

COPY ./.tmux.conf /home/user/.tmux.conf

STOPSIGNAL SIGTERM

ENTRYPOINT ["/scripts/init_commands.sh"]
CMD /bin/bash
