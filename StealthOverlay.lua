-- CONFIG SECTION --
STEALTHOVERLAY_SHOWTIME = 2;
STEALTHOVERLAY_FADETIME = 0.05;
STEALTHOVERLAY_CANCELTIME = 3;
-- END --

function StealthOverlay_OnLoad()

	local localizedClass, class = UnitClass("player");
	class = strupper(class);
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
	
end

function StealthOverlay_OnEvent(event, arg1, arg2)
	
	if event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_START" and arg2 == "Stealth" then
		StealthOverlayFrame.display = true;
		StealthOverlayFrame.onload = false;
		StealthOverlayFrame.timer = STEALTHOVERLAY_SHOWTIME;
		StealthOverlayFrame:SetAlpha(0);
		StealthOverlayFrame:Show();
	end
	
	if event == "COMBAT_TEXT_UPDATE" and arg1 == "AURA_END" and arg2 == "Stealth" then
		StealthOverlayFrame.display = false;
		StealthOverlayFrame.onload = false;
		StealthOverlayFrame.timer = STEALTHOVERLAY_FADETIME; 
		StealthOverlayFrame:SetAlpha(1);
		StealthOverlayFrame:Show();
	end
	
	if event == "PLAYER_ENTERING_WORLD" then
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(1);
		if isActive then
			StealthOverlayFrame.display=true;
			StealthOverlayFrame.onload=true;
			StealthOverlayFrame.timer=STEALTHOVERLAY_SHOWTIME;
			StealthOverlayFrame:SetAlpha(1);
			StealthOverlayFrame:Show();
		end
	end
	
end

function StealthOverlay_Stealth(t)
	if not t then t = STEALTHOVERLAY_CANCELTIME; end
	
	local texture, name, isActive, isCastable = GetShapeshiftFormInfo(1);
	local timeNow = time();
	
	if not isActive then
		__LST = timeNow;
		CastSpellByName("Stealth");
	else
		if __LST ~= nil then
			if __LST+t < timeNow then
				CastSpellByName("Stealth");
			end
		else
			CastSpellByName("Stealth");
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