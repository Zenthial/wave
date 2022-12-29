local Tiles = workspace:WaitForChild("FinishedTiles")
local TileChildren = Tiles:GetChildren()
local EndTiles = workspace:WaitForChild("EndTiles")
local EndChildren = EndTiles:GetChildren()

local MAX_TILES = 3
local shouldFlip = true

type Tile = Model & {
    Start: Part,
    End: Part?,
}

type DungeonGeneration = {
    CurrentTile: Tile,
    NumTiles: number
}

local DungeonGeneration: DungeonGeneration = {
    NumTiles = 0,
    Tiles = {}
}

function DungeonGeneration:Start()
    local startTile = EndChildren[Random.new():NextInteger(1, #EndChildren)]:Clone()

    startTile:PivotTo(CFrame.new(Vector3.new(0, 30, 0)))
    startTile.Parent = workspace
    table.insert(self.Tiles, startTile)

    self.NumTiles += 1
    self:HandleTile(startTile)
end

function DungeonGeneration:HandleTile(currentTile: Tile)
    local endPart = currentTile.End
    
    local newTile = TileChildren[Random.new():NextInteger(1, #TileChildren)]:Clone() :: Tile
    -- if shouldFlip then
    --     newTile:PivotTo(endPart.CFrame * CFrame.Angles(0, math.rad(180), 0))
    --     shouldFlip = false
    -- else
    --     newTile:PivotTo(endPart.CFrame)
    --     shouldFlip = true
    -- end
    newTile:PivotTo(endPart.CFrame * CFrame.Angles(0, math.rad(180), 0))
    newTile.Parent = workspace
    
    table.insert(self.Tiles, newTile)

    self.NumTiles += 1
    if self.NumTiles < MAX_TILES then
        self:HandleTile(newTile)
    else
        for _, thing: Tile in self.Tiles do
            for _, part: Part in thing:GetDescendants() do
                if part.Name == "Start" or part.Name == "End" then
                    part.Transparency = 1
                end
            end
        end
    end
end

return DungeonGeneration
