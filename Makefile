LIB=modules/sdb/sdb.luvit
CFLAGS+=-Isdb/src

all: sdb/src/sdb
	${MAKE} ${LIB}

${LIB}:
	${CC} -shared ${CFLAGS} -o ${LIB} sdb/src/*.o ${LDFLAGS}

sdb/src/sdb:
	-[ ! -d sdb ] && hg clone http://hg.youterm.com/sdb
	cd sdb/src ; CFLAGS=-fPIC ${MAKE} CC="${CC}"

clean:
	-[ -d sdb ] && { cd sdb ; ${MAKE} clean ; }
	rm -f modules/sdb/sdb.luvit test.sdb test.sdb.lock

mrproper: clean
	rm -rf sdb
