require "statemachine"
module(..., package.seeall)

ConsoleWarrior = {}
ConsoleWarrior.states = {}

ConsoleWarrior.states.idle = {
  edges = {
    toJump = {
      trigger = 'input.jump',
      destination = "jump"
    },
  },
  animation = "ConsoleWarrior is idle."
}

ConsoleWarrior.states.jump = {
  edges = {
    toIdle = {
      trigger = "time",
      guard = function(self, event)
        return self.age > 1
      end,
      destination = "idle"
    }
  },
  animation = "ConsoleWarrior is flailing about..."
}

function ConsoleWarrior:draw()
  love.graphics.print(self.activeState.animation, 100, 100)
end

function new()
  o = ConsoleWarrior
  o.activeState = ConsoleWarrior.states.idle
  setmetatable(o, {__index=statemachine.StateMachine})
  return o
end