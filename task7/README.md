# Task 7: Logging&Monitoring. Big Brother.
Мониторинг: Город засыпает просыпается ....
## Tasks:
### 1. Zabbix:
Тут нормально описано https://losst.ru/ustanovka-zabbix-na-ubuntu
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
sudo vi /etc/zabbix/zabbix_agentd.conf
```
```
Server=192.168.1.200
Hostname=Zabbix
```

После изменения конфигурации перезапустить сервис zabbix-agent:
```
sudo systemctl restart zabbix-agent
```

Добавить новый хост в Zabbix на вкладке Hosts и наблюдать за его состоянием.



####EXTRA 1.2.1: сделать это ансиблом


#### 1.3 Сделать несколько своих дашбородов, куда вывести данные со своих триггеров (например мониторить размер базы данных из предыдущего задания и включать алерт при любом изменении ее размера - можно спровоцировать вручную)


#### 1.4 Active check vs passive check - применить у себя оба вида - продемонстрировать.


#### 1.5 Сделать безагентный чек любого ресурса (ICMP ping)


#### 1.6 Спровоцировать алерт - и создать Maintenance инструкцию 


#### 1.7 Нарисовать дашборд с ключевыми узлами инфраструктуры и мониторингом как и хостов так и установленного на них софта





### 2. ELK: 


Никто не забыт и ничто не забыто.


#### 2.1 Установить и настроить ELK 


#### 2.2 Организовать сбор логов из докера в ELK и получать данные от запущенных контейнеров


#### 2.3 Настроить свои дашборды в ELK


#### EXTRA 2.4: Настроить фильтры на стороне Logstash (из поля message получить отдельные поля docker_container и docker_image)


#### 2.5 Настроить мониторинг в ELK - получать метрики от ваших запущенных контейнеров


#### 2.6 Посмотреть возможности и настройки




### 3. Grafana:


#### 3.1 Установить Grafana интегрировать с установленным ELK


#### 3.2 Настроить Дашборды



