


Push your docker image to docker hub (https://hub.docker.com/). 
Create any description for your Docker image. 



EXTRA: Integrate your docker image and your github repository. 
Create an automatic deployment for each push. 
(The Deployment can be in the “Pending” status for 10-20 minutes. This is normal).




Приложение на Golang и юзает jin. 
Является мини-сервером, который показывает хтмл из директориии www. 
Да, так быстрее и удобнее.



Теперь создадим наш первый action, который будет запускать тесты. Согласно документации все действия должны хранится в специальной директории:

$ mkdir -p .github/workflows