__ = require "underscore"
require "input"
require "events"

function love.load()
  sheet = love.graphics.newImage("test sprite sheet.png")
  frame = love.graphics.newQuad(0, 0, 32, 32, 64, 64)
  age = 0
  width = 32
  height = 32
  frames = {{0, 0}, {1, 0}, {0, 1}, {1, 1}}
end

function love.draw()
  love.graphics.drawq(sheet, frame, 0, 0)
end

function love.update(dt)
  age = age + dt
  local frameOffset = frames[math.ceil(age % #frames)]
  frame:setViewport(frameOffset[1] * width, frameOffset[2] * height, width, height)
  events.cause('time', {timeDelta = dt})
  events.notify()
end

love.keypressed = input.battle.keypressed
love.keyreleased = input.battle.keyreleased