require "luapd_wrapper"
--require "love.sound"

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

function luapd_send_message(...)
	local msglength = #arg
	local receiver = arg[1]
	local selector = arg[2]

	luapd_start_message(msglength)
	for i=msglength,3,-1 do
		if type(arg[i]) == "string" then luapd_add_symbol(arg[i])
		elseif type(arg[i]) == "number" then luapd_add_float(arg[i])
		end
	end
	luapd_finish_message(receiver, selector)
end

lovepd:init("lua-test.pd", "./", 44100, 64, 1, 2)

lovepd:process_block()

for i,v in ipairs(lovepd:get_output_buffer()) do print(i, v) end



