local inInstance = false;
local startTime = 0;

function InstanceProfits_EventHandler(self, event, ...)
  if (event == "ZONE_CHANGED_NEW_AREA") then
  	local name, type, difficulty, difficultyName = GetInstanceInfo();
  	if (type == "raid" || type == "party") then
  		inInstance = true;
  		startTime = time();
  		print("You have entered the " .. difficultyName .. " version of " .. name);
  	elseif inInstance then
  		inInstance = false;
  		local totalTime = difftime(time(), startTime);
  		print("You have exited your instance after spending " .. totalTime .. " seconds inside.");
  end
end