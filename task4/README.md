Task 4: Ansible for beginners 


Важные моменты:

1. Посмотреть что такое Configuration Management Systems. [X]



2. Преимущества и недостатки Ansible над другими инструментами [X]



3. Ознакомиться с основами ансибла и синтаксисом YAML []



4. Основы работы с Ansible из официальной документации []



EXTRA Jinja2 templating - почитать документацию []


Tasks:
1. Развернуть три виртуальные машины в облаке. На одну из них (control_plane) установить Ansible.

Установка Ansible на Ubuntu:
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible

Установка Ansible на CentOS:
sudo yum install epel-release
sudo yum install ansible


2. Ping pong - выполнить встроенную команду ансибла ping. Пинговать две другие машины.




3. Мой Первый Плейбук - написать плейбук по установке Docker на две машины и выполнить его.




       
EXTRA 1. Написать плейбук по установке Docker и одного из (LAMP/LEMP стек, Wordpress, ELK, MEAN - GALAXY нельзя) в Docker.


EXTRA 2. Вышесказанные плейбуки не должны иметь дефолтных кредов к базам данных и/или админке.


EXTRA 3.  Для исполнения плейбуков должны использоваться dynamic inventory (GALAXY можно)




Результатом выполнения данного задания являются ansible файлы в GitHub. 
















