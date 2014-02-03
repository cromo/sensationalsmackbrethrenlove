__ = require "underscore"
require "input"
require "events"

sheets = {}

local setViewportOf = function(self, quad, metatilePosition)
  quad:setViewport(
      metatilePosition[1] * self.metatileSize[1],
      metatilePosition[2] * self.metatileSize[2],
      self.metatileSize[1], self.metatileSize[2])
end

newSheet = function(name, path, metatileSize)
  if sheets[name] then
    print(string.format(
        "warning: sheet name reused: \"%s\" was originally loaded from \"%s\" will be replaced by \"%s\"",
        name, sheets[name].path, path))
  end
  sheets[name] = {
    name = name,
    path = path,
    image = love.graphics.newImage(path),
    metatileSize = metatileSize,
    setViewportOf = setViewportOf
  }
end

Animation = {}

Animation.frameAt = function(self, t)
  local frameOffset = self.frames[1]
  local cumulativeOffsets = __.reduce(self.frames, {0}, function(memo, frame)
    memo[#memo + 1] = memo[#memo] + frame[3]
    return memo
  end)
  for i, offset in ipairs(cumulativeOffsets) do
    if t % self.length_s < offset then
      frameOffset = self.frames[i - 1]
      break
    end
  end
  sheets[self.sheetName]:setViewportOf(self.frame, frameOffset)
end

Animation.draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.drawq(sheets[self.sheetName].image, self.frame, x, y, r, sx, sy, ox, oy, kx, ky)
end

Animation.update = function(self, dt)
  self.age = self.age + dt
  self:frameAt(self.age)
end

newAnimation = function(sheetName, frames)
  local o = Animation
  o.sheetName = sheetName
  o.frames = frames
  o.length_s = __.reduce(frames, 0, function(memo, frame)
    return memo + frame[3]
  end)
  o.frame = love.graphics.newQuad(
      0, 0, sheets[sheetName].metatileSize[1], sheets[sheetName].metatileSize[2],
      sheets[sheetName].image:getWidth(), sheets[sheetName].image:getHeight())
  o.age = 0
  return o
end

function love.load()
  newSheet("dev.animation", "test sprite sheet.png", {32, 32})
  testAnimation = newAnimation("dev.animation", {{0, 0, 1}, {1, 0, 2}, {0, 1, 0.5}, {1, 1, 0.2}})
end

function love.draw()
  testAnimation:draw(80, 180)
end

function love.update(dt)
  testAnimation:update(dt)
  events.cause('time', {timeDelta = dt})
  events.notify()
end

love.keypressed = input.battle.keypressed
love.keyreleased = input.battle.keyreleased