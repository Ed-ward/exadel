## Task 6: Databases. Remember everything.
*Базы данных. Кто владеет информацией, тот владеет миром*
 
>Важные моменты:
Основные понятия баз данных. Познакомиться с существующими базами данных. Различия SQL/NoSQL баз данных (Примеры)
 
## Tasks:

### 1. Развернуть в облаке контейнер с базой данных SQL (MySQL or PostgreSQL)

Установка руками заключается в выполнении ряда команд (в нашем случае внутри докер-контейнера):
```
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql -c "SELECT version();"
sudo su - postgres
psql
\q
sudo -u postgres psql
```
Для упрощения можно использовать готовый образ https://hub.docker.com/_/postgres

Докер-файл прилагается. (В нем дополнительно создаются volumes и устанавливается nano.)

Полезные команды для работы с Postgres вынес в отдельный файл, чтобы повысить читаемость.

Также в этом пункте надо выполнить некоторые подготовительные действия:

### Создание нового пользователя:
```
sudo su - postgres -c "createuser newuser"
```
### Создание новой БД
```sudo su - postgres -c "createdb new_base"```
### Подключение к серверу БД:

```sudo -u postgres psql```

### Даем пользователю права:

```grant all privileges on database new_base to newuser;```

--------   

### 2. Заполнить базу данных. Сделать две таблицы:
Students (ID; Student; StudentId);
Result (ID; StudentId; Task1; Task2; Task3; Task4);
Данные брать из:
https://docs.google.com/spreadsheets/d/1bJ6aDyDSBPAbck56ji6q98rw8S69i_cDymm4gN0vu3o/edit?ts=60c0e27d#gid=0

#### Создание таблиц 
```CREATE TABLE Students (ID integer, Student text, StudentId integer);```

```CREATE TABLE Result (ID integer, StudentId integer, Task1 text, Task2 text, Task3 text, Task4 text);```


EXTRA: 2.1. Написать SQL скрипт, который будет заполнять базу данных и проверять на наличие уже существующих таблиц/записей.



3. Написать запрос который по вашей фамилии будет находить информацию по выполненным заданиям и выводить результат на экран.



4. Сделайте dump базы данных, удалите существующую и восстановите из дампа.



5. Написать Ansible роль для развертывания SQL или noSQL базы данных. Креды не должны храниться в GitHub.



EXTRA: 
1. Прочитать про репликацию SQL и NoSQL.
2. Написать Ansible роль для создания SQL/NoSQL кластера.
3. Написать Pipeline для Jenkins который будет запускать ансибл плейбуки для SQL/NoSQL.
