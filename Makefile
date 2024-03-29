GO ?= go
GOFMT ?= gofmt "-s"
GOFILES := $(shell find . -name "*.go" -type f -not -path "./vendor/*")
PACKAGES ?= $(shell $(GO) list ./... | grep -v /vendor/)
IMAGE := theodesp/golangdocs.com
VERSION ?= $(shell grep "APP_VERSION" Dockerfile | cut -d " " -f3)

all: test-all

test-all: test-lint test

.PHONY: test
test:
	-rm -f coverage.out
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
	$(GO) test -short ./...

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
	@if [ "${DEPLOY}" = "true" ]; then\
		docker build --pull --cache-from "${IMAGE}" --tag "${IMAGE}" .;\
	fi

.PHONY: push-image
push-image:
	docker tag "${IMAGE}" "${IMAGE}:latest"
	docker tag "${IMAGE}" "${IMAGE}:${VERSION}"
	docker push ${IMAGE}:${VERSION}
	docker push ${IMAGE}:latest