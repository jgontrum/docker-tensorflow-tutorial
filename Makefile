## Target hostname
REMOTE=123.234.345.456
IMAGENAME=yourname/yourapp
CONTAINERNAME=myapp

REMOTE_PATH=~/

## SHH config for this server
SSH_KEY=~/.ssh/id_rsa
SSH_USER=root

## The linux distribution that is running on the server.
## Possible values: ubuntu, debian
REMOTE_SYSTEM=debian

## Name of the system, like 'xenial' for Ubuntu or 'jessie' for Debian.
REMOTE_SYSTEM_VERSION=jessie
################################################################################
# COMMANDS
SSH=ssh -i $(SSH_KEY) -oStrictHostKeyChecking=no $(SSH_USER)@$(REMOTE)
SCP=scp -i $(SSH_KEY) -oStrictHostKeyChecking=no

# Leave this empty, if you do not use '$(SUDO)'. Else: SUDO=sudo
SUDO=

################################################################################

all: docker_setup docker_start


# Setup docker depending on the system running on the server
docker_setup:
ifeq ($(REMOTE_SYSTEM),ubuntu)
	@echo "[$(APP)] Starting the initial Docker setup on an Ubuntu machine..."
	@$(SSH) '$(SUDO) apt-get update && $(SUDO) apt-get -y install apt-transport-https ca-certificates && $(SUDO) apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
	@$(SSH) '$(SUDO) echo "deb https://apt.dockerproject.org/repo ubuntu-$(REMOTE_SYSTEM_VERSION) main" > /etc/apt/sources.list.d/docker.list'
	@$(SSH) '$(SUDO) apt-get update && $(SUDO) apt-get -y install linux-image-extra-$$(uname -r) docker-engine'
else
ifeq ($(REMOTE_SYSTEM),debian)
	@echo "[$(APP)] Starting the initial Docker setup on a Debian machine..."
	@$(SSH) '$(SUDO) apt-get update && $(SUDO) apt-get -y install apt-transport-https ca-certificates && $(SUDO) apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
	@$(SSH) '$(SUDO) echo "deb https://apt.dockerproject.org/repo debian-$(REMOTE_SYSTEM_VERSION) main" > /etc/apt/sources.list.d/docker.list'
	@$(SSH) '$(SUDO) apt-get update && $(SUDO) apt-get -y install docker-engine'
endif
endif

# Start the docker service
docker_start:
	@$(SSH) '$(SUDO) service docker start'
	@echo "[$(APP)] Docker started on the remote machine."

docker_stop:
	@$(SSH) '$(SUDO) service docker stop'
	@echo "[$(APP)] Docker stopped on the remote machine."

docker_restart: docker_stop docker_start

upload:
	@$(SSH) 'mkdir -p $(REMOTE_PATH)'
	@$(SCP) -r . $(SSH_USER)@$(REMOTE):$(REMOTE_PATH)/
	@$(SSH) 'docker build -t $(IMAGENAME) .'

deploy: upload stop start

start:
	@$(SSH) 'docker kill $(CONTAINERNAME) 2>/dev/null > /dev/null ; true'
	@$(SSH) 'docker rm $(CONTAINERNAME) 2>/dev/null > /dev/null ; true'
	@$(SSH) 'docker run --restart=always -d -v $(REMOTE_PATH)/shared:/usr/shared --name="$(CONTAINERNAME)" $(IMAGENAME) 2>/dev/null > /dev/null'

stop:
	@$(SSH) 'docker kill $(CONTAINERNAME) 2>/dev/null > /dev/null ; true'
	@$(SSH) 'docker rm $(CONTAINERNAME) 2>/dev/null > /dev/null ; true'
