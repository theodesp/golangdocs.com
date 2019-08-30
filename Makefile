GO ?= go
GOFMT ?= gofmt "-s"
GOFILES := $(shell find . -name "*.go" -type f -not -path "./vendor/*")
PACKAGES ?= $(shell $(GO) list ./... | grep -v /vendor/)
IMAGE := theodesp/golangdocs.com

all: test-all

test-all: test-lint test

.PHONY: test
test:
	-rm coverage.out
	@for package in $(PACKAGES) ; do \
		$(GO) test -race -coverprofile=profile.out -covermode=atomic $$package ; \
		if [ -f profile.out ]; then \
			cat profile.out | grep -v "mode:" >> coverage.out; \
			rm profile.out ; \
		fi \
	done

.PHONY: test-lint
test-lint:
	golangci-lint run $(GOFILES)

vet:
	$(GO) vet $(PACKAGES)

# Test fast
test-fast:
	go test -short ./...

.PHONY: fmt
fmt:
	$(GOFMT) -w $(GOFILES)

# Clean junk
.PHONY: clean
clean:
	$(GO) clean ./...

.PHONY: install
install:
	$(GO) get -u github.com/stretchr/testify

.PHONY: image
image:
	docker build -t ${IMAGE}:${VERSION} .
	docker tag ${IMAGE}:${VERSION} ${IMAGE}:latest

.PHONY: push-image
push-image:
	docker push ${IMAGE}:${VERSION}
	docker push ${IMAGE}:latest