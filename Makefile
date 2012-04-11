luaExample:
	gcc -O2 -c -I ./libpd/libpd_wrapper/ -o luapd_wrapper.o luapd_wrapper.c
	gcc -bundle -o luapd_wrapper.so luapd_wrapper.o liblua.a libpd-osx.a

