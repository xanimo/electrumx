.PHONY: deps build clean run test user

BASEDIR=$(PWD)/contrib/scripts

deps:
	$(BASEDIR)/deps

build:
	$(BASEDIR)/build

clean:
	$(BASEDIR)/clean

run:
	$(BASEDIR)/run $(container)

test:
	$(BASEDIR)/test

user:
	$(BASEDIR)/user

container:
	$(BASEDIR)/container
