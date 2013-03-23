--[[
Need this functionality for events to be complete:
- receiving events (via cause)
- queueing events
- dispatching events
- registering reactors
- unregistering reactors
]]

local __ = require "underscore"

module(..., package.seeall)

local events = {}
local subscribers = {}

function cause(eventType, options)
  event = options or {}
  event.type = eventType
  events[#events + 1] = event
end

function notify()
  local eventsToDispatch
  eventsToDispatch, events = events, {}
  for event = 1, #eventsToDispatch do
    for receiver = 1, #subscribers do
      subscribers[receiver]:reactTo(eventsToDispatch[event])
    end
  end
end

-- Subscribe subscriber to receive events. subscriber should have a
-- reactTo(self, event) function in its table.
function subscribe(subscriber)
  if not __(subscribers):include(subscriber) then
    subscribers[#subscribers + 1] = subscriber
  end
end

-- Removes a subscriber from the list of subscribers. It will no longer receive
-- calls to reactTo(self, event).
function unsubscribe(subscriber)
  subscribers = __(subscribers):reject(function(s) return s == subscriber end)
end

t = {}
function t:reactTo(event)
  print(__(event):chain():keys():join(","):value())
end