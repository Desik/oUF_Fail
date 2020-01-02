local addon, ns = ...
local cfg = ns.cfg
local cast = ns.cast
local lib = CreateFrame("Frame")
local _, playerClass = UnitClass("player")

ns.colors = setmetatable({
    class = setmetatable({
        ["MONK"] = {0.35, 0.98, 0.35},
        ["HUNTER"] = {0.29, 0.89, 0.05},
        ["WARLOCK"] = {0.49, 0.15, 0.8},
        ["PRIEST"] = {1.0, 1.0, 1.0},
        ["PALADIN"] = {0.96, 0.55, 0.73},
        ["MAGE"] = {0, 0.75, 1},
        ["ROGUE"] = {0.99, 0.82, 0.09},
        ["DRUID"] = {1.0, 0.47, 0.13},
        ["SHAMAN"] = {0.14, 0.35, 1.0},
        ["WARRIOR"] = {0.78, 0.61, 0.43},
        ["DEATHKNIGHT"] = {0.77, 0.12, 0.23},
    }, {__index = oUF.colors.class}),
    
    power = setmetatable({
        ['MANA'] = {0.18, 0.4, 1.0},
        ['RAGE'] = {1.0, 0, 0},
        ['FOCUS'] = {1.0, 0.75, 0.25},
        ['ENERGY'] = {1.0, 0.9, 0.35},
        ['RUNIC_POWER'] = {0.44, 0.44, 0.44},
    }, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

-- FUNCTIONS
local retVal = function(f, val1, val2, val3)
    if f.mystyle == "player" or f.mystyle == "target" then
        return val1
    elseif f.mystyle == "failRaid" or f.mystyle == "party" then
        return val3
    else
        return val2
    end
end

--status bar filling fix (from oUF_Mono)
local fixStatusbar = function(b)
    b:GetStatusBarTexture():SetHorizTile(false)
    b:GetStatusBarTexture():SetVertTile(false)
end

--backdrop table
local backdrop_tab = {
    bgFile = cfg.backdrop_texture,
    edgeFile = cfg.backdrop_edge_texture,
    tile = false,
    tileSize = 0,
    edgeSize = 5,
    insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
    },
}

-- backdrop func
lib.gen_backdrop = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(0, 0, 0, 0.8)
end

lib.gen_castbackdrop = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(0, 0, 0, 0.6)
    f:SetBackdropBorderColor(0, 0, 0, 1)
end

lib.gen_totemback = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0, 0, 0, 0.8)
end

lib.gen_expback = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(0, 0, 0, 0.4)
    f:SetBackdropBorderColor(0, 0, 0, 0.8)
end

lib.gen_classback = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(0, 0, 0, 0.2)
    f:SetBackdropBorderColor(0, 0, 0, 0.7)
end

-- Right Click Menu
lib.menu = function(self)
    local unit = self.unit:sub(1, -2)
    local cunit = self.unit:gsub("(.)", string.upper, 1)
    
    if (cunit == 'Vehicle') then
        cunit = 'Pet'
    end
    
    if (unit == "party" or unit == "partypet") then
        ToggleDropDownMenu(1, nil, _G["PartyMemberFrame" .. self.id .. "DropDown"], "cursor", 0, 0)
    elseif (_G[cunit .. "FrameDropDown"]) then
        ToggleDropDownMenu(1, nil, _G[cunit .. "FrameDropDown"], "cursor", 0, 0)
    end
end

--fontstring func
lib.gen_fontstring = function(f, name, size, outline)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(name, size, outline)
    fs:SetShadowColor(0, 0, 0, 0.8)
    fs:SetShadowOffset(1, -1)
    fs:SetWordWrap(disable)
    --fs.frequentUpdates = true
    return fs
end

-- Power Bar Arrow Function
-- Special thanks to Zork and Rainrider for the initial implementation
-- And special thanks to MiRai, Phanx and Caleb for helping improve on it
local arrow = {[[Interface\Addons\oUF_Fail\media\textureArrow]]}
local arrowDefaultColor = {.55, 0, 0}-- Dark Red

lib.setPowerArrowColor = function(self)
    local unit = self.__owner.unit -- store this to avoid extra table lookups
    local _, powerType = UnitPowerType(unit)
    
    if powerType and UnitIsPlayer(unit) then -- make sure powerType is non-nil
        local color
        if unit == "focustarget" and powerType == "RAGE" then
            color = arrowDefaultColor
        else
            color = oUF.colors.power[powerType] or arrowDefaultColor -- fall back to default color for undefined power types
        end
        self.arrow:SetVertexColor(color[1], color[2], color[3])-- 3 table lookups is still faster than 1 function call
        self.arrow:Show()
    else
        self.arrow:Hide()
    end
end

lib.setClassArrowColor = function(self)
    local unit = self.__owner.unit
    local _, classType = UnitClass(unit)
    if classType and UnitIsPlayer(unit) then
        local color = oUF.colors.class[classType] or arrowDefaultColor
        self.arrow:SetVertexColor(color[1], color[2], color[3])
        self.arrow:Show()
    else
        self.arrow:Hide()
    end
end

local fixTex = function(tex)
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = tex:GetTexCoord()
    tex:SetTexCoord(ULy, ULx, LLy, LLx, URy, URx, LRy, LRx)
end

function AltPowerBarOnToggle(self)
    local unit = self:GetParent().unit or self:GetParent():GetParent().unit
end
function AltPowerBarPostUpdate(self, min, cur, max)
    local perc = math.floor((cur / max) * 100)
    if perc < 35 then
        self:SetStatusBarColor(0, 1, 0)
    elseif perc < 70 then
        self:SetStatusBarColor(1, 1, 0)
    else
        self:SetStatusBarColor(1, 0, 0)
    end
    local unit = self:GetParent().unit or self:GetParent():GetParent().unit
    local type = select(10, UnitAlternatePowerInfo(unit))
end

--gen healthbar func
lib.gen_hpbar = function(f)
        --local unit = f.__owner.unit
        local class, classFileName = UnitClass("player")
        --statusbar
        local s = CreateFrame("StatusBar", nil, f)
        s:SetStatusBarTexture(cfg.statusbar_texture)
        fixStatusbar(s)
        s:SetHeight(retVal(f, 30, 24, 20))
        s:SetWidth(f:GetWidth())
        s:SetPoint("BOTTOM", 0, 0)
        s:SetFrameLevel(3)
        --helper
        local h = CreateFrame("Frame", nil, s)
        h:SetFrameLevel(2)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_backdrop(h)
        --bg
        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture(cfg.statusbar_texture)
        b:SetAllPoints(s)
        b:SetVertexColor(1, 0.1, 0.1, 0.8)
        --[[ Smooth updating player health text test
        if f.mystyle == "player" then
        local text = lib.gen_fontstring(f.Health, cfg.font, 36, "THINOUTLINE")
        text:SetPoint("RIGHT", f.Health, "RIGHT", 2, -4)
        text:SetJustifyH("RIGHT")
        s.text = text
        s.PostUpdate = function(self, unit, value, maxvalue, minvalue)
        local color = RAID_CLASS_COLORS[classFileName]
        local r, g, b = (class, color.r, color.g, color.b)
        self.text:SetFormattedText("|cff%02x%02x%02x%d", r * 255, g * 255, b * 255, value)
        end
        else
        end]]
        f.Health = s
        f.Health.bg2 = b
end

--gen hp strings func
lib.gen_hpstrings = function(f, unit)
        --creating helper frame here so our font strings don't inherit healthbar parameters
        local h = CreateFrame("Frame", nil, f)
        h:SetAllPoints(f.Health)
        h:SetFrameLevel(15)
        local fontsize
        if f.mystyle == "player" then fontsize = cfg.healthbarfontsize
        elseif f.mystyle == "target" then fontsize = 15
        elseif f.mystyle == "party" then fontsize = 15
        elseif f.mystyle == "failRaid" then fontsize = 12
        else fontsize = 16
        end
        
        local name = lib.gen_fontstring(f.Health, cfg.font, retVal(f, 16, 16, 16), "THINOUTLINE")
        if f.mystyle == "player" then
            name:SetPoint("RIGHT", f.Health, "RIGHT", 0, 0)
            name:SetJustifyH("RIGHT")
        elseif f.mystyle == "raid" or f.mystyle == "party" then
            name:SetPoint("LEFT", f.Health, "LEFT", 0, 4)
            name:SetJustifyH("LEFT")
        elseif f.mystyle == "pet" or f.mystyle == "partypet" then
            name:SetPoint("LEFT", f.Health, "TOPLEFT", 2, -4)
            name:SetJustifyH("LEFT")
        else
            name:SetPoint("LEFT", f.Health, "TOPLEFT", 6, -1)
            name:SetJustifyH("LEFT")
        end
        
        local hpval = lib.gen_fontstring(f.Health, cfg.font, fontsize, "THINOUTLINE")
        if f.mystyle == "player" then
            hpval:SetPoint("RIGHT", f.Health, "RIGHT", 2, -6)
            hpval:SetJustifyH("RIGHT")
        elseif f.mystyle == "party" or f.mystyle == "pet" or f.mystyle == "partypet" then
            hpval:SetPoint("RIGHT", f.Health, "RIGHT", 6, -8)
            hpval:SetJustifyH("LEFT")
        elseif f.mystyle == "failRaid" then
            hpval:SetPoint("RIGHT", f.Health, "RIGHT", 5, -6)
            hpval:SetJustifyH("RIGHT")
        elseif f.mystyle == "focus" or f.mystyle == "focustarget" then
            hpval:SetPoint("RIGHT", f.Health, "RIGHT", 2, -6)
            hpval:SetJustifyH("LEFT")
        else
            hpval:SetPoint("RIGHT", f.Health, "TOPRIGHT", retVal(f, 2, 2, -3), retVal(f, -25, -15, -17))
        end
        
        if f.mystyle == "player" then
            name:SetPoint("RIGHT", f, "RIGHT", 10, 6)
        elseif f.mystyle == "target" or f.mystyle == "pet" or f.mystyle == "partypet" then
            name:SetPoint("RIGHT", f, "RIGHT", 0, -12)
        else
            name:SetPoint("RIGHT", f, "RIGHT", 0, 0)
        end
        
        if f.mystyle == "player" then
            f:Tag(name, "[fail:afkdnd]")
        elseif f.mystyle == "target" or f.mystyle == "party" then
            f:Tag(name, "[fail:level] [fail:color][name][fail:afkdnd]")
        elseif f.mystyle == "raid" then
            f:Tag(name, "[fail:color][name][fail:afkdnd]")
        else
            f:Tag(name, "[fail:color][name]")
        end
        if f.mystyle == "player" then
            f:Tag(hpval, "[fail:color][curhp]")
        
        else
            
            f:Tag(hpval, retVal(f, "[fail:color][fail:hp]", "[fail:color][fail:raidhp]", "[fail:color][fail:raidhp]"))
        end
        
        local level = lib.gen_fontstring(f.Health, cfg.font, 18, "THINOUTLINE")
        level:SetPoint("LEFT", f.Health, "TOPLEFT", 6, -1)
        level:SetJustifyH("LEFT")
        if f.mystyle == "player" and cfg.ShowPlayerName then
            f:Tag(level, "[fail:level] [fail:color][name]")
        else
            end
end

--gen powerbar func
lib.gen_ppbar = function(f)
        --statusbar
        local s = CreateFrame("StatusBar", nil, f)
        s:SetStatusBarTexture(cfg.powerbar_texture)
        fixStatusbar(s)
        if f.mystyle == "player" or f.mystyle == "pet" then
            s:SetHeight(20)
            s:SetWidth(f:GetWidth())
            s:SetPoint("TOP", f, "TOP", 8, 0)
        else
            s:SetHeight(retVal(f, 16, 14, 10))
            s:SetWidth(f:GetWidth())
            s:SetPoint("TOP", f, "TOP", 5, 0)
        end
        s:SetFrameLevel(1)
        
        --helper
        local h = CreateFrame("Frame", nil, s)
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_backdrop(h)
        --bg
        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture(cfg.powerbar_texture)
        b:SetAllPoints(s)
        --arrow
        if f.mystyle ~= "tot" and f.mystyle ~= "failRaid" and f.mystyle ~= "pet" then
            s.arrow = s:CreateTexture(nil, "OVERLAY")
            s.arrow:SetTexture([[Interface\Addons\oUF_Fail\media\textureArrow]])
            s.arrow:SetSize(16, 16)
            s.arrow:SetPoint("BOTTOM", s:GetStatusBarTexture(), "RIGHT", 0, retVal(f, 9, 9, 6))
            fixTex(s.arrow)
            
            if f.mystyle == "player" or f.mystyle == "target" then
                --== smooth power text for player==--
                local text = lib.gen_fontstring(f.Health, cfg.font, 20, "OUTLINE")
                text:SetPoint("RIGHT", s.arrow, "LEFT", 6, -8)
                
                s:HookScript("OnValueChanged", function(f, value)
                    local r, g, b = s:GetStatusBarColor()
                    if (value >= 1e3) then
                        text:SetFormattedText("|cff%02x%02x%02x%.1fk", r * 255, g * 255, b * 255, value / 1e3)
                    else
                        text:SetFormattedText("|cff%02x%02x%02x%d", r * 255, g * 255, b * 255, value)
                    end
                end)
            
            --[[local text = lib.gen_fontstring(f.Health, cfg.font, 18, "OUTLINE")
            text:SetPoint("RIGHT", s.arrow, "LEFT", 6, -8)
            
            s.text = text
            s.PostUpdate = function(self, unit, value, maxvalue, minvalue)
            local r, g, b = s:GetStatusBarColor()
            if (value >= 1e3) then
            self.text:SetFormattedText("|cff%02x%02x%02x%.1fk", r * 255, g * 255, b * 255, value / 1e3)
            else
            self.text:SetFormattedText("|cff%02x%02x%02x%d", r * 255, g * 255, b * 255, value)
            end
            end ]]
            else
                --==regular power text for everyone else==--
                local powertext = lib.gen_fontstring(f.Health, cfg.font, 18, "OUTLINE")
                powertext:SetPoint("RIGHT", s.arrow, "LEFT", 6, -8)
                --powertext:SetJustifyH("RIGHT")
                f:Tag(powertext, "[fail:pp]")
            end
            --==No arrows for raid and boss==--
            if f.mystyle ~= "raid" and f.mystyle ~= "failBoss" then
                f:Tag(powa, "[fail:pp]")
            end
            
            if cfg.ShowExtraUnitArrows == "true" then
                s.arrow:Show()
            else
                s.arrow:Hide()
            end
        end
        
        f.Power = s
        f.Power.bg = b
end

--gen combat and LFD icons
lib.gen_InfoIcons = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    --combat icon
    if f.mystyle == 'player' then
        f.Combat = h:CreateTexture(nil, 'OVERLAY')
        f.Combat:SetSize(16, 16)
        f.Combat:SetPoint('LEFT', -4, -16)
        f.Combat:SetTexture([[Interface\Addons\oUF_Fail\media\combat]])
    end
    -- rest icon
    if f.mystyle == 'player' and UnitLevel("Player") < 100 then
        f.Resting = h:CreateTexture(nil, 'OVERLAY')
        f.Resting:SetSize(22, 22)
        f.Resting:SetPoint('BOTTOMLEFT', -3, -3)
        f.Resting:SetTexture([[Interface\Addons\oUF_Fail\media\resting]])
        f.Resting:SetAlpha(0.75)
    end
    --Leader icon
    li = h:CreateTexture(nil, "OVERLAY")
    li:SetPoint("BOTTOMRIGHT", f, 0, -1)
    if f.mystyle ~= "player" then
        li:SetSize(12, 12)
    else
        li:SetSize(16, 16)
    end
    f.Leader = li
    
    --Assist icon
    ai = h:CreateTexture(nil, "OVERLAY")
    ai:SetPoint("TOPRIGHT", f, 4, 1)
    ai:SetSize(16, 16)
    ai:SetAlpha(100)
    if f.mystyle == "raid" then
        ai:Show()
    else
        ai:Hide()
    end
    f.Assistant = ai
    --ML icon
    local ml = h:CreateTexture(nil, 'OVERLAY')
    ml:SetSize(12, 12)
    ml:SetAlpha(100)
    ml:SetPoint('LEFT', f.Leader, -64, 2)
    if f.mystyle == "raid" then
        ml:Show()
    else
        ml:Hide()
    end
    f.MasterLooter = ml
end

-- LFG Role Indicator
lib.gen_LFDRole = function(f)
    local lfdi = lib.gen_fontstring(f.Health, cfg.smallfont, 10, "THINOUTLINE")
    lfdi:SetPoint('BOTTOM', f.Health, 'TOP', 0, 4)
    f:Tag(lfdi, "[fail:lfdrole]")
end

-- phase icon
lib.addPhaseIcon = function(self)
    local picon = self.Health:CreateTexture(nil, 'OVERLAY')
    picon:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 40, 8)
    picon:SetSize(16, 16)
    
    self.PhaseIcon = picon
end

-- quest icon
lib.addQuestIcon = function(self)
    local qicon = self.Health:CreateTexture(nil, 'OVERLAY')
    qicon:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 8)
    qicon:SetSize(16, 16)
    
    self.QuestIcon = qicon
end

--gen raid mark icons
lib.gen_RaidMark = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    h:SetAlpha(0.8)
    local ri = h:CreateTexture(nil, 'OVERLAY', h)
    ri:SetPoint("CENTER", f.Health, "BOTTOM", -8, 18)
    ri:SetTexture([[Interface\Addons\oUF_Fail\media\raidicons.blp]])
    local size = retVal(f, 24, 14, 18)
    ri:SetSize(size, size)
    f.RaidIcon = ri
end

--gen hilight texture
lib.gen_highlight = function(f)
    local OnEnter = function(f)
        UnitFrame_OnEnter(f)
        f.Highlight:Show()
    end
    local OnLeave = function(f)
        UnitFrame_OnLeave(f)
        f.Highlight:Hide()
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.statusbar_texture)
    hl:SetVertexColor(.5, .5, .5, .1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end

-- Create Target Border
function lib.CreateTargetBorder(self)
    self.TargetBorder = self.Health:CreateTexture("BACKGROUND", nil, self)
    self.TargetBorder:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -24, 24)
    self.TargetBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 24, -24)
    self.TargetBorder:SetTexture([[Interface\Addons\oUF_Fail\media\target]])
    self.TargetBorder:SetVertexColor(1.0, 1.0, 0.1, 0.6)
    self.TargetBorder:SetBlendMode("ADD")
    self.TargetBorder:Hide()
end

-- Raid Frames Target Highlight Border
function lib.ChangedTarget(self, event, unit)
    
    if (UnitIsUnit('target', 'player')) then
        self.TargetBorder:Show()
    else
        self.TargetBorder:Hide()
    end
end

-- Create Raid Threat Status Border
function lib.CreateThreatBorder(self)
    
    local glowBorder = {edgeFile = cfg.backdrop_edge_texture, edgeSize = 5}
    self.Thtborder = CreateFrame("Frame", nil, self)
    self.Thtborder:SetPoint("TOPLEFT", self, "TOPLEFT", -8, 9)
    self.Thtborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 9, -8)
    self.Thtborder:SetBackdrop(glowBorder)
    self.Thtborder:SetFrameLevel(1)
    self.Thtborder:Hide()
end

-- Raid Frames Threat Highlight
function lib.UpdateThreat(self, event, unit)
    
    if (self.unit ~= unit) then return end
    
    local status = UnitThreatSituation(unit)
    unit = unit or self.unit
    
    if status and status > 1 then
        local r, g, b = GetThreatStatusColor(status)
        self.Thtborder:Show()
        self.Thtborder:SetBackdropBorderColor(r, g, b, 1)
    else
        self.Thtborder:SetBackdropBorderColor(r, g, b, 0)
        self.Thtborder:Hide()
    end
end

-- Castbar
local PostCastStart = function(castbar, unit)
    if unit ~= 'player' then
        if castbar.interrupt then
            castbar.Backdrop:SetBackdropBorderColor(1, .9, .4)
            castbar.Backdrop:SetBackdropColor(1, .9, .4)
        else
            castbar.Backdrop:SetBackdropBorderColor(0, 0, 0)
            castbar.Backdrop:SetBackdropColor(0, 0, 0)
        end
    end
end

local CustomTimeText = function(castbar, duration)
    if castbar.casting then
        castbar.Time:SetFormattedText("%.1f / %.1f", duration, castbar.max)
    elseif castbar.channeling then
        castbar.Time:SetFormattedText("%.1f / %.1f", castbar.max - duration, castbar.max)
    end
end

lib.gen_castbar = function(f)
    if not cfg.Castbars then return end
    local cbColor = {95 / 255, 182 / 255, 255 / 255}
    local s = CreateFrame("StatusBar", "oUF_failCastbar" .. f.mystyle, f)
    s:SetHeight(16)
    if f.mystyle == "focus" then
        s:SetWidth(f:GetWidth() * 2 - 14)
    elseif f.mystyle == "player" then
        s:SetWidth(f:GetWidth() - 21)
    else
        s:SetWidth(f:GetWidth() - 30)
    end
    if f.mystyle == "player" then
        s:SetPoint("BOTTOM", f, "TOP", 20, 13)
    elseif f.mystyle == "target" then
        s:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, -30)
    elseif f.mystyle == "targettarget" then
        s:SetPoint("BOTTOM", f, "TOP", 0, 0)
    else
        s:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 30, -15)
    end
    s:SetStatusBarTexture(cfg.statusbar_texture)
    s:SetStatusBarColor(95 / 255, 182 / 255, 255 / 255, 1)
    s:SetFrameLevel(1)
    --color
    s.CastingColor = cbColor
    s.CompleteColor = {20 / 255, 208 / 255, 0 / 255}
    s.FailColor = {255 / 255, 12 / 255, 0 / 255}
    s.ChannelingColor = cbColor
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT", -5, 5)
    h:SetPoint("BOTTOMRIGHT", 5, -5)
    lib.gen_castbackdrop(h)
    --spark
    sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetTexture(spark)
    sp:SetBlendMode("ADD")
    sp:SetVertexColor(1, 1, 1, 1)
    sp:SetHeight(s:GetHeight() * 2.5)
    sp:SetWidth(s:GetWidth() / 18)
    --spell text
    local txt = lib.gen_fontstring(s, cfg.font, 16, "THINOUTLINE")
    txt:SetPoint("LEFT", 2, 10)
    txt:SetJustifyH("LEFT")
    --time
    local t = lib.gen_fontstring(s, cfg.font, 18, 'THINOUTLINE')
    t:SetPoint("RIGHT", -2, 0)
    txt:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    --icon
    local i = s:CreateTexture(nil, "ARTWORK")
    i:SetSize(24, 24)
    i:SetPoint("BOTTOMRIGHT", s, "BOTTOMLEFT", -6, 0)
    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --helper2 for icon
    local h2 = CreateFrame("Frame", nil, s)
    h2:SetFrameLevel(0)
    h2:SetPoint("TOPLEFT", i, "TOPLEFT", -5, 5)
    h2:SetPoint("BOTTOMRIGHT", i, "BOTTOMRIGHT", 5, -5)
    lib.gen_backdrop(h2)
    if f.mystyle == "player" then
        --latency (only for player unit)
        local z = s:CreateTexture(nil, "OVERLAY")
        z:SetTexture(cfg.statusbar_texture)
        z:SetVertexColor(1, 0.1, 0, .6)
        z:SetPoint("TOPRIGHT")
        z:SetPoint("BOTTOMRIGHT")
        s:SetFrameLevel(1)
        s.SafeZone = z
        -- custom latency display
        local l = lib.gen_fontstring(s, cfg.font, 10, "THINOUTLINE")
        l:SetPoint("CENTER", -2, 17)
        l:SetJustifyH("RIGHT")
        l:Hide()
        s.Lag = l
        --  f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)	--removed with 8.0
    end
    s.OnUpdate = cast.OnCastbarUpdate
    s.PostCastStart = cast.PostCastStart
    s.PostChannelStart = cast.PostCastStart
    s.PostCastStop = cast.PostCastStop
    s.PostChannelStop = cast.PostChannelStop
    s.PostCastFailed = cast.PostCastFailed
    s.PostCastInterrupted = cast.PostCastFailed
    
    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
end

-- mirror castbar!
lib.gen_mirrorcb = function(f)
    for _, bar in pairs({'MirrorTimer1', 'MirrorTimer2', 'MirrorTimer3', }) do
        for i, region in pairs({_G[bar]:GetRegions()}) do
            if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
                region:Hide()
            end
        end
        _G[bar .. 'Border']:Hide()
        _G[bar]:SetParent(UIParent)
        _G[bar]:SetScale(1)
        _G[bar]:SetHeight(16)
        _G[bar]:SetWidth(280)
        _G[bar]:SetBackdropColor(.1, .1, .1)
        _G[bar .. 'Background'] = _G[bar]:CreateTexture(bar .. 'Background', 'BACKGROUND', _G[bar])
        _G[bar .. 'Background']:SetTexture(cfg.statusbar_texture)
        _G[bar .. 'Background']:SetAllPoints(bar)
        _G[bar .. 'Background']:SetVertexColor(.15, .15, .15, .75)
        _G[bar .. 'Text']:SetFont(cfg.font, 14)
        _G[bar .. 'Text']:ClearAllPoints()
        _G[bar .. 'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
        _G[bar .. 'StatusBar']:SetAllPoints(_G[bar])
        --glowing borders
        local h = CreateFrame("Frame", nil, _G[bar])
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_backdrop(h)
    end
end

-- Post Create Icon Function
local myPostCreateIcon = function(self, button)
        
        self.showDebuffType = true
        self.showBuffType = true
        --self.showStealableBuffs = true
        self.disableCooldown = true
        button.cd.noOCC = true
        button.cd.noCooldownCount = true
        
        --		button.icon:SetTexCoord(0,1,0,1)
        button.icon:SetTexCoord(.07, .93, .07, .93)
        button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.overlay:SetTexture(cfg.debuffBorder)
        button.overlay:SetTexCoord(0, 1, 0, 1)
        button.overlay.Hide = function(self)self:SetVertexColor(0.3, 0.3, 0.3) end
        
        
        button.time = lib.gen_fontstring(button, cfg.smallfont, 20, "OUTLINE")
        button.time:SetPoint("BOTTOM", button, 2, -4)
        button.time:SetJustifyH('CENTER')
        button.time:SetVertexColor(1, 1, 1)
        
        button.count = lib.gen_fontstring(button, cfg.smallfont, 15, "OUTLINE")
        button.count:ClearAllPoints()
        button.count:SetPoint("TOPRIGHT", button, 5, 3)
        button.count:SetJustifyH('RIGHT')
        button.count:SetVertexColor(1, 1, 1)
        
        -- helper
        local h = CreateFrame("Frame", nil, button)
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_expback(h)
end

-- Post Update Icon Function
local myPostUpdateIcon = function(self, unit, icon, index, offset, filter, isDebuff)
        
        local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
        
        if duration and duration > 0 then
            icon.time:Show()
            icon.timeLeft = expirationTime
            icon:SetScript("OnUpdate", CreateBuffTimer)
        else
            icon.time:Hide()
            icon.timeLeft = math.huge
            icon:SetScript("OnUpdate", nil)
        end
        
        -- Desaturate non-Player Debuffs
        if (icon.isDebuff) then
            if (unit == "target") then
                if (unitCaster == 'player' or unitCaster == 'vehicle') then
                    icon.icon:SetDesaturated(false)
                elseif (not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don't desaturate debuffs
                    icon:SetBackdropColor(0, 0, 0)
                    icon.overlay:SetVertexColor(0.3, 0.3, 0.3)
                    icon.icon:SetDesaturated(true)
                end
            end
        end
        
        -- Right Click Cancel Buff/Debuff
        icon:SetScript('OnMouseUp', function(self, mouseButton)
            if mouseButton == 'RightButton' then
                CancelUnitBuff('player', index)
            end end)
        
        icon.first = true
end

local FormatTime = function(s)
    local day, hour, minute = 86400, 3600, 60
    if s >= day then
        return format("%dd", floor(s / day + 0.5)), s % day
    elseif s >= hour then
        return format("%dh", floor(s / hour + 0.5)), s % hour
    elseif s >= minute then
        if s <= minute * 5 then
            return format("%d:%02d", floor(s / 60), s % minute), s - floor(s)
        end
        return format("%dm", floor(s / minute + 0.5)), s % minute
    elseif s >= minute / 12 then
        return floor(s + 0.5), (s * 100 - floor(s * 100)) / 100
    end
    return format("%.1f", s), (s * 100 - floor(s * 100)) / 100
end

-- Create Buff/Debuff Timer Function
function CreateBuffTimer(self, elapsed)
    local currentTime = GetTime()
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.1 then
        if not self.first then
            self.timeLeft = self.timeLeft - self.elapsed
        else
            self.timeLeft = self.timeLeft - GetTime()
            self.first = false
        end
        
        if self.timeLeft > 0 and self.timeLeft <= 60 * 15 then -- Show time between 0 and 15 min
            local time = FormatTime(self.timeLeft)
            self.time:SetText(time)
            if self.timeLeft >= 6 and self.timeLeft <= 60 * 5 then -- if Between 5 min and 6sec
                self.time:SetTextColor(0.95, 0.95, 0.95)
            elseif self.timeLeft > 3 and self.timeLeft < 6 then -- if Between 6sec and 3sec
                self.time:SetTextColor(0.95, 0.70, 0)
            elseif self.timeLeft <= 3 then -- Below 3sec
                self.time:SetTextColor(0.9, 0.05, 0.05)
            else
                self.time:SetTextColor(0.95, 0.95, 0.95)-- Fallback Color
            end
        else
            self.time:Hide()
        end
        self.elapsed = 0
    end
end


--[[ Generates the Buffs
lib.createBuffs = function(f)
b = CreateFrame("Frame", nil, f)
b.onlyShowPlayer = cfg.buffsOnlyShowPlayer
if f.mystyle == "target" then
b.size = 30
b.num = 14
b.spacing = 5
if(playerClass == "ROGUE" or playerClass == "DRUID") then
b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 2, 36)
else
b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 6, 16)
end
b.initialAnchor = "BOTTOMLEFT"
b["growth-x"] = "RIGHT"
b["growth-y"] = "UP"
b:SetHeight((b.size+b.spacing)*4)
b:SetWidth(f:GetWidth())
else
b.num = 0
end
b.PostCreateIcon = myPostCreateIcon
b.PostUpdateIcon = myPostUpdateIcon

f.Buffs = b
end

-- Generates the Debuffs
lib.createDebuffs = function(f)
b = CreateFrame("Frame", nil, f)
if f.mystyle == "tot" or f.mystyle == "focus" then
b.onlyShowPlayer = false
b.size = 36
b.num = 8
else
b.onlyShowPlayer = cfg.debuffsOnlyShowPlayer
b.size = 36
b.num = 12
end
b.spacing = 6
b:SetHeight((b.size+b.spacing)*5)
b:SetWidth(f:GetWidth())
b:SetPoint("TOPLEFT", f, "TOPRIGHT", 16, 0)
b.initialAnchor = "TOPLEFT"
b["growth-x"] = "RIGHT"
b["growth-y"] = "DOWN"
b.PostCreateIcon = myPostCreateIcon
b.PostUpdateIcon = myPostUpdateIcon

f.Debuffs = b
end]]
-- Generates the Buffs
lib.createBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.onlyShowPlayer = cfg.buffsOnlyShowPlayer
    if f.mystyle == "target" then
        b:SetPoint("TOPLEFT", f, "TOPRIGHT", 16, 0)
        b.initialAnchor = "TOPLEFT"
        b["growth-x"] = "RIGHT"
        b["growth-y"] = "DOWN"
        b.size = 28
        b.num = 10
        b.spacing = 6
        b:SetHeight((b.size + b.spacing) * 4)
        b:SetWidth(f:GetWidth())
    elseif f.mystyle == "player" then
        b:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -5)
        b.initialAnchor = "TOPRIGHT"
        b["growth-x"] = "LEFT"
        b["growth-y"] = "DOWN"
        b.size = 36
        b.num = 40
        b.spacing = 5
        b:SetHeight((b.size + b.spacing) * 4)
        b:SetWidth(f:GetWidth() * 2)
    else
        b.num = 0
    end
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
    
    f.Buffs = b
end

-- Generates the Debuffs
lib.createDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    if f.mystyle == "tot" or f.mystyle == "focus" then
        b.onlyShowPlayer = false
        b.size = 36
        b.num = 8
    else
        b.onlyShowPlayer = cfg.showTargetDebuffs
        b.size = 38
        b.num = 8
    end
    b.spacing = 6
    b:SetHeight((b.size + b.spacing) * 5)
    b:SetWidth(f:GetWidth())
    if (playerClass == "ROGUE" or playerClass == "DRUID") then
        b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 18)
    else
        b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 6)
    end
    b.initialAnchor = "BOTTOMLEFT"
    b["growth-x"] = "RIGHT"
    b["growth-y"] = "UP"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
    
    f.Debuffs = b
end

-- raid post update
lib.PostUpdateRaidFrame = function(Health, unit, min, max)
        
        local disconnnected = not UnitIsConnected(unit)
        local dead = UnitIsDead(unit)
        local ghost = UnitIsGhost(unit)
        
        if disconnnected or dead or ghost then
            Health:SetValue(max)
            
            if (disconnnected) then
                Health:SetStatusBarColor(0, 0, 0, 0.6)
            elseif (ghost) then
                Health:SetStatusBarColor(1, 1, 1, 0.6)
            elseif (dead) then
                Health:SetStatusBarColor(1, 0, 0, 0.7)
            end
        else
            Health:SetValue(min)
            if (unit == 'vehicle') then
                Health:SetStatusBarColor(22 / 255, 106 / 255, 44 / 255)
            end
        end
        
        if not UnitInRange(unit) then
            Health.bg2:SetVertexColor(.6, 0.3, 0.3, 1)
        else
            Health.bg2:SetVertexColor(1, 0.1, 0.1, 1)
        end
end


-- Class specific powers
lib.gen_AltPowerBar = function(self)
        
        local pad
        if (IsAddOnLoaded('oUF_Experience') or IsAddOnLoaded('oUF_Reputation')) then pad = -8
        else
            pad = 0
        end
        
        local AdditionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", self.Power)
        AdditionalPower:SetHeight(6)
        AdditionalPower:SetWidth(self.Power:GetWidth() - 20)
        AdditionalPower:SetPoint("TOP", self.Health, "BOTTOM", 0 - pad, -1 + pad)
        AdditionalPower:SetFrameLevel(1)
        AdditionalPower:SetStatusBarTexture(cfg.statusbar_texture)
        AdditionalPower:SetStatusBarColor(.117, .55, 1)
        
        AdditionalPower.bg = AdditionalPower:CreateTexture(nil, "BORDER")
        AdditionalPower.bg:SetTexture(cfg.statusbar_texture)
        AdditionalPower.bg:SetVertexColor(.05, .15, .4)
        AdditionalPower.bg:SetPoint("TOPLEFT", AdditionalPower, "TOPLEFT", 0, 0)
        AdditionalPower.bg:SetPoint("BOTTOMRIGHT", AdditionalPower, "BOTTOMRIGHT", 0, 0)
        
        local h = CreateFrame("Frame", nil, AdditionalPower)
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT", 4, -4)
        lib.gen_classback(h)
        
        self.DruidMana = AdditionalPower
        self.DruidMana.bg = AdditionalPower.bg
end

-- Runebar
lib.genRunes = function(self)
    if playerClass ~= "DEATHKNIGHT" then return end
    local Runes = CreateFrame("Frame", nil, self)
    Runes:SetPoint('CENTER', self.Health, 'TOP', 2, 1)
    Runes:SetHeight(8)
    Runes:SetWidth(self.Health:GetWidth())
    
    local pad
    if (IsAddOnLoaded('oUF_Experience') or IsAddOnLoaded('oUF_Reputation')) then pad = -8
    else
        pad = 0
    end
    
    for i = 1, 6 do
        Runes[i] = CreateFrame("StatusBar", self:GetName() .. "_Runes" .. i, self)
        Runes[i]:SetHeight(8)
        Runes[i]:SetWidth((self.Health:GetWidth() / 6) - 5)
        Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
        Runes[i]:SetFrameLevel(10)
        Runes[i]:SetStatusBarColor(70 / 255, 180 / 255, 210 / 255)
        Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
        Runes[i].bg:SetTexture(cfg.statusbar_texture)
        Runes[i].bg:SetPoint("TOPLEFT", Runes[i], "TOPLEFT", 0, 0)
        Runes[i].bg:SetPoint("BOTTOMRIGHT", Runes[i], "BOTTOMRIGHT", 0, 0)
        Runes[i].bg.multiplier = 0.2
        
        local h = CreateFrame("Frame", nil, Runes[i])
        h:SetFrameLevel(1)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_classback(h)
        
        if (i == 1) then
            Runes[i]:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0 - pad, -6 + pad)
        else
            Runes[i]:SetPoint('TOPLEFT', Runes[i - 1], 'TOPRIGHT', 1, 0)
        end
    end
    
    self.Runes = Runes
end
-- Class Power
lib.gen_Classbar = function(self)
        
        local pad
        if (IsAddOnLoaded('oUF_Experience') or IsAddOnLoaded('oUF_Reputation')) then pad = -8
        else
            pad = 0
        end
        
        local maxPower, color
        if playerClass == "MAGE" then
            maxPower = 4
            color = {0.15, 0.55, 0.8}
        elseif playerClass == "MONK" then
            maxPower = 6
            color = {0.9, 0.99, 0.9}
        elseif playerClass == "PALADIN" then
            maxPower = 5
            color = {0.9, 0.95, 0.33}
        elseif playerClass == "WARLOCK" then
            maxPower = 5
            color = {0.86, 0.22, 1}
        end
        
        if maxPower ~= nil then
            local ClassIcons = CreateFrame("Frame", nil, self)
            ClassIcons:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
            ClassIcons:SetHeight(8)
            ClassIcons:SetWidth(self.Health:GetWidth())
            ClassIcons:SetFrameLevel(10)
            
            for i = 1, maxPower do
                ClassIcons[i] = CreateFrame("StatusBar", self:GetName() .. playerClass .. i, self)
                ClassIcons[i]:SetHeight(8)
                ClassIcons[i]:SetWidth((ClassIcons:GetWidth() / maxPower) - 2.5)
                ClassIcons[i]:SetStatusBarTexture(cfg.statusbar_texture)
                ClassIcons[i]:SetStatusBarColor(color[1], color[2], color[3])
                ClassIcons[i]:SetFrameLevel(11)
                
                local h = CreateFrame("Frame", nil, ClassIcons[i])
                h:SetFrameLevel(10)
                h:SetPoint("TOPLEFT", -5, 5)
                h:SetPoint("BOTTOMRIGHT", 5, -5)
                lib.gen_classback(h)
                
                if (i == 1) then
                    ClassIcons[i]:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0 - pad, -5 + pad)
                else
                    ClassIcons[i]:SetPoint('TOPLEFT', ClassIcons[i - 1], "TOPRIGHT", 3, 0)
                end
            end
            
            self.ClassIcons = ClassIcons
        end
end

-- Combo points
lib.RogueComboPoints = function(self)
    if (playerClass == "ROGUE" or playerClass == "DRUID") then
        
        local pad
        if (IsAddOnLoaded('oUF_Experience') or IsAddOnLoaded('oUF_Reputation')) then pad = -8
        else
            pad = 0
        end
        
        local combo = CreateFrame("Frame", nil, self)
        combo:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
        combo:SetHeight(8)
        combo:SetWidth(self:GetWidth())
        
        for i = 1, 8 do
            combo[i] = CreateFrame("StatusBar", self:GetName() .. "_CPoints" .. i, self)
            combo[i]:SetHeight(8)
            combo[i]:SetStatusBarTexture(cfg.statusbar_texture)
            combo[i]:SetFrameLevel(10)
            combo[i].bg = combo[i]:CreateTexture(nil, "BORDER")
            combo[i].bg:SetTexture(cfg.statusbar_texture)
            combo[i].bg:SetPoint("TOPLEFT", combo[i], "TOPLEFT", 0, 0)
            combo[i].bg:SetPoint("BOTTOMRIGHT", combo[i], "BOTTOMRIGHT", 0, 0)
            combo[i].bg.multiplier = 0.3
            
            local h = CreateFrame("Frame", nil, combo[i])
            h:SetFrameLevel(1)
            h:SetPoint("TOPLEFT", -5, 5)
            h:SetPoint("BOTTOMRIGHT", 5, -5)
            lib.gen_classback(h)
            
            
            if (i == 1) then
                combo[i]:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0 - pad, -5 + pad)
            else
                combo[i]:SetPoint('TOPLEFT', combo[i - 1], 'TOPRIGHT', 2, 0)
            end
        end
        
        combo[1]:SetStatusBarColor(.3, .9, .3)
        combo[2]:SetStatusBarColor(.3, .9, .3)
        combo[3]:SetStatusBarColor(.3, .9, .3)
        combo[4]:SetStatusBarColor(.9, .9, 0)
        combo[5]:SetStatusBarColor(.9, .3, .3)
        combo[6]:SetStatusBarColor(.9, .3, .3)
        combo[7]:SetStatusBarColor(.9, .3, .3)
        combo[8]:SetStatusBarColor(.9, .3, .3)
        
        self.FailCPoints = combo
    end
end

-- ReadyCheck
lib.ReadyCheck = function(self)
    if cfg.RCheckIcon then
        rCheck = self.Health:CreateTexture(nil, "OVERLAY")
        rCheck:SetSize(14, 14)
        rCheck:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", -13, -12)
        self.ReadyCheck = rCheck
    end
end

-- raid debuffs
lib.raidDebuffs = function(f)
    if cfg.showRaidDebuffs then
        local raid_debuffs = {
            debuffs = {
                -- Any Zone
                ["Viper Sting"] = 12, -- Viper Sting
                ["Wound Poison"] = 9, -- Wound Poison
                ["Mortal Strike"] = 8, -- Mortal Strike
                ["Furious Attacks"] = 8, -- Furious Attacks
                ["Aimed Shot"] = 8, -- Aimed Shot
                ["Counterspell"] = 10, -- Counterspell
                ["Blind"] = 10, -- Blind
                ["Cyclone"] = 10, -- Cyclone
                ["Hex"] = 7, -- Hex
                ["Polymorph"] = 7, -- Polymorph
                ["Entangling Roots"] = 7, -- Entangling Roots
                ["Frost Nova"] = 7, -- Frost Nova
                ["Freezing Trap"] = 7, -- Freezing Trap
                ["Crippling Poison"] = 6, -- Crippling Poison
                ["Bash"] = 5, -- Bash
                ["Cheap Shot"] = 5, -- Cheap Shot
                ["Kidney Shot"] = 5, -- Kidney Shot
                ["Throwdown"] = 5, -- Throwdown
                ["Sap"] = 5, -- Sap
                ["Hamstring"] = 5, -- Hamstring
                ["Wing Clip"] = 5, -- Wing Clip
                ["Fear"] = 3, -- Fear
                ["Psychic Scream"] = 3, -- Psychic Scream
                ["Howl of Terror"] = 3, -- Howl of Terror
                ["Intimidating Shout"] = 3, -- Intimidating Shout
            
            },
        }
        
        local instDebuffs = {}
        local instances = raid_debuffs.instances
        local getzone = function()
            local zone = GetInstanceInfo()
            if instances[zone] then
                instDebuffs = instances[zone]
            else
                instDebuffs = {}
            end
        end
        
        local debuffs = raid_debuffs.debuffs
        local CustomFilter = function(icons, ...)
            local _, icon, name, _, _, _, dtype = ...
            if instDebuffs[name] then
                icon.priority = instDebuffs[name]
                return true
            elseif debuffs[name] then
                icon.priority = debuffs[name]
                return true
            else
                icon.priority = 0
            end
        end
        
        local dbsize = 18
        local debuffs = CreateFrame("Frame", nil, f)
        debuffs:SetWidth(dbsize)debuffs:SetHeight(dbsize)
        debuffs:SetPoint("TOPRIGHT", -10, 3)
        debuffs.size = dbsize
        
        debuffs.CustomFilter = CustomFilter
        f.raidDebuffs = debuffs
    end
end

-- oUF_HealPred
lib.HealPred = function(self)
    if not cfg.ShowIncHeals then return end
    
    local mhpb = CreateFrame('StatusBar', nil, self.Health)
    mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
    mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
    mhpb:SetWidth(self:GetWidth())
    mhpb:SetStatusBarTexture(cfg.statusbar_texture)
    mhpb:SetStatusBarColor(1, 1, 1, 0.4)
    mhpb:SetFrameLevel(1)
    
    local ohpb = CreateFrame('StatusBar', nil, self.Health)
    ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
    ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
    ohpb:SetWidth(self:GetWidth())
    ohpb:SetStatusBarTexture(cfg.statusbar_texture)
    ohpb:SetStatusBarColor(1, 1, 1, 0.4)
    mhpb:SetFrameLevel(1)
    self.HealPrediction = {
        myBar = mhpb,
        otherBar = ohpb,
        maxOverflow = 1,
    }
end

-- Addons/Plugins -------------------------------------------
-- Totem timer
lib.gen_TotemBar = function(self)
    if playerClass ~= "SHAMAN" then return end
    local totems = CreateFrame("Frame", nil, self)
    totems:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -3)
    totems:SetWidth(self:GetWidth() - 140)
    totems:SetHeight(6)
    totems:SetFrameLevel(6)
    totems.Destroy = true
    totems.colors = {{233 / 255, 46 / 255, 16 / 255}; {173 / 255, 217 / 255, 25 / 255}; {35 / 255, 127 / 255, 255 / 255}; {178 / 255, 53 / 255, 240 / 255}; }
    
    for i = 1, 4 do
        totems[i] = CreateFrame("StatusBar", nil, totems)
        totems[i]:SetHeight(totems:GetHeight())
        totems[i]:SetWidth(((self:GetWidth() - 140) - 3) / 4)
        
        if (i == 1) then
            totems[i]:SetPoint("LEFT", totems)
        else
            totems[i]:SetPoint("LEFT", totems[i - 1], "RIGHT", 1, 0)
        end
        totems[i]:SetStatusBarTexture(cfg.statusbar_texture)
        totems[i]:GetStatusBarTexture():SetHorizTile(false)
        totems[i]:SetMinMaxValues(0, 1)
        
        totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
        totems[i].bg:SetAllPoints()
        totems[i].bg:SetTexture(cfg.statusbar_texture)
        totems[i].bg.multiplier = 0.3
    end
    totems.backdrop = CreateFrame("Frame", nil, totems)
    
    --[[CreateShadowclassbar(totems.backdrop)
    totems.backdrop:SetBackdropBorderColor(.2,.2,.2,1)
    totems.backdrop:SetPoint("TOPLEFT", -2, 2)
    totems.backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
    totems.backdrop:SetFrameLevel(5) ]]
    self.TotemBar = totems
end



-- oUF_DebuffHighlight
lib.debuffHighlight = function(self)
    if cfg.enableDebuffHighlight then
        local dbh = self.Health:CreateTexture(nil, "OVERLAY")
        dbh:SetAllPoints(self.Health)
        dbh:SetTexture(cfg.debuffhighlight_texture)
        dbh:SetBlendMode("ADD")
        dbh:SetVertexColor(0, 0, 0, 0)-- set alpha to 0 to hide the texture
        self.DebuffHighlight = dbh
        self.DebuffHighlightAlpha = 0.5
        self.DebuffHighlightFilter = true
    end
end

-- AuraWatch
local AWPostCreateIcon = function(AWatch, icon, spellID, name, self)
    icon.cd:SetReverse()
    local count = lib.gen_fontstring(icon, cfg.smallfont, 12, "OUTLINE")
    count:SetPoint("CENTER", icon, "BOTTOM", 3, 3)
    icon.count = count
    local h = CreateFrame("Frame", nil, icon)
    h:SetFrameLevel(4)
    h:SetPoint("TOPLEFT", -3, 3)
    h:SetPoint("BOTTOMRIGHT", 3, -3)
    lib.gen_backdrop(h)
end
lib.createAuraWatch = function(self, unit)
    if cfg.showAuraWatch then
        local auras = {}
        local spellIDs = {
            DEATHKNIGHT = {
            },
            DRUID = {
                33763, -- Lifebloom
                8936, -- Regrowth
                774, -- Rejuvenation
                48438, -- Wild Growth
            },
            HUNTER = {
                34477, -- Misdirection
            },
            MAGE = {
            },
            PALADIN = {
                53563, -- Beacon of Light
                25771, -- Forbearance
            },
            PRIEST = {
                17, -- Power Word: Shield
                139, -- Renew
                33076, -- Prayer of Mending
                6788, -- Weakened Soul
            },
            ROGUE = {
                57934, -- Tricks of the Trade
            },
            SHAMAN = {
                974, -- Earth Shield
                61295, -- Riptide
            },
            WARLOCK = {
                20707, -- Soulstone Resurrection
            },
            WARRIOR = {
            },
        }
        
        auras.onlyShowPresent = true
        auras.anyUnit = true
        auras.PostCreateIcon = AWPostCreateIcon
        -- Set any other AuraWatch settings
        auras.icons = {}
        
        for i, sid in pairs(spellIDs[playerClass]) do
            local icon = CreateFrame("Frame", nil, self)
            icon.spellID = sid
            -- set the dimensions and positions
            icon:SetWidth(14)
            icon:SetHeight(14)
            icon:SetFrameLevel(5)
            icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 12 * i, 5)
            
            auras.icons[sid] = icon
        end
        self.AuraWatch = auras
    end
end

-- oUF_Experience
lib.gen_exp = function(self)
    if (IsAddOnLoaded('oUF_Experience')) and UnitLevel("player") ~= MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] then
        local Experience = CreateFrame("StatusBar", nil, self)
        Experience:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 8, 8)
        Experience:SetStatusBarTexture(cfg.xpbar_texture)
        Experience:SetStatusBarColor(0.8, 0.1, 1, 0.8)
        Experience:SetHeight(16)
        Experience:SetWidth(self.Health:GetWidth())
        Experience:SetFrameLevel(1)
        fixStatusbar(Experience)
        
        local h = CreateFrame("Frame", nil, Experience)
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_expback(h)
        
        local Rested = CreateFrame("StatusBar", nil, Experience)
        Rested:SetStatusBarTexture(cfg.xpbar_texture)
        Rested:SetStatusBarColor(0, 0.4, 1, 0.8)
        Rested:SetAllPoints(Experience)
        fixStatusbar(Rested)
        
        local bg = Rested:CreateTexture(nil, 'BACKGROUND')
        bg:SetAllPoints(Experience)
        bg:SetTexture(cfg.xpbar_texture)
        bg:SetVertexColor(0.05, 0.05, 0.05, 0.4)
        
        local textframe = CreateFrame("Frame", nil, Experience)
        textframe:SetFrameLevel(10)
        textframe:SetAllPoints(Experience)
        textframe:SetAlpha(0)
        
        local exptext = lib.gen_fontstring(textframe, cfg.font, 12, "THINOUTLINE")
        exptext:SetPoint("CENTER", textframe, "BOTTOM", 0, 0)
        self:Tag(exptext, '[fail:curxp] / [fail:maxxp] - [fail:perxp]%')
        
        -- Mouseover!
        textframe:HookScript('OnEnter', function(self)self:SetAlpha(1) end)
        textframe:HookScript('OnLeave', function(self)self:SetAlpha(0) end)
        textframe:EnableMouse(true)
        
        self.Experience = Experience
        self.Experience.Rested = Rested
    
    end
end

-- oUF_Reputation
lib.gen_rep = function(self)
    if (IsAddOnLoaded("oUF_Reputation")) and UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] then
        local Reputation = CreateFrame("StatusBar", nil, self)
        Reputation:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 8, 8)
        Reputation:SetStatusBarTexture(cfg.xpbar_texture)
        Reputation:SetStatusBarColor(0.8, 0.1, 1, 0.8)
        Reputation:SetHeight(16)
        Reputation:SetWidth(self.Health:GetWidth())
        Reputation:SetFrameLevel(1)
        fixStatusbar(Reputation)
        
        -- Color the bar by current standing
        Reputation.colorStanding = true
        
        local h = CreateFrame("Frame", nil, Reputation)
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -5, 5)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        lib.gen_expback(h)
        
        local textframe = CreateFrame("Frame", nil, Reputation)
        textframe:SetFrameLevel(10)
        textframe:SetAllPoints(Reputation)
        textframe:SetAlpha(0)
        
        local reptext = lib.gen_fontstring(textframe, cfg.font, 10, "THINOUTLINE")
        reptext:SetPoint("CENTER", textframe, "BOTTOM", 0, 0)
        self:Tag(reptext, '[reputation] - [currep] / [maxrep]')
        
        -- Mouseover!
        textframe:HookScript('OnEnter', function(self)self:SetAlpha(1) end)
        textframe:HookScript('OnLeave', function(self)self:SetAlpha(0) end)
        textframe:EnableMouse(true)
        
        self.Reputation = Reputation
    end
end

-- oUF_CombatFeedback
lib.gen_combat_feedback = function(self)
    if IsAddOnLoaded("oUF_CombatFeedback") and cfg.CombatFeedback then
        local h = CreateFrame("Frame", nil, self.Health)
        h:SetAllPoints(self.Health)
        h:SetFrameLevel(30)
        local cfbt = lib.gen_fontstring(h, cfg.font, 18, "THINOUTLINE")
        cfbt:SetPoint("CENTER", self.Health, "BOTTOM", 0, -1)
        cfbt.maxAlpha = 0.75
        cfbt.ignoreEnergize = true
        self.CombatFeedbackText = cfbt
    end
end

-- oUF_FloatingCombatFeedback
lib.gen_floating_combat_feedback = function(self)
    if IsAddOnLoaded("oUF_FloatingCombatFeedback") and cfg.FloatingCombatFeedback then
        self.FloatingCombatFeedback = CreateFrame("Frame", nil, self.Health)
        self.FloatingCombatFeedback:SetFrameLevel(30)
        self.FloatingCombatFeedback:SetPoint("CENTER", self.Health, "BOTTOM", 0, -1)
        for i = 1, 6 do
            self.FloatingCombatFeedback[i] = lib.gen_fontstring(self.FloatingCombatFeedback, cfg.font, 18, "THINOUTLINE")
        end
        self.FloatingCombatFeedback.ignoreEnergize = true
        if cfg.FountainMode then
            self.FloatingCombatFeedback.Mode = "Fountain"
        else
            self.FloatingCombatFeedback.Mode = "Standard"
        end
    end
end

--hand the lib to the namespace for further usage
ns.lib = lib
