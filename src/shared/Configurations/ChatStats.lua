local module = {	
	Lines 						= 50,                        -- Maximum lines of chat in the window at any time
	TagColor					= Color3.fromRGB(170, 170, 255), -- Color of specialized tag
	NameBuffer 					= 2,                         -- Distance between tag label and name label
	TextBuffer 					= 10,                        -- Distance between name label and text label
	TextSize					= "Size18",                  -- Default text size
	SpaceSize					= 2,                         -- size of one space; 2 = two spaces
	TweenTime					= 0.5,                       -- Time to tween chat line
	DefaultChatText				= [[PRESS %s TO CHAT]],      -- Text displayed when not focused on text box (fred you forgot add the regex)
	DefaultChatTextFadeInTime	= 0.01,                      -- Time it takes for default chat text to fade in
	TeamChatSign				= "[TEAM]",                  -- String placed after name when a message is in teamchat
	MinimumMessageSize			= 1,                         -- Minimum message size to send message; if message isn't long enough, unfocus text box
	TeamColors					= {                          -- Name tag color based on teamcolor (New colors need to be manually supported here, wtf)
		
                                    -- Training/Roleplay chat colors
                                    ["Royal purple"]        = {["Text"] = Color3.fromRGB(98, 37, 209), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Bright violet"]       = {["Text"] = Color3.fromRGB(98, 37, 209), ["Stroke"] = Color3.fromRGB(0, 0, 0)},

                                    ["Medium stone grey"]   = {["Text"] = Color3.fromRGB(163, 162, 165), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Institutional white"] = {["Text"] = Color3.fromRGB(225, 255, 255), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Gold"]                = {["Text"] = Color3.fromRGB(239, 184, 56), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Alder"]               = {["Text"] = Color3.fromRGB(180, 128, 255), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Quill grey"]    = {["Text"] = Color3.fromRGB(223, 223, 222), ["Stroke"] = Color3.fromRGB(255, 255, 255)},
                                    ["Black"] = {["Text"] = Color3.fromRGB(0, 0, 0), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                            
                                    -- STA chat colors
                                    ["Medium blue"] = {["Text"] = Color3.fromRGB(110, 153, 202), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                            
                                    -- Common chat colors
                                    ["Bright blue"] = {["Text"] = Color3.fromRGB(0, 170, 255), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Sand blue"] = {["Text"] = Color3.fromRGB(85, 170, 255), ["Stroke"] = Color3.fromRGB(0, 0, 0)},

                                    ["Bright green"] = {["Text"] = Color3.fromRGB(85, 170, 127), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Bright red"] = {["Text"] = Color3.fromRGB(223, 100, 89), ["Stroke"] = Color3.fromRGB(0, 0, 0)},
                                    ["Dusty Rose"] = {["Text"] = Color3.fromRGB(223, 100, 0), ["Stroke"] = Color3.fromRGB(0, 0, 0)},

                                    ["Default"] = {["Text"] = Color3.fromRGB(225, 255, 255), ["Stroke"] = Color3.fromRGB(255, 255, 255)},
								},
	TagDivider					= { -- Text put before & after tag
									Left = "[",
									Right = "]"
								},
	TitleTags 					= { -- Title Tags associated with name/UserIDs
									["FLEET COMMANDER"] = { 7448176 },
--									["CONSUL GENERAL"] = { 9345226 },
--									["COMMUNITY OVERSEER"] = { 91009423 }
	
								},
	NameTags					= { -- Tags associated with name/UserIDs
									["DEV"] = { 9345226, 15538276 }, -- tom enes
									["HONOURABLE CHAIRMAN"] = { 10782492 },
									["ARENA CHAMPION"] = { 50155649 },
									["BUNS"] = { 33858640 },
									--["ACADEMY HEAD"] = { 13202550 },
									["WSB"] = { 33858640, 4032604,
										 --Beta
										41874170, 17573219, 29075228, 3394637, 57939164, 
										 --Gamma
										37414739, 91009423, 26330685, 23109, 19237074, 30061855, 20355864, 14892318,
										 --Delta
										80959153, 397559141, 47582621, 75050392, 38388377, 56161014, 
										 --Alpha
										35823079, 107369619, 30726228, 34389982, 9080555, 40508460, 58563341,
										
                                        -- WSB 2020 Winners (Y14[S])
                                        105539056, 1680299, 6287475, 1099480079, 18743306, 30957837, 360872878, 32675186, 41874170, 7466254,
                                        
                                        -- WSB 2020 Winners (L95)
                                        24483832, 558330419, 80959153, 22467056, 11169325, 50817505, 19403259, 52824724, 25677659, 26217681, 76331902, 28611859,
                                        
                                        -- WSB 2020 Winners (X11)	
                                        13202550, 180146549, 4241048, 38037900, 72613658, 21215398, 43631613, 1173987425, 14553794, 584020049,
                                        
                                        -- WSB 2020 Winners (SUF)
                                        384017, 16103956, 119611893, 75047647, 27092227, 223830619, 34337529,
										},						
									},
	AllyTags                    = { -- Tags associated with allies
									["32087"]  = "MB",
									["333620"] = "RGRM",
									["44565"]  = "FC",
									["14638"]  = "RSF",
									["823736"] = "UWF",
									["4276218"]= "LSE",
								},
	GroupTags 					= { -- Tags associated with groups
									["3758883"] = "ST",
									["5430057"] = "SABLE",
									["5429962"] = "CORUS",
								},
	RankTags					= {
									["196"] = "OFC",
									["199"] = "HICOM",
									["254"] = "MARSHAL",
									["255"] = "CHAIRMAN"
								}
}

return module
