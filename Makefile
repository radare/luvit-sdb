LUVIT_DIR?=/Users/pancake/prg/luvit/luvit/deps/luajit

XCFLAGS+=-I${LUVIT_DIR}/src
XCFLAGS+=-Isdb/src
LDFLAGS+=-shared -fPIC 
LDFLAGS+=${LUVIT_DIR}/src/libluajit.a
LDFLAGS+=sdb/src/libsdb.a
LIB=modules/sdb.luvit

ifeq ($(shell uname -sm | sed -e s,x86_64,i386,),Darwin i386)
CC=gcc -arch i386
endif

all: sdb/src/sdb
	mkdir -p modules
	${CC} ${XCFLAGS} ${CFLAGS} ${LDFLAGS} -o ${LIB} sdb.c

sdb/src/sdb:
	-[ ! -d sdb ] && hg clone http://hg.youterm.com/sdb
	cd sdb/src ; ${MAKE} CC="${CC}"

clean:
	-[ -d sdb ] && { cd sdb ; ${MAKE} clean ; }
	rm -f sdb.luvit test.sdb test.sdb.lock

mrproper: clean
	rm -rf sdb modules
