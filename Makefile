GO ?= go
GOFMT ?= gofmt "-s"
GOFILES := $(shell find . -name "*.go" -type f -not -path "./vendor/*")
PACKAGES ?= $(shell $(GO) list ./... | grep -v /vendor/)

all: test

.PHONY: test
test:
	-rm coverage.txt
	@for package in $(PACKAGES) ; do \
		$(GO) test -race -coverprofile=profile.out -covermode=atomic $$package ; \
		if [ -f profile.out ]; then \
			cat profile.out | grep -v "mode:" >> coverage.out; \
			rm profile.out ; \
		fi \
	done

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