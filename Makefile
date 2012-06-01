windows: libpd.dll lua51.dll
	gcc -O2 -c -I./libpd/libpd_wrapper/ -I./libpd/pure-data/src/ -I./lua/ -o luapd_wrapper.o luapd_wrapper.c
	gcc -shared -o luapd_wrapper.dll luapd_wrapper.o libpd.dll lua51.dll
macosx:
	gcc -O2 -c -I./libpd/libpd_wrapper/ -o luapd_wrapper.o luapd_wrapper.c
	gcc -bundle -undefined dynamic_lookup -o luapd_wrapper.so luapd_wrapper.o libpd-osx.a

libpd.dll:
	cd libpd/ && make libs/libpd.dll
	cp libpd/libs/libpd.dll ./

lua51.dll:
	cd lua/ && make mingw MYCFLAGS=-DLUA_DL_DLL
	cp lua/lua51.dll ./

clean:
	rm *.o

superclean:
	rm *.dll
	cd lua/ && rm lua51.dll
	cd libpd/libs/ && rm libpd.dll


