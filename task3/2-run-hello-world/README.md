Простейший "hello world" в Docker делается примерно так: </br>
```docker run hello-world``` </br>
Вывод будет такой или похожий: </br>

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete
Digest: sha256:9f6ad537c5132bcce57f7a0a20e317228d382c3cd61edae14650eec68b2b345c
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
 ```
 
Тут нам Docker сообщает что не нашел локального образа, затем он скачал его, запустил и далее идет сообщение из самого образа hello-world.


## Основные Docker команды 
https://hub.docker.com

1. docker ps — смотрим список запущенных контейнеров
2. docker pull — загрузка образа
3. docker build — собирает образ
4. docker logs — смотрим логи
5. docker run — запускаем контейнер
6. docker stop — останавливает контейнер
7. docker kill — «убивает» контейнер
8. docker rm — удаляет контейнер

Примеры:

Эта команда выводит список всех контейнеров Docker, запущенных ранее. </br>
```sudo docker ps -a -s```

А эта выводит список всех образов Docker </br>
```sudo docker images```

Docker inspect отображает низкоуровневую информацию о конкретном объекте Docker. <IMAGE|CONTAINER ID> </br>
```sudo docker inspect d065729c7070 ```

Выполнение команды оболочки внутри конкретного контейнера. </br>
```sudo docker exec -ti <CONTAINER> bash```

Остановить конкретный контейнер </br>
```sudo docker stop 5563a18d90ff``` 

Очистка от неиспользуемых объектов </br>
```sudo docker system prune```

Убить выполняющийся контейнер </br>
```sudo docker kill <CONTAINER>```         

Убить все выполняющиеся контейнеры </br>
```sudo docker kill $(docker ps -q)```        

Удаление образов, контейнеров и томов Docker подробнее: </br>
https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes-ru


Вообще, команд намного больше, но этого для старта хватает. :-)

Экстра лежит в соседнем файле в этой же директории.