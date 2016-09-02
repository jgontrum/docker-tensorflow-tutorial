# Docker Tensorflow Tutorial

## Installation

- Set up a vanilla Debian server.
- Add your SSH key to the _~/.ssh/authorized_keys_ file of the root user on the server.
- Enable IP forwarding, otherwise you'll have difficulties communicating with your Docker containers.
- Install and start Docker
- Configure port forwarding

### IP Forwarding

Uncomment the line

```
#net.ipv4.ip_forward=1
```

in the _/etc/sysctl.conf_ file:

```
vim /etc/sysctl.conf
:%s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g
:x
sysctl -p
```

### Install Docker

Set the variable 'REMOTE' in the Makefile to the IP of your server and run 'make' on your local machine.

### Port Forwarding

Assuming you need to access the ports 8888 and 6006 for TensorBoard Jupyter, forward them to you local machine.

#### Solution 1: Config

~/.ssh/config [local machine]

```
Host tensorserver
    User root
    HostName 123.234.345.456
    LocalForward 8888 127.0.0.1:8888
    LocalForward 6006 127.0.0.1:6006
```

Open the ports with

```
ssh tensorserver
```

or without having to keep the ssh shell open:

```
ssh -fN tensorserver
```

#### Solution 2: Full SSH Command

```
ssh -L 8888:localhost:8888 root@123.234.345.456
```

## Use Docker

### Start an image from Docker Hub

On the server run:

```
docker pull tensorflow/tensorflow:latest
```

to download the image.

Then start it with:

```
docker run -it -p 127.0.0.1:8888:8888 --name mycontainer tensorflow/tensorflow:latest
```

CMD                   | Explanation
--------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-it                   | Interactive mode, you can control the program in the container
-d                    | Detached mode, the container runs in the background
-p                    | Make the following port accessable to the host system
127.0.0.1:8888:8888   | HOST_IP:HOST_PORT:CONTAINER_PORT
127.0.0.1             | The port is only open locally, e.g. for the port forwarding
0.0.0.0               | The port ist open to the whole internet (default)
tensorflow/tensorflow | Name of the image to run. USER/IMAGE:TAG
--name mycontainer    | Give this container the name 'mycontainer'. Naming your containers makes it more easy to stop and restart them once they run in detached and not the interactive mode.

### Build and run your own Docker image

Copy this folder to the server to '/root' and build a new container:

```
docker build -t yourname/yourapp .
```

Share the folder '/root/shared' with the container, so it can run the python script 'run.py' in the folder.

```
docker run -it -v /root/shared:/usr/shared yourname/yourapp
```

The flag '-v' shared a local directory to a path in the docker container: '-v LOCAL:CONTAINER'. Once started, this container runs the file 'run.py' in your local folder /root/shared.

#### The easy way

Just set the variable 'REMOTE_PATH' in the Makefile to place this folder should be copied on the server and run

```
make deploy
```

## Cheat Sheet

CMD            | Explanation
-------------- | -----------------------------------------------------
docker ps      | Show all the running containers
docker ps -a   | Show all containers, including those that are stopped
docker stop ID | Stop the container with the given ID
docker kill ID | Kill the container with the given ID
docker rm ID   | Remove the container with the given ID
docker images  | List all local images
docker rmi ID  | Remove the image with the given ID
