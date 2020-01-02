local addon, ns = ...

local cfg = ns.cfg
local lib = ns.lib



-- Unit has an Aura
function hasUnitAura(unit, name)
    
    local _, _, _, count, _, _, _, caster = UnitAura(unit, name)
    if (caster and caster == "player") then
        return count
    end
end

-- Unit has a Debuff
function hasUnitDebuff(unit, name)
    
    local _, _, _, count, _, _, _, _ = UnitDebuff(unit, name)
    if (count) then return count
    end
end

oUF.colors.smooth = {0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22, }

local MyPvPUpdate = function(self, event, unit)
    if (unit ~= self.unit) then return end
    
    local pvp = self.MyPvP
    if (pvp) then
        local factionGroup = UnitFactionGroup(unit)
        -- FFA!
        if (UnitIsPVPFreeForAll(unit)) then
            pvp:SetTexture([[Interface\TargetingFrame\UI-PVP-FFA]])
            pvp:Show()
        elseif (UnitIsPVP(unit) and factionGroup) then
            if (factionGroup == 'Horde') then
                pvp:SetTexture([[Interface\Addons\oUF_Fail\media\Horde]])
            else
                pvp:SetTexture([[Interface\Addons\oUF_Fail\media\Alliance]])
            end
            pvp:Show()
        else
            pvp:Hide()
        end
    end
end
-----------------------------
-- STYLE FUNCTIONS
-----------------------------
local UnitSpecific = {
        
        player = function(self, ...)
            
            self.mystyle = "player"
            
            -- Size and Scale
            self:SetScale(cfg.scale)
            self:SetSize(192, 42)
            
            -- Generate Bars
            lib.gen_hpbar(self)
            lib.gen_hpstrings(self)
            lib.gen_highlight(self)
            lib.gen_ppbar(self)
            lib.gen_RaidMark(self)
            lib.gen_combat_feedback(self)
            lib.gen_floating_combat_feedback(self)
            lib.gen_InfoIcons(self)
            lib.HealPred(self)
            -- Buffs and Debuffs
            if cfg.showPlayerAuras then
                BuffFrame:Hide()
                lib.createBuffs(self)
                lib.createDebuffs(self)
                lib.gen_WeaponEnchant(self)
            end
            
            self.Health.frequentUpdates = true
            self.Health.colorSmooth = true
            self.Health.Smooth = true
            -- self.Health.bg.multiplier = 0.2
            self.Power.colorPower = true
            --self.Power.arrow.colorPower = true
            self.Power.Smooth = true
            self.Power.frequentUpdates = true
            self.Power.bg.multiplier = 0.2
            
            lib.gen_exp(self)
            lib.gen_rep(self)
            lib.gen_castbar(self)
            lib.debuffHighlight(self)
            self.Power.PostUpdate = lib.setPowerArrowColor
            
            -- PvP Icon
            local pvp = self.Health:CreateTexture(nil, "OVERLAY")
            pvp:SetHeight(32)
            pvp:SetWidth(32)
            pvp:SetPoint("BOTTOMLEFT", -8, -16
            )
            self.MyPvP = pvp
            
            -- This makes oUF update the information.
            self:RegisterEvent("UNIT_FACTION", MyPvPUpdate)
            -- This makes oUF update the information on forced updates.
            table.insert(self.__elements, MyPvPUpdate)
            
            if cfg.showRunebar then lib.genRunes(self) end
            if cfg.showClassbar then lib.gen_Classbar(self) end
            lib.RogueComboPoints(self)
            lib.gen_AltPowerBar(self)
            
            -- Addons
            if cfg.showTotemBar then lib.gen_TotemBar(self) end
        --== smooth power text for player==--
        end,
        
        target = function(self, ...)
            
            self.mystyle = "target"
            
            -- Size and Scale
            self:SetScale(cfg.scale)
            self:SetSize(256, 38)
            
            -- Generate Bars
            lib.gen_hpbar(self)
            lib.gen_hpstrings(self)
            lib.gen_highlight(self)
            lib.gen_ppbar(self)
            lib.gen_RaidMark(self)
            lib.gen_combat_feedback(self)
            lib.gen_floating_combat_feedback(self)
            
            --style specific stuff
            self.Health.frequentUpdates = true
            self.Health.colorSmooth = true
            self.Health.Smooth = true
            -- self.Health.bg.multiplier = 0.3
            self.Power.frequentUpdates = true
            self.Power.Smooth = true
            self.Power.colorTapping = true
            self.Power.colorDisconnected = true
            self.Power.colorHappiness = false
            self.Power.colorHealth = true
            self.Power.colorReaction = true
            self.Power.colorClass = true
            self.Power.bg.multiplier = 0.5
            if cfg.ShowExtraUnitArrows then self.Power.PostUpdate = lib.setClassArrowColor end
            lib.gen_castbar(self)
            lib.gen_mirrorcb(self)
            lib.debuffHighlight(self)
            lib.HealPred(self)
            
            -- PvP Icon
            local pvp = self.Health:CreateTexture(nil, "OVERLAY")
            --pvp:SetTexture(1, 0, 0)
            pvp:SetHeight(36)
            pvp:SetWidth(36)
            pvp:SetPoint("BOTTOMRIGHT", 24, -12)
            self.MyPvP = pvp
            
            -- This makes oUF update the information.
            self:RegisterEvent("UNIT_FACTION", MyPvPUpdate)
            -- This makes oUF update the information on forced updates.
            table.insert(self.__elements, MyPvPUpdate)
            
            if cfg.showTargetBuffs then lib.createBuffs(self) end
            if cfg.showTargetDebuffs then lib.createDebuffs(self) end
        end,
        
        targettarget = function(self, ...)
            
            self.mystyle = "tot"
            
            -- Size and Scale
            self:SetScale(cfg.scale)
            self:SetSize(150, 30)
            
            -- Generate Bars
            lib.gen_hpbar(self)
            lib.gen_hpstrings(self)
            lib.gen_highlight(self)
            lib.gen_ppbar(self)
            lib.gen_RaidMark(self)
            
            --style specific stuff
            self.Health.frequentUpdates = true
            self.Health.colorSmooth = true
            self.Health.Smooth = true
            -- self.Health.bg.multiplier = 0.3
            self.Power.Smooth = true
            self.Power.colorTapping = true
            self.Power.colorDisconnected = true
            self.Power.colorHappiness = false
            self.Power.colorClass = true
            self.Power.colorReaction = true
            self.Power.colorHealth = true
            self.Power.bg.multiplier = 0.5
            lib.HealPred(self)
            lib.createBuffs(self)
            lib.createDebuffs(self)
        
        end,
        
        focus = function(self, ...)
            
            self.mystyle = "focus"
            
            -- Size and Scale
            self:SetScale(cfg.scale)
            self:SetSize(140, 30)
            
            -- Generate Bars
            lib.gen_hpbar(self)
            lib.gen_hpstrings(self)
            lib.gen_highlight(self)
            lib.gen_ppbar(self)
            lib.gen_RaidMark(self)
            
            --style specific stuff
            self.Health.frequentUpdates = true
            self.Health.Smooth = true
            self.Health.colorSmooth = true
            -- self.Health.bg.multiplier = 0.3
            self.Power.Smooth = true
            self.Power.colorTapping = true
            self.Power.colorDisconnected = true
            self.Power.colorHappiness = false
            self.Power.colorClass = true
            self.Power.colorReaction = true
            self.Power.colorHealth = true
            self.Power.bg.multiplier = 0.5
            if cfg.ShowExtraUnitArrows then self.Power.PostUpdate = lib.setClassArrowColor end
            lib.gen_castbar(self)
            lib.HealPred(self)
            lib.createDebuffs(self)
        end,
        
        focustarget = function(self, ...)
            
            self.mystyle = "focustarget"
            
            -- Size and Scale
            self:SetScale(cfg.scale)
            self:SetSize(140, 30)
            
            -- Generate Bars
            lib.gen_hpbar(self)
            lib.gen_hpstrings(self)
            lib.gen_highlight(self)
            lib.gen_ppbar(self)
            lib.gen_RaidMark(self)
            
            --style specific stuff
            self.Health.frequentUpdates = true
            self.Health.colorSmooth = true
            self.Health.colorClass = true
            self.Health.Smooth = true
            self.Power.Smooth = true
            self.Power.colorTapping = true
            self.Power.colorDisconnected = true
            self.Power.colorPower = true
            self.Power.colorReaction = true
            self.Power.bg.multiplier = 0.5
            if cfg.ShowExtraUnitArrows then self.Power.PostUpdate = lib.setPowerArrowColor end
            lib.gen_castbar(self)
            lib.HealPred(self)
        
        end}

-- Pet style
local function CreatePetStyle(self, unit)
    
    self.mystyle = "pet"
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    -- Size and Scale
    self:SetScale(cfg.scale)
    self:SetSize(90, 30)
    
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.Smooth = true
    -- self.Health.bg.multiplier = 0.3
    self.Power.Smooth = true
    self.Power.colorTapping = true
    self.Power.colorDisconnected = true
    self.Power.colorHappiness = false
    self.Power.colorClass = true
    self.Power.colorReaction = true
    self.Power.colorHealth = true
    self.Power.bg.multiplier = 0.5
    lib.gen_castbar(self)
    lib.HealPred(self)

end

-- Partypet style
local function CreatePartyPetStyle(self)
    
    -- Size and Scale
    self:SetScale(cfg.scale)
    self:SetSize(90, 30)
    self.mystyle = "partypet"
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.Smooth = true
    -- self.Health.bg.multiplier = 0.3
    self.Power.Smooth = true
    self.Power.colorTapping = true
    self.Power.colorDisconnected = true
    self.Power.colorHappiness = false
    self.Power.colorClass = true
    self.Power.colorReaction = true
    self.Power.colorHealth = true
    self.Power.bg.multiplier = 0.5
    lib.gen_castbar(self)

end

-- Party style
local function CreatePartyStyle(self)
    self.menu = lib.menu
    self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type2", "menu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    if self:GetAttribute("unitsuffix") == "pet" then
        return CreatePartyPetStyle(self)
    end
    self.mystyle = "party"
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    lib.ReadyCheck(self)
    lib.gen_LFDRole(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.Smooth = true
    self.Power.Smooth = true
    -- self.Health.bg.multiplier = 0.3
    self.Power.colorClass = true
    self.Power.bg.multiplier = 0.5
    self.Power.arrow.colorPower = true
    if cfg.ShowExtraUnitArrows then self.Power.PostUpdate = lib.setClassArrowColor end
    lib.gen_InfoIcons(self)
    lib.CreateTargetBorder(self)
    lib.CreateThreatBorder(self)
    lib.HealPred(self)
    lib.debuffHighlight(self)
    lib.raidDebuffs(self)
    
    self.Health.PostUpdate = lib.PostUpdateRaidFrame
    self:RegisterEvent('PLAYER_TARGET_CHANGED', lib.ChangedTarget)
    self:RegisterEvent('RAID_ROSTER_UPDATE', lib.ChangedTarget)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", lib.UpdateThreat)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", lib.UpdateThreat)
end

-- Raid frames layout
local CreateRaidStyle = function(self, unit, isSingle)
    self.menu = lib.menu
    self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type2", "menu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self.mystyle = "failRaid"
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    lib.ReadyCheck(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    --self.Health.Smooth = true
    --self.Power.Smooth = true
    -- self.Health.bg.multiplier = 0.3
    self.Power.colorClass = true
    self.Power.bg.multiplier = 0.5
    lib.gen_InfoIcons(self)
    lib.CreateTargetBorder(self)
    lib.CreateThreatBorder(self)
    lib.HealPred(self)
    lib.debuffHighlight(self)
    lib.raidDebuffs(self)
    lib.createAuraWatch(self, unit)
    
    self.Health.PostUpdate = lib.PostUpdateRaidFrame
    self:RegisterEvent('PLAYER_TARGET_CHANGED', lib.ChangedTarget)
    self:RegisterEvent('GROUP_ROSTER_UPDATE', lib.ChangedTarget)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", lib.UpdateThreat)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", lib.UpdateThreat)
end


-- The Shared Style Function
local GlobalStyle = function(self, unit, isSingle)
        
        self.menu = lib.spawnMenu
        self:RegisterForClicks('AnyDown')
        
        -- Call Unit Specific Styles
        if (UnitSpecific[unit]) then
            return UnitSpecific[unit](self)
        end
end

-- The Shared Style Function for Party and Raid
local GroupGlobalStyle = function(self, unit)
        
        self.menu = lib.spawnMenu
        self:RegisterForClicks('AnyDown')
        
        -- Call Unit Specific Styles
        if (UnitSpecific[unit]) then
            return UnitSpecific[unit](self)
        end
end

-- Boss frames layout
local function CreateBossStyle(self, unit)
    
    self.mystyle = "failBoss"
    
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    
    -- Size and Scale
    self:SetSize(150, 29)
    
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    --self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorPower = true
    self.Power.colorReaction = true
    self.Power.colorTapping = true
    self.Power.bg.multiplier = 0.5
    lib.gen_castbar(self)
    lib.gen_mirrorcb(self)

--[[if cfg.showBossBuffs then	lib.createBuffs(self) end
if cfg.showBossDebuffs then lib.createDebuffs(self) end
]]
end

local function CreateMTStyle(self, unit, isSingle)
    self.mystyle = "failMT"
    self:SetSize(150, 29)
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    lib.ReadyCheck(self)
    lib.createDebuffs(self)
    self.Health.frequentUpdates = false
    self.Health.colorClass = true

end

local function CreateArenaStyle(self, unit, isSingle)
    self.mystyle = "failArena"
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = .3,
    }
    
    -- Size and Scale
    self:SetSize(150, 29)
    
    -- Generate Bars
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib.gen_ppbar(self)
    lib.gen_RaidMark(self)
    
    --style specific stuff
    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    --self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorHealth = true
    self.Power.colorClass = true
    self.Power.bg.multiplier = 0.5
    lib.gen_castbar(self)
    lib.gen_mirrorcb(self)
    
    lib.createBuffs(self)
    lib.createDebuffs(self)

end

-----------------------------
-- SPAWN UNITS
-----------------------------
oUF:RegisterStyle('fail', GlobalStyle)
oUF:RegisterStyle('failPet', CreatePetStyle)
oUF:RegisterStyle('failParty', CreatePartyStyle)
oUF:RegisterStyle('failRaid', CreateRaidStyle)
oUF:RegisterStyle('failMT', CreateMTStyle)
oUF:RegisterStyle('failArena', CreateArenaStyle)
oUF:RegisterStyle('failBoss', CreateBossStyle)

oUF:Factory(function(self)
        -- Single Frames
        self:SetActiveStyle('fail')
        self:Spawn('player'):SetPoint("CENTER", UIParent, cfg.PlayerRelativePoint, cfg.PlayerX, cfg.PlayerY)
        self:Spawn('target'):SetPoint("CENTER", UIParent, cfg.TargetRelativePoint, cfg.TargetX, cfg.TargetY)
        if cfg.showtot then self:Spawn('targettarget'):SetPoint("BOTTOMLEFT", oUF_failTarget, cfg.TotRelativePoint, cfg.TotX, cfg.TotY) end
        if cfg.showfocus then self:Spawn('focus'):SetPoint("BOTTOMRIGHT", oUF_failPlayer, cfg.FocusRelativePoint, cfg.FocusX, cfg.FocusY) end
        if cfg.showfocustarget then self:Spawn('focustarget'):SetPoint("BOTTOMLEFT", oUF_failFocus, "TOPRIGHT", cfg.FocusTargetX, cfg.FocusTargetY) end
        
        if cfg.showpet then
            self:SetActiveStyle("failPet")
            local pet = self:Spawn("pet", "oUF_failPetFrame")
            pet:SetPoint("TOPRIGHT", oUF_failPlayer, "TOPLEFT", -14, 0)
            pet:SetScale(cfg.scale)
        end
        
        -- Party Frames
        if cfg.ShowParty then
            self:SetActiveStyle('failParty')
            local party = oUF:SpawnHeader('failParty', nil, 'custom  [group:party,nogroup:raid][@raid6,noexists,group:raid] show;hide',
                --local party = oUF:SpawnHeader('oUF_Party', nil, "solo", "showSolo", true,  -- debug
                "showParty", true,
                "showPlayer", false,
                'template', 'oUF_failPartyPet',
                --'useOwnerUnit', true,
                "yoffset", -20,
                "oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
   		]] ):format(128, 26))
            party:SetScale(cfg.partyScale)
            party:SetPoint('BOTTOM', UIParent, 'CENTER', cfg.PartyX, cfg.PartyY)
        else
            oUF:DisableBlizzard 'party'
        end
        
        -- Raid Frames
        if cfg.ShowRaid then
            self:SetActiveStyle('failRaid')
            
            local raid25 = oUF:SpawnHeader("oUF_Raid", nil, "custom show; [@raid6,exists] show; hide", -- Raid frames for 6-25 players.
                "showRaid", cfg.ShowRaid,
                "showSolo", false,
                "showPlayer", true,
                "showParty", false,
                "xoffset", 9,
                "yOffset", -8,
                "groupFilter", "1,2,3,4,5,6,7,8",
                "groupBy", "GROUP",
                "groupingOrder", "1,2,3,4,5,6,7,8",
                "sortMethod", "INDEX",
                "maxColumns", 8,
                "unitsPerColumn", 5,
                "columnSpacing", 12,
                "point", "TOP",
                "columnAnchorPoint", "RIGHT",
                "oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
		]] ):format(75, 25))
            --raid25:SetScale(cfg.raidScale)
            raid25:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', cfg.RaidX, cfg.RaidY)
            
            local raid40 = oUF:SpawnHeader("oUF_Raid", nil, "custom [@raid26,exists] hide; hide", -- Raid frames for 26-40 players.
                "showRaid", cfg.ShowRaid,
                "showPlayer", true,
                "showParty", false,
                "xoffset", 9,
                "yOffset", -8,
                "groupFilter", "1,2,3,4,5,6,7,8",
                "groupBy", "GROUP",
                "groupingOrder", "1,2,3,4,5,6,7,8",
                "sortMethod", "INDEX",
                "maxColumns", 8,
                "unitsPerColumn", 5,
                "columnSpacing", 9,
                "point", "TOP",
                "columnAnchorPoint", "RIGHT",
                "oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
		]]):format(50, 25))
            --raid40:SetScale(cfg.raidScale)
            raid40:SetPoint('CENTER', UIParent, 'CENTER', cfg.RaidX + 135, cfg.RaidY)
        
        end
        
        -- Main Tank Frames
        if cfg.showMTFrames then
            self:SetActiveStyle('failMT')
            local tank = oUF:SpawnHeader('oUF_MT', nil, 'raid',
                'oUF-initialConfigFunction', ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]] ):format(80, 22),
                'showRaid', true,
                'groupFilter', 'MAINTANK',
                'yOffset', 8,
                'point', 'BOTTOM',
                'template', 'oUF_MainTank')
            tank:SetPoint("TOP", UIParent, "TOP", cfg.TankX, cfg.TankY)
        end
        
        -- Boss Frames
        if cfg.showBossFrames then
            self:SetActiveStyle('failBoss')
            local boss = {}
            for i = 1, MAX_BOSS_FRAMES do
                boss[i] = self:Spawn("boss" .. i, "oUF_Boss" .. i)
                if i == 1 then
                    boss[i]:SetPoint("CENTER", UIParent, "CENTER", cfg.BossX, cfg.BossY)
                else
                    boss[i]:SetPoint("BOTTOMRIGHT", boss[i - 1], "BOTTOMRIGHT", 0, 60)
                end
            end
        end
        
        -- Arena Frames
        if cfg.showArenaFrames then
            self:SetActiveStyle('failArena')
            
            local arena = {}
            for i = 1, 5 do
                arena[i] = self:Spawn("arena" .. i, "oUF_Arena" .. i)
                if i == 1 then
                    arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "TOPRIGHT", cfg.BossX, cfg.BossY)
                else
                    arena[i]:SetPoint("BOTTOMRIGHT", arena[i - 1], "BOTTOMRIGHT", 0, 90)
                end
                arena[i]:SetSize(150, 30)
            end
            
            local FailPrepArena = {}
            for i = 1, 5 do
                FailPrepArena[i] = CreateFrame("Frame", "FailPrepArena" .. i, UIParent)
                FailPrepArena[i]:SetAllPoints(arena[i])
                FailPrepArena[i]:SetBackdropColor(0, 0, 0)
                --CreateShadow(FailPrepArena[i])
                FailPrepArena[i].Health = CreateFrame("StatusBar", nil, FailPrepArena[i])
                FailPrepArena[i].Health:SetAllPoints()
                FailPrepArena[i].Health:SetStatusBarTexture(cfg.statusbar_texture)
                FailPrepArena[i].Health:SetStatusBarColor(.3, .3, .3, 1)
                FailPrepArena[i].SpecClass = FailPrepArena[i].Health:CreateFontString(nil, "OVERLAY")
                FailPrepArena[i].SpecClass:SetFont(cfg.font, 9, "OUTLINE")
                FailPrepArena[i].SpecClass:SetPoint("CENTER")
                FailPrepArena[i]:Hide()
            end
            
            local ArenaListener = CreateFrame("Frame", "FailArenaListener", UIParent)
            ArenaListener:RegisterEvent("PLAYER_ENTERING_WORLD")
            ArenaListener:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
            ArenaListener:RegisterEvent("ARENA_OPPONENT_UPDATE")
            ArenaListener:SetScript("OnEvent", function(self, event)
                if event == "ARENA_OPPONENT_UPDATE" then
                    for i = 1, 5 do
                        local f = _G["FailPrepArena" .. i]
                        f:Hide()
                    end
                else
                    local numOpps = GetNumArenaOpponentSpecs()
                    
                    if numOpps > 0 then
                        for i = 1, 5 do
                            local f = _G["FailPrepArena" .. i]
                            local s = GetArenaOpponentSpec(i)
                            local _, spec, class = nil, "UNKNOWN", "UNKNOWN"
                            
                            if s and s > 0 then
                                _, spec, _, _, _, _, class = GetSpecializationInfoByID(s)
                            end
                            
                            if (i <= numOpps) then
                                if class and spec then
                                    f.SpecClass:SetText(spec .. "  -  " .. LOCALIZED_CLASS_NAMES_MALE[class])
                                    
                                    local color = arena[i].colors.class[class]
                                    f.Health:SetStatusBarColor(unpack(color))
                                    
                                    f:Show()
                                end
                            else
                                f:Hide()
                            end
                        end
                    else
                        for i = 1, 5 do
                            local f = _G["FailPrepArena" .. i]
                            f:Hide()
                        end
                    end
                end
            end)
        
        end
end)
