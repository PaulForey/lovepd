require "debug"
HC = require "hardoncollider"
require "Explosion"
require "Missile"
--require "luapd_wrapper"
require "lovepd"

function love.load()
    print("The start of my shit!")
	-- Init the hardoncollider library:
	Collider = HC(100, onCollision, onCollisionStop)

	-- Create the table I'm going to use to store the graphics (sprites really)
	graphics = {}
    
    fps = 0

	-- Some graphics set up:
	love.graphics.setBackgroundColor(0,0,0)

    --[[
    samplerate = 44100
    blocksize = 64
    inputchannels = 0
    outputchannels = 2
    --]]
    print("initing lovepd")
    lovepd:init("lua-test.pd", "./")
    print("lovepd initted")
	--lovepd:printhook(print) PRINTHOOK don't exist yet!

    lovepd:send_message("lua-test-2-start", "float", 8)

    --[[
	for i=0,10*lovepd.samplerate/lovepd.blocksize do
        lovepd:process_block()
	end

	for i,v in ipairs(lovepd:get_output_buffer()) do print(i, v) end
    --]]

end

function love.mousepressed(x, y, button)
	if button == 'l' then
		-- Create a Missile in the graphics table:
		table.insert(graphics, Missile.create(love.graphics.getWidth()/2,
									love.graphics.getHeight()-50, x, y))
        --print("Missile spawned!")
	end
end

function love.keypressed(key)
	if key == "p" then
		for i, v in ipairs(graphics) do print(i, v) end
	end

	for shape in Collider:activeShapes() do
		print(shape)
	end
end

function love.update(dt)
	-- Iterate over and update the explosions list:
	for i, v in ipairs(graphics) do v:update(dt) end

	-- Update hardoncollider:
	Collider:update(dt)

    -- Update Pure Data:
    --lovepd:process_block()
    --[[
    soundData = love.sound.newSoundData(blocksize, samplerate, 16, outputchannels)
    lovepd:process_block()
    for i,v in ipairs(lovepd:get_output_buffer()) do 
        soundData.setSample(i, v)
    end
    source = love.audio.newSource(soundData)
    source:play()
    --]]
    
end

function love.draw()
	-- Iterate over and draw the explosions list:
	for i,v in ipairs(graphics) do v:draw() end
    -- love.graphics.print(lovepd:get_output_buffer()[1], 100, 100)
end

function love.quit()
    lovepd:finish()
end

function onCollision(dt, shapeOne, shapeTwo, mtvX, mtvY)
	-- If an explosion and a missile touch, then explode the missile:
	--print(shapeOne.parent.type, shapeTwo.parent.type)
	if shapeOne.parent.type == "Missile" and
			shapeTwo.parent.type == "Explosion" then
		shapeOne.parent:explode()
		--print("explosion and missile collision!")
	end
end

function onCollisionStop(dt, shapeOne, shapeTwo)
	--print("Collision stopped!")
end




