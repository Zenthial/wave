local CollectionService = game:GetService("CollectionService")
local Tiles = workspace:WaitForChild("FinishedTiles")
local TileChildren = Tiles:GetChildren()
local LeftCorners = workspace:WaitForChild("LeftCornerTiles")
local LeftCornerChildren = LeftCorners:GetChildren()
local RightCorners = workspace:WaitForChild("RightCornerTiles")
local RightCornerChildren = RightCorners:GetChildren()
local EndTiles = workspace:WaitForChild("EndTiles")
local EndChildren = EndTiles:GetChildren()

local MAX_TILES = 10
local MAX_TILE_ITERATIONS = 3
local SAME_TILE_CHANCE = 0.33
local MAX_SAME_TURNS = 2                
local CORNER_CHANCE = 0.25
local RNG = Random.new()

type Tile = Model & {
    Start: Part?,
    End: Part,
}

type DungeonGeneration = {
    Tiles: {Tile},
}

type State = {
    NumTiles: number,
    CurrentTileIterations: number,
    Direction: string, -- Left, Right
    NumInLastDirection: number,
    JustTurned: boolean,
    MustGoStraight: boolean
}

local DungeonGeneration: DungeonGeneration = {
    Tiles = {},
}

function DungeonGeneration:Start()
    table.clear(self.Tiles)
    local startTile = EndChildren[RNG:NextInteger(1, #EndChildren)]:Clone()

    startTile:PivotTo(CFrame.new(Vector3.new(0, 100, 0)))
    startTile.Parent = workspace
    table.insert(self.Tiles, startTile)

    local state = {
        NumTiles = 1,
        CurrentTileIterations = 0,
        Direction = "Left",
        JustTurned = false,
        NumInLastDirection = 0,
        MustGoStraight = false
    } :: State

    self:HandleTile(startTile, state)
end

local function cleanPart(part: Part)
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
end

function DungeonGeneration:ChooseTile(currentTile: Tile, state: State): Tile
    local newTile: Tile = nil

    local generationChance = RNG:NextNumber()
    if state.CurrentTileIterations < MAX_TILE_ITERATIONS and state.NumTiles > 1 and state.JustTurned == false and generationChance <= SAME_TILE_CHANCE then
        state.CurrentTileIterations += 1
        newTile = Tiles:FindFirstChild(currentTile.Name):Clone()
    elseif state.MustGoStraight == false and state.NumTiles > 1 and state.JustTurned == false and 1 - generationChance <= 1 - CORNER_CHANCE then
        state.CurrentTileIterations = 1
        state.JustTurned = true
        if state.NumInLastDirection > MAX_SAME_TURNS then
            state.NumInLastDirection = 0
            state.Direction = if state.Direction == "Left" then "Right" else "Left"
        else
            local randomChance = RNG:NextNumber()
            if randomChance <= .5 then
                state.Direction = if state.Direction == "Left" then "Right" else "Left"
                state.NumInLastDirection = 0
            end
        end
        if state.Direction == "Left" then
            newTile = LeftCornerChildren[RNG:NextInteger(1, #LeftCornerChildren)]:Clone()
        else
            newTile = RightCornerChildren[RNG:NextInteger(1, #RightCornerChildren)]:Clone()
        end
        state.NumInLastDirection += 1
    else
        state.CurrentTileIterations = 1
        state.JustTurned = false
        newTile = TileChildren[RNG:NextInteger(1, #TileChildren)]:Clone() :: Tile
    end

    return newTile
end

function DungeonGeneration:HandleTile(currentTile: Tile, state: State)
    local endPart = currentTile.End
    cleanPart(endPart)
    if currentTile:FindFirstChild("Start") then
        cleanPart(currentTile.Start)
    end
    
    local newTile = self:ChooseTile(currentTile, state)
    newTile:PivotTo(endPart.CFrame)
    newTile.Parent = workspace

    print(newTile.Name)
    table.insert(self.Tiles, newTile)

    if state.NumTiles < MAX_TILES then
        state.NumTiles += 1
        self:HandleTile(newTile, state)
    else
        for _, thing in self.Tiles do
            for _, part: Part in thing:GetDescendants() do
                if part.Name == "Start" or part.Name == "End" then
                    part.Transparency = 1
                end
            end
        end
    end
end

return DungeonGeneration
