local inInstance = false;
local timeSpent = {};
local instanceName, lootedMoney, vendorMoney, startTime, startRepair;

function InstanceProfits_EventHandler(self, event, ...)
	local lootableItems = {};
	local ignorezones = { [1152]=true, [1330]=true, [1153]=true, [1154]=true, [1158]=true, [1331]=true, [1159]=true, [1160]=true };
	if (event == "ZONE_CHANGED_NEW_AREA") then
		local name, type, difficulty, difficultyName, _, _, _, instanceMapId, _ = GetInstanceInfo();
		if ((type == "raid" or type == "party") and not ignorezones[instanceMapID] and not inInstance) then
			inInstance = true;
			startTime = time();
			instanceName = name;
			startRepair = GetRepairAllCost();
			lootedMoney, vendorMoney = 0, 0;
			print("You have entered the " .. difficultyName .. " version of " .. name);
		elseif inInstance then
			inInstance = false;
			local totalTime = difftime(time(), startTime);
			local n = GetNumSavedInstances();
			for i=1, n do
				local savedName, savedId = GetSavedInstanceInfo(i);
				if (savedName == instanceName) then
					timeSpent[savedId] = {
						['time'] = totalTime,
						['lootedMoney'] = lootedMoney,
						['vendorMoney'] = vendorMoney
					};
				end
			end
			print("You have exited your instance after spending " .. totalTime .. " seconds inside. You earned " .. lootedMoney .. " copper from mobs and " .. vendorMoney .. " copper from looted items that you can vendor.");
		end
	elseif event == "LOOT_OPENED" and inInstance then
		lootableItems = {};
		for i=1, GetNumLootItems() do
			local _, item, quantity = GetLootSlotInfo(i);
			if (quantity ~= 0) then
				lootableItems[item] = quantity;
			else
				for line in item:gmatch("[^\r\n]+") do
					local number = 0;
					local denomination = "";
					for word in line:gmatch("%w+") do
						if tonumber(word) ~= nil then
							number = word;
						else
							denomination = word;
						end
					end
					if denomination == 'gold' then
						lootedMoney = lootedMoney + (number * 100 * 100);
					elseif denomination == 'silver' then
						lootedMoney = lootedMoney + (number * 100);
					elseif denomination == 'copper' then
						lootedMoney = lootedMoney + number;
					end
				end
			end
		end
	elseif event == "LOOT_CLOSED" and inInstance then
		for name, quantity in lootableItems do
			_, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(name);
			vendorMoney = vendorMoney + (vendorPrice * quantity);
		end
	end
end