.PHONY: deps build clean run test

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
