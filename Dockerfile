#----------------------------------------------------------------------------
FROM golang:1.15
WORKDIR /go/src/app
COPY ./src .
RUN go get -u \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o webby . \
    && setcap CAP_NET_BIND_SERVICE+ep ./webby
#----------------------------------------------------------------------------
FROM scratch
COPY --from=0 /go/src/app/webby /webby
USER 40000:40000
ENTRYPOINT ["/webby"]