local __ = require "underscore"
require "events"
local cause = events.cause
module(..., package.seeall)

local function quickExit(key)
  if key == 'escape' then
    love.event.push('quit')
  end
end

local function equals(value)
  return function(x)
    return x == value
  end
end

--[[
  Input methods used in battles; these will emit events in the logical domain
  for battles, e.g. jump or smash.
]]

local buttonState = {
  tiltDirections = {},
  hardnessModifier = 'tilt',
  attackType = 'attack'
}

local tilt = {}
tilt.directions = {
  w = 'up',
  a = 'left',
  s = 'down',
  d = 'right'
}

local hardness = {}
hardness.down = {lshift = 'smash'}
hardness.up = {lshift = 'tilt'}

local attackType = {}
attackType.down = {lctrl = 'special'}
attackType.up = {lctrl = 'attack'}

local movement = {}
movement.directions = {
  left = 'left',
  right = 'right',
  down = 'down'
}

battle = {}

function battle.keypressed(key, unicode)
  quickExit(key)
  if tilt.directions[key] then
    buttonState.tiltDirections[#buttonState.tiltDirections + 1] =
        tilt.directions[key]
  end
  if hardness.down[key] then
    buttonState.hardnessModifier = hardness.down[key]
  end
  if attackType.down[key] then
    buttonState.attackType = attackType.down[key]
  end
  if key == ' ' then
    -- A plain attack can't have a hardness modifier, but all directional
    -- attacks do.
    if #buttonState.tiltDirections == 0 then
      cause('input.' .. buttonState.attackType .. '.neutral')
    else
      cause(
          'input.' .. buttonState.attackType .. '.' ..
          buttonState.hardnessModifier .. '.' ..
          buttonState.tiltDirections[#buttonState.tiltDirections])
    end
  end

  if movement.directions[key] then
    if key ~= 'down' then
      cause('input.move.' .. key)
    end
    -- Todo(cromo): Add crouch, drop through platforms, and fast fall cases.
  end

  if key == 'q' then
    cause 'input.shield'
  end
  if key == 'up' then
    cause 'input.jump'
  end
  if key == 'e' then
    cause 'input.grab'
  end
end

function battle.keyreleased(key, unicode)
  buttonState.tiltDirections =
      __.reject(buttonState.tiltDirections, equals(tilt.directions[key]))
  if hardness.down[key] then
    buttonState.hardnessModifier = hardness.up[key]
  end
  if attackType.down[key] then
    buttonState.attackType = attackType.up[key]
  end

  -- Todo(cromo): Add jump release
end