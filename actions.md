# More Github Action

* https://dev.to/cloudx/multi-arch-docker-images-the-easy-way-with-github-actions-4k54
* https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
* https://dev.to/willvelida/pushing-container-images-to-github-container-registry-with-github-actions-1m6b

## Publish to Docker hub

```yaml
name: Build

# Controls when the workflow will run
on:
  workflow_dispatch
  push:
    branches:
      - 'main'
      - 'dev'
    tags:
      - 'v*.*.*'
  pull_request:
    branches:
      - 'main'
      - 'dev'

# permissions are needed if pushing to ghcr.io
permissions: 
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Get the repository's code
      - name: Checkout
        uses: actions/checkout@v2
      # https://github.com/docker/setup-qemu-action
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      # https://github.com/docker/setup-buildx-action
      - name: Set up Docker Buildx
        id: buildx
        uses: docker/setup-buildx-action@v1
      - name: Login to GHCR
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Login to Docker Hub
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      # https://github.com/docker/metadata-action
      - name: Docker meta
        id: meta42 # you'll use this in the next step
        uses: docker/metadata-action@v3
        with:
          # list of Docker images to use as base name for tags
          images: |
            <specify the image name>
          # Docker tags based on the following events/attributes
          tags: |
            type=schedule
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
            type=sha
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta42.outputs.tags }}
          labels: ${{ steps.meta42.outputs.labels }}
```
