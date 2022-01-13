local game = remodel.readPlaceFile("behavior_trees.rbxl")

remodel.createDirAll("src/shared/BehaviorTrees")

for _, thing in pairs(game.ServerStorage.BehaviorTrees:GetChildren()) do
    remodel.writeModelFile(thing, "src/shared/BehaviorTrees/"..thing.Name..".rbxmx")
end

-- remodel run load_behavior_trees.lua