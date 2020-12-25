
# Start a container with a shell:
docker run -it <image-name> /bin/bash

# mount your code directory into container at /src
# (Assumes you are in project root)
docker run -it -v "$(pwd)":/src <image-name> /bin/bash

# "shell" into a running container:
docker exec -it <container-name> bash

# Misc

# To inspect a running container:
docker inspect <container-name> (or <container-id>)

# To get the process ID for a container:
docker inspect --format {{.State.Pid}} <container-name-or-id>

# To list (and pretty-print) the current mounted volumes for a container:
docker inspect --format='{{json .Volumes}}' <container-id> | python -mjson.tool

# To copy files/folders between a container and your host:
docker cp foo.txt mycontainer:/foo.txt

# To list currently running containers:
docker ps

# To list all containers:
docker ps -a

# To remove all stopped containers:
docker rm $(docker ps -qa)

# To list all images:
docker images

# To remove all untagged images:
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

# To remove all volumes not used by at least one container:
docker volume prune
