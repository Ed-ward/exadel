#!/bin/bash
app="docker.hello-go"
docker build -t ${app} .
docker run --rm -d -p 3000:3000 \
--name=${app} \
-v $PWD:/app ${app}
