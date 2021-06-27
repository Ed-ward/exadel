##  Task 5: Jenkins. Автоматизируй, Управляй и Контролируй
 
Важные моменты:
Почитать про Jenkins. Что это такое и для чего он нужен? Способы применения. Что такое императивный и декларативный подход. 
 
### Tasks: (done)
1. Установить Jenkins (Jenkins должен быть установлен в Docker контейнере). </br>

   Скрипт установки docker в AWS (in user data):
```   
#!/usr/bin/env bash
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt -y install docker-ce
usermod -aG docker ubuntu
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### А. Ручная установка (Долгий путь, сделано только, чтобы попробовать.)
Берем любой образ чистой ОС (ubuntu)
docker pull ubuntu:xenial-20210611
docker run  ubuntu:xenial-20210611

Подключаемся внутрь контейнера:
```sudo docker exec -ti <CONTAINER> bash```

Теперь ручная установка в контейнере (состоит из двух этапов): </br>
Installation of Java

```sudo apt update
sudo apt search openjdk
sudo apt install openjdk-11-jdk
java -version
```
Installation Jenkins Long Term Support release
```
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```
### Б. Чтобы получить Jenkins в docker достаточно использовать официальный образ.
https://hub.docker.com/r/jenkins/jenkins/ </br>
https://www.jenkins.io/doc/book/installing/docker/




2. Установить необходимые плагины (если потребуются на ваше усмотрение).
3. Настроить несколько билд агентов.
4. Создать Freestyle project. Который будет в результате выполнения на экран выводить текущее время.
5. Создать Pipeline который будет на хосте выполнять команду docker ps -a.
6. Создать Pipeline который будет выкачивать из вашего репозитория код и будет собирать докер образ из вашего Dockerfile (который вы писали во время знакомства с докером).
7. Передать переменную PASSWORD=QWERTY! В зашифрованном виде в докер контейнер.
 
### EXTRA: (not completed)
1. Написать pipeline который будет на дополнительной виртуальной машине запускать докер контейнер из вашего докерфайла.
2. Написать ансибл скрипт который будет разворачивать дженкинс.
3. Развернуть локальный docker registry загрузить в него докер образ, выгрузить докер образ из docker registry и запустить контейнер на окружении (с использованием Jenkinsfile)
4. Настроить двухстороннюю интеграцию между Jenkins и вашим Git репозиторием. Jenkins проект будет запускаться автоматически при наличии изменений в вашем репозитории а также в Git будет виден статус последней сборки из дженкинса (успешно/неуспешно/в процессе).
