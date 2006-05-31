LDFLAGS=`xml2-config --libs` -lcrypto
CFLAGS=`xml2-config --cflags` -fPIC -g -Wall -pedantic

all: ssstest

sssrmap.o: sssrmap.c

ssstest: ssstest.o sssrmap.o

python: _sssrmap.i sssrmap.o
	swig -python -noproxy _sssrmap.i
	${CC} ${CFLAGS} -c _sssrmap_wrap.c -I/usr/include/python2.4/
	${LD} ${LDFLAGS} -shared sssrmap.o _sssrmap_wrap.o -o _sssrmap.so

perl: sssrmap.i sssrmap.o
	swig -perl sssrmap.i
	${CC} ${CFLAGS} -c sssrmap.c sssrmap_wrap.c `perl -MExtUtils::Embed -e ccopts`
	${LD} ${LDFLAGS} -shared sssrmap.o sssrmap_wrap.o -o sssrmap.so
clean:
	rm -f *.o ssstest *.so

