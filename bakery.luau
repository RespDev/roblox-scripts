-- Import MarcSync with the correct path and initialize it with an example token
local MarcSync = require(game:GetService("ServerScriptService"):WaitForChild("MarcSync")["MarcSyncv1.1"])
local ms = MarcSync.new("TOKEN HERE")

-- Define the tool name you want to give to the player if they have access
local toolName = "SpecialTool"

-- Function to give the tool to the player if they have authorized access
local function giveToolIfAuthorized(player)
	-- Fetch data from the bakeryAccess collection for this player
	local bakeryAccessCollection = ms:getCollection("bakeryAccess")
	local data = bakeryAccessCollection:getEntries({
		["username"] = player.Name
	})[1]

	if data then
		local storedUsername = data:getValue("username")
		local access = data:getValue("access")

		-- Check if the player's username matches and if they have access
		if player.Name == storedUsername and access then
			-- Check if the player already has the tool
			local backpack = player:WaitForChild("Backpack")
			if not backpack:FindFirstChild(toolName) then
				-- Give the player the tool
				local tool = game.ServerStorage:FindFirstChild(toolName):Clone()
				tool.Parent = backpack
			end
		end
	end
end

-- Event listener for when a player joins the game
game.Players.PlayerAdded:Connect(function(player)
	giveToolIfAuthorized(player)
	
	player.CharacterAdded:Connect(function()
		giveToolIfAuthorized(player)
	end)
end)
