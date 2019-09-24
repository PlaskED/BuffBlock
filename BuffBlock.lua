local BB_PlayerName = nil;
local BB_default = {};
local BuffBlockMenuStrings = {
   ["BattleShout"] = "Battle Shout",
   ["BlessingOfSalvation"] = "Blessing of Salvation",
   ["GreaterBlessingOfSalvation"] = "Greater Blessing of Salvation",
   ["BlessingOfLight"] = "Blessing of Light",
   ["GreaterBlessingOfLight"] = "Greater Blessing of Light",
   ["BlessingOfSanctuary"] = "Blessing of Sanctuary",
   ["GreaterBlessingOfSanctuary"] = "Greater Blessing of Sanctuary",
   ["BlessingOfMight"] = "Blessing of Might",
   ["GreaterBlessingOfMight"] = "Greater Blessing of Might",
   ["Thorns"] = "Thorns",
   ["Bloodthirst"] = "Bloodthirst",
   ["DivineSpirit"] = "Divine Spirit",
   ["PrayerOfSpirit"] = "Prayer of Spirit",
   ["ArcaneIntellect"] = "Arcane Intellect",
   ["ArcaneBrilliance"] = "Arcane Brilliance",
   ["BlessingOfProtection"] = "Blessing of Protection",
   ["AbolishPoison"] = "Abolish Poison",
   ["AbolishDisease"] = "Abolish Disease",
   ["Renew"] = "Renew",
   ["Rejuvenation"] = "Rejuvenation",
   ["Regrowth"] = "Regrowth",
   ["Inspiration"] = "Inspiration",
   ["DivineIntervention"] = "Divine Intervention",
}

function BuffBlock_OnLoad()
   BuffBlockFrame:RegisterUnitEvent("UNIT_AURA", "player");
   BuffBlockFrame:RegisterEvent("ADDON_LOADED");
   DEFAULT_CHAT_FRAME:AddMessage("Buff Block. /BB for options", 1, 1, 0.5);
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
      BUFF_CONFIG[BB_PlayerName] = BB_default;
   end;
end;

function BuffBlock_OnEvent(event, ...)
   if (event == "UNIT_AURA") then
		Kill_Buffs();
   elseif (event == "ADDON_LOADED") then
		local addonName = ...;
		if (addonName == "BuffBlock") then
			BuffBlock_Init();
		end;
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
   local label = BuffBlockMenuStrings[buffName] or "ERROR";
   
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
      DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[buffName]);
   else
      BUFF_CONFIG[BB_PlayerName][buffName] = nil;
      DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[buffName]);
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
   --local buffIndex, untilCancelled = GetPlayerBuff(i, "CANCELABLE");
   --print(buffIndex);
   CancelPlayerBuff(buffName);
   DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[buffName], 1, 1, 0.5);
end;

function Kill_Buffs()
   local i = 1;
   local buff = UnitBuff("player", i, "CANCELABLE");
   while buff do
      local buffName = select(1, buff);
	  print("buffName: "..buffName);
	  KillBuff(i, buffName);
      if BUFF_CONFIG[BB_PlayerName].buffName then
		if (buffName ~= "GreaterBlessingOfSalvation" or buffName ~= "BlessingOfSalvation") then
			local _, active, _, _, _ = GetShapeshiftFormInfo(2);
			if (IsShieldEquipped() and active) then
				KillBuff(i, buffName);
			end;
		else
			KillBuff(i, buffName);
		end;
      end;
      i = i + 1;
      buff = UnitBuff("player", i, "CANCELABLE");
   end;
end;
