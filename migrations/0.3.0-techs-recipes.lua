local check = function(force, techname)
  if force.technologies[techname] ~= nil and force.technologies[techname].researched then
    force.technologies[techname].researched = false
    force.technologies[techname].researched = true
  end
end

for i, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()
  check(force, 'smr-tech1')
  check(force, 'smr-tech2')
  check(force, 'smr-tech3')
end