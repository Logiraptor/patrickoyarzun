
HUGO_VERSION := 0.53

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
endif
ifeq ($(UNAME_S),Darwin)
	HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_macOS-64bit.tar.gz
endif

.PHONY: clean

site/public/BUILD_METADATA: hugo site/assets/img/avatar.png $(shell find site -type f | grep -v site/public)
	cd site; ../hugo
	date > site/public/BUILD_METADATA
	git log -1 --pretty=format:%H >> site/public/BUILD_METADATA

site/assets/img/avatar.png:
	wget -O site/assets/img/avatar.png https://www.gravatar.com/avatar/1bd0f98dad76d9b2f7efc49a984f69aa

hugo:
	#
	wget -O hugo.tar.gz ${HUGO_URL}
	tar -xvf hugo.tar.gz hugo

clean:
	rm -f hugo hugo.tar.gz
	rm -rf site/public
