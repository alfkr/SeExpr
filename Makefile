-include Makefile.config

FLAVOR ?= optimize
prefix ?= $(shell pf-makevar --absolute root)
libdir ?= $(shell pf-makevar lib)

# TODO: when RHEL6 is fully retired remove th
# Don't set CXX when native GCC version is 4.8.
#SETCXX := $(shell expr `gcc -dumpversion` \< 4.8)
#ifeq "$(SETCXX)" "1"
#    CXX=/opt/rh/devtoolset-2/root/usr/bin/g++
#endif


## Temporary staging directory
# DESTDIR =

# Specified by `git make-pkg` when building .pkg files
# mac_pkg =

export prefix DESTDIR

all:
	mkdir -p build/${FLAVOR}
	export CXX=${CXX}
	cd build/${FLAVOR} &&  CXX=${CXX} cmake -DCMAKE_INSTALL_PREFIX=$(prefix) -DCMAKE_INSTALL_LIBDIR=$(libdir) ${EXTRA_CMAKE_ARGS}  ../../
	$(MAKE) -C build/${FLAVOR} all
clean:
	rm -rf build/${FLAVOR} Linux-*

install: all
	$(MAKE) -C build/${FLAVOR} install
	pkgconfig-gen --name seexpr2 --desc 'SeExpr v2 Library' \
	--generate --destdir '$(DESTDIR)' --prefix $(prefix) --libdir $(libdir)

test: install
	python src/tests/imageTestsReportNew.py runall

format:
	find $(CURDIR)/src -name '*.cpp' | xargs clang-format -i
	find $(CURDIR)/src -name '*.h' | xargs clang-format -i

basictest: install
	$(prefix)/share/test/SeExpr2/testmain2 -- --gtest_filter="BasicTests.*"

precommit: format
