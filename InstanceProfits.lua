local inInstance = false;
local timeSpent = {};
local instanceName, lootedMoney, vendorMoney, startTime, startRepair, savedId;

print("HELLO AT THE TOP OF MY FILE CHANGED");

local frame = CreateFrame("FRAME", "InstanceProfitsFrame");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("LOOT_OPENED");
frame:RegisterEvent("LOOT_CLOSED");
frame:RegisterEvent("PLAYER_LOGOUT");
local function eventHandler(self, event, ...)
 local lootableItems = {};
	local ignorezones = { [1152]=true, [1330]=true, [1153]=true, [1154]=true, [1158]=true, [1331]=true, [1159]=true, [1160]=true };
	if (event == "ZONE_CHANGED_NEW_AREA") then
	print("HELLO WORLD");
		local name, type, difficulty, difficultyName, _, _, _, instanceMapId, _ = GetInstanceInfo();
		if ((type == "raid" or type == "party") and ignorezones[instanceMapId] == nil and not inInstance) then
			inInstance = true;
			startTime = time();
			instanceName = name;
			startRepair = GetRepairAllCost();
			lootedMoney, vendorMoney = 0, 0;
			local n = GetNumSavedInstances();
			for i=1, n do
				local savedName, saveId, resets, difficulty, locked = GetSavedInstanceInfo(i);
				if (savedName == instanceName and locked) then
					savedId = saveId;
					if (timeSpent[savedId] ~= nil) then
						lootedMoney = timeSpent[savedId]['lootedMoney'];
						vendorMoney = timeSpent[savedId]['vendorMoney'];
						startTime = startTime - timeSpent[savedId]['time'];
						startRepair = startRepair - timeSpent[savedId]['repair'];
					end
				end
			end
			print("You have entered the " .. difficultyName .. " version of " .. name);
		elseif inInstance then
			inInstance = false;
			local totalTime = difftime(time(), startTime);
			local endRepair = GetRepairAllCost();
			local n = GetNumSavedInstances();
			if (timeSpent[savedId] == nil) then
				for i=1, n do
					local savedName, saveId = GetSavedInstanceInfo(i);
					if (savedName == instanceName) then
						savedId = saveId;
					end
				end
			end
			if savedId ~= nil then
				timeSpent[savedId] = {
					['name'] = instanceName,
					['time'] = totalTime,
					['lootedMoney'] = lootedMoney,
					['vendorMoney'] = vendorMoney,
					['repair'] = endRepair - startRepair
				};
			end
			print("You have exited your instance after spending " .. totalTime .. " seconds inside. You earned " .. lootedMoney .. " copper from mobs and " .. vendorMoney .. " copper from looted items that you can vendor.");
		end
	elseif event == "LOOT_OPENED" and inInstance then
		print("LOOT OPENED");
		lootableItems = {};
		for i=1, GetNumLootItems() do
			local _, item, quantity = GetLootSlotInfo(i);
			if (quantity ~= 0) then
				lootableItems[item] = quantity;
				print(item);
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
					if denomination == 'Gold' then
						lootedMoney = lootedMoney + (number * 100 * 100);
					elseif denomination == 'Silver' then
						lootedMoney = lootedMoney + (number * 100);
					elseif denomination == 'Copper' then
						lootedMoney = lootedMoney + number;
					end
				end
			end
		end
	elseif event == "LOOT_CLOSED" and inInstance then
		print("LOOT CLOSED");
		for name, quantity in pairs(lootableItems) do
			_, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(name);
			print(name);
			print(quantity);
			print(vendorPrice);
			vendorMoney = vendorMoney + (vendorPrice * quantity);
		end
	elseif event == "ADDON_LOADED" and arg1 == "InstanceProfits" then
	print("ADDON LOADED YEAY!");
		timeSpent = _G["IP_InstanceRunsTable"];
		if timeSpent == nil then
			timeSpent = {};
		end
	elseif event == "PLAYER_LOGOUT" then
		_G["IP_InstanceRunsTable"] = timeSpent;
	end
end
frame:SetScript("OnEvent", eventHandler);

function InstanceProfits_EventHandler(self, event, ...)
	
end
