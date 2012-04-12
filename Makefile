windows:
	gcc -O2 -c -I./libpd/libpd_wrapper/ -I./libpd/pure-data/src/ -I./lua/ -o luapd_wrapper.o luapd_wrapper.c
	gcc -shared -o luapd_wrapper.dll luapd_wrapper.o ./lua/lua51.dll libpd.dll
macosx:
	gcc -O2 -c -I ./libpd/libpd_wrapper/ -o luapd_wrapper.o luapd_wrapper.c
	gcc -bundle -undefined dynamic_lookup -o luapd_wrapper.so luapd_wrapper.o libpd-osx.a

