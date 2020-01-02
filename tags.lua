local addon, ns = ...
local cfg = ns.cfg

local SVal = function(val)
    if val then
        if (val >= 1e6) then
            return ("%.1fm"):format(val / 1e6)
        elseif (val >= 1e3) then
            return ("%.1fk"):format(val / 1e3)
        else
            return ("%d"):format(val)
        end
    end
end

local function hex(r, g, b)
    if r then
        if (type(r) == 'table') then
            if (r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
        end
        return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
    end
end

ns.colors = setmetatable({
    power = setmetatable({
        ['MANA'] = {0.18, 0.4, 1.0},
        ['RAGE'] = {1.0, 0, 0},
        ['FOCUS'] = {1.0, 0.75, 0.25},
        ['ENERGY'] = {1.0, 0.9, 0.35},
        ['RUNIC_POWER'] = {0.44, 0.44, 0.44},
    }, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

oUF.Tags.Methods["fail:lfdrole"] = function(unit)
    local role = UnitGroupRolesAssigned(unit)
    if role == "HEALER" then
        return "|cff8AFF30Heals|r"
    elseif role == "TANK" then
        return "|cffFFF130Tank|r"
    elseif role == "DAMAGER" then
        return "|cffFF6161DPS|r"
    end
end
oUF.Tags.Events["fail:lfdrole"] = "PLAYER_ROLES_ASSIGNED PARTY_MEMBERS_CHANGED"

oUF.Tags.Methods['fail:DDG'] = function(u)
    if not UnitIsConnected(u) then
        return "|cffCFCFCF D/C|r"
    elseif UnitIsGhost(u) then
        return "|cffCFCFCF Ghost|r"
    elseif UnitIsDead(u) then
        return "|cffCFCFCF Dead|r"
    end
end
oUF.Tags.Events['fail:DDG'] = 'UNIT_NAME_UPDATE UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags.Methods['fail:hp'] = function(u)
    if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
        return oUF.Tags.Methods['fail:DDG'](u)
    else
        local per = oUF.Tags.Methods['perhp'](u) .. "%" or 0
        local min, max = UnitHealth(u), UnitHealthMax(u)
        if u == "player" or u == "target" then
            if min ~= max then
                return "|cFFFFAAAA" .. SVal(min) .. "|r/" .. SVal(max) .. "   " .. per
            else
                return SVal(max) .. "   " .. per
            end
        else
            return per
        end
    end
end
oUF.Tags.Events['fail:hp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'

oUF.Tags.Methods['fail:heal'] = function(u)
    local incheal = UnitGetIncomingHeals(u, 'player') or 0
    if incheal > 0 then
        return "|cff8AFF30+" .. SVal(incheal) .. "|r"
    end
end
oUF.Tags.Events['fail:heal'] = 'UNIT_HEAL_PREDICTION'

oUF.Tags.Methods['fail:raidhp'] = function(u)
    if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
        return oUF.Tags.Methods['fail:DDG'](u)
    else
        local per = oUF.Tags.Methods['perhp'](u) .. "%" or 0
        return per
    end
end
oUF.Tags.Events['fail:raidhp'] = 'UNIT_HEALTH'

oUF.Tags.Methods['fail:color'] = function(u, r)
    local _, class = UnitClass(u)
    local reaction = UnitReaction(u, "player")
    
    if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
        return "|cffA0A0A0"
    elseif (UnitIsTapDenied(u)) then
        return hex(oUF.colors.tapped)
    elseif (UnitIsPlayer(u)) then
        return hex(oUF.colors.class[class])
    elseif reaction then
        return hex(oUF.colors.reaction[reaction])
    else
        return hex(1, 1, 1)
    end
end
oUF.Tags.Events['fail:color'] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'

oUF.Tags.Methods["fail:afkdnd"] = function(unit)
        
        return UnitIsAFK(unit) and "|cffCFCFCF <afk>|r" or UnitIsDND(unit) and "|cffCFCFCF <dnd>|r" or ""
end
oUF.Tags.Events["fail:afkdnd"] = 'PLAYER_FLAGS_CHANGED UNIT_POWER UNIT_MAXPOWER'

oUF.Tags.Methods['fail:power'] = function(u)
    local min, max = UnitPower(u), UnitPowerMax(u)
    if min ~= max then
        return SVal(min) .. "/" .. SVal(max)
    else
        return SVal(max)
    end
end
oUF.Tags.Events['fail:power'] = 'UNIT_POWER UNIT_MAXPOWER'

oUF.Tags.Methods['fail:pp'] = function(u)
    if u == "player" or u == "target" then
        local _, class = UnitClass(u)
        if (UnitIsPlayer(u)) then
            return hex((oUF.colors.class[class]) or {0 / 255, 75 / 255, 60 / 255}) .. SVal(UnitPower(u))
        end
    end
end
oUF.Tags.Events['fail:pp'] = 'UNIT_POWER UNIT_MAXPOWER'

--oUF.Tags.Methods['fail:pp'] = function(u)
--    if u == "player" then
--		local _, str = UnitPowerType(u)
--		if str then
--			return hex(ns.colors.power[str] or {0/255,  75/255,  60/255})..SVal(UnitPower(u))
--		end
--	end
--end
--oUF.Tags.Events['fail:pp'] = 'UNIT_POWER UNIT_MAXPOWER'
oUF.Tags.Methods['fail:tpp'] = function(u)
    if u == "target" then
        local _, class = UnitClass(u)
        if (UnitIsPlayer(u)) then
            return hex((oUF.colors.class[class]) or {0 / 255, 75 / 255, 60 / 255}) .. SVal(UnitPower(u))
        end
    end
end
oUF.Tags.Events['fail:tpp'] = 'UNIT_POWER UNIT_MAXPOWER'

-- Level
oUF.Tags.Methods["fail:level"] = function(unit)
        
        local c = UnitClassification(unit)
        local l = UnitLevel(unit)
        local d = GetQuestDifficultyColor(l)
        
        local str = l
        
        if l <= 0 then l = "??" end
        
        if c == "worldboss" then
            str = string.format("|cff%02x%02x%02xBOSS|r", 250, 20, 0)
        elseif c == "eliterare" then
            str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r+", d.r * 255, d.g * 255, d.b * 255, l)
        elseif c == "elite" then
            str = string.format("|cff%02x%02x%02x%s|r+", d.r * 255, d.g * 255, d.b * 255, l)
        elseif c == "rare" then
            str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r", d.r * 255, d.g * 255, d.b * 255, l)
        else
            if not UnitIsConnected(unit) then
                str = "??"
            else
                if UnitIsPlayer(unit) then
                    str = string.format("|cff%02x%02x%02x%s", d.r * 255, d.g * 255, d.b * 255, l)
                elseif UnitPlayerControlled(unit) then
                    str = string.format("|cff%02x%02x%02x%s", d.r * 255, d.g * 255, d.b * 255, l)
                else
                    str = string.format("|cff%02x%02x%02x%s", d.r * 255, d.g * 255, d.b * 255, l)
                end
            end
        end
        
        return str
end
oUF.Tags.Events["fail:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods['fail:curxp'] = function(unit)
    return SVal(UnitXP(unit))
end

oUF.Tags.Methods['fail:maxxp'] = function(unit)
    return SVal(UnitXPMax(unit))
end

oUF.Tags.Methods['fail:perxp'] = function(unit)
    return floor(UnitXP(unit) / UnitXPMax(unit) * 100 + 0.5)
end

oUF.Tags.Events['fail:curxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
oUF.Tags.Events['fail:maxxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
oUF.Tags.Events['fail:perxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
