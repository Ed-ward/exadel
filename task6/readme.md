## Task 6: Databases. Remember everything.
*Базы данных. Кто владеет информацией, тот владеет миром*
 
>Важные моменты:
Основные понятия баз данных. Познакомиться с существующими базами данных. Различия SQL/NoSQL баз данных (Примеры)
 
## Tasks:

### 1. Развернуть в облаке контейнер с базой данных SQL (MySQL or PostgreSQL)

Установка руками заключается в выполнении ряда команд (в нашем случае внутри докер-контейнера):
```
apt update
apt install postgresql postgresql-contrib
postgres psql -c "SELECT version();"
```

Для упрощения можно использовать готовый образ https://hub.docker.com/_/postgres

Докер-файл прилагается. (В нем дополнительно создаются volumes и устанавливается nano.)

Полезные команды для работы с Postgres вынес в отдельный файл, чтобы повысить читаемость.

Также в этом пункте надо выполнить некоторые подготовительные действия:

### Создание нового пользователя:
```
su - postgres -c "createuser exa_user"
```
### Создание новой БД
```su - postgres -c "createdb exa_base"```
### Подключение к серверу БД:

```sudo -u postgres psql```
или
```su - postgres```

### Запуск консоли
```psql```

### Даем пользователю права:

```grant all privileges on database exa_base to exa_user;```

--------   

### 2. Заполнить базу данных. Сделать две таблицы:
Students (ID; Student; StudentId);
Result (ID; StudentId; Task1; Task2; Task3; Task4);
Данные брать из:
https://docs.google.com/spreadsheets/d/1bJ6aDyDSBPAbck56ji6q98rw8S69i_cDymm4gN0vu3o/edit?ts=60c0e27d#gid=0

#### Выбрать базу
```\c exa_base```

#### Создание таблиц 
```CREATE TABLE Students (ID serial , Student text, StudentID int not null);```

```CREATE TABLE Result  (ID serial , StudentID INTEGER, TASK1 text, TASK2 text, TASK3 text, TASK4 text);```

#### Импорт данных из csv в таблицу postgresql

Были созданы два файла с данными в формате csv и с помощью mobaxterm помещены в контейнер

Затем, руководствуясь этими ответами, был выполнен импорт

https://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgresql-table

```
copy Students(Student,StudentId) FROM '/home/students.csv' DELIMITER ',' CSV HEADER;
copy Result(StudentId,Task1,Task2,Task3,Task4) FROM '/home/result.csv' DELIMITER ',' CSV HEADER;
```
Вот результат
```
exa_base=# copy Result(StudentId,Task1,Task2,Task3,Task4) FROM '/home/result.csv' DELIMITER ',' CSV HEADER;
COPY 21
exa_base=# select * from Result;
 id | studentid | task1 |     task2     | task3 | task4
----+-----------+-------+---------------+-------+-------
  1 |         1 | Done  | Done+         | Done+ | Done+
  2 |         2 | Done+ | Done+         | Done+ | Done+
  3 |         3 | Done  | Done+         | Done+ | Done+
  4 |         4 | Done+ | Done+         | Done  | Done
  5 |         5 | Done  | Done          | Done  | Done
  6 |         7 | Done+ | Done+         | Done+ | Done+
  7 |         8 | Done  | not completed | Done  | Done
  8 |         9 | Done  | Done+         | Done  | Done
  9 |        10 | Done+ | Done+         | Done+ | Done
 10 |        11 | Done  | Done          | Done  | Done
 11 |        14 | Done  | Done+         | Done+ | Done+
 12 |        16 | Done  | Done+         | Done  | Done
 13 |        18 | Done  | Done+         | Done+ | Done+
 14 |        19 | Done  | Done+         | Done+ | Done+
 15 |        20 | Done  | Done+         | Done+ | Done+
 16 |        21 | Done+ | Done+         | Done+ | Done+
 17 |        22 | Done+ | Done+         | Done+ | Done+
 18 |        23 | Done  | Done          | Done+ | Done+
 19 |        24 | Done  | Done          | Done  | Done
 20 |        26 | Done  | Done+         | Done+ | Done+
 21 |        27 | Done+ | Done+         | Done+ | Done+
(21 rows)

exa_base=# select * from Students;
 id |                student                | studentid
----+---------------------------------------+-----------
  1 | Назар Винник               |         1
  2 | Александр Рекун         |         2
  3 | Олег Бандрівський     |         3
  4 | Владимир Бурдыко       |         4
  5 | Вадим Марков               |         5
  6 | Игорь Войтух               |         7
  7 | Дмитрий Мошна             |         8
  8 | Евгений Козловский   |         9
  9 | Эд Еленский                 |        10
 10 | Игорь Зинченко           |        11
 11 | Виталий Костюков       |        14
 12 | Евгений Лактюшин       |        16
 13 | Михаил Лопаев             |        18
 14 | Михаил Мостыка           |        19
 15 | Андрей Новогродский |        20
 16 | Cазонова Анна              |        21
 17 | Дмитрий Соловей         |        22
 18 | Артём Фортунатов       |        23
 19 | Хоменко Іван               |        24
 20 | Алексей Шутов             |        26
 21 | Юрий Щербина               |        27
(21 rows)

exa_base=# 
```
/*скриншот добавил.*/



EXTRA: 2.1. Написать SQL скрипт, который будет заполнять базу данных и проверять на наличие уже существующих таблиц/записей.



###3. Написать запрос который по вашей фамилии будет находить информацию по выполненным заданиям и выводить результат на экран.

Так как требуется сделать запрос по фамилии, а они хранятся в таблице не отдельно, 
а в столбце вместе с именами то искать надо так ``` ~ 'Еленский'```, а не ``` = 'Еленский'```.
```
exa_base=# select students.student, task1, task2, task3, task4
exa_base-# from students,result
exa_base-# where students.studentid=result.studentid and students.student ~ 'Еленский';
        student        | task1 | task2 | task3 | task4
-----------------------+-------+-------+-------+-------
 Эд Еленский | Done+ | Done+ | Done+ | Done
(1 row)

exa_base=#
```
(Выбираем столбцы "студент" и "таски 1-4" из таблиц "студенты" и "результаты" 
со строками в которых одинаковые Айди студентов и студент содержит необходимый текст  ХD))) )

4. Сделайте dump базы данных, удалите существующую и восстановите из дампа.



5. Написать Ansible роль для развертывания SQL или noSQL базы данных. Креды не должны храниться в GitHub.



EXTRA: 
1. Прочитать про репликацию SQL и NoSQL.
2. Написать Ansible роль для создания SQL/NoSQL кластера.
3. Написать Pipeline для Jenkins который будет запускать ансибл плейбуки для SQL/NoSQL.
