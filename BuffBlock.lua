local BB_PlayerName = nil;
local BB_default = {};
local BuffBlockMenuObjects = {};
local BuffBlockMenuStrings = {
   [00]= "Battle Shout",
   [01]= "Blessing of Salvation",
   [02]= "Greater Blessing of Salvation",
   [03]= "Divine Spirit",
   [04]= "Prayer of Spirit",
   [05]= "Arcane Intellect",
   [06]= "Arcane Brilliance",
   [07]= "Blessing of Protection"
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
      local unit = select(1, ...)
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

function BuffBlock_GetOption(num)
   local labelString = getglobal(this:GetName().."Text");
   local label = BuffBlockMenuStrings[num] or "";
   BuffBlockMenuObjects[num] = this;
   
   if num == 00 and BUFF_CONFIG[BB_PlayerName].BATTLESHOUT
      or num == 01 and BUFF_CONFIG[BB_PlayerName].SALVATION
      or num == 02 and BUFF_CONFIG[BB_PlayerName].GREATERSALVATION
      or num == 03 and BUFF_CONFIG[BB_PlayerName].DIVINESPIRIT
      or num == 04 and BUFF_CONFIG[BB_PlayerName].PRAYEROFSPIRIT
      or num == 05 and BUFF_CONFIG[BB_PlayerName].ARCANEINTELLECT
      or num == 06 and BUFF_CONFIG[BB_PlayerName].ARCANEBRILLIANCE
      or num == 07 and BUFF_CONFIG[BB_PlayerName].BLESSINGOFPROTECTION
   or nil then
      this:SetChecked(true);
   else
      this:SetChecked(nil);
   end;
   labelString:SetText(label);
end;

function BuffBlock_SetOption(num)
   local checked = this:GetChecked();
   if num == 00 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].BATTLESHOUT = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].BATTLESHOUT = nil;
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 01 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].SALVATION = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].SALVATION = nil;
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 02 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].GREATERSALVATION = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].GREATERSALVATION = nil
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 03 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].DIVINESPIRIT = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].DIVINESPIRIT = nil;
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 04 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].PRAYEROFSPIRIT = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].PRAYEROFSPIRIT = nil;
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 05 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].ARCANEINTELLECT = 1
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].ARCANEINTELLECT = nil
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end
   elseif num == 06 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].ARCANEBRILLIANCE = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].ARCANEBRILLIANCE = nil
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   elseif num == 07 then
      if checked then
	 BUFF_CONFIG[BB_PlayerName].BLESSINGOFPROTECTION = 1;
	 DEFAULT_CHAT_FRAME:AddMessage("Blocking "..BuffBlockMenuStrings[num]);
      else
	 BUFF_CONFIG[BB_PlayerName].BLESSINGOFPROTECTION = nil;
	 DEFAULT_CHAT_FRAME:AddMessage("Stopped blocking "..BuffBlockMenuStrings[num]);
      end;
   end;
end;

function IsShieldEquipped()
   local slot = GetInventorySlotInfo("SecondaryHandSlot")
   local link = GetInventoryItemLink("player", slot)
   if link  then
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

function Kill_Buffs()
   local i = 0;
   while not (GetPlayerBuff(i, "HELPFUL") == -1) do
      local buffIndex, untilCancelled = GetPlayerBuff(i, "HELPFUL");
      local texture = GetPlayerBuffTexture(buffIndex);
      
      --DEFAULT_CHAT_FRAME:AddMessage("DEBUG: "..texture, 1, 1, 0.5);
      
      if BUFF_CONFIG[BB_PlayerName].BATTLESHOUT then
	 if (string.find(texture,"BattleShout")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[00], 1, 1, 0.5);
	 end;
      end;
      if BUFF_CONFIG[BB_PlayerName].SALVATION then
	 if (string.lower(UnitClass("player")) ~= "warrior" or (IsShieldEquipped() and GetShapeshiftFormInfo(2))) then
	    if (string.find(texture,"SealOfSalvation")) then
	       CancelPlayerBuff(buffIndex);
	       DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[01], 1, 1, 0.5);
	    end;
	 end;
      end;
      if BUFF_CONFIG[BB_PlayerName].GREATERSALVATION then
	 if (string.lower(UnitClass("player")) ~= "warrior" or (IsShieldEquipped() and GetShapeshiftFormInfo(2))) then
	    if (string.find(texture,"GreaterBlessingofSalvation")) then
	       CancelPlayerBuff(buffIndex);
	       DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[02], 1, 1, 0.5);
	    end;
	 end;
      end;
      if BUFF_CONFIG[BB_PlayerName].DIVINESPIRIT then
	 if (string.find(texture,"DivineSpirit")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[03], 1, 1, 0.5);
	 end;
      end;
      if BUFF_CONFIG[BB_PlayerName].PRAYEROFSPIRIT then
	 if (string.find(texture,"PrayerofSpirit")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[04], 1, 1, 0.5);
	 end
      end
      if BUFF_CONFIG[BB_PlayerName].ARCANEINTELLECT then
	 if (string.find(texture,"MagicalSentry")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[05], 1, 1, 0.5);
	 end
      end
      if BUFF_CONFIG[BB_PlayerName].ARCANEBRILLIANCE then
	 if (string.find(texture,"ArcaneIntellect")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[06], 1, 1, 0.5);
	 end;
      end;
      if BUFF_CONFIG[BB_PlayerName].BLESSINGOFPROTECTION then
	 if (string.find(texture,"SealOfProtection")) then
	    CancelPlayerBuff(buffIndex);
	    DEFAULT_CHAT_FRAME:AddMessage("Blocked "..BuffBlockMenuStrings[07], 1, 1, 0.5);
	 end;
      end;
      i = i + 1;
   end;
end;
