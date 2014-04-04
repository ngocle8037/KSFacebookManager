# File:         Makefile
# Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change:  05-Apr-2014.

COCOAPODS = pod
GIT = git
UPDATESUBMODULE = submodule update --recursive

all: install

# install
install:
	$(COCOAPODS) install; $(GIT) $(UPDATESUBMODULE) --init

# update
update: pod git

pod:
	$(COCOAPODS) update

git:
	$(GIT) $(UPDATESUBMODULE)

clean:

purge:

