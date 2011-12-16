XCFLAGS+=-Isdb/src
LDFLAGS+=-fPIC 

LIB=modules/sdb/init.luvit

all: sdb/src/sdb
	mkdir -p modules/sdb
	echo ${LDFLAGS}
	${CC} ${XCFLAGS} ${CFLAGS} ${LDFLAGS} -o ${LIB} sdb.c

sdb/src/sdb:
	-[ ! -d sdb ] && hg clone http://hg.youterm.com/sdb
	cd sdb/src ; ${MAKE} CC="${CC}"

clean:
	-[ -d sdb ] && { cd sdb ; ${MAKE} clean ; }
	rm -f sdb.luvit test.sdb test.sdb.lock

mrproper: clean
	rm -rf sdb modules
