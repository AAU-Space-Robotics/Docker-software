# Docker-Software
This is all the docker images for the aau space robotics team

## Build

To build the docker images you need to be in the root of this repo and then run:
```
docker compose build <service_name>
```
Note:
When building the ROS packages run:
```
colcon build --symlink-install
```
This links the files, instead of copy them.


## Visuals
In order to use X11 support (to show GUI elements from within the docker container),
you have to relax xhost permissions before starting the docker container:

    xhost +local:root

And restrict those permissions again afterwards using:

    xhost -local:root



# Usage
## Start container
Execute:

    docker compose run --name <container_name> slam

This will make a container with the given name, and put you in the container.

To (re-)start the container and attach to it use:

    docker start -ai <container_name>

