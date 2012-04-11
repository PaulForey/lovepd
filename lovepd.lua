require("luapd_wrapper")

lovepd = {}

function lovepd:init (filename, dirname, samplerate,
			blocksize, inputchannels, outputchannels)
	self.filename = filename
	self.dirname = dirname
	self.samplerate = samplerate
	self.blocksize = blocksize
	self.inputchannels = inputchannels
	self.outputchannels = outputchannels
	luapd_init()
	luapd_init_audio(self.inputchannels, self.outputchannels,
											self.samplerate)

	-- Open a pd patch:
	if luapd_openfile(self.filename, self.dirname) == -1 then
		error("Cannot open Pure Data file!")
	end

	-- Tell pd to start audio:
	luapd_start_message(1)
	luapd_add_float(1)
	luapd_finish_message("pd", "dsp")
	
	-- Set up the buffers:
	self.inbuf = {}
	self.outbuf = {}
	for i = 1,self.blocksize*self.inputchannels do
		table.insert(self.inbuf, 0)
	end
	for i = 1,self.blocksize*self.outputchannels do
		table.insert(self.outbuf, 0)
	end
end

function lovepd:process_block ()
	luapd_process_float(1, self.inbuf, self.outbuf)
	--for i,v in ipairs(outbuf) do print(i, v) end
end

function lovepd:get_output_buffer ()
	return self.outbuf
end

-- The following function needs to have some polymorphism.
-- Need to look that up.
-- RESULT: we do it with passing a table. Look up "default values".
--[[
function luapd_send_message(arg)
--]]

lovepd:init("lua-test.pd", "./", 44100, 64, 0, 2)

--lovepd_printhook(print)

for i=0,10*lovepd.samplerate/lovepd.blocksize do
	lovepd:process_block()
end

--for i,v in ipairs(lovepd_get_output_buffer()) do print(i, v) end

