## Настройка репликации Postgresql.
(в рамках Extra1, но больше для себя)

 1. На primary-сервере заходим в оболочку postgresql (psql) и там создаем пользователя, 
    от имени которого будет выполняться репликация:
```
CREATE USER replicator REPLICATION LOGIN CONNECTION LIMIT 1000 ENCRYPTED PASSWORD 'your_password';
```
 2. Выходим из оболочки и в файле **_pg_hba.conf_** разрешаем подключения пользователю **replicator** к primary:<br>
`host replication replicator ip_standby/32 password`<br>
В файле **_pg_hba.conf_** на **standby** должна быть такая же строка
 3. Редактируем кофигурационный файл **postgresql.conf** на primary, настроив следующие параметры:<br>
```
wal_level = logical
wal_log_hints = on
archive_mode = on
archive_command = 'cp -i %p /var/lib/postgresql/archive/%f'
max_wal_senders = 15
hot_standby = on
```
 4. Создаем директорию **archive** в каталоге где установлен сам postgresql на primary, в данном примере каталог выглядит вот так:<br>
```
mkdir -p /var/lib/postgresql/archive/
```
 5. Делаем рестарт **primary**<br>
```
sudo service postgresql restart
```
 6. Заходим на **standby**. Если **primary** запущен, то сначала останавливаем службу:<br>
```
sudo service postgresql stop
```
И выполняем восстановление всех каталогов с данными и архивами с **primary** при помощи следующей команды:<br> 
```
pg_basebackup -h 192.168.0.95 -U replicator -D /var/lib/postgresql/11/main -P -p 5432
```
Eсли система ругается, что папка не пустая, то делаем ее пустой и повторяем предыдущую команду.

 7. Стартуем **standby**:<br>
```
sudo service postgresql start
```
 8. Проверяем, установилась или нет связь на **primary**:<br>
```
select * from pg_stat_replication;
```
Если выдаст хоть одну строку - репликация удалась.
