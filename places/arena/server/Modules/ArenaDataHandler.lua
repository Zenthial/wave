local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")

type ArenaDataHandler_T = {
    Map: MemoryStoreSortedMap
}
local ArenaDataHandler: ArenaDataHandler_T = {}

function ArenaDataHandler:Start()
    self.Map = MemoryStoreService:GetSortedMap(game.PrivateServerId)
end

-- returns a dictionary with red and blue keys, which contain userid lists
function ArenaDataHandler:GetTeams(): {["Red"]: {number}, ["Blue"]: {number}}
    return nil --self.Map:GetAsync("Teams")
end

return ArenaDataHandler