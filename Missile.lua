-- Create the missile class:
Missile = {}
Missile.__index = Missile
Missile.__tostring = function() return "Missile" end
Missile.type = "Missile"

-- Missile's constructor:
function Missile.create(startx, starty, destx, desty)
	local missile = {}
	setmetatable(missile, Missile)
	missile.x = startx
	missile.y = starty
	missile.destx = destx
	missile.desty = desty
	missile.fillmode = "fill"
	missile.color = {255,10,10}
	missile.width = 3
	missile.height = 10
	missile.speed = 50
	missile.angle = 0
	missile.rect = Collider:addRectangle(missile.x,
									missile.y,
									missile.width,
									missile.height)
	missile.rect.parent = missile

	-- Draw the missile's image to a canvas:
	missile.canvas = love.graphics.newCanvas(missile.width, missile.height)
	love.graphics.setCanvas(missile.canvas)
	love.graphics.setColor(missile.color[1], missile.color[2], missile.color[3])
	love.graphics.rectangle(missile.fillmode, 0, 0,
							missile.width, missile.height)
	love.graphics.setCanvas() -- Resets to normal canvas (the screen)
	return missile
end

-- Middile's desconstructor:
function Missile:remove()
	Collider:remove(self.rect)
	for i, v in ipairs(graphics) do
		if v == self then
			table.remove(graphics, i)
		end
	end
	self = nil
end

-- Missile's explosion function:
function Missile:explode()
	-- Spawn an explosion:
	table.insert(graphics, Explosion.create(self.x, self.y))

	-- Kill self:
	self.remove(self)
end

-- Missile's update function:
function Missile:update(dt)
	local diffx = self.destx - self.x
	local diffy = self.desty - self.y

	self.angle = -((math.atan2(diffx, diffy) + math.pi) * 180/math.pi)

	self.x = self.x + self.speed * math.cos(self.angle) * dt
	self.y = self.y + self.speed * math.sin(self.angle) * dt

	self.rect:moveTo(self.x, self.y)

	if diffx < 4 and diffx > -4 and diffy < 4 and diffx > -4 then
		self.explode(self)
	end

	--print(diffx, diffy)
end

function Missile:draw()
	local radians = self.angle*math.pi/180

	love.graphics.setColorMode("replace")
	love.graphics.draw(self.canvas, self.x, self.y, radians)
	love.graphics.setColorMode("modulate")
end
					



