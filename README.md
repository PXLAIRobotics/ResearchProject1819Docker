# Research Project 18 19 Docker
This project contains a Dockerfile and its dependencies to run ROS Melodic, Webots, PyCharm, ... in a container with hardware acceleration using nvidia-docker.

## Prerequisites
- A computer with a recent NVIDIA graphics card
- Native Linux (Ubuntu, Debian and CentOS are supported, see nvidia-docker)
- Docker CE installed
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) installed
- [Git Large File Storage (LFS) ](https://git-lfs.github.com/) installed

## Setup and usage
### 1. Clone the repository using `git lfs`
There is a large file in this repository. It is stored using Git Large File Storage (LFS). First clone the repository like usual. Then change your directory to where the repository is located. Finally perform `git lfs pull` to download the large file.

```bash
$ git clone https://github.com/PXLAIRobotics/ResearchProject1819Docker
$ cd ResearchProject1819Docker
$ git lfs pull
```

### 2. Build the image
A simple bash script to build the image is included in this repository.

```bash
$ ./build_image.sh
```

This will download and install all the dependencies, including ROS Melodic, Webots and PyCharm. When completed it should show up in the output of `docker image ls` as `research_project1819`.

### 3. Create a container
Execute the provided bash script called `start_container.sh`. This will create a new container with the name 'research_project1819' with your GPU enabled inside the container.

### 4. Using the container
The container will start a simple bash environment. The terminal multiplexer `tmux` is also present. It's advised to use it if multiple bash shells are needed. For example, to run Webots together with other programs.

A `tmux` [cheat sheet](documents/tmux.pdf) is included in this repository.

The directory `/Projects/catkin_ws/src` on the docker container is linked to the directory `src` in this repository.

When all processes finish, the container will stop. It's still present on the host. To restart it and interact with with a new bash console, execute the following command. The `-a` flag will attach your terminal to the docker container.

```bash
$ docker start -a research_project1819
```

### 5. Removing the container
The container can be removed when it will not be used anymore. The container can be removed by executing the bash script `remove_container.sh`.

```bash
$ ./remove_container.sh
```
