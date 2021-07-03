# Немного полезных команд для Postgresql.
Оказывается, начал забывать, было полезно вспомнить :)

### Установка Postgresql:
```
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql -c "SELECT version();"
sudo su - postgres
psql
\q
sudo -u postgres psql
```
### Создание нового пользователя:
```
sudo su - postgres -c "createuser username"
```

### Создание новой БД
```sudo su - postgres -c "createdb new_db_name"```

### Подключение к серверу БД:

```sudo -u postgres psql```

### Даем пользователю права:

```grant all privileges on database lab_db to username;```

### Добавляем IP который будет слушать сервер БД ('*'==любой адрес)

```
sudo nano /etc/postgresql/11/main/postgresql.conf	
---listen_addresses = '*'
```
### Перезапуск службы

```sudo service postgresql restart```

### Проверяем применился ли конфиг

```ss -nlt | grep 5432	#check change```

### Добавляем в pg_hba.conf пользователя которому разрешено входящее подключение
(вместо trust можно указывать пароль или md5)
```
host    hostname     username      192.168.0.97/25         trust
```
### Создание нового пользователя из командной строки c паролем и ограничением подключений
(применяется для репликации и вообще...)
```
CREATE USER replicator REPLICATION LOGIN CONNECTION LIMIT 1000 ENCRYPTED PASSWORD 'password';
```

### Вывести список пользователей (команда запускается из БД):
```
select * from pg_shadow;
```

### Вывести список баз данных (команда запускается из БД)
```
select * from pg_database;
```

### Или из командной строки
```psql -A -q -t -c "select datname from pg_database" template1```

### Очистить таблицу
```TRUNCATE lab_db;```

### Проверка и перезапуск кластера
```
pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
11  main    5432 down   postgres /var/lib/postgresql/11/main /var/log/postgresquerylog//postgresql.csv,/var/log/postgresquerylog//postgresql.log

sudo pg_ctlcluster 11 main start
```

### Проверка логов если кластер не запускается
```
systemctl status postgresql@11-main.service
journalctl -xe

sudo nano /etc/postgresql/11/main/postgresql.conf

data_directory = '/var/lib/postgresql/11/main'
$PGDATA=/var/lib/postgresql
```

### Настройка логов транзакций и архивирование

```
sudo su postgres
wal_level = logical 
wal_log_hints = on 
archive_mode = on
archive_command = 'cp -i %p /var/lib/postgresql/archive/%f'
max_wal_senders = 15
hot_standby = on
synchronous_commit = remote_write
mkdir -p /var/lib/postgresql/archive
```
### Проверка репликации
```
select usename,application_name,client_addr,backend_start,state,sync_state from pg_stat_replication;
```

### Создание таблицы 
```CREATE TABLE my_new_db (c1 integer, c2 text);```

### Заполняем ее данными и анализируем время выполнения
```
EXPLAIN analyze INSERT INTO my_new_db SELECT i, md5(random()::text) FROM generate_series(1, 1000000)AS i;
SELECT * FROM my_new_db limit 10;
```

### Установка dhis

```
sudo useradd -d /home/dhis -m dhis -s /bin/false # создаем нового пользователя
sudo passwd dhis			# добавляем ему пароль
mkdir /home/dhis/config			# создаем папку конфигураций dhis
chown dhis:dhis /home/dhis/config	# устанавливаем владельца dhis
sudo -u postgres createuser -SDRP dhis	# создаем пользователя dhis в postgres без привелегий
sudo -u postgres createdb -O dhis dhis2	# создаем базу данных
sudo -u postgres psql -c "create extension postgis;" dhis2	# добавлем пользователю БД DHIS 2 разрешение на создание расширений, используя пользователя postgres 
```
