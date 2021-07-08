# Task 7: Logging&Monitoring. Big Brother.
Мониторинг: Город засыпает просыпается ....
## Tasks:
### 1. Zabbix:
Тут нормально описано https://losst.ru/ustanovka-zabbix-na-ubuntu

--------

#### 1.1 Установить на сервер - сконфигурировать веб и базу
Для установки с нуля потребуется предварительная установка Apache, PHP, MySQL:
```
sudo apt update
sudo apt install apache2
sudo apt install mysql-server
sudo apt install php php-cli php-common php-mysql
```

После чего необходимо указать часовой пояс в php.ini. (секция Data и строка timezone)
```
sudo nano /etc/php/apache2/php.ini
```
```
[Date]
date.timezone = 'Europe/Minsk'
```
Выполнить добавление репозитория (немного странный способ)
```
wget http://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_5.2-1+ubuntu20.04_all.deb
sudo apt update
```
Сама установка Zabbix:
```
sudo apt install zabbix-server-mysql zabbix-frontend-php
```
Создать БД и выдать все привилегии пользователю:
```
mysql -u root -p
mysql> CREATE DATABASE zabbixdb CHARACTER SET utf8 COLLATE utf8_bin;;
mysql> GRANT ALL on zabbixdb.* to zabbix@localhost IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
```

Загрузить таблицы в базу данных из /usr/share/doc/zabbix-server-mysql/ или /usr/share/zabbix-server-mysql/. :
```
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbixdb
```
(тут указать своего пользователя и имя базы данных
 

Чтобы Zabbix смог подключиться к базе данных нужно отредактировать конфигурационный файл и указать там данные аутентификации:
```
sudo nano /etc/zabbix/zabbix_server.conf
```
```
DBHost=localhost
DBName=zabbixdb
DBUser=zabbix
DBPassword=password
```

Включить конфигурационный файл zabbix для apache2:
```
sudo a2enconf zabbix-frontend-php
```
Перезапустить Zabbix и Apache, чтобы применить изменения:
```
sudo systemctl restart apache2
sudo systemctl restart zabbix-server
```

Настройка веб-интерфейса zabbix

* открыть http://адрес/zabbix/ 
* в мастере настройки указать параметры доступа к базе данных
* изменить ip и порт, на котором будет слушать Zabbix (опционально)
* выбрать тему оформления (опционально)
* проверить корректность настроек и применить
* Залогиниться в Заббикс (дефолтно: логин Admin и пароль zabbix.)

-------------

#### 1.2 Поставить на подготовленные ранее сервера или виртуалки заббикс агенты 

Zabbix Agent собирает данные о нагрузке на систему, использовании ресурсов и передает на сервер Zabbix. 

Можно настроить: 
* активную проверку (агент будет отправлять все данные на сервер периодически)
* пассивную (данные будут отправляться по запросу).

Для установки используется тот же репозиторий, что и для сервера. 
```
wget http://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_5.2-1+ubuntu20.04_all.deb
sudo apt update
```

Команда для установки агента:
```
sudo apt install zabbix-agent
```
Отредактировать конфигурационный файл (указать IP адрес сервера и имя хоста):
```
sudo nano /etc/zabbix/zabbix_agentd.conf
```
```
Server=192.168.0.100
Hostname=ZabbixServer
```
(это вариант passive check)
После изменения конфигурации перезапустить сервис zabbix-agent:
```
sudo systemctl restart zabbix-agent
```

<details><summary> Дело было так: </summary>
<pre>
user@user-VirtualBox1:~$ sudo apt install zabbix-agent
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages were automatically installed and are no longer required:
  libfprint-2-tod1 libllvm10
Use 'sudo apt autoremove' to remove them.
The following NEW packages will be installed:
  zabbix-agent
0 upgraded, 1 newly installed, 0 to remove and 10 not upgraded.
Need to get 204 kB of archives.
After this operation, 816 kB of additional disk space will be used.
Get:1 http://repo.zabbix.com/zabbix/5.2/ubuntu focal/main amd64 zabbix-agent amd64 1:5.2.7-1+ubuntu20.04 [204 kB]
Fetched 204 kB in 1s (218 kB/s)        
Selecting previously unselected package zabbix-agent.
(Reading database ... 185234 files and directories currently installed.)
Preparing to unpack .../zabbix-agent_1%3a5.2.7-1+ubuntu20.04_amd64.deb ...
Unpacking zabbix-agent (1:5.2.7-1+ubuntu20.04) ...
Setting up zabbix-agent (1:5.2.7-1+ubuntu20.04) ...
Created symlink /etc/systemd/system/multi-user.target.wants/zabbix-agent.service
 → /lib/systemd/system/zabbix-agent.service.
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.7) ...
user@user-VirtualBox1:~$ sudo nano /etc/zabbix/zabbix_agentd.conf
user@user-VirtualBox1:~$ sudo systemctl restart zabbix-agent
user@user-VirtualBox1:~$ sudo systemctl status zabbix-agent
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor >
     Active: active (running) since Wed 2021-07-07 19:20:32 +03; 27s ago
    Process: 11813 ExecStart=/usr/sbin/zabbix_agentd -c $CONFFILE (code=exited,>
   Main PID: 11815 (zabbix_agentd)
      Tasks: 6 (limit: 4652)
     Memory: 4.4M
     CGroup: /system.slice/zabbix-agent.service
             ├─11815 /usr/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf
             ├─11816 /usr/sbin/zabbix_agentd: collector [idle 1 sec]
             ├─11817 /usr/sbin/zabbix_agentd: listener #1 [waiting for connecti>
             ├─11818 /usr/sbin/zabbix_agentd: listener #2 [waiting for connecti>
             ├─11819 /usr/sbin/zabbix_agentd: listener #3 [waiting for connecti>
             └─11820 /usr/sbin/zabbix_agentd: active checks #1 [idle 1 sec]

ліп 07 19:20:32 user-VirtualBox1 systemd[1]: Starting Zabbix Agent...
ліп 07 19:20:32 user-VirtualBox1 systemd[1]: Started Zabbix Agent.
user@user-VirtualBox1:~$ 
</pre>
</details>


Теперь можно добавить новый хост в Zabbix на вкладке Hosts и наблюдать за его состоянием.

------------------
#### Быстрее и удобнее можно установить Заббикс в контейнере 
Подробная информация есть тут https://www.zabbix.com/documentation/4.0/ru/manual/installation/containers

Готовое решение Zabbix со встроенными MySQL базой данных, Zabbix сервером, Zabbix веб-интерфейсом выглядит так:
```
docker run --name zabbix-appliance -t \
      -p 10051:10051 \
      -p 80:80 \
      --restart unless-stopped \
      -d zabbix/zabbix-appliance:latest
```
Можно использовать отдельные контейнеры для БД, сервера Заббикс и Вебинтерфейса. 

В такой случае более удобен Docker Compose.

Ямлы смотреть тут: https://github.com/zabbix/zabbix-docker

Запускать так: ``` docker-compose -f ./docker-compose_v3_ubuntu_mysql_local.yaml up -d ```

---------------------
#### EXTRA 1.2.1: сделать это ансиблом

Ох уж этот ансибл))

-----------------
#### 1.3 Сделать несколько своих дашбородов, куда вывести данные со своих триггеров (например мониторить размер базы данных из предыдущего задания и включать алерт при любом изменении ее размера - можно спровоцировать вручную)

См. скрины.
Мониторил загрузку процессора. Алерты при загрузке >90%

----------------
#### 1.4 Active check vs passive check - применить у себя оба вида - продемонстрировать.

читал это https://blog.zabbix.com/zabbix-agent-active-vs-passive/9207/

* Passive check делал так:
Отредактировать конфигурационный файл (указать IP адрес сервера и имя хоста):
```
sudo nano /etc/zabbix/zabbix_agentd.conf
```
```
Server=192.168.0.100
Hostname=ZabbixServer
```

После изменения конфигурации перезапустить сервис zabbix-agent:
```
sudo systemctl restart zabbix-agent
```


* Active check - вот так:
Отредактировать конфигурационный файл (указать IP адрес сервера и имя хоста):
```
sudo nano /etc/zabbix/zabbix_agentd.conf
```
```
ServerActive=192.168.0.135
Hostname=ZabbixServer
```

После изменения конфигурации перезапустить сервис zabbix-agent:
```
sudo systemctl restart zabbix-agent
```

-------------
#### 1.5 Сделать безагентный чек любого ресурса (ICMP ping)

ICMP из коробки Заббикс не умеет, но это легко исправляется.
По видеокурсу OTUS сделан шаблон для ICMP (скрин).

Мониторится три узла: локальный хост без агента, днс гугла 8.8.8.8 и неправильный днс гугла 8.8.8.5 =)
Еще по SNMP мониторится сетевая железка.
Скрины прилагаются.

UPD: коллеги подсказали, что уже Template Module ICMP Ping есть (потом поищу).

----------------
#### 1.6 Спровоцировать алерт - и создать Maintenance инструкцию 

Create a Maintenance in Zabbix https://www.youtube.com/watch?v=ALw6bMbmfcg

Был алерт на "плохой пинг 8.8.8.5" в режиме обслуживания система игнорит алерты.
Может быть полезно при работах на действующей системе.

скрин

-----------------
#### 1.7 Нарисовать дашборд с ключевыми узлами инфраструктуры и мониторингом как и хостов так и установленного на них софта

Поставил на один узел докер, на другой апач.

В настройках заббикса указал что к узлам надо применить шаблоны для докера и апача. 

На дашборд вывел инфо по ним плюс опрос сетевой железки по СНМП и состояние сервера мониторинга.

скрин или могу расшарить.

-----------
### 2. ELK: 

Никто не забыт и ничто не забыто.


#### 2.1 Установить и настроить ELK 
Читал тут: https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04-ru

Elastic Stack (прежнее название — комплекс ELK) включает четыре основных компонента:

* Elasticsearch: распределенная поисковая система RESTful, которая сохраняет все собранные данные.
* Logstash: элемент обработки данных комплекса Elastic, отправляющий входящие данные в Elasticsearch.
* Kibana: веб-интерфейс для поиска и визуализации журналов.
* Beats: компактные элементы переноса данных одиночного назначения, которые могут отправлять данные с сотен или тысяч компютеров в Logstash или Elasticsearch.

----------

Шаг 1 — Установка и настройка Elasticsearch

Добавляем ключ:
```
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
```
 

Добавляем список источников Elastic в директорию sources.list.d, где APT будет искать новые источники:
```
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
```
Обновляем списки пакетов, чтобы APT мог прочитать новый источник Elastic:
```
    sudo apt update
```

Устанавливаем Elasticsearch:
```
    sudo apt install elasticsearch
```
 
Система Elasticsearch установлена (и готова к настройке). 

Правим файл конфигурации Elasticsearch, elasticsearch.yml. :
```
    sudo nano /etc/elasticsearch/elasticsearch.yml
```
*помним про отступы*

В файле *elasticsearch.yml* можно настроить варианты конфигурации для кластера, узла, пути, памяти, сети, обнаружения и шлюза.
Для демонстрации односерверной конфигурации надо регулировать настройки только для хоста сети.

Elasticsearch прослушивает весь трафик порта 9200.
Для ограничения доступа и повышения безопасности можно найти в /etc/elasticsearch/elasticsearch.yml строку с указанием network.host, раскомментировать и заменить значение на localhost:

```
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: localhost
```

Это минимальные настройки, с которыми можно начинать использовать Elasticsearch. 
Запускаем службу Elasticsearch (запуск может занять некоторое время). 
```
    sudo systemctl start elasticsearch
```
 
Затем можно активировать автозагрузку Elasticsearch при каждом запуске сервера:
```
    sudo systemctl enable elasticsearch
```
 
Протестировать работу службы Elasticsearch, отправив запрос HTTP:
```
    curl -X GET "localhost:9200"
```
Получим ответ, содержащий базовую информацию о локальном узле:
```
user@user-VirtualBox1:~$ curl -X GET "localhost:9200"
{
  "name" : "user-VirtualBox1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "COmhRmEwR8ey1CtcFjWIbw",
  "version" : {
    "number" : "7.13.3",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "5d21bea28db1e89ecc1f66311ebdec9dc3aa7d64",
    "build_date" : "2021-07-02T12:06:10.804015202Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
user@user-VirtualBox1:~$ 
```
Установка и настройка Elasticsearch завершена

-----------




#### 2.2 Организовать сбор логов из докера в ELK и получать данные от запущенных контейнеров


#### 2.3 Настроить свои дашборды в ELK


#### EXTRA 2.4: Настроить фильтры на стороне Logstash (из поля message получить отдельные поля docker_container и docker_image)


#### 2.5 Настроить мониторинг в ELK - получать метрики от ваших запущенных контейнеров


#### 2.6 Посмотреть возможности и настройки




### 3. Grafana:


#### 3.1 Установить Grafana интегрировать с установленным ELK


#### 3.2 Настроить Дашборды



