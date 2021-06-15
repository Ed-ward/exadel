## Task 3: Docker


### Docs:
Read documentation about docker (https://docs.docker.com/)


### Tasks:
> 1. Install docker. (Hint: please use VMs or Clouds  for this.) [X] </br> 
> * EXTRA 1.1. Write bash script for installing Docker. [X] </br>


> 2. Find, download and run any docker container "hello world". (Learn commands and parameters to create/run docker containers. [X]</br>
> * EXTRA 2.1 Use image with html page, edit html page and paste text: <Username> Sandbox 2021 [X]


> 3.1 Create your Dockerfile for building a docker image. Your docker image should run any web application (nginx, apache, httpd). Web application should be located inside the docker image.  [X] </br>
> * EXTRA 3.1.1. For creating docker image use clear basic images (ubuntu, centos, alpine, etc.)  [X] </br>


> 3.2. Add an environment variable "DEVOPS"=<username> to your docker image.  [X] </br>
> * EXTRA 3.2.1. Print environment variable with the value on a web page (if environment variable changed after container restart - the web page must be updated with a new value)  [X] </br>

 
> 4. Push your docker image to docker hub (https://hub.docker.com/). Create any description for your Docker image.  [X] </br>
> * EXTRA 4.1. Integrate your docker image and your github repository. Create an automatic deployment for each push. (The Deployment can be in the “Pending” status for 10-20 minutes. This is normal). [X] </br>

 
> 5. Create docker-compose file. Deploy a few docker containers via one docker-compose file.  [X] </br>
first image - your docker image from the previous step. 5 nodes of the first image should be run;
second image - any java application;
last image - any database image (mysql, postgresql, mongo or etc.).
Second container should be run right after a successful run of a database container.</br>
> * EXTRA 5.1. Use env files to configure each service. [X]

 
The task results is the docker/docker-compose files in your GitHub repository [X]
