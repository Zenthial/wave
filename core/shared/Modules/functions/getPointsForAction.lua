local pointsArray = {
    ["Assist"]					   = 50,
	["AssistAsKill"]			   = 100,
	["Spotting"]				   = 10,
	["Heal"]					   = 20,
	["Repair"]					   = 20,
	["Close call"]				   = 20,
	["Kill from the grave"]		   = 10,
	["Headshot"]				   = 20,
	["Marksman"]				   = 10,
	["Deployable destroyed"]	   = 50,
	["Captured"]				   = 5,
	["Revenge"]					   = 20,
	["Killingspree"]			   = 10,
	["Kill"]					   = 100,
    ["Vehicle Destroyed"]          = 100,
	["Double kill"]				   = 5,
	["Triple kill"]				   = 10,
	["Quad kill"]				   = 15,
	["Rampage"]					   = 20,
	["Savage"]					   = 25,
	["No mercy"]				   = 30,
	["Easy"]					   = 35,
	["Not even tryin'"]			   = 40,
	["You gotta calm down"]		   = 45,
	["Call the popo"]			   = 50,
	["Bye"]						   = 55,
	["System unavailable"]		   = 60,
	["Mining"]	   				   = 100
}

local killstreakDictionary = {
	"Double kill", "Triple kill", "Quad kill", "Rampage", "Savage", "No mercy", "Easy", "Not even tryin'", "You gotta calm down", "Call the popo", "Bye", "System unavailable"
}

-- this variable states the max amount of seconds that can occur between kills and still result in a kill streak
local TIME_BETWEEN_KILLS = 2

return function(player: Player, action: string, killedPlayer: Player)
	local points = 0
	local pointAwards = {action}
	if os.time() - player:GetAttribute("LastKillTime") <= TIME_BETWEEN_KILLS and action == "Kill" then
		if player:GetAttribute("CurrentKillstreak") == 0 then
			player:SetAttribute("CurrentKillstreak", 1)
		else
			player:SetAttribute("CurrentKillstreak", player:GetAttribute("CurrentKillstreak") + 1)
			local killStreakName = killstreakDictionary[player:GetAttribute("CurrentKillstreak")]
			points += pointsArray[killStreakName]
			table.insert(pointAwards, killStreakName)
		end
	else
		player:SetAttribute("CurrentKillstreak", 0)
	end

	if player:GetAttribute("Health") <= 10 and player:GetAttribute("Shields") <= 5 then
		points += pointsArray["Close call"]
		table.insert(pointAwards, "Close call")
	end

	if player:GetAttribute("Dead") == true then
		points += pointsArray["Kill from the grave"]
		table.insert(pointAwards, "Kill from the grave")
	end
	
	if player:GetAttribute("ActualLastKiller") == killedPlayer.Name then
		points += pointsArray["Revenge"]
		table.insert(pointAwards, "Revenge")
	end

    points += pointsArray[action] or 0

	return points, pointsArray
end