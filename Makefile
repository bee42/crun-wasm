# BuildKit is a next generation container image builder. You can enable it using
# an environment variable or using the Engine config, see:
# https://docs.docker.com/develop/develop-images/build_enhancements/#to-enable-buildkit-builds
export DOCKER_BUILDKIT=1

GIT_TAG?=$(shell git describe --tags --match "v[0-9]*" 2> /dev/null)
ifeq ($(GIT_TAG),)
	GIT_TAG=edge
endif

BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
GIT_SHA=$(shell git rev-parse --short HEAD)

# When you create your secret use the DockerHub in the name and this will find it
REPO?=$(shell basename ${PWD})
TAG?=${GIT_TAG}
DEV_IMAGE?=${REPO}/kindest-minion-wasmedge:dev
PROD_IMAGE?=bee42/crun-wasm/kindest-minion-wasmedge:${TAG}

# Local development happens here!
.PHONY: dev
all: dev
dev:
	@docker buildx build --tag ${DEV_IMAGE} \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_REVISION=${GIT_SHA} \
	--load ./kind/wasmedge

# Build a production image for the application.
.PHONY: build
build:
	@docker --context default buildx build \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_REVISION=${GIT_SHA} \
	--platform linux/amd64,linux/arm64 \
	--tag ${PROD_IMAGE} ./kind/wasmedge

# Push the production image to a registry.
.PHONY: push
push:
	@docker --context default buildx build \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_REVISION=${GIT_SHA} \
	--platform linux/amd64,linux/arm64 \
	--push --tag ${PROD_IMAGE} ./kind/wasmedge

# create a local multi arch buildx builder
.PHONY: builder
builder:
	@docker buildx create --name builder
	@docker buildx inspect builder --bootstrap
	@docker buildx use builder

# Remove the dev container, dev image, test image, and clear the builder cache.
.PHONY: clean
clean:
	@docker rmi ${DEV_IMAGE} || true
	@docker builder prune --force --filter type=exec.cachemount --filter=unused-for=24h
