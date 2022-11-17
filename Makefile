.PHONY: deps build clean run test user

DOCKER=0
BASEDIR=$(PWD)/contrib/scripts

deps:
	$(BASEDIR)/deps $(DOCKER)

build:
	$(BASEDIR)/build $(DOCKER)

clean:
	$(BASEDIR)/clean

run:
	$(BASEDIR)/run $(DOCKER)

test:
	$(BASEDIR)/test

user:
	$(BASEDIR)/user $(DOCKER)
