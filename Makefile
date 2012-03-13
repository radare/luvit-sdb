-include sdb/config.mk
LIB=modules/sdb/sdb.luvit
CFLAGS+=-Isdb/src

all: sdb/src/sdb
	${MAKE} ${LIB}

${LIB}:
	${CC} -shared ${CFLAGS} -o ${LIB} sdb/src/*.o ${LDFLAGS}

sdb/src/sdb: sdb
	cd sdb/src ; CFLAGS=-fPIC ${MAKE} CC="${CC}"

sdb:
	hg clone http://hg.youterm.com/sdb

clean:
	-[ -d sdb ] && { cd sdb ; ${MAKE} clean ; }
	rm -f modules/sdb/sdb.luvit test.sdb test.sdb.lock

lua-sdb.dylib:
	${CC} ${CFLAGS} ${LDFLAGS} -dynamiclib -shared -fPIC lua-sdb.c -llua

dist: sdb
	rm -rf luvit-sdb
	git clone . luvit-sdb
	${MAKE} dist2

dist2:
	rm -rf luvit-sdb-${VERSION}
	mv luvit-sdb luvit-sdb-${VERSION}
	cd luvit-sdb-${VERSION} ; ${MAKE} sdb ; rm -rf .git sdb/.hg
	zip -r luvit-sdb-${VERSION}.zip luvit-sdb-${VERSION}

mrproper: clean
	rm -rf sdb

.PHONY: all clean dist dist2 mrproper
