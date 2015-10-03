VERSION ?= latest

all:
	rm -f serf
	unzip -d . upstream/0.6.4_linux_amd64.zip
	docker build -t quay.io/jhansen/serf .
	docker tag quay.io/jhansen/serf quay.io/jhansen/serf:${VERSION}
	docker push quay.io/jhansen/serf:${VERSION}

clean:
	rm -f serf
