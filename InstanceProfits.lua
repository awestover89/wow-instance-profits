local inInstance = false;

function InstanceProfits_EventHandler(self, event, ...)
  if (event == "ZONE_CHANGED_NEW_AREA") then
  	local name, type, difficulty, difficultyName = GetInstanceInfo();
  	if (type == "raid" || type == "party") then
  		inInstance = true;
  		print("You have entered the " .. difficultyName .. " version of " .. name);
  	elseif inInstance then
  		inInstance = false;
  		print("You have exited your instance.")
  end
end