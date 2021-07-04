#!/bin/bash
app="docker.postgres"
docker build -t ${app} .
docker run --rm -d -p 5432:5432 \
--name=${app} \
-v $PWD:/app ${app}
