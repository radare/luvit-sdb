LIB=modules/sdb/sdb.luvit

CFLAGS+=-I${LUVIT_DIR}/deps/luajit/src
LDFLAGS+=-fPIC

all: sdb/src/sdb
	mkdir -p modules/sdb
	echo "return require './sdb'" > modules/sdb/init.lua
	${CC} -shared -Isdb/src ${CFLAGS} -o ${LIB} sdb.c sdb/src/libsdb.a ${LDFLAGS}

sdb/src/sdb:
	-[ ! -d sdb ] && hg clone http://hg.youterm.com/sdb
	cd sdb/src ; CFLAGS=-fPIC ${MAKE} CC="${CC}"

clean:
	-[ -d sdb ] && { cd sdb ; ${MAKE} clean ; }
	rm -f sdb.luvit test.sdb test.sdb.lock

mrproper: clean
	rm -rf sdb modules
