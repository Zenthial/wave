return function(part0, part1, name, C0, C1)
	part0.Anchored = false

	local weld = Instance.new("ManualWeld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Name = name

	if C0 then
		weld.C0 = C0
	else
		weld.C0 = CFrame.new()
	end	

	if C1 then
		weld.C1 = C1
	end
    
    weld.Parent = part0

	return weld
end