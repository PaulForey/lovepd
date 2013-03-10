require "luapd"
--require "love.sound"

lovepd = {}

function lovepd:init (filename, dirname)
	self.filename = filename
	self.dirname = dirname
    print("luapd_init() ...")
	luapd_init()
    print("luapd_init() success")

    print("luapd_openfile() ...")
    if luapd_openfile(self.filename, self.dirname) == -1 then
        print("Cannot open Pure Data file!")
    else
        print("luapd_openfile() success")
    end

    print("luapd_init_audio() ...")
	if luapd_init_audio() == -1 then
        print("luapd_init_audio() failure!")
    else
        print("luapd_init_audio() success")
    end

	-- Tell pd to start audio:
	luapd_start_message(1)
	luapd_add_float(1)
	luapd_finish_message("pd", "dsp")
	
end

function lovepd:send_message(...)
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

function lovepd:finish()
    luapd_halt_audio();
end
