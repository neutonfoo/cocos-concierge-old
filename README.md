# Coco's Concierge

Coco's Concierge contains two microservices, the reverse-proxy and updater. 

This reverse proxy service is used to route all traffic on port 80 to the appropriate microservice. It opens port 80 to the internet and is the only publicly accessible port on the Droplet. The nginx-conf-generator.sh script generates an nginx.conf file based on the projects.json file.

The updater service is used to manage microservice deployment (with the exception of the reverse-proxy and itself/updater). 

## Deploying to Coco's House

1. All services share a bridge network `cocos-network`. This allows the reverse proxy to route the connect to the correct microservice.
2. Therefore, all docker-compose.yml files need to be included in the network. Microservices share another isolated network within their repository.