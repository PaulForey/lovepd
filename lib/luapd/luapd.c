#include "z_libpd.h"
#include "lua.h"
#include "portaudio.h"
#include <stdio.h>

/*
 * Required functions (in order of z_libpd.h):
 * 	libpd_init
 * 	libpd_openfile
 * 	libpd_init_audio
 * 	libpd_process_float
 * 	libpd_start_message
 * 	libpd_add_float
 * 	libpd_add_symbol
 * 	libpd_finish_message
 * 	libpd_printhook --Tricky, gonna require passing a lua function
 * 										as an argument.
 */

#define IN_CHANNELS 2
#define OUT_CHANNELS 2
#define SAMPLE_RATE 44100
#define BLOCKSIZE 64
#define TICK 1

PaStreamParameters inputParameters, outputParameters;
PaStream *stream;
PaError err;

FILE *pdLogFile;

static void AudioError(PaError err) {
    pdLogFile = fopen("LuaPdLog.txt", "a+");
    if (pdLogFile == NULL) printf("Log file failed to open!");
    fprintf( pdLogFile, "An error occured while using the portaudio stream\n" );
    fprintf( pdLogFile, "Error number: %d\n", err );
    fprintf( pdLogFile, "Error message: %s\n", Pa_GetErrorText( err ) );
    fclose(pdLogFile);
    Pa_Terminate();
}

static int AudioCallback(const void *input,
                                void *output,
                                unsigned long frameCount,
                                const PaStreamCallbackTimeInfo *timeInfo,
                                PaStreamCallbackFlags statusFlags,
                                void *userData) {
	// portaudio input
    /*
    err = Pa_ReadStream(stream, input, BLOCKSIZE * TICK);
    if (err != paNoError) printf("Error reading stream!");
    */

    // libpd process dsp
    libpd_process_float(TICK, (float*)input, (float*)output);

    // portaudio output
    Pa_WriteStream(stream, output, BLOCKSIZE * TICK);
    //if (err != paNoError) {
    //    printf("Error writing stream!");
    //    AudioError(err);
    //    return -1;
    //}

	return 0;
}


static void luapd_print(const char *s) {
    pdLogFile = fopen("LuaPdLog.txt", "a+");
    if (pdLogFile == NULL) printf("Log file failed to open!");
	printf("luapd_print: %s", s);
	fprintf(pdLogFile, "luapd_print: %s", s);
    fclose(pdLogFile);
}

static int luapd_init(lua_State *L) {
    remove("LuaPdLog.txt");
	libpd_printhook = (t_libpd_printhook) luapd_print;
    luapd_print("Print this!\n");
	libpd_init();
	return 0;
}

static int luapd_openfile(lua_State *L) {
	const char *basename = lua_tostring(L, 1);
	const char *dirname = lua_tostring(L, 2);
    luapd_print("Attempting to open file\n");
	lua_pushinteger(L, libpd_openfile(basename, dirname) ? 0 : -1);
    luapd_print("Attempted to open file\n");
	return 1;
}

static int luapd_init_audio(lua_State *L) {
    // PURE DATA
    luapd_print("    initting libpd ...\n");
	libpd_init_audio(IN_CHANNELS, OUT_CHANNELS, SAMPLE_RATE);
    luapd_print("    initting libpd success\n");
 
    // PORTAUDIO
    luapd_print("    initting portaudio ...\n");
    err = Pa_Initialize();
    if( err != paNoError ) {
        AudioError(err);
        lua_pushinteger(L, -1);
        return 1;
    }
    luapd_print("    initting portaudio success\n");
 
	//    INPUT
    inputParameters.device = Pa_GetDefaultInputDevice();
    if (inputParameters.device == paNoDevice) {
        luapd_print("Error: No default input device.\n");
        AudioError(err);
        lua_pushinteger(L, -1);
        return 1;
    }
    inputParameters.channelCount = IN_CHANNELS;
    inputParameters.sampleFormat = paFloat32;
    inputParameters.suggestedLatency = Pa_GetDeviceInfo( inputParameters.device )->defaultLowInputLatency;
    inputParameters.hostApiSpecificStreamInfo = NULL;
 
	//    OUTPUT
    outputParameters.device = Pa_GetDefaultOutputDevice();
    if (outputParameters.device == paNoDevice) {
        luapd_print("Error: No default output device.\n");
        AudioError(err);
        lua_pushinteger(L, -1);
        return 1;
    }
    outputParameters.channelCount = OUT_CHANNELS;
    outputParameters.sampleFormat = paFloat32;
    outputParameters.suggestedLatency = Pa_GetDeviceInfo( outputParameters.device )->defaultLowOutputLatency;
    outputParameters.hostApiSpecificStreamInfo = NULL;
 
    err = Pa_OpenStream( &stream, &inputParameters, &outputParameters, SAMPLE_RATE,
              BLOCKSIZE, paClipOff, AudioCallback, NULL);
    if (err != paNoError) {
        AudioError(err);
        lua_pushinteger(L, -1);
        return 1;
    }
 
    err = Pa_StartStream( stream );
    if (err != paNoError) {
        AudioError(err);
        lua_pushinteger(L, -1);
        return 1;
    }

    // If we've got here, everything should be a-ok.
    lua_pushinteger(L, 0);
	return 1;
}

static int luapd_halt_audio(lua_State *L) {
    Pa_Terminate();
    return 0;
}


static int luapd_start_message(lua_State *L) {
	int max_length = lua_tointeger(L, 1);
	lua_pushinteger(L, libpd_start_message(max_length));
	return 1;
}

static int luapd_add_float(lua_State *L) {
	libpd_add_float((float)lua_tonumber(L, 1));
	return 0;
}

static int luapd_add_symbol(lua_State *L) {
	libpd_add_symbol(lua_tostring(L, 1));
	return 0;
}

static int luapd_finish_message(lua_State *L) {
	const char *receiver = lua_tostring(L, 1);
	const char *selector = lua_tostring(L, 2);
	lua_pushinteger(L, libpd_finish_message(receiver, selector));
	return 1;
}


int luaopen_luapd(lua_State *L) {
	lua_register(L, "luapd_init", luapd_init);
	lua_register(L, "luapd_openfile", luapd_openfile);
	lua_register(L, "luapd_init_audio", luapd_init_audio);
	lua_register(L, "luapd_halt_audio", luapd_halt_audio);
	lua_register(L, "luapd_start_message", luapd_start_message);
	lua_register(L, "luapd_add_float", luapd_add_float);
	lua_register(L, "luapd_add_symbol", luapd_add_symbol);
	lua_register(L, "luapd_finish_message", luapd_finish_message);
}
	
