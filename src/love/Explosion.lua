--Shapes = require("hardoncollider.shapes")
-- Create the explosion class:
Explosion = {}
Explosion.__index = Explosion
Explosion.__tostring = function() return "Explosion" end
Explosion.type = "Explosion"

-- Explosion's constructor:
function Explosion.create(x, y)
	local explosion = {}
	setmetatable(explosion, Explosion)
	explosion.x = x
	explosion.y = y
	explosion.fillmode = "fill"
	explosion.color = {255, 155, 20}
	explosion.radius = 1
	explosion.segments = 50
	explosion.growthrate = 30
	explosion.maxsize = 60
	explosion.circle = Collider:addCircle(explosion.x,
									explosion.y,
									explosion.radius) 
	explosion.circle.parent = explosion
    lovepd:send_message("explosion", "bang")

	return explosion
end

-- Explosion's deconstructor:
function Explosion:remove()
	--print("deleting!")
	Collider:remove(self.circle)
	for i, v in ipairs(graphics) do
		if v == self then
			table.remove(graphics, i)
		end
	end
	self = nil
end

-- Explosion's update function (to be called by love.update):
function Explosion:update(dt)
	-- Increase the circle size:
	self.radius = self.radius + self.growthrate * dt

	-- Remove the old HC shape and a new one:
	Collider:remove(self.circle)
	self.circle = Collider:addCircle(self.x,
									self.y,
									self.radius) 
	self.circle.parent = self

	-- Once at a certain size, delete self (might not work)
	if self.radius >= self.maxsize then
		self.remove(self)
	end
end


-- Explosion's draw function (to be called by love.draw):
function Explosion:draw()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3])
	love.graphics.circle(self.fillmode, self.x, self.y, 
							self.radius, self.segments)
end
