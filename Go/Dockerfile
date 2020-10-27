# heroku
FROM golang:1.12.12-alpine3.9 AS build

ENV GOPATH $GOPATH:/go
ENV PATH $PATH:$GOPATH/bin

RUN apk update && \
  apk add --no-cache git ca-certificates && \
  go get "github.com/beego/bee" && \
  go get "github.com/astaxie/beego" && \
  go get "github.com/astaxie/beego/session" && \
  go get "github.com/ChimeraCoder/anaconda" && \
  go get "firebase.google.com/go" && \
  go get "firebase.google.com/go/messaging" && \
  rm -rf /var/cache/apk/*

ADD . /go/src/app
WORKDIR /go/src/app
RUN go build -o app main.go

FROM alpine:3.9
RUN apk update && \
apk --no-cache add tzdata ca-certificates && \
  rm -rf /var/cache/apk/*
COPY --from=build /go/src/app/ .
CMD ["./app"]