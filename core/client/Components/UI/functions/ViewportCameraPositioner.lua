return function(camera: Camera, frame: ViewportFrame, model: Model)
    local cf, size = model:GetBoundingBox()
    
    local rot = CFrame.Angles(math.rad(0), math.rad(-90), 0)
    
    size = rot:VectorToObjectSpace(size)
    local sizeX, sizeY, sizeZ = math.abs(size.X), math.abs(size.Y), math.abs(size.Z)
    
    -- local frameSize = 800
    
    local h = (sizeY / (math.tan(math.rad(camera.FieldOfView / 2)) * 2)) + (sizeZ / 1.8)
    
    -- local frameX = (sizeX > sizeY and frameSize or (frameSize * (sizeX / sizeY)))
    -- local frameY = (sizeY > sizeX and frameSize or (frameSize * (sizeY / sizeX)))
    
    -- frame.Size = UDim2.new(0, frameX, 0, frameY)
    
    return cf * rot * CFrame.new(0, 0, h)
end