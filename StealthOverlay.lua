-- CONFIG SECTION --
STEALTHOVERLAY_SHOWTIME = 2;
STEALTHOVERLAY_FADETIME = 0.05;
STEALTHOVERLAY_CANCELTIME = 3;
local L_STEALTH = "Stealth";
local L_PROWL = "Prowl";
-- END --

local localizedClass, class = UnitClass("player");
class = strupper(class);

function StealthOverlay_OnLoad()
	if ( class ~= "ROGUE" and class ~= "DRUID" ) then
		DisableAddOn("StealthOverlay");
		ReloadUI();
		return
	end
	
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("COMBAT_TEXT_UPDATE"); -- from Blizzard_CombatText.lua

	SlashCmdList["STEALTHOVERLAY_SLASHCMD"] = function(msg)
		if ( msg == "" ) then
			StealthOverlay_Stealth(STEALTHOVERLAY_CANCELTIME);
		else
			StealthOverlay_Stealth(tonumber(msg));
		end
	end
	
	SLASH_STEALTHOVERLAY_SLASHCMD1 = '/caststealth'
	SLASH_STEALTHOVERLAY_SLASHCMD2 = '/stealth'
	SLASH_STEALTHOVERLAY_SLASHCMD3 = '/prowl'
	
end

function StealthOverlay_OnEvent(event, arg1, arg2)
	
	if (event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_START") and (arg2 == L_STEALTH or arg2 == L_PROWL) then
		StealthOverlayFrame.display = true;
		StealthOverlayFrame.onload = false;
		StealthOverlayFrame.timer = STEALTHOVERLAY_SHOWTIME;
		StealthOverlayFrame:SetAlpha(0);
		StealthOverlayFrame:Show();
	end
	
	if (event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_END") and (arg2 == L_STEALTH or arg2 == L_PROWL) then
		StealthOverlayFrame.display = false;
		StealthOverlayFrame.onload = false;
		StealthOverlayFrame.timer = STEALTHOVERLAY_FADETIME; 
		StealthOverlayFrame:SetAlpha(1);
		StealthOverlayFrame:Show();
	end
	
	if event == "PLAYER_ENTERING_WORLD" then
		if ( class == "ROGUE" ) then
			local texture, name, isActive, isCastable = GetShapeshiftFormInfo(1);
			if isActive then
				StealthOverlayFrame.display=true;
				StealthOverlayFrame.onload=true;
				StealthOverlayFrame.timer=STEALTHOVERLAY_SHOWTIME;
				StealthOverlayFrame:SetAlpha(1);
				StealthOverlayFrame:Show();
			end
		elseif ( class == "DRUID" ) then
			if ( StealthOverlay_HasAura("player", L_PROWL) ) then
				StealthOverlayFrame.display=true;
				StealthOverlayFrame.onload=true;
				StealthOverlayFrame.timer=STEALTHOVERLAY_SHOWTIME;
				StealthOverlayFrame:SetAlpha(1);
				StealthOverlayFrame:Show();
			end
		end
	end
	
end

if ( class == "DRUID" ) then
	CreateFrame("GameTooltip", "StealthOverlayScanner", nil, "GameTooltipTemplate");
	StealthOverlayScanner:SetOwner(WorldFrame, "ANCHOR_NONE");

	function StealthOverlay_HasAura(unit, name)
		StealthOverlayScanner:ClearLines()
		for i=1,32 do
			StealthOverlayScanner:SetUnitBuff(unit,i)
			if ( StealthOverlayScannerTextLeft1:GetText() == name ) then 
				return true
			end
		end
	end
	
	function StealthOverlay_Stealth(t)
		if not t then t = STEALTHOVERLAY_CANCELTIME; end
		
		local isActive = StealthOverlay_HasAura("player", L_PROWL);
		local timeNow = time();
		
		if not isActive then
			__LST = timeNow;
			CastSpellByName(L_PROWL);
		else
			if __LST ~= nil then
				if __LST+t < timeNow then
					CastSpellByName(L_PROWL);
				end
			else
				CastSpellByName(L_PROWL);
			end
		end
	end
elseif ( class == "ROGUE" ) then
	function StealthOverlay_Stealth(t)
		if not t then t = STEALTHOVERLAY_CANCELTIME; end
		
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(1);
		local timeNow = time();
		
		if not isActive then
			__LST = timeNow;
			CastSpellByName(L_STEALTH);
		else
			if __LST ~= nil then
				if __LST+t < timeNow then
					CastSpellByName(L_STEALTH);
				end
			else
				CastSpellByName(L_STEALTH);
			end
		end
	end
end

function StealthOverlay_OnUpdate(arg1)
	this.timer = this.timer - arg1;
	if this.timer <= 0 then
		if not this.display then
			this:Hide();
		end
	elseif this.timer > 0 then
		if this.onload then return end
		-- fade in
		if this.display then
			this:SetAlpha( 1 - ( ( (this.timer/STEALTHOVERLAY_SHOWTIME) * 100) / 100)  );
		-- fade out
		else
			this:SetAlpha(( (this.timer/STEALTHOVERLAY_SHOWTIME) * 100) / 100);
		end
	end
end	