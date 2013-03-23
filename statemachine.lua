module(..., package.seeall)

StateMachine = {
  activeState = nil,
  previousState = nil,
  age = 0,
  states = {}
}

function StateMachine:new(o)
  o = o or {}
  setmetatable(o, StateMachine)
end

function new(o)
  return StateMachine:new()
end

function StateMachine:reactTo(event)
  if event.type == 'time' then
    self.age = self.age + event.timeDelta
  end

  for transitionIndex = 1, #self.activeState.transitions do
    local transition = self.activeState.transitions[transitionIndex]
    
    if (transition.trigger == nil or transition.trigger == event.type) and
       (transition.guard == nil or transition.guard(self, event)) then

      if transition.effect then
        transition.effect(event)
      end

      if transition.destination and self.states[transition.destination] then
        self.previousState = self.activeState
        self.activeState = self.states[transition.destination]
        self.age = 0
        return
      end
    end
  end
end
