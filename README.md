# Practices Notes

One of my main goals is to add some abstraction to event handling, like using the Input module inside util for UserInput handling, rather than writing the low level code yourself each time

Component Generation VSC Snippet
```json
"Component": {
		"prefix": [
			"component"
		],
		"body": [
			"local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
			"",
			"local wcs = require(ReplicatedStorage:WaitForChild(\"Shared\"):WaitForChild(\"wcs\"))",
			"",
			"type Cleaner_T = {",
			"\tAdd: (Cleaner_T, any) -> (),",
			"\tClean: (Cleaner_T) -> ()",
			"}",
			"",
			"type ${0:$TM_FILENAME_BASE}_T = {",
			"\t__index: ${0:$TM_FILENAME_BASE}_T",
			"\tName: string",
			"\tTag: string",
			"",
			"\tCleaner: Cleaner_T",
			"}",
			"",
			"local ${0:$TM_FILENAME_BASE}: ${0:$TM_FILENAME_BASE}_T = {}",
			"${0:$TM_FILENAME_BASE}.__index = ${0:$TM_FILENAME_BASE}",
			"${0:$TM_FILENAME_BASE}.Name = \"${0:$TM_FILENAME_BASE}\"",
			"${0:$TM_FILENAME_BASE}.Tag = \"${0:$TM_FILENAME_BASE}\"",
			"${0:$TM_FILENAME_BASE}.Ancestor = game",
			"${0:$TM_FILENAME_BASE}.Needs = {\"Cleaner\"}",
			"",
			"function ${0:$TM_FILENAME_BASE}.new(root: any)",
			"\treturn setmetatable({",
			"\t\tRoot = root,",
			"\t}, ${0:$TM_FILENAME_BASE})",
			"end",
			"",
			"function ${0:$TM_FILENAME_BASE}:CreateDependencies()",
			"\treturn {}",
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
			"wcs.create_component(${0:$TM_FILENAME_BASE})",
			"",
			"return ${0:$TM_FILENAME_BASE}"
		]
	}
```