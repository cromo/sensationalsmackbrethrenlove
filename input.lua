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
  hardnessModifier = {},
  attackType = {}
}

local tilt = {}
tilt.keys = {'w', 'a', 's', 'd'}
tilt.directions = {
  w = 'up',
  a = 'left',
  s = 'down',
  d = 'right'
}

local hardness = {}
hardness.keys = {'lshift'}
hardness.directions = {
  lshift = 'smash'
}

local attackType = {}
attackType.keys = {'lctrl'}
attackType.types = {
  lctrl = 'special'
}

battle = {}

function battle.keypressed(key, unicode)
  quickExit(key)
  if __.include(tilt.keys, key) then
    __.unshift(buttonState.tiltDirections, tilt.directions[key])
  elseif __.include(hardness.keys, key) then
    __.unshift(buttonState.hardnessModifier, hardness.directions[key])
  elseif __.include(attackType.keys, key) then
    __.unshift(buttonState.attackType, attackType.types[key])
  elseif key == ' ' then
    -- A plain attack can't have a hardness modifier, but all directional
    -- attacks do.
    if #buttonState.tiltDirections == 0 then
      cause(
          'input.' ..
          (0 < #buttonState.attackType and 'special' or 'attack') .. '.neutral')
    else
      cause(
          'input.' ..
          (0 < #buttonState.attackType and 'special.' or 'attack.') ..
          (0 < #buttonState.hardnessModifier and 'smash.' or 'tilt.') ..
          __.first(buttonState.tiltDirections))
    end
  end
end

function battle.keyreleased(key, unicode)
  buttonState.tiltDirections =
      __.reject(buttonState.tiltDirections, equals(tilt.directions[key]))
  buttonState.hardnessModifier =
      __.reject(buttonState.hardnessModifier, equals(hardness.directions[key]))
  buttonState.attackType =
      __.reject(buttonState.attackType, equals(attackType.types[key]))
end

function battle.debug()
  return status .. "\n" ..
      "tilt: {" .. __.join(buttonState.tiltDirections, ",") .. "}\n" ..
      "hardness: {" .. __.join(buttonState.hardnessModifier, ",") .. "}\n" ..
      "special: {" .. __.join(buttonState.attackType, ",") .. "}"
end

debug = battle.debug