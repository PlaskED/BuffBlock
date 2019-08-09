local BB_PlayerName = nil;
local BB_default = {};
local BuffBlockMenuObjects = {};
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
   this:RegisterEvent("UNIT_AURA");
   this:RegisterEvent("VARIABLES_LOADED");
   DEFAULT_CHAT_FRAME:AddMessage("Buff Block. /BB for options", 1, 1, 0.5);
   SLASH_BB1 = "/BB";
   SlashCmdList["BB"] = BuffBlock_Command;
end;

function BuffBlock_Init()
   BB_PlayerName = UnitName("player").." of "..GetCVar("realmName");
   
   if (BUFF_CONFIG == nil) then
      BUFF_CONFIG = {};
   end;
   
   if (BUFF_CONFIG[BB_PlayerName] == nil) then
      BUFF_CONFIG[BB_PlayerName] = BB_default;
   end;
end;

function BuffBlock_OnEvent()
   if (event == "UNIT_AURA") then
      local unit = select(1, event);
      if unit == "player" then
		Kill_Buffs();
      end;
   elseif (event == "VARIABLES_LOADED") then
      BuffBlock_Init();
   end;
end;

function BuffBlock_Command()
   if BuffBlockOptions:IsShown() then
      BuffBlockOptions:Hide();
   else
      BuffBlockOptions:Show();
   end;
end;

function BuffBlock_GetOption(buffName)
   local labelString = getglobal(this:GetName().."Text");
   local label = BuffBlockMenuStrings[buffName] or "";
   BuffBlockMenuObjects[buffName] = this;

   if BUFF_CONFIG[BB_PlayerName].buffName or nil then
      this:SetChecked(true);
   else
      this:SetChecked(nil);
   end;
   labelString:SetText(label);
end;

function BuffBlock_SetOption(buffName)
   local checked = this:GetChecked();
   if checked then
      BUFF_CONFIG[BB_PlayerName].buffName = true;
      DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[buffName]);
   else
      BUFF_CONFIG[BB_PlayerName].buffName = nil;
      DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[buffName]);
   end;
end;

function IsShieldEquipped()
   local slot = GetInventorySlotInfo("SecondaryHandSlot")
   local link = GetInventoryItemLink("player", slot)
   if link then
      local found, _, id, name = string.find(link, "item:(%d+):.*%[(.*)%]")
      if found then
	 local _,_,_,_,_,itemType = GetItemInfo(tonumber(id))
	 if(itemType == "Shields") then
	    return true
	 end
      end
   end
   return false
end

function KillBuff(buffName)
   CancelPlayerBuff("player", buffName);
   DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[buffName], 1, 1, 0.5);
end;

function Kill_Buffs()
   local i = 1;
   local buff = UnitBuff("player", i, "CANCELABLE");
   while buff do
      local buffName = select(1, buff);
      
      --DEFAULT_CHAT_FRAME:AddMessage("DEBUG: "..texture, 1, 1, 0.5);

      --if BUFF_CONFIG[BB_PlayerName].buffName ~= nil then
      if BUFF_CONFIG[BB_PlayerName].buffName then
	 if (buffName ~= "GreaterBlessingOfSalvation" or buffName ~= "BlessingOfSalvation") then
	    if (IsShieldEquipped() and GetShapeshiftFormInfo(2)) then
	       KillBuff(buffName);
	    end;
	 else
	    KillBuff(buffName);
	 end;
      end;
      i = i + 1;
      buff = UnitBuff("player", i, "CANCELABLE");
   end;
end;