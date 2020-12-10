#all: push

VERSION = 0.1.0
TAG = $(VERSION)
PREFIX = gcr.io/serverlab/webby

GOLANG_CONTAINER = golang:1.15
GOFLAGS ?= -mod=vendor
DOCKERFILEPATH = .
DOCKERFILE = Dockerfile # note, this can be overwritten e.g. can be DOCKERFILE=DockerFileForPlus

BUILD_IN_CONTAINER = 0
PUSH_TO_GCR =
GENERATE_DEFAULT_CERT_AND_KEY =
DOCKER_BUILD_OPTIONS =

GIT_COMMIT = $(shell git rev-parse --short HEAD)

export DOCKER_BUILDKIT = 1

binary:
ifneq ($(BUILD_IN_CONTAINER),1)
	cd ./src
	pwd
	CGO_ENABLED=0 GO111MODULE=on GOFLAGS='$(GOFLAGS)' GOOS=linux go build -installsuffix cgo -ldflags "-w -X main.version=${VERSION} -X main.gitCommit=${GIT_COMMIT}" -o webby
endif

container:
	docker build -t $(PREFIX):$(TAG) .

clean:
	rm -f webby
