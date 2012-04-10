require("luapd_wrapper")

function lovepd_init (filename, dirname, samplerate,
			blocksize, inputchannels, outputchannels)
	luapd_init()
	samplerate = 44100
	blocksize = 64
	inputchannels = 1
	outputchannels = 2
	luapd_init_audio(inputchannels, outputchannels, samplerate)

	-- Open a pd patch:
	if luapd_openfile(filename, dirname) == 0 then
		error("Cannot open Pure Data file!")
	end

	-- Tell pd to start audio:
	luapd_start_message(1)
	luapd_add_float(1)
	luapd_finish_message("pd", "dsp")
	
	-- Set up the buffers:
	inbuf = {}
	outbuf = {}
	for i = 1,blocksize*inputchannels do
		table.insert(inbuf, 0)
	end
	for i = 1,blocksize*outputchannels do
		table.insert(outbuf, 0)
	end
end

function lovepd_process_block ()
	luapd_process_float(1, inbuf, outbuf)
	--for i,v in ipairs(outbuf) do print(i, v) end
end

function lovepd_get_output_buffer ()
	return outbuf
end

-- The following function needs to have some polymorphism.
-- Need to look that up.
-- RESULT: we do it with passing a table. Look up "default values".

--[[
function luapd_send_message(arg)
--]]

lovepd_init("lua-test.pd", "./", 44100, 64, 0, 2)

lovepd_process_block()

for i,v in ipairs(lovepd_get_output_buffer()) do print(i, v) end
