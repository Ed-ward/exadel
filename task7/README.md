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

#### Шаг 1 — Установка и настройка Elasticsearch

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

#### Шаг 2 — Установка и настройка информационной панели Kibana

!!! Согласно официальной документации, Kibana следует устанавливать только после установки Elasticsearch. 


Поскольку источник пакетов Elastic уже добавили надо просто установить с помощью apt:
```
    sudo apt install kibana
```
 
Активировать и запустить службу Kibana:
```
    sudo systemctl enable kibana
    sudo systemctl start kibana
```
 
Поскольку согласно настройкам Kibana прослушивает только localhost, 
мы должны задать обратный прокси, чтобы разрешить внешний доступ (используем Nginx)
```
    sudo apt install
```

Используем команду openssl для создания административного пользователя Kibana.

Эта команда создаст административного пользователя Kibana и пароль и сохранит их в файле htpasswd.users. 
```
    echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users
```
Придумываем и вводим пароль для доступа к веб-интерфейсу Kibana.



Теперь создадим файл серверного блока Nginx. 
(В качестве примера имя localhost, но это имя FQDN или IP-адрес сервера) 

Создаем файл серверного блока Nginx, используя nano:
```
    sudo nano /etc/nginx/sites-available/localhost
```
 
Добавим в файл блок кода и обязательно замените your_domain на FQDN или публичный IP-адрес сервера. 
Этот код настраивает Nginx для перенаправления трафика HTTP сервера в приложение Kibana, 
которое прослушивает порт localhost:5601. 
Также он настраивает Nginx для чтения файла htpasswd.users и требует использования базовой аутентификации.
```
server {
    listen 80;

    server_name localhost;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
 
Сохраняем, закрываем файл.

Активируем новую конфигурацию, создав символическую ссылку на каталог sites-enabled:
```
    sudo ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
```
 
Проверить конфигурацию на синтаксические ошибки:
```
    sudo nginx -t
```
 
Если на экране результатов сообщение syntax is ok, перезапустить службу Nginx:
```
    sudo systemctl reload nginx
```

Чтобы разрешить соединения с Nginx можем изменить правила:
```
    sudo ufw allow 'Nginx Full'
```
 
Удалить (если надо) ранее созданное правило:
```
    sudo ufw delete allow 'Nginx HTTP'
```
 

Теперь приложение Kibana доступно через FQDN или публичный IP-адрес вашего сервера комплекса Elastic. 
Вы можете посмотреть страницу состояния сервера Kibana, открыв следующий адрес и введя свои учетные данные в диалоге:

http://localhost/status

-------
#### Шаг 3 — Установка и настройка Logstash

Хотя Beats может отправлять данные напрямую в базу данных Elasticsearch, 
рекомендуется использовать для обработки данных Logstash. 
Это даст гибкую возможность собирать данные из разных источников, 
преобразовывать их в общий формат и экспортировать в другую базу данных.

Установить Logstash с помощью следующей команды:
```
    sudo apt install logstash
```

После установки Logstash перейти к настройке. 
Файлы конфигурации Logstash находятся в каталоге /etc/logstash/conf.d. 
Дополнительную информацию о синтаксисе конфигурации можно найти в справочнике по конфигурации, 
предоставляемом Elastic. 
Logstash - "конвейер", принимающий данные на одном конце, обрабатывающий и отправляющий их в пункт назначения 
(в нашем случае пунктом назначения является Elasticsearch). 
Конвейер Logstash имеет два обязательных элемента, input и output, 
а также необязательный элемент filter. Плагины ввода потребляют данные источника, 
плагины фильтра обрабатывают данные, а плагины вывода записывают данные в пункт назначения.

Конвейер Logstash

Создать файл конфигурации с именем 02-beats-input.conf, где настроим ввод данных Filebeat:
```
    sudo nano /etc/logstash/conf.d/02-beats-input.conf
```
 Конфигурация ввода. (В ней задается ввод beats, который прослушивает порт TCP 5044.)
```
input { beats { port => 5044 }}
```
 Сохраняем, закрываем файл.

Создать файл конфигурации с именем 30-elasticsearch-output.conf:
```
    sudo nano /etc/logstash/conf.d/30-elasticsearch-output.conf
```

Вставить следующую конфигурацию вывода. 
(Этот вывод настраивает Logstash для хранения данных Beats в Elasticsearch, 
запущенном на порту localhost:9200, в индексе с названием используемого компонента Beat. 
В этом обучающем модуле используется компонент Beat под названием Filebeat:
```
output { if[@metadata][pipeline] { elasticsearch { hosts => ["localhost:9200"]
manage_template => false index =>
"%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}" pipeline =>
"%{[@metadata][pipeline]}" } } else { elasticsearch { hosts =>
["localhost:9200"] manage_template => false index =>
"%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}" } } }
```

 Сохраняем, закрываем файл.

Тест конфигурации Logstash с помощью  команды:
```
    sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
```

Если ошибок синтаксиса не будет, в выводе появится сообщение ```Config Validation Result: OK. Exiting Logstash``` через несколько секунд после запуска. 
Если нет этого сообщения, проверить ошибки вывода и обновить конфигурацию для их исправления. 
Предупреждения от OpenJDK не должны вызывать проблем, и их можно игнорировать.

```
user@user-VirtualBox1:~$ sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
Using bundled JDK: /usr/share/logstash/jdk
OpenJDK 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.
Sending Logstash logs to /var/log/logstash which is now configured via log4j2.properties
[2021-07-08T17:37:34,084][INFO ][logstash.runner          ] Log4j configuration path used is: /etc/logstash/log4j2.properties
[2021-07-08T17:37:34,092][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.13.3", "jruby.version"=>"jruby 9.2.16.0 (2.5.7) 2021-03-03 f82228dc32 OpenJDK 64-Bit Server VM 11.0.11+9 on 11.0.11+9 +indy +jit [linux-x86_64]"}
[2021-07-08T17:37:34,111][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.queue", :path=>"/var/lib/logstash/queue"}
[2021-07-08T17:37:34,116][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.dead_letter_queue", :path=>"/var/lib/logstash/dead_letter_queue"}
[2021-07-08T17:37:35,070][INFO ][org.reflections.Reflections] Reflections took 30 ms to scan 1 urls, producing 24 keys and 48 values 
Configuration OK
[2021-07-08T17:37:35,848][INFO ][logstash.runner          ] Using config.test_and_exit mode. Config Validation Result: OK. Exiting Logstash
user@user-VirtualBox1:~$ 

```



Если тестирование конфигурации выполнено успешно, запустить и активировать Logstash.
```
    sudo systemctl start logstash
    sudo systemctl enable logstash
```
 
Теперь Logstash работает нормально и полностью настроен, и можно перейти к установке Filebeat.

--------

#### Шаг 4 — Установка и настройка Filebeat

Комплекс Elastic использует несколько компактных элементов транспортировки данных (Beats) 
для сбора данных из различных источников и их транспортировки в Logstash или Elasticsearch. 
Ниже перечислены компоненты Beats, доступные в Elastic:
```
    Filebeat: собирает и отправляет файлы журнала.
    Metricbeat: собирает метрические показатели использования систем и служб.
    Packetbeat: собирает и анализирует данные сети.
    Winlogbeat: собирает данные журналов событий Windows.
    Auditbeat: собирает данные аудита Linux и отслеживает целостность файлов.
    Heartbeat: отслеживает доступность услуг посредством активного зондирования.
```


Установить Filebeat с помощью apt:
```
    sudo apt install filebeat
```
 

Затем настроить Filebeat для подключения к Logstash. 
Изменим образец файла конфигурации, входящий в комплектацию Filebeat:
```
    sudo nano /etc/filebeat/filebeat.yml
```
*использовать точно такое количество пробелов, как в инструкциях*

Filebeat поддерживает разнообразные выводы, но обычно события отправляются только напрямую 
в Elasticsearch или в Logstash для дополнительной обработки. 
Filebeat не потребуется отправлять данные в Elasticsearch напрямую, поэтому отключим этот вывод. 
Для этого мы найдем раздел output.elasticsearch и закомментируем строки /etc/filebeat/filebeat.yml:

```
#output.elasticsearch:
  # Array of hosts to connect to.
  #hosts: ["localhost:9200"]
```


Затем настроим раздел output.logstash. 
Уберем режим комментариев для строк output.logstash: и hosts: ["localhost:5044"], удалив #. 
Так мы настроим Filebeat для подключения к Logstash на сервере комплекса Elastic Stack через порт 5044, 
который мы ранее задали для ввода Logstash:

```
output.logstash:
  # The Logstash hosts
  hosts: ["localhost:5044"]
```
 

 Сохраняем, закрываем файл.

Функции Filebeat можно расширить с помощью модулей Filebeat. 
Например, модуль system, который собирает и проверяет данные журналов, 
созданных службой регистрации систем в распространенных дистрибутивах Linux.

Активируем его:
```
    sudo filebeat modules enable system
```
 
!!! Посмотреть список включенных и отключенных модулей можно с помощью следующей команды:
```
    sudo filebeat modules list
```

Получен  следующий список:
```
user@user-VirtualBox1:~$ sudo filebeat modules list
Enabled:
system

Disabled:
activemq
apache
auditd
aws
awsfargate
azure
barracuda
bluecoat
cef
checkpoint
cisco
coredns
crowdstrike
cyberark
cyberarkpas
cylance
elasticsearch
envoyproxy
f5
fortinet
gcp
google_workspace
googlecloud
gsuite
haproxy
ibmmq
icinga
iis
imperva
infoblox
iptables
juniper
kafka
kibana
logstash
microsoft
misp
mongodb
mssql
mysql
mysqlenterprise
nats
netflow
netscout
nginx
o365
okta
oracle
osquery
panw
pensando
postgresql
proofpoint
rabbitmq
radware
redis
santa
snort
snyk
sonicwall
sophos
squid
suricata
threatintel
tomcat
traefik
zeek
zoom
zscaler
user@user-VirtualBox1:~$ 
```

Filebeat по умолчанию настроен для использования путей по умолчанию для системных журналов 
и журналов авторизации. 
Можно посмотреть параметры модуля в файле конфигурации /etc/filebeat/modules.d/system.yml.

Затем нужно настроить конвейеры обработки Filebeat, 
выполняющие синтаксический анализ данных журнала перед их отправкой через logstash в Elasticsearch. 
Чтобы загрузить конвейер обработки для системного модуля, ввести следующую команду:
```
    sudo filebeat setup --pipelines --modules system
```
 
Затем загрузить в Elasticsearch шаблон индекса. 
Индекс Elasticsearch — это коллекция документов со сходными характеристиками. 
Индексы идентифицируются по имени, которое используется для ссылки на индекс 
при выполнении различных операций внутри него. 
Шаблон индекса применяется автоматически при создании нового индекса.

Использовать следующую команду для загрузки шаблона:
```
    sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'
```
Вывод 
```
Index setup finished.
```

В комплект Filebeat входят образцы информационных панелей Kibana, 
позволяющие визуализировать данные Filebeat в Kibana. 
Прежде чем использовать информационные панели, нужно создать шаблон индекса и загрузить 
информационные панели в Kibana.

При загрузке информационных панелей Filebeat подключается к Elasticsearch для проверки информации о версиях. 
Для загрузки информационных панелей при включенном Logstash необходимо отключить вывод Logstash 
и активировать вывод Elasticsearch:
```
    sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601
```
 

Результат выглядит примерно следующим образом:

```
user@user-VirtualBox1:~$ sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601
Overwriting ILM policy is disabled. Set `setup.ilm.overwrite: true` for enabling.

Index setup finished.
Loading dashboards (Kibana must be running and reachable)
Loaded dashboards
Setting up ML using setup --machine-learning is going to be removed in 8.0.0. Please use the ML app instead.
See more: https://www.elastic.co/guide/en/machine-learning/current/index.html
Loaded machine learning job configurations
Loaded Ingest pipelines
user@user-VirtualBox1:~$ 
```
Теперь можно запустить и активировать Filebeat:
```
    sudo systemctl start filebeat
    sudo systemctl enable filebeat
```
 

Если всё настроено в комплексе Elastic, 
то Filebeat начнет отправлять системный журнал и журналы авторизации в Logstash, 
откуда эти данные будут загружаться в Elasticsearch.

Чтобы подтвердить получение этих данных в Elasticsearch необходимо отправить в индекс Filebeat запрос с помощью следующей команды:
```
    curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'
```
 

Результат выглядит следующим образом:

```
user@user-VirtualBox1:~$ curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'
{
  "took" : 7,
  "timed_out" : false,
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 10000,
      "relation" : "gte"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "tlmjhnoBeg79cGr_SMFT",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3519743
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for 10.0.2.15 on enp0s3.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T06:59:34.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.669589138Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "s1mjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3563664
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for 172.18.0.1 on br-b2f9f1d544d6.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.702950477Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "tFmjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3563778
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for fe80::42:f5ff:fecb:1503 on docker0.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703089036Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "tVmjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3563897
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for 172.17.0.1 on docker0.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703227415Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "tlmjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3564003
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for fe80::3434:fe6f:c79a:12cd on enp0s8.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703367475Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "t1mjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3564123
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for 192.168.0.205 on enp0s8.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703505794Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "t1mjhnoBeg79cGr_SMFT",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3519847
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for ::1 on lo.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T06:59:34.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.669783667Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "uFmjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3564231
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for fe80::f21a:8b5c:20e9:85f1 on enp0s3.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703697413Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "uVmjhnoBeg79cGr_SMKA",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3564351
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Withdrawing address record for 10.0.2.15 on enp0s3.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T07:04:54.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.703840042Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      },
      {
        "_index" : "filebeat-7.13.3-2021.07.08",
        "_type" : "_doc",
        "_id" : "ulmjhnoBeg79cGr_SMFT",
        "_score" : 1.0,
        "_source" : {
          "agent" : {
            "hostname" : "user-VirtualBox1",
            "name" : "user-VirtualBox1",
            "id" : "4462af80-99d6-4bb9-802b-1ebd51339453",
            "type" : "filebeat",
            "ephemeral_id" : "346f2663-0721-4137-9c78-2f350e32e591",
            "version" : "7.13.3"
          },
          "process" : {
            "name" : "avahi-daemon",
            "pid" : 452
          },
          "log" : {
            "file" : {
              "path" : "/var/log/syslog.1"
            },
            "offset" : 3520150
          },
          "fileset" : {
            "name" : "syslog"
          },
          "message" : "Registering new address record for fe80::b8d4:21ff:fe71:99e1 on vethccb3741.*.",
          "tags" : [
            "beats_input_codec_plain_applied"
          ],
          "input" : {
            "type" : "log"
          },
          "@timestamp" : "2021-07-01T06:59:34.000+03:00",
          "system" : {
            "syslog" : { }
          },
          "ecs" : {
            "version" : "1.9.0"
          },
          "related" : {
            "hosts" : [
              "user-VirtualBox1"
            ]
          },
          "service" : {
            "type" : "system"
          },
          "@version" : "1",
          "host" : {
            "hostname" : "user-VirtualBox1",
            "os" : {
              "kernel" : "5.8.0-59-generic",
              "codename" : "focal",
              "name" : "Ubuntu",
              "type" : "linux",
              "family" : "debian",
              "version" : "20.04.2 LTS (Focal Fossa)",
              "platform" : "ubuntu"
            },
            "ip" : [
              "10.0.2.15",
              "fe80::f21a:8b5c:20e9:85f1",
              "192.168.0.205",
              "fe80::3434:fe6f:c79a:12cd",
              "fe80::9eac:af78:a568:9fb0",
              "172.18.0.1",
              "172.17.0.1"
            ],
            "containerized" : false,
            "name" : "user-VirtualBox1",
            "id" : "165cbc1aaef247028518b715156be85e",
            "mac" : [
              "08:00:27:05:08:1a",
              "08:00:27:f9:2f:2b",
              "02:42:32:fd:2b:0c",
              "02:42:fa:51:1e:5b"
            ],
            "architecture" : "x86_64"
          },
          "event" : {
            "ingested" : "2021-07-08T15:01:25.670675612Z",
            "timezone" : "+03:00",
            "kind" : "event",
            "module" : "system",
            "dataset" : "system.syslog"
          }
        }
      }
    ]
  }
}
user@user-VirtualBox1:~$ 

```
Как это понимать:
Если в результатах показано 0 совпадений, Elasticsearch не выполняет загрузку журналов в индекс, 
который искали, и нужно проверить настройки на ошибки. 
Если получили ожидаемые результаты, перейти к следующему шагу, где увидим, 
как выполняется навигация по информационным панелям Kibana.

--------
#### 2.2 Организовать сбор логов из докера в ELK и получать данные от запущенных контейнеров


#### 2.3 Настроить свои дашборды в ELK


#### EXTRA 2.4: Настроить фильтры на стороне Logstash (из поля message получить отдельные поля docker_container и docker_image)


#### 2.5 Настроить мониторинг в ELK - получать метрики от ваших запущенных контейнеров


#### 2.6 Посмотреть возможности и настройки




### 3. Grafana:


#### 3.1 Установить Grafana интегрировать с установленным ELK


#### 3.2 Настроить Дашборды



