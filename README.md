# wAVE
wAVE was an attempt at making new tech for the ROBLOX group WIJ. It failed. If you're at all interested in what we attempted to accomplish, the code is opensource.

The contributors were tomspell, Conmmander, and seliso (in order of contribution)

# Practices Notes

One of my main goals is to add some abstraction to event handling, like using the Input module inside util for UserInput handling, rather than writing the low level code yourself each time

Component Generation VSC Snippet
```json
	"tcs": {
		"prefix": [
			"tcs, component_tcs",
			"component"
		],
		"body": [
			"local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
			"",
			"local tcs = require(ReplicatedStorage:WaitForChild(\"Shared\"):WaitForChild(\"tcs\"))",
			"",
			"type Cleaner_T = {",
			"\tAdd: (Cleaner_T, any) -> (),",
			"\tClean: (Cleaner_T) -> ()",
			"}",
			"",
			"type Courier_T = {",
			"\tListen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},",
			"\tSend: (Courier_T, Port: string, ...any) -> ()",
			"}",
			"",
			"type ${0:$TM_FILENAME_BASE}_T = {",
			"\t__index: ${0:$TM_FILENAME_BASE}_T,",
			"\tName: string,",
			"\tTag: string,",
			"",
			"\tCleaner: Cleaner_T,",
			"\tCourier: Courier_T",
			"}",
			"",
			"local ${0:$TM_FILENAME_BASE}: ${0:$TM_FILENAME_BASE}_T = {}",
			"${0:$TM_FILENAME_BASE}.__index = ${0:$TM_FILENAME_BASE}",
			"${0:$TM_FILENAME_BASE}.Name = \"${0:$TM_FILENAME_BASE}\"",
			"${0:$TM_FILENAME_BASE}.Tag = \"${0:$TM_FILENAME_BASE}\"",
			"${0:$TM_FILENAME_BASE}.Ancestor = game",
			"",
			"function ${0:$TM_FILENAME_BASE}.new(root: any)",
			"\treturn setmetatable({",
			"\t\tRoot = root,",
			"\t}, ${0:$TM_FILENAME_BASE})",
			"end",
			"",
			"function ${0:$TM_FILENAME_BASE}:Start()",
			"",
			"end",
			"",
			"function ${0:$TM_FILENAME_BASE}:Destroy()",
			"\tself.Cleaner:Clean()",
			"end",
			"",
			"tcs.create_component(${0:$TM_FILENAME_BASE})",
			"",
			"return ${0:$TM_FILENAME_BASE}"
		]
	}
```