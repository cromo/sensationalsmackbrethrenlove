__ = require "underscore"
require "input"
require "events"

function love.draw()
end

function love.update(dt)
  events.cause('time', {timeDelta = dt})
  events.notify()
end

love.keypressed = input.battle.keypressed
love.keyreleased = input.battle.keyreleased