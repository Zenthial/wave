local Tiles = workspace:WaitForChild("FinishedTiles")
local TileChildren = Tiles:GetChildren()
local Corners = workspace:WaitForChild("CornerTiles")
local CornerChildren = Corners:GetChildren()
local EndTiles = workspace:WaitForChild("EndTiles")
local EndChildren = EndTiles:GetChildren()

local MAX_TILES = 10
local CORNER_CHANCE = 0.5
local RNG = Random.new()

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
    table.clear(self.Tiles)
    local startTile = EndChildren[RNG:NextInteger(1, #EndChildren)]:Clone()

    startTile:PivotTo(CFrame.new(Vector3.new(0, 30, 0)))
    startTile.Parent = workspace
    table.insert(self.Tiles, startTile)

    self.NumTiles = 1
    self:HandleTile(startTile)
end

function DungeonGeneration:HandleTile(currentTile: Tile)
    local endPart = currentTile.End
    
    local newTile = TileChildren[RNG:NextInteger(1, #TileChildren)] :: Tile
    local shouldGenerateCorner = RNG:NextNumber()
    if shouldGenerateCorner <= CORNER_CHANCE then
        newTile = CornerChildren[RNG:NextInteger(1, #CornerChildren)] :: Tile
    end

    newTile = newTile:Clone()
    newTile:PivotTo(endPart.CFrame)
    newTile.Parent = workspace
    print(newTile.Name)
    
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
