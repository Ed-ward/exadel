
4. и 4.1

* Push your docker image to docker hub (https://hub.docker.com/). 
* Create any description for your Docker image. 

Порядок работы с гит обычный т.е. примерно такой:
добавили, закоммитили запушили, добавили тег, запушили тег. 
 
```https://github.com/Ed-ward/exadel-3-4.1
user@PC MINGW64 /d/exadel-3-4.1 (main)
$ git add *

user@PC MINGW64 /d/exadel-3-4.1 (main)
$ git commit
[main 36b19ff] test9
 1 file changed, 1 insertion(+), 1 deletion(-)

user@PC MINGW64 /d/exadel-3-4.1 (main)
$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 12 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 285 bytes | 285.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/Ed-ward/exadel-3-4.1.git
   4ed8d00..36b19ff  main -> main

user@PC MINGW64 /d/exadel-3-4.1 (main)
$ git tag v1.07f

user@PC MINGW64 /d/exadel-3-4.1 (main)
$ git push --tags
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/Ed-ward/exadel-3-4.1.git
 * [new tag]         v1.07f -> v1.07f
```

Если на локальной машине установлен докер, то можно пушить руками на докерхаб вот так:
```
You can push a new image to this repository using the CLI
docker tag local-image:tagname new-repo:tagname
docker push new-repo:tagname
Make sure to change tagname with your desired image repository tag.
```
Но если публиковать на докерхабе руками, то на старую авторизацию ругается.
Лучше сразу делать по ключам. (отдельная статья и танцы с бубном если акки зареганы на разные почты)


Если делать через GitHub workflow публикацию на Hub.Docker то норм, главное старых статей не читать. ))
Согласно документации все действия должны хранится в специальной директории:
```mkdir -p .github/workflows```
в виде yaml-файлов.

На стороне Гихаба включить Actions, добавить тесты, и публикацию из стандартных yaml-файлов.


EXTRA: 
* Integrate your docker image and your github repository. 
* Create an automatic deployment for each push. 
(The Deployment can be in the “Pending” status for 10-20 minutes. This is normal).

Сделал 4.1 отдельным репо т.к. не проходили тесты и было некогда разбираться: </br>
https://github.com/Ed-ward/exadel-3-4.1 </br>

Куча старых статей уже не актуальна для задания :-(

Сначала сделал публикацию на каждый пуш, но это плохо - билдится неаккуратно, без тегов, всё подряд, много и часто при частых пушах докерхаб забанит.
Правильнее делать по релизам.

```on:
 release:
   types: [published]
```
Когда уверены, что надо пушить - сделали релиз, подписали, оформили и всё заверте...

Прочее:
Изменилась политика докерхаба (наверное, но не точно). Автосборка на новых акках не работает.
Нашел один из старых своих акков, там всё нормально.
https://hub.docker.com/repository/docker/8901310/exadel341/general

По поводу приложения в образе.
Сначала хотел на Go что-то (оно тоже работает), но в итоге сделал на питоне.
Да, так вышло чуть быстрее и удобнее и тесты в Actions удалось опробовать.

