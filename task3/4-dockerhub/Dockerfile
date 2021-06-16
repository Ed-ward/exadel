FROM golang:alpine
RUN mkdir /hello 
ADD ./hello /hello/ 
WORKDIR /hello 
RUN go build -o main . 
CMD ["/hello/main"]
EXPOSE 7700

