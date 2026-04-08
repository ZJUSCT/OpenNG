NAME=netgate
BUILDTIME=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
VERSION ?= $(shell v="$$(git describe --tags --abbrev=7 --dirty 2>/dev/null)"; \
	echo "$${v:-0.0.0}" | sed 's/^v//; s/-/./g')

GOBUILD=go build -a \
	-ldflags "-w -s \
	-X 'main.buildstamp=$(BUILDTIME)' \
	-X 'main.gitver=$(VERSION)'"

HOST_ARCH=$(shell uname -m)
ifeq ($(HOST_ARCH),x86_64)
  HOST_GOARCH=amd64
else ifeq ($(HOST_ARCH),aarch64)
  HOST_GOARCH=arm64
else
  HOST_GOARCH=$(HOST_ARCH)
endif

ui:
	(cd ui/html && npm install && npm run build)

linux-amd64:
	GOOS=linux GOARCH=amd64 GOAMD64=v2 $(GOBUILD) -o $(NAME)

linux-arm64:
	GOOS=linux GOARCH=arm64 $(GOBUILD) -o $(NAME)

all: linux-$(HOST_GOARCH)

deb: deb-$(HOST_GOARCH)

deb-amd64: linux-amd64 ui
	fpm -t deb -v "$(VERSION)" -p "$(NAME)_$(VERSION)_amd64.deb" --architecture amd64 -f

deb-arm64: linux-arm64 ui
	fpm -t deb -v "$(VERSION)" -p "$(NAME)_$(VERSION)_arm64.deb" --architecture arm64 -f

clean:
	rm -f $(NAME) *.deb

.PHONY: all ui linux-amd64 linux-arm64 deb deb-amd64 deb-arm64 clean
