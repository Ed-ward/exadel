### 3.1 Делаем Dockerfile для создания образа с веб-сервером и запуска своего приложения.
### +
### Extra 3.1.1 - делаем 3.1, но на чистом образе
### +
### 3.2 учимся добавлять переменные окружения

Ниже просто разбор докерфайла для этих заданий.

* берем чистый образ
```FROM alpine:3.11```

* добавляем то, что надо по пункту 3.2
```ENV DEVOPS='Ed_Elensky'```

* ставим Python (не кэшируем и удаляем лишнее для минимизации образа)
```
ENV PYTHONUNBUFFERED=1
RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
```

* добавляем файлы приложений и зависимостей
```ADD hello.py requirements.txt /```
  
* выполняем установку
```
RUN pip3 install --no-cache -r requirements.txt
ENTRYPOINT ["python3"]
```

* запускаем
```CMD ["hello.py"]```


----------
* В зависимостях указан Flask==1.1.2

---------
* в hello.py простой хелло-ворлд на фреймворке flask:
````
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello world!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=False)
````

----
* Файл для запуска start.sh
```
#!/bin/bash
app="docker.hello"
docker build -t ${app} .
docker run --rm -d -p 5000:5000 \
--name=${app} \
-v $PWD:/app ${app}

```
----
Смотреть запущенное в контейнере приложение можно на 5000 порту в браузере или из консоли.



----
Extra 3.2.1 - выводим переменную на веб-странице (должна меняться при изменении значения)
это потом.
