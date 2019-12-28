local BB = BB_Globals;
local BB_PlayerName = nil;

function BuffBlock_OnLoad()
    BuffBlockFrame:RegisterEvent("ADDON_LOADED");
   BuffBlockFrame:RegisterUnitEvent("UNIT_AURA", "player");
   BuffBlockFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
   DEFAULT_CHAT_FRAME:AddMessage("Buff Block. /BB for options", 0.35, 0.75, 0.75);
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
	-- When leaving combat there might be pending changes so run them
	elseif (event == "PLAYER_REGEN_ENABLED") then
		KillBuffs();
		BuffBlock_SaveSettings();
   end;
end;

function BuffBlock_Command()
   if BuffBlockOptions:IsShown() then
      BuffBlockOptions:Hide();
   else
      BuffBlockOptions:Show();
   end;
end;

function BuffBlock_SaveSettings()
	local macroName = getglobal("MacroNameEditBox"):GetText();
	BUFF_CONFIG[BB_PlayerName].MacroName = macroName;
	local prependMacroBody = getglobal("MacroBodyEditBox"):GetText();
	UpdateBuffBlockMacro(prependMacroBody);
end;

function BuffBlock_GetMacroName(self)
	local macroName = BUFF_CONFIG[BB_PlayerName].MacroName or "ERROR";
	self:SetText(macroName);
end;

function BuffBlock_GetMacroIcon(self)
	local macroName = BUFF_CONFIG[BB_PlayerName].MacroName;
	_, iconTexture, _, _ = GetMacroInfo(macroName);
	if iconTexture then
		-- Set icon texture some way
	end
end;

function BuffBlock_GetMacroBody(self)
	local macroName = BUFF_CONFIG[BB_PlayerName].MacroName;
	_, _, macroBody, _ = GetMacroInfo(macroName);
	if macroBody then
		self:SetText(filterCancelAuraCommands(macroBody));
	end
end;

function BuffBlock_GetBuffOption(self, buffName)
   local labelString = getglobal(self:GetName().."Text");
   local buffKey = formatBuffName(buffName);
   local label = BB.BuffBlockMenuStrings[buffKey] or "ERROR";
   
   if BUFF_CONFIG[BB_PlayerName].Buffs[buffKey] or nil then
      self:SetChecked(true);
   else
      self:SetChecked(nil);
   end;
   labelString:SetText(label);
end;

function filterCancelAuraCommands(macroBody)
	local res = macroBody:gsub("/cancelaura[%s]+[%a%d%s\\(\\)]+", "");
	return res;
end;

function formatBuffName(buffName)
	return buffName:gsub("%s", ""):lower();
end;

function BuffBlock_SetBuffOption(self, buffName)
   local checked = self:GetChecked();
	buffKey = formatBuffName(buffName);
   if checked then
	  BUFF_CONFIG[BB_PlayerName].Buffs[buffKey] = true;
      DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BB.BuffBlockMenuStrings[buffKey], 0.35, 0.75, 0.75);
   else
      BUFF_CONFIG[BB_PlayerName].Buffs[buffKey] = nil;
      DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BB.BuffBlockMenuStrings[buffKey], 0.35, 0.75, 0.75);
   end;
end;

function KillBuff(i, buffName)
	buffKey = formatBuffName(buffName);
	if InCombatLockdown() then
		 DEFAULT_CHAT_FRAME:AddMessage("You must remove "..BB.BuffBlockMenuStrings[buffKey], 1, 0.25, 0.25);
	else
		CancelUnitBuff("player", i);
		DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BB.BuffBlockMenuStrings[buffKey], 0.75, 0.25, 0.25);
	end;
end;

function KillBuffs()
   local i = 1;
   local buff = UnitBuff("player", i, "HELPFUL");
   while buff do
      local buffName = select(1, buff);
      local buffKey = formatBuffName(buffName);
      if BUFF_CONFIG[BB_PlayerName].Buffs[buffKey] then
		if (buffKey == "greaterblessingofsalvation" or buffKey == "blessingofsalvation") then
			local _, active, _, _, _ = GetShapeshiftFormInfo(2);
			if (active) then
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
function UpdateBuffBlockMacro(prependMacroBody)
	if InCombatLockdown() then
		return 0;
	end;
	
	local newMacroBody = prependMacroBody;
	for k,v in pairs(BUFF_CONFIG[BB_PlayerName].Buffs) do
		if v then
			if (string.len(newMacroBody) > 0) then
				newMacroBody = newMacroBody.."\n/cancelaura "..BB.BuffBlockMenuStrings[k];
			else
				newMacroBody = "/cancelaura "..BB.BuffBlockMenuStrings[k];
			end;
		end;
	end;
	
	local macroId = 0;
	local macroName = BUFF_CONFIG[BB_PlayerName].MacroName;
	local iconName = BUFF_CONFIG[BB_PlayerName].IconName;
	if GetMacroIndexByName(macroName) == 0 then
		--Macro does not exist, create it
		macroId = CreateMacro(macroName, iconName, newMacroBody, 1);
	else
		--Update existing macro
		macroId = EditMacro(macroName, nil, nil, newMacroBody, 1, 1);
	end;
	
	return macroId;
end;

-- Places the BuffBlock macro at the cursor
function PickupBuffBlockMacro()
	if not InCombatLockdown() then
		BuffBlock_SaveSettings();
		PickupMacro(BUFF_CONFIG[BB_PlayerName].MacroName);
	end;
end;
	
	
