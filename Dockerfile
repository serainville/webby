ARG FINALIMAGE=scratch
#----------------------------------------------------------------------------
FROM golang:1.15

ARG SETCAP="true"

WORKDIR /go/src/app
COPY ./src .
RUN echo "SET CAP: ${SETCAP}"
RUN go get -u \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o webby . \
    && if [ "$SETCAP" == "true" ];  then echo $SETCAP; setcap CAP_NET_BIND_SERVICE+ep ./webby; fi
#----------------------------------------------------------------------------
FROM ${FINALIMAGE}
COPY --from=0 /go/src/app/webby /webby
ENTRYPOINT ["/webby"]