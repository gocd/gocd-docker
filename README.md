This is the repository which contains the Dockerfiles and supporting scripts for:

https://registry.hub.docker.com/u/gocd/gocd-agent/

https://registry.hub.docker.com/u/gocd/gocd-server/

Follow those URLs for more details about the actual images. For instructions to build the Docker images yourself, check
the first line of each Dockerfile.


# Running
## Server
	docker run -d -i -t -p 8153:8153 gocd-server
	docker run -d -i -t -p 8153:8153 -e AGENT_KEY=your_key_here gocd-server
### Mounting volumes
To mount the necessary volumes use;
	-v `pwd`/gocd-server/volumes/var/lib/go-server:/var/lib/go-server
	-v `pwd`/gocd-server/volumes/var/log/go-server:/var/log/go-server
	-v `pwd`/gocd-server/volumes/etc/go:/etc/go
## Agent
	docker run -ti -e GO_SERVER=your.go.server.ip_or_host gocd-agent
	docker run -ti --link <CONTAINER_NAME>:go-server gocd-agent
	for each in 1 2 3; do docker run -d --link <CONTAINER_NAME>:go-server gocd-agent; done
# Building
## Server
	docker build -t gocd-server -f Dockerfile.gocd-server .
## Agent
	docker build -t gocd-agent -f Dockerfile.gocd-agent .
# Getting into the container
	docker exec -i -t CONTAINER-ID bash
# Additional information
The agent starts using a default auto-registration key of 123456789abcdef. If you need to use a different auto-registration key, all you need to do is to set the AGENT_KEY environment variable. Like this:
	docker run -e AGENT_KEY=your_key_here -d --link ... gocd-agent
Sources of this docker container (the Dockerfile, etc) are here, on GitHub.
