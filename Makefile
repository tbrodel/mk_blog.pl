PREFIX = /usr/local
BINDIR = ${PREFIX}/bin
DATADIR = ${PREFIX}/share

all: 
	@echo "Usage: make [de]install [MAKE_ARGS]"

install:
	install -d -m 0755 templates/ ${DATADIR}/mk_blog.pl/templates/
	install -m 0644 templates/* ${DATADIR}/mk_blog.pl/templates
	install -m 0755 mk_blog.pl ${BINDIR}

deinstall:
	rm -f ${BINDIR}/mk_blog.pl
	rm -rf ${DATADIR}/mk_blog.pl/
