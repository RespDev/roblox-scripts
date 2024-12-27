-- GoodShops Ranking Commands
local GroupService = game:GetService("GroupService")

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	-- Configuration
	local GroupID = 16914160 -- GoodShops
	local AuthKey = "NO TOKEN FOR YOU!"
	local webhookUrl = "HOW COULD YOU WANT THIS"

	local bot
	pcall(function()
		bot = require(game.ReplicatedStorage.RankingBot.bot)
	end)

	if not bot then
		warn("Failed to load RankingBot. Ensure it is in ReplicatedStorage.")
	else
		print("Successfully loaded RankingBot.")
	end

	local SendMessageRemote = game.ReplicatedStorage:WaitForChild("SendMessage")

	server.Commands.Promote = {
		Prefix = server.Settings.Prefix;
		Commands = {"promote"};
		Args = {"username"};
		Description = "Promote a player in the group.";
		Hidden = false;
		Fun = false;
		AdminLevel = "Moderators";
		Function = function(plr, args)
			local target = service.GetPlayers(plr, args[1])[1]
			if not target then
				SendMessageRemote:FireClient(plr, "Player not found.")
				return
			end

			if plr:GetRankInGroup(GroupID) < 14 then
				SendMessageRemote:FireClient(plr, "You must be a Senior Supervisor+ to promote someone!")
				return
			end

			if target == plr then
				SendMessageRemote:FireClient(plr, "You cannot promote yourself.")
				return
			end

			local callerRank = plr:GetRankInGroup(GroupID)
			local targetRank = target:GetRankInGroup(GroupID)

			if targetRank >= callerRank then
				SendMessageRemote:FireClient(plr, "You cannot promote someone with a higher or equal rank.")
				return
			end

			if callerRank <= 15 and targetRank >= 12 then
				SendMessageRemote:FireClient(plr, "You cannot promote this player to Trainee Supervisor or higher.")
				return
			end

			local groupInfo
			local success, err = pcall(function()
				groupInfo = GroupService:GetGroupInfoAsync(GroupID)
			end)

			if not success or not groupInfo then
				SendMessageRemote:FireClient(plr, "Failed to retrieve group info: " .. (err or "Unknown error"))
				return
			end

			-- Find the next rank's ID and name
			local roles = groupInfo.Roles
			local nextRankInfo
			for i, role in ipairs(roles) do
				if role.Rank == targetRank + 1 then
					nextRankInfo = role
					break
				end
			end

			if not nextRankInfo then
				SendMessageRemote:FireClient(plr, "This player cannot be promoted any further!")
				return
			end

			local newRank = nextRankInfo.Rank
			local newRankName = nextRankInfo.Name

			if not bot or not bot.rankRequest then
				SendMessageRemote:FireClient(plr, "Ranking bot is not properly set up.")
				return
			end

			success, err = pcall(function()
				bot:rankRequest(AuthKey, target.UserId, GroupID, newRank)
			end)

			if success then
				SendMessageRemote:FireClient(plr, "Successfully promoted: " .. target.Name .. " to rank " .. newRankName .. ".")

				-- Webhook
				local webhookModule = require(script.WebhookService)
				local req = webhookModule:new()

				req.Author = "Promotion"
				req.Description = target.Name .. " has been promoted to **" .. newRankName .. "** by " .. plr.Name
				req.Color = webhookModule.colors.red
				req.TimeStamp = DateTime.now():ToIsoDate()

				req:sendAuthorEmbed(webhookUrl)
			else
				SendMessageRemote:FireClient(plr, "Error promoting player: " .. err)
			end
		end;
	}

	server.Commands.Demote = {
		Prefix = server.Settings.Prefix;
		Commands = {"demote"};
		Args = {"username"};
		Description = "Demote a player in the group.";
		Hidden = false;
		Fun = false;
		AdminLevel = "Admins";
		Function = function(plr, args)
			local target = service.GetPlayers(plr, args[1])[1]
			if not target then
				SendMessageRemote:FireClient(plr, "Player not found.")
				return
			end

			if plr:GetRankInGroup(GroupID) < 16 then
				SendMessageRemote:FireClient(plr, "You must be a Trainee Manager+ to demote someone!")
				return
			end

			if target == plr then
				SendMessageRemote:FireClient(plr, "You cannot demote yourself.")
				return
			end

			local callerRank = plr:GetRankInGroup(GroupID)
			local targetRank = target:GetRankInGroup(GroupID)

			if targetRank >= callerRank then
				SendMessageRemote:FireClient(plr, "You cannot demote someone with a higher or equal rank.")
				return
			end

			local groupInfo
			local success, err = pcall(function()
				groupInfo = GroupService:GetGroupInfoAsync(GroupID)
			end)

			if not success or not groupInfo then
				SendMessageRemote:FireClient(plr, "Failed to retrieve group info: " .. (err or "Unknown error"))
				return
			end

			-- Find the previous rank's ID and name
			local roles = groupInfo.Roles
			local prevRankInfo
			for i, role in ipairs(roles) do
				if role.Rank == targetRank - 1 then
					prevRankInfo = role
					break
				end
			end

			if not prevRankInfo then
				SendMessageRemote:FireClient(plr, "This player cannot be demoted any further!")
				return
			end

			local newRank = prevRankInfo.Rank
			local newRankName = prevRankInfo.Name

			if not bot or not bot.rankRequest then
				SendMessageRemote:FireClient(plr, "Ranking bot is not properly set up.")
				return
			end

			success, err = pcall(function()
				bot:rankRequest(AuthKey, target.UserId, GroupID, newRank)
			end)

			if success then
				SendMessageRemote:FireClient(plr, "Successfully demoted: " .. target.Name .. " to rank " .. newRankName .. ".")

				-- Webhook
				local webhookModule = require(script.WebhookService)
				local req = webhookModule:new()

				req.Author = "Demotion"
				req.Description = target.Name .. " has been demoted to **" .. newRankName .. "** by " .. plr.Name
				req.Color = webhookModule.colors.red
				req.TimeStamp = DateTime.now():ToIsoDate()

				req:sendAuthorEmbed(webhookUrl)
			else
				SendMessageRemote:FireClient(plr, "Error demoting player: " .. err)
			end
		end;
	}
end
