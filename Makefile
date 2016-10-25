VERSION=1.1
USER=sonn
REPO=fbuilder8

build: check_version
	docker build -t $(USER)/$(REPO):$(VERSION) .
#
check_version:

push:
	docker push $(USER)/$(REPO):$(VERSION)
