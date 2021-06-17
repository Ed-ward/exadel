## 5. и 5.1ex Docker compose

### Порядок действий
Если используем готовые образы - находим их или создаем.

Находим / нужные файлы приложений. </br>
(Желательно всё разместить в отдельных директориях и написать докерфайлы.)

Пишем файл docker-compose.yml </br>

В нем указывается что запускать с какими окружениями портами вольюмами зависимостями и т.д. </br>
Подробнее я смотрел тут (и много где еще):  </br>
https://habr.com/ru/company/ruvds/blog/450312/  </br>
https://itisgood.ru/2019/02/05/kak-zapuskat-kontejnery-s-pomoshhju-docker-compose/  </br>
https://webdevkin.ru/posts/raznoe/docker  </br>
https://losst.ru/ispolzovanie-docker-dlya-chajnikov  </br>

Переменные из файла делаются так (указали файл в ямле и заполнили файл .env): </br>
https://stackoverflow.com/questions/46917831/how-to-load-several-environment-variables-without-cluttering-the-dockerfile

### Основные команды:  </br>

Запустить (из директории с ямлом): </br>
```docker-compose up```

Запустить в фоновом режиме: </br>
```docker-compose up -d```

Остановить запущеное: </br>
```docker-compose stop```

Остановить и удалить: </br>
```docker-compose down```

Пересобрать и запустить после небольших изменений: </br>
```docker-compose up --build```

Подключиться к контейнеру (изменения сотрутся при перезапуске): </br>
```docker-compose exec название-контейнера /bin/bash```


