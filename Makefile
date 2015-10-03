VERSION      ?= latest
IMAGE_REPO   ?= quay.io/jhansen/serf
SERF_VERSION ?= 0.6.4

.PHONY: all prep clean build tag push clean
all: clean prep build tag push
	echo "Done! ${IMAGE_REPO}:${VERSION}"

prep:
	unzip -d . upstream/0.6.4_linux_amd64.zip

clean:
	rm -f serf

build: clean prep
	docker build -t ${IMAGE_REPO} .

tag:
	docker tag ${IMAGE_REPO} ${IMAGE_REPO}:${VERSION}

push:
	docker push quay.io/jhansen/serf:${VERSION}
