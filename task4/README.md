## Task 4: Ansible for beginners 

#### Важные моменты:

1. Посмотреть что такое Configuration Management Systems. [X]

2. Преимущества и недостатки Ansible над другими инструментами [X]

3. Ознакомиться с основами ансибла и синтаксисом YAML [X]

4. Основы работы с Ansible из официальной документации [X]


EXTRA: Jinja2 templating - почитать документацию []


### Tasks:
1. Развернуть три виртуальные машины в облаке. [X] На одну из них (control_plane) установить Ansible. [X]

Установка Ansible на Ubuntu:
```
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```
Установка Ansible на CentOS:
```
sudo yum install epel-release
sudo yum install ansible
```
Установка Ansible на Amazon Linux через PIP </br>
(плюсы - 1 команда, минусы - не создается конфиг файл)
```
sudo pip3 install ansible
```
Проверить установку можно спросив версию приложения: ansible --version

Примечание - в ubuntu всё ок:
```
ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.5 (default, Jan 27 2021, 15:41:15) [GCC 9.3.0]
```
А в Amazon Linux 2 AMI версия python не устраивает (хотя не фатально старая):
```
ansible --version
[DEPRECATION WARNING]: Ansible will require Python 3.8 or newer on the controller starting with Ansible 2.12. Current version: 3.7.9 (default, Apr 30 2021, 20:11:56) [GCC 7.3.1 20180712 (Red Hat
7.3.1-12)]. This feature will be removed from ansible-core in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ansible [core 2.11.1]
  config file = None
  configured module search path = ['/home/ec2-user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  ansible collection location = /home/ec2-user/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.7.9 (default, Apr 30 2021, 20:11:56) [GCC 7.3.1 20180712 (Red Hat 7.3.1-12)]
  jinja version = 3.0.1
  libyaml = True
```


2. Ping pong - выполнить встроенную команду ансибла ping. Пинговать две другие машины. [X]</br>

Для выполнения пинг, ansible понадобится доп. информация о хостах, поэтому:

Для подключения к другим машинам в папку .ssh кладем их ключи и меняем права</br>
```sudo chmod 400 key.pem```</br>

Создаем папку проекта в которой будет inventory-файл (hosts.txt) </br>
По минимуму можно колонку ip-адресов вписать. </br>
Правильно - указывать группы, адреса, шлюзы (если надо), юзеров, и ключи (пути к ним). </br>
Не правильно - указывать в этом файле пароли ))) </br>
Идеально - повыкидывать в др. конфиг файлы и в переменные всё кроме ip.</br>

Содержимое файла примерно такое:
```
[test_servers]
srv1 ansible_host=<ip-address> ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/key.pem

[staging_servers]
srv2 ansible_host=<ip-address> ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/key.pem

[prod_servers]
srv3 ansible_host=<ip-address>  ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/key.pem
```



Проверка подключения делается так:
```ansible -i hosts.txt all -m ping```

Вывод будет примерно такой:
```
ubuntu@ip-address:~/ansible$ ansible -i hosts.txt all -m ping
srv1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
srv2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
srv0 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
srv3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Полезные команды: </br>
посмотреть все группы, переменные </br>
```ansible-inventory --list  </br>```
или 
```ansible-inventory --graph </br>```

Еще больше информации: </br>
```ansible all -m setup``` </br>

Запуск чего-нибудь </br>
```ansible all -m shell -a "uptime" ```  </br>
```ansible all -m shell -a "ls /var"``` и т.д. </br>

``ansible all -m command -a "ls /var"`` (не работают перенаправления и проч.)  </br>

Копирование файла на все хосты:  </br>
```ansible all -m copy -a "src=test-file.txt dest=/home mode=777" -b ``` </br>

Удаление файла (и не только)  </br>
```ansible all -m file -a "path=/home/test-file.txt state=absent" -b ```</br> 

Загрузка файлов по URL </br>
```ansible all -m get_url -a "url=some_link dest=/home" -b``` </br>

Установка </br>
```ansible all -m yum -a "name=stress state=installed" -b``` </br>

Удаление </br>
```ansible all -m yum -a "name=stress state=removed" -b``` </br>

Проверка доступности сайта: </br>
```ansible all -m uri -a "url=http://ya.ru"``` </br>

Прочитать что-то по url: </br>
```ansible all -m uri -a "url=http://ya.ru return_content=yes"``` </br>

Поставить апач: </br>
```ansible all -m yum -a "name=httpd state=installed" -b``` </br>
```ansible all -m service -a "name=httpd state=started enabled=yes"``` </br>

Дэбагинг, посмотреть инфо о выполнении команд </br>
```
ansible all -m shell -a "uptime" -v </br>
ansible all -m shell -a "uptime" -vv </br>
ansible all -m shell -a "uptime" -vvv </br>
ansible all -m shell -a "uptime" -vvvv </br>
ansible all -m shell -a "uptime" -vvvvv </br>
```

Список модулей ансибла </br>
```ansible-doc -l </br>```


3. Мой Первый Плейбук - написать плейбук по установке Docker на две машины и выполнить его. </br>

Пример содержимого простейшего плейбука (просто пингует): </br>

```
---
- name: Test connect to my servers
  hosts: all
  become: yes

  tasks:

  - name: ping my servers
    ping:
```
Запускать плейбук так: ```ansible-playbook playbook1.yml``` </br>
 
Для выполнения задания 3 создан файл docker_play.yml </br>
(запускать командой ```ansible-playbook docker_play.yml```) </br>

Для удобства ниже приведено содержимое этого файла: </br>

```
---
- name: install docker in tsp
  hosts: tsp_servers
  become: yes

  tasks:
    - name: install aptitude using apt
      apt: name=aptitude state=latest update_cache=yes force_apt_get=yes

    - name: install required packages
      apt: name={{ item }} state=latest update_cache=yes
      loop: [ 'apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common']

    - name: gpg apt key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: add docker repository
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu bionic stable
        state: present

    - name: update apt and install docker-ce
      apt: update_cache=yes name=docker-ce state=latest
```


А это, то что мне больше нравится по оформлению, но я не заставил это работать :-(
```
---
- hosts: docker
  become: true
  tasks:
    - name: install depensy
      apt:
        name: "{{item}}"
        state: present
        update_cache: yes
      loop:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg-agent
        - software-properties-common- name: add GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present- name: add repository docker
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu bionic stable
        state: present- name: install docker
      apt:
        name: "{{item}}"
        state: latest
        update_cache: yes
      loop:
        - docker-ce
        - docker-ce-cli
        - containerd.io- name: make sure that docker was started and enabled
      service:
        name: docker
        state: started
        enabled: yeshandlers
    - name: restart docker
      service: 
        name: docker 
        state: restarted
```
      
EXTRA 1. Написать плейбук по установке Docker и одного из (LAMP/LEMP стек, Wordpress, ELK, MEAN - GALAXY нельзя) в Docker.


EXTRA 2. Вышесказанные плейбуки не должны иметь дефолтных кредов к базам данных и/или админке.


EXTRA 3.  Для исполнения плейбуков должны использоваться dynamic inventory (GALAXY можно)




Результатом выполнения данного задания являются ansible файлы в GitHub. 

















