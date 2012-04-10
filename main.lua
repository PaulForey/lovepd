HC = require("hardoncollider")
require("Explosion")
require("Missile")

function love.load()
	-- Init the hardoncollider library:
	Collider = HC(100, onCollision, onCollisionStop)

	-- Create the table I'm going to use to store the graphics (sprites really)
	graphics = {}

	-- Some graphics set up:
	love.graphics.setBackgroundColor(0,0,0)
end

function love.mousepressed(x, y, button)
	if button == 'l' then
		-- Create a Missile in the graphics table:
		table.insert(graphics, Missile.create(love.graphics.getWidth()/2,
									love.graphics.getHeight()-50, x, y))
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
end

function love.draw()
	-- Iterate over and draw the explosions list:
	for i, v in ipairs(graphics) do v:draw() end
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


