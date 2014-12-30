function InstanceProfits_EventHandler(self, event, ...)
  if (event == "RAID_INSTANCE_WELCOME") then
  	local name, time_left = ...;
  	print("You are entering " .. name .. " and your instance lock will expire in " .. time_left);
  end
  if (event == "PLAYER_LEAVING_WORLD") then
  	print("You are leaving.");
  end
end