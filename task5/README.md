##  Task 5: Jenkins. Автоматизируй, Управляй и Контролируй
 
Важные моменты:
Почитать про Jenkins. Что это такое и для чего он нужен? Способы применения. Что такое императивный и декларативный подход. 
 
### Tasks: 
### 1. Установить Jenkins (Jenkins должен быть установлен в Docker контейнере). </br>

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
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### А. Ручная установка (Долгий путь.)
Берем любой образ чистой ОС (ubuntu)
```
docker pull ubuntu:21.10
```
Запускаем и подключаемся внутрь контейнера:
```docker run -it  ubuntu:21.10 bash```

Теперь ручная установка в контейнере (состоит из двух этапов): </br>
Installation of Java

```
apt update
apt search openjdk
apt install openjdk-8-jre -y
java -version
```
Installation Jenkins Long Term Support release </br>
(maybe usefull ```apt-get update && apt-get install -y gnupg2``` )


```
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y
sudo service jenkins status
```
После этого можно выйти из контейнера и сохранить изменения в новый образ:
```
sudo docker commit -m "Add Java and Jenkins" -a "Ed_Elensky" b2697aac0fbd ubuntu:my
```


### Б. Чтобы получить Jenkins в docker достаточно использовать официальный образ.
https://hub.docker.com/r/jenkins/jenkins/ </br>
https://www.jenkins.io/doc/book/installing/docker/

Использовать буду образ jenkins:2.289.1-lts на своих виртуальных машинах (т.к. free tier от AWS кончается).
Для этого написан .yml файл</br>
```
version: '3'
services:
 myjenkins:
  image: "jenkins/jenkins:2.289.1-lts"
  container_name: "jenkins"
  ports:
  - 8080:8080
  volumes:
  - ./jenkins/:/var/jenkins
```

После запуска контейнера уже знакомой командой ```sudo docker-compose up``` 
остается зайти на 127.0.0.1:8080 и прочитав unlock-пароль разблокировать jenkins.
>$ cat /var/jenkins_home/secrets/initialAdminPassword </br>
71b44339016d45afa493768d3efa604c

### 2. Установить необходимые плагины (если потребуются на ваше усмотрение).
Плагины устанавливаются либо сразу после разблокировки (defaulе набор или custom), 
а также, при необходимости, через Dashboard (manage jenkins ---> manage plugin) </br>
Добавил плагины для докера (ssh-agent и ssh-slave).

### 3. Настроить несколько билд агентов.
Делал в aws по этому мануалу (получилось) - https://www.jenkins.io/doc/book/using/using-agents/#ji-toolbar
Эксперименты с докером заняли много времени, которое можно было уделить Дженкинсу. 

Но на локальных виртуальных машинах строго по заданию не получается. 
Если контейнеры на одном хосте - то всё ок.
Если мастер в контейнере, а ноды нет - тоже ок.
Но если на разных, то мастер Дженкинса из своего контейнера пытается подключиться к ноде
в другом контейнере на другом хосте, и вместо этого происходят попытки подключения к хостам,
а не к контейнерам. 

Решение нашел вот такое: https://www.netangels.pro/article/ssh-to-docker/
Не уверен, что оптимальное.

UPD: Все решилось использованием актуальных докер-образов дженкинса вместо самостоятельных сборок.
Как оказалось, проблема была не в самом подключении по SSH (хотя ошибка говорила об этом), а в запуске ява-аплета на ноде.
Дальше не копал, но потом посмотрю внимательнее.

### 4. Создать Freestyle project. Который будет в результате выполнения на экран выводить текущее время.
Тут всё просто. (но непонятно. Что значит на экран? в консоли? в браузере? в BIOS?)

Если речь о браузере:

В разделе Build нашего проекта в первый execute shell добавил сам код страницы 
```
echo '------------------build start--------------------'
cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html;charset=UTF-8">
<title>Hello everyone!</title>
<meta name="description" content="More HelloWorld for God of HelloWorld! XD">
<script type="text/javascript">
function startTime()
{
var tm=new Date();
var h=tm.getHours();
var m=tm.getMinutes();
var s=tm.getSeconds();
m=checkTime(m);
s=checkTime(s);
document.getElementById('timer').innerHTML=h+":"+m+":"+s;
t=setTimeout('startTime()',500);
}
function checkTime(i)
{
if (i < 10)
{
i="0" + i;
}
return i;
}
</script>
</head>

<body onload="startTime()">
  <div><b>Hello Everyone :-)</b></div>
  <div id="timer"></div>
</body>

</html>
EOF
echo '------------------build finish--------------------' 

```
Во втором execute shell будет тест (просто считает количество Hello. Если их хватает - всё ок.)
```
echo '------------------test start--------------------'

result=`grep "Hello" index.html | wc -l`
echo $result

if [ "$result" = "3"]
then
    echo "Test Passed"
    exit 0
else
    echo "Test Failed"
    exit 1
fi
echo '------------------test finish--------------------'

```
Деплоим это с помощью плагина Publish Over SSH 
перемещаем index.html в предварительно запущенный где-нибудь apache2 в /var/www/html/ и смотрим браузер.
(были танцы с ключами).


Если всё делать упрощенно:
В разделе Build в execute shell добавим команду 
sh -c date
запустим джобу и посмотрим лог.

Там будет что-то похожее:

```
Started by user Ed_Elensky
Running as SYSTEM
Building on master in workspace /var/jenkins_home/workspace/time2
[time2] $ /bin/sh -xe /tmp/jenkins4604948750337872272.sh
+ sh -c date
Tue 29 Jun 2021 12:09:06 PM UTC
Finished: SUCCESS
```
Сложностей не возникло.


### 5. Создать Pipeline который будет на хосте выполнять команду docker ps -a.
С виду всё просто, но есть подводные камни. 
Если Дженкинс или ноды на которых выполняется джоба не в контейнере то всё очень просто (выполняем docker ps -a и смотрим лог)
Несмотря на то, что из контейнера я могу подключиться к хосту по ssh, такие финты в pipeline не проходят :)))
```
pipeline {
    agent any
    stages {
        stage('ask') {
            steps {
                sh '''
                  ssh user@192.168.0.205
                  docker ps -a
                '''  
            }
        }
    }
}
```
вот пример log если выполнять в pipe ssh login@adress 
```
Started by user Ed_Elensky
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/ask-docker-in-host
[Pipeline] {
[Pipeline] stage
[Pipeline] { (ask)
[Pipeline] sh
+ ssh user@192.168.0.205
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.8.0-59-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 updates can be applied immediately.

Your Hardware Enablement Stack (HWE) is supported until April 2025.
+ docker ps -a
/var/jenkins_home/workspace/ask-docker-in-host@tmp/durable-6908c9b7/script.sh: 3: /var/jenkins_home/workspace/ask-docker-in-host@tmp/durable-6908c9b7/script.sh: docker: not found
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
ERROR: script returned exit code 127
Finished: FAILURE
```
В общем, так делать не надо, но это поучительно.

А вот так уже лучше:
```
pipeline {
    agent any
    stages {
        stage('ask') {
            agent {
                label 'user-VirtualBox1'
            }
            steps {
                sh("docker ps -a")
            }
        }
    }
}
```
Для этого хост был подключен к дженкинсу как нода. 
Не совсем то, что я хотел изначально. 
(Думал, что реально любую систему из дженкинса получится опросить, а тут их очень плотно подружить пришлось.)

Вывод такой:
```
Started by user Ed_Elensky
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/ask-docker-in-host
[Pipeline] {
[Pipeline] stage
[Pipeline] { (ask)
[Pipeline] sh
+ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED        STATUS        PORTS                                                                                                                                            NAMES 
49225d3ab621   jenkins/jenkins:2.289.1-lts   "/sbin/tini -- /usr/…"   12 hours ago   Up 12 hours   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 50000/tcp, 0.0.0.0:49155->1342/tcp, :::49155->1342/tcp, 0.0.0.0:49154->2222/tcp, :::49154->2222/tcp   jenkins 
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

До сих пор не понимаю, почему ноды локальных виртуалках попили крови. На aws такого не было, зато с ресурсами беда. )))

### 6. Создать Pipeline который будет выкачивать из вашего репозитория код и будет собирать докер образ из вашего Dockerfile (который вы писали во время знакомства с докером).
В процессе поиска решения вот это понравилось =) : https://habr.com/ru/post/477464/

И вот это (особенно, комментарии): https://habr.com/ru/company/ua-hosting/blog/488536/

Если по делу, то я использовал такое решение:

```
pipeline {
    agent { label 'node3'}   
    stages {
        stage('download-from-git') {
            steps {
             git branch: 'master', url: "https://github.com/Ed-ward/exadel.git"
            }    
        }        
        stage('create-my-image') {
            steps {
            sh '''cd task3/3-create-dockefile/
            docker image build -t task3:pipeline -f task3inpipejenkins .
            '''
            }    
        }
        stage('view-my-images') {
            steps {
               sh("docker images")
            }
        }

    }
}
```
Что тут происходит: всё по мануалу, только добавил разбивку на 3 этапа
* из ветки мастер моего репо получаем файлы
* заходим в папку с заданием по докеру и билдим образ
* смотрим, что получилось

*/не забыть сделать скрин/*

### 7. Передать переменную PASSWORD=QWERTY! В зашифрованном виде в докер контейнер.

Задача состоит из двух действий: 
1) научиться передавать переменные окружения из Jenkins в контейнер Docker. 
2) научиться скрывать/шифровать передаваемые данные.

Про способы передачи переменных среды нагуглил и почитал тут (основные решения - встроенный функционал или плагины): https://codengineering.ru/q/how-to-set-environment-variables-in-jenkins-21926
Решил не усложнять и использовать установку переменной окружения через "управление Дженкинс - настройка системы - глобальные свойства - чекбокс переменные окружения - добавить переменные окружения". Это самый простой и наименее навязчивый способ сделать это.

Далее я нашел информацию о создании и использовании secret в качестве переменной: https://blog.mailon.com.ua/jenkins-%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-secret-%D0%B2-%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2/

Этот способ основан на создании креда «Credentials» -> «Add credentials» и последующем указании «Use secret text(s) or file(s)» в job’е в разделе «Build Environment» и не требует применения плагинов.

Вызываемая далее переменная PASSWORD будет иметь шифрованное значение, и при необходимости ее можно вызывать как саму по себе, так и подставлять в команду запуска контейнера
```
docker  run -d -e PASSWORD=$PASSWORD tomcat
```
(Это работает во Freestyle project, как реализовать в pipe я пока не решил.)


В случае использования плагина "Mask passwords" можно передавать зашифрованные переменные как в Freestyle project так и в Pipeline:





### EXTRA: 
1. Написать pipeline который будет на дополнительной виртуальной машине запускать докер контейнер из вашего докерфайла.
2. Написать ансибл скрипт который будет разворачивать дженкинс.
3. Развернуть локальный docker registry загрузить в него докер образ, выгрузить докер образ из docker registry и запустить контейнер на окружении (с использованием Jenkinsfile)
4. Настроить двухстороннюю интеграцию между Jenkins и вашим Git репозиторием. Jenkins проект будет запускаться автоматически при наличии изменений в вашем репозитории а также в Git будет виден статус последней сборки из дженкинса (успешно/неуспешно/в процессе).
