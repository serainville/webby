#all: push

VERSION = 0.1.4
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
	docker build -t $(PREFIX):$(TAG)-scratch --build-arg SETCAP=false .

container_alpine:
	docker build -t $(PREFIX):$(TAG)-alpine --build-arg FINALIMAGE=alpine .

container_debian:
	docker build -t $(PREFIX):$(TAG)-debian --build-arg FINALIMAGE=debian:bullseye-slim .

container_ubuntu:
	docker build -t $(PREFIX):$(TAG)-ubuntu --build-arg FINALIMAGE=ubuntu:20.04 .

container_cap:
	docker build -t $(PREFIX):$(TAG)-scratch-cap -f Dockerfile.cap .

container_nonpriv:
	docker build -t $(PREFIX):$(TAG)-scratch-nonpriv -f Dockerfile.nonpriv .

build: Dockerfile
	@docker build -t $(SNAPSHOT) -f Dockerfile .

push: build
	@docker push $(SNAPSHOT)

release: container container_alpine container_cap container_debian container_nonpriv container_ubuntu
	@docker push $(PREFIX):$(TAG)-scratch
	@docker push $(PREFIX):$(TAG)-scratch-cap
	@docker push $(PREFIX):$(TAG)-scratch-nonpriv
	@docker push $(PREFIX):$(TAG)-alpine
	@docker push $(PREFIX):$(TAG)-ubuntu
	#@docker tag $(SNAPSHOT) $(RELEASE)
	#  @docker push $(RELEASE)

clean:
	rm -f webby
