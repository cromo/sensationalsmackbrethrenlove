local __ = require "underscore"

module(..., package.seeall)

local status = ""
local function cause(eventType)
  status = eventType
end

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
hardness.directions = {
  lshift = 'smash'
}

local attackType = {}
attackType.types = {
  lctrl = 'special'
}

battle = {}

function battle.keypressed(key, unicode)
  quickExit(key)
  if tilt.directions[key] then
    buttonState.tiltDirections[#buttonState.tiltDirections + 1] =
        tilt.directions[key]
  end
  if hardness.directions[key] then
    buttonState.hardnessModifier = hardness.directions[key]
  end
  if attackType.types[key] then
    buttonState.attackType = attackType.types[key]
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
  if key == 'q' then
    cause 'input.shield'
  end
  if key == 'e' then
    cause 'input.jump'
  end
  if key == 'f' then
    cause 'input.grab'
  end
end

function battle.keyreleased(key, unicode)
  buttonState.tiltDirections =
      __.reject(buttonState.tiltDirections, equals(tilt.directions[key]))
  if hardness.directions[key] then
    buttonState.hardnessModifier = 'tilt'
  end
  if attackType.types[key] then
    buttonState.attackType = 'attack'
  end
end

function battle.debug()
  return status .. "\n" ..
      "tilt: {" .. __.join(buttonState.tiltDirections, ",") .. "}\n" ..
      "hardness: " .. buttonState.hardnessModifier .. "\n" ..
      "type: " .. buttonState.attackType
end

debug = battle.debug