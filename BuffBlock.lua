local BB = BB_Globals;
local BB_PlayerName = nil;

function BuffBlock_OnLoad()
    BuffBlockFrame:RegisterEvent("ADDON_LOADED");
   BuffBlockFrame:RegisterUnitEvent("UNIT_AURA", "player");
   BuffBlockFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
   DEFAULT_CHAT_FRAME:AddMessage("Buff Block. /BB for options", 1, 0.75, 0.75);
   SLASH_BB1 = "/BB";
   SlashCmdList["BB"] = BuffBlock_Command;
end;

function BuffBlock_Init()
	local name,_ = UnitName("player");
	local realm = GetRealmName();
    BB_PlayerName = name.." of "..realm;
   
   if (BUFF_CONFIG == nil) then
      BUFF_CONFIG = {};
   end;
   
   if (BUFF_CONFIG[BB_PlayerName] == nil) then
      BUFF_CONFIG[BB_PlayerName] = BB.BB_default;
   end;
end;

function BuffBlock_OnEvent(event, ...)
   if (event == "UNIT_AURA") then
		KillBuffs();
   elseif (event == "ADDON_LOADED") then
		local addonName = ...;
		if (addonName == "BuffBlock") then
			BuffBlock_Init();
		end;
	-- When leaving combat there might be pending blocks so update macro and kill buffs again.
	elseif (event == "PLAYER_REGEN_ENABLED") then
		KillBuffs();
		UpdateBuffBlockMacro();
   end;
end;

function BuffBlock_Command()
   if BuffBlockOptions:IsShown() then
      BuffBlockOptions:Hide();
   else
      BuffBlockOptions:Show();
   end;
end;

function BuffBlock_GetOption(self, buffName)
   local labelString = getglobal(self:GetName().."Text");
   local label = BB.BuffBlockMenuStrings[buffName] or "ERROR";
   
   if BUFF_CONFIG[BB_PlayerName][buffName] or nil then
      self:SetChecked(true);
   else
      self:SetChecked(nil);
   end;
   labelString:SetText(label);
end;

function BuffBlock_SetOption(self, buffName)
   local checked = self:GetChecked();
   if checked then
	  BUFF_CONFIG[BB_PlayerName][buffName] = true;
      DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BB.BuffBlockMenuStrings[buffName], 1, 0.75, 0.75);
   else
      BUFF_CONFIG[BB_PlayerName][buffName] = nil;
      DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BB.BuffBlockMenuStrings[buffName], 1, 0.75, 0.75);
   end;
end;

function IsShieldEquipped()
   local slot = GetInventorySlotInfo("SecondaryHandSlot");
   local link = GetInventoryItemLink("player", slot);
   if link then
      local found, _, id, name = string.find(link, "item:(%d+):.*%[(.*)%]");
      if found then
		local _,_,_,_,_,_,itemType = GetItemInfo(tonumber(id));
		 if(itemType == "Shields") then
			return true;
		 end;
      end;
   end;
   return false;
end

function KillBuff(i, buffName)
	if InCombatLockdown() then
		 DEFAULT_CHAT_FRAME:AddMessage("You must remove "..BB.BuffBlockMenuStrings[buffName], 1, 0.5, 0.5);
	else
		CancelUnitBuff("player", i-1);
		DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BB.BuffBlockMenuStrings[buffName], 1, 0.75, 0.5);
	end;
end;

function KillBuffs()
   local i = 1;
   local buff = UnitBuff("player", i, "HELPFUL");
   while buff do
      local buffName = select(1, buff);
      local buffKey = buffName:gsub("%s+", "");
      if BUFF_CONFIG[BB_PlayerName][buffKey] then
		if (buffKey == "GreaterBlessingOfSalvation" or buffKey == "BlessingOfSalvation") then
			local _, active, _, _, _ = GetShapeshiftFormInfo(2);
			if not (IsShieldEquipped() and active) then
				KillBuff(i, buffName);
			end;
		else
			KillBuff(i, buffName);
		end;
      end;
      i = i + 1;
      buff = UnitBuff("player", i, "HELPFUL");
   end;
end;

-- Updates the BuffBlock macro according to the current config settings
-- If the macro does not exist, it is created.
-- Note: If outside of combat, it will not update/create macro
function UpdateBuffBlockMacro()
	if InCombatLockdown() then
		return 0;
	end;
	
	local newMacroBody = "";
	for k,v in BUFF_CONFIG[BB_PlayerName] do
		if v then
			if (string.len(newMacroBody) > 0) then
				newMacroBody = newMacroBody.."\n/cancelaura"..BB.BuffBlockMenuStrings[k];
			else
				newMacroBody = "/cancelaura "..BB.BuffBlockMenuStrings[k];
			end;
		end;
	end;
	
	local macroId = 0;
	if GetMacroIndexByName(BuffBlockMacroName) == 0 then
		--Macro does not exist, create it
		macroId = CreateMacro(BuffBlockMacroName, BuffBlockIconName, newMacroBody, 1);
		print("Created macro at index: "..tostring(macroId));
	else
		--Update existing macro
		macroId = EditMacro(BuffBlockMacroName, nil, nil, newMacroBody, 1, 1);
		print("Updated macro at index: "..tostring(macroId));
	end;
	
	return macroId;
end;

-- Places the BuffBlock macro at the cursor
function PickupBuffBlockMacro()
	if InCombatLockdown() then
		PickupMacro(BuffBlockMacroName);
	end;
end;
	
	
