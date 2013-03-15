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
  return StateMachine:new(0)
end

function StateMachine:reactTo(event)
  if event.type == 'time' then
    self.age = self.age + event.timeDelta
  end

  for key, edge in pairs(self.activeState.edges) do
    
    if (edge.trigger == nil or edge.trigger == event.type) and
       (edge.guard == nil or edge.guard(self, event)) then

      print("Got this far...")
      print(edge.destination)

      if edge.effect then
        edge.effect(event)
      end

      if edge.destination and self.states[edge.destination] then
        self.previousState = self.activeState
        self.activeState = self.states[edge.destination]
        self.age = 0
        print("State Changed!")
        return
      end
    end
  end
end
