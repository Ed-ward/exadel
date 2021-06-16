#### Самое сложное в этом задании было найти чей-то образ именно со статическим html сайтом внутри. XD
#### Потратив несколько часов было принято решение взять обычный официальный апач и за две минуты поставить точку в этом задании.

0. Тут лежит официальный образ Apache </br>
https://hub.docker.com/_/httpd?tab=description&page=1&ordering=last_updated

1. Забираем его себе командой  </br>
```docker pull httpd```

2. Запускаем (пока без докерфайла) командой </br>
```docker run -dit --name my-apache-app -p 8080:80 -v "$PWD":/usr/local/apache2/htdocs/ httpd:2.4```
(предварительно разрешить порт 8080 для входящих TCP)

3. Убедимся что контейнер запущен: </br>
```docker ps -a -s```
Ответ будет примерно такой: </br>
```
CONTAINER ID   IMAGE       COMMAND              CREATED             STATUS             PORTS                                   NAMES           SIZE
d8776fc76e06   httpd:2.4   "httpd-foreground"   About an hour ago   Up About an hour   0.0.0.0:8080->80/tcp, :::8080->80/tcp   my-apache-app   203B (virtual 138MB)
```


4. После чего заходим в запущенный контейнер: </br>
```sudo docker exec -ti d8776fc76e06 bash```

5. Осматриваемся ```ls``` и заходим в "директорию сайта" :-))) (в нашем случае это папка htdocs) ```cd httpdocs```

6. Заменяем содержимое в файле оглавления на своё: </br>
```echo '<html> <head> <title>TASK-2Ex</title> </head> <body> <p><b>Ed_Elensky</b></p> </br> <p><b>Sandbox 2021</b></p> </body> </html>' > index.html```

7. Смотрим результат в браузере по адресу инстанса/виртуальной машины или из терминала командой curl.

Всё.