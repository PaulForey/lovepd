LovePD
======

### Description ###

A (slow) project attempting to combine the lua/sdl-based Love2D game engine with libpd (Pure Data) running the sounds.

The to do list looks something like:
 - I now have to make Love2D able to used lovepd.lua and the subsequent luapd_wrapper C code. This is tricky since Love2D's lua engine complains if you tell it to dynamically load a C library. It looks like I have to compile it into Love2D itself. I'm currently working on being able to compile Love2D on Mac OS X but I think I need to update my SDK, and therefore my XCode and my entire freakin' operating system. Sigh.
 - Make a tiny prototype to show off some features.
 - WINDOWS TO DOs:
    - Work out how to compile luapd_wrapper.dll so that it's dependencies are static, not dynamic.
    - Work out how to get audio from Pure Data to the user. Currently looking at PortAudio.
        - What will that mean for other, normal Love2D sounds? I feel like I should be able to support them.

The to done list:
 - Finish luapd wrapper for libpd == luapd_wrapper.so
 - Make a nice lua file (lovepd.lua) for the Love2D engine to interface with libpd == lovepd.lua
 - WINDOWS:
    - Pure Data is crunching numbers! The DLL is being loaded and is doing it's job.

I'll see how I get on.
