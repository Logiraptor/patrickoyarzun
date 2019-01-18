
HUGO_VERSION := 0.53

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
	PACKR_URL := https://github.com/gobuffalo/packr/releases/download/v2.0.0-rc.14/packr_2.0.0-rc.14_linux_amd64.tar.gz
endif
ifeq ($(UNAME_S),Darwin)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_macOS-64bit.tar.gz
	PACKR_URL := https://github.com/gobuffalo/packr/releases/download/v2.0.0-rc.14/packr_2.0.0-rc.14_darwin_amd64.tar.gz
endif

.PHONY: clean

main: server.go site/public/BUILD_METADATA packr2
	./packr2
	go build -o main .

site/public/BUILD_METADATA: hugo $(shell find site -type f | grep -v site/public)
	cd site; ../hugo
	date > site/public/BUILD_METADATA
	git log -1 --pretty=format:%H >> site/public/BUILD_METADATA

hugo:
	#
	wget -O hugo.tar.gz ${HUGO_URL}
	tar -xvf hugo.tar.gz hugo

packr2:
	wget -O packr.tar.gz ${PACKR_URL}
	tar -xvf packr.tar.gz packr2

clean:
	rm -f hugo packr2 hugo.tar.gz packr.tar.gz main gin-bin patrickoyarzun
	rm -rf site/public
	packr2 clean
