## Установка Docker на Ubuntu

* Обновляем: </br>
```sudo apt update```    


* Устанавливаем пакеты для HTTPS: </br>
```sudo apt install apt-transport-https ca-certificates curl software-properties-common```


* Добавляем ключ репозитория Docker: </br>
```curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ```


* Добавляем репозиторий Docker:  </br>
```sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"```


* обновим информацией о Docker из добавленного репозитория: </br>
    ```sudo apt update```


* устанавливаем Docker: </br>
    ```sudo apt install docker-ce```

#### Docker установлен, демон запущен, и процесс будет запускаться при загрузке системы.  

### Использование команды Docker без sudo (опционально) </br>
* Добавить себя:  ```sudo usermod -aG docker ${USER}```
* Добавить кого-то: ```sudo usermod -aG docker username```


* Для применения этих изменений необходимо разлогиниться ```exit``` и снова залогиниться на сервере 
* или задать следующую команду:  ``` su - ${USER}``` (потребуется пароль)


Убедиться, что пользователь добавлен в группу docker:
```id -nG```

### Установка Docker Compose:
```sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose```  </br>

```sudo chmod +x /usr/local/bin/docker-compose```

Посмотреть версию:
```docker-compose --version```


### P.S. В этой же директории лежит скрипт для установки Docker в Ubuntu (из OS). </br>

* Для автоматической установки Docker при создании инстанса в AWS достаточно этого:
```
#!/usr/bin/env bash
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt -y install docker-ce
usermod -aG docker ubuntu
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
* Потом можно зайти и проверить, что всё установилось и работает:
```sudo systemctl status docker```

_____________
 
#### P.S.S. Не забывать делать скрипты исполняемыми!
* Используется утилита chmod. 
  Синтаксис утилиты: </br>
  ```chmod категория действие флаг адрес_файла```

Категория - флаги могут устанавливаться для трех категорий: владельца файла, группы файла и всех остальных пользователей. </br> 
В команде они указываются символами u (user) g (group) o (other) соответственно. </br>
Действие - может быть + (плюс), что будет значить установить флаг или - (минус) снять флаг. </br>
Флаг - r (чтение), w (запись), x (выполнение).

* Сделать исполняемый скрипт в linux для владельца файла: </br>
```chmod u+x адрес_файла```

* Чтобы файл могли выполнять и другие пользователи, нужно указать также другие категории: g и o: </br>
```chmod ugo+x адрес_файла```

* Посмотреть флаги с помощью утилиты ls: </br>
```ls -l каталог_с_файлами```

Первое rwx - флаги владельца, второе - группы, а третье - для всех остальных.  </br>
Если флаг не установлен, на его месте будет прочерк.

Снять флаг исполняемого файла - та же команда только со знаком минус: </br>
```chmod u-x адрес_файла```


