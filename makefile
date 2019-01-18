
HUGO_VERSION := 0.53

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
endif
ifeq ($(UNAME_S),Darwin)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_macOS-64bit.tar.gz
endif

.PHONY: clean

site/public/BUILD_METADATA: hugo $(shell find site -type f | grep -v site/public)
	cd site; ../hugo
	date > site/public/BUILD_METADATA
	git log -1 --pretty=format:%H >> site/public/BUILD_METADATA

hugo:
	#
	wget -O hugo.tar.gz ${HUGO_URL}
	tar -xvf hugo.tar.gz hugo

clean:
	rm -f hugo hugo.tar.gz
	rm -rf site/public
