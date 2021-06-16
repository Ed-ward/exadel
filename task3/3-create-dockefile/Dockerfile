FROM alpine:3.11
ENV PYTHONUNBUFFERED=1
ENV DEVOPS='Ed_Elensky'
RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
ADD hello.py requirements.txt /
RUN pip3 install --no-cache -r requirements.txt
ENTRYPOINT ["python3"]
CMD ["hello.py"]
