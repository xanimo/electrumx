.PHONY: deps build clean run test build-box test-var

docker=0
basedir=`pwd`/contrib/scripts

deps:
	$(basedir)/deps $(docker)

build:
	$(basedir)/build

clean:
	$(basedir)/clean

run:
	$(basedir)/run

test:
	$(basedir)/test

build-box:
	docker build -t xanimo/electrumx \
	. --no-cache
