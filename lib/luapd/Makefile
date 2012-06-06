windows:
	gcc -O2 -c -I../libpd/libpd_wrapper/ -I../libpd/pure-data/src/ -I../lua/ -I../luapd/ \
		-I../portaudio/include -I./lib/ luapd.c -o luapd.o
	gcc -shared luapd.o lua51.dll libpd.dll libportaudio-2.dll \
		-o luapd.dll
	cp luapd.dll ../../
macosx:
	gcc -O2 -c -I./lib/libpd/libpd_wrapper/ -o luapd.o luapd.c
	gcc -bundle -undefined dynamic_lookup luapd.o libpd-osx.a -o luapd.so

libpd.dll:
	cd ../libpd/ && make ./libs/libpd.a
	cp ../libpd/libs/libpd.dll ./

lua51.dll:
	cd ../lua/ && make mingw MYCFLAGS=-DLUA_DL_DLL
	cp ../lua/lua51.dll ./

clean:
	rm *.o

superclean:
	rm *.dll
	cd ./lib/lua/ && rm lua51.dll
	cd ./lib/libpd/libs/ && rm libpd.dll


