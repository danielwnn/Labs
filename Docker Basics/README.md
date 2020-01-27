## Lab Challenge

Docker Fundamentals:

* Create a Dockerfile and build a Docker image using the Dockerfile
* Run a container using the built image with following conditions
  * Use a user-defined bridge network - "my-net"
  * Create a volume - "logdata", which is mounted at /logdata inside the container 
  * The website can be browsed through port 8080 on localhost
* Tag the image correctly and push it to an Azure Container Registry

Useful References:

* [Net Core Sample Project](https://github.com/MicrosoftDocs/mslearn-tailspin-spacegame-web)
* [Build Dotnet Docker Image](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-3.1)
* [Dockerfile Reference](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/organization-management?view=azure-devops)
* [Docker Run Reference](https://docs.docker.com/engine/reference/run/)
* [Docker Build Reference](https://docs.docker.com/engine/reference/commandline/build/)
* [Docker Bridge Network](https://docs.docker.com/network/bridge/)

