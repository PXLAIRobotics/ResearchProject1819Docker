# Research Project 18 19 Docker
A Dockerfile and its dependencies to run ROS Melodic, Webots, PyCharm, ... in a container with hardware acceleration using nvidia-docker.

## Prerequisites
- A computer with a recent NVidia graphics Card
- Native Linux (Ubuntu, Debian and CentOS are supported, see nvidia-docker)
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
- [Git Large File Storage (LFS) ](https://git-lfs.github.com/)

## Setup and usage
### 1. Clone the repository using `git lfs`
There are a few large files in this repository. They are stored using Git Large File Storage (LFS). **DO NOT** use the standard `git clone` command. It will not clone the complete repository. Worse, it will clone it partially 

```bash
$ git lfs clone 
```

### 2. Build the image
A simple bash script to build the image is included in this repository.

```bash
$ ./build_image.sh
```

This will download and install all the dependencies, including ROS Melodic, Webots and PyCharm. When completed it should show up in the output of `docker image ls` as `research_project1819`. 

### 3. Create a container
Execute the provided bash script called `start_container.sh`. This will create a new container with a random name with your GPU enabled inside the container.


### 4. Using the container
The container will start a simple bash environment. The terminal multiplexer `tmux` is also present. It's advised to use it if multiple Bash shells are needed. For example, to run Webots together with other programs.

A `tmux` [cheat sheet](documents/tmux.pdf) is included in this repository.

When all processes finnish, the container will stop. It's still present on the host. To restart it and interact with with a new Bash console, execute the following two commands:

```bash
$ docker start the_random_name_of_your_container
$ docker attach the_random_name_of_your_container 
```


