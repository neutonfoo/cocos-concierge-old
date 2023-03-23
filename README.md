# Coco's Concierge

Coco's Concierge contains two microservices, the reverse-proxy and updater. 

This reverse proxy service is used to route all traffic on port 80 to the appropriate microservice. It opens port 80 to the internet and is the only publicly accessible port on the Droplet. The nginx-conf-generator.sh script generates an nginx.conf file based on the projects.json file, and this file is copied into the nginx container.

The updater service is used to manage microservice deployment (with the exception of the reverse-proxy and itself/updater). 

## projects.json

There are two types of microservices that can be listed in the projects.json directory: services and daemons.

Allow for direct incoming traffic on port 80 (has to be port 80). Whereas daemons do not allow for incoming traffic and will not be included in the nginx.conf routing.

## updater

The updater microservice is a Flask application that manages the deployment of microservices within the Droplet (wth the exception of reverse-proxy and itself).
> The deployment of reverse-proxy and updater are managed entirely through GitHub Actions in this repository.

## Deploying to Coco's House

1. All services share a bridge network `cocos-network`. This allows the reverse proxy to route the connection to the correct microservice.