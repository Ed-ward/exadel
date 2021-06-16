#!/bin/bash
app="docker.hello"
docker build -t ${app} .
docker run --rm -d -p 5000:5000 \
--name=${app} \
-v $PWD:/app ${app}
