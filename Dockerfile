FROM golang:alpine as build

WORKDIR /build

RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/main/" > /etc/apk/repositories \
    && apk update \
    && apk add --no-cache git

#RUN git config --global https.proxy http://127.0.0.1:1080

#RUN git config --global https.proxy https://127.0.0.1:1080

RUN go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/

COPY go.mod go.sum ./

RUN  go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o keepalived_exporter -ldflags "-s -w"


FROM scratch

COPY --from=build /build/keepalived_exporter /keepalived_exporter
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER 65534
EXPOSE 9650

ENTRYPOINT ["/keepalived_exporter"]
