__ = require "underscore"
require "input"
require "events"

function love.draw()
  love.graphics.print(input.debug(), 0, 0)
end

love.keypressed = input.battle.keypressed
love.keyreleased = input.battle.keyreleased