  -----------------------------
  -- INIT
  -----------------------------

  local addon, ns = ...
  local cfg = CreateFrame("Frame")
  local mediaFolder = "Interface\\AddOns\\oUF_Fail\\media\\"	-- don't touch this ...

  -----------------------------
  -- CONFIG
  -----------------------------
  
  -- Units
  cfg.showtot = true -- show target of target frame
  cfg.showpet = true -- show pet frame
  cfg.showpartypet = true -- show party pet frame
  cfg.showfocus = true -- show focus frame
  cfg.showfocustarget = true -- show focus target frame
  cfg.ShowPlayerName = true -- show player's name and level
  cfg.ShowExtraUnitArrows = true -- show power arrows on additional frames (target, focus, focus target)
  cfg.showBossFrames = true -- show boss frame
  cfg.showMTFrames = false -- show main tank frame - not yet working
  
  -- Raid and Party
  cfg.ShowParty = true -- show party frames
  cfg.party_leader_icon = true -- Show Leader Icon
  cfg.ShowRaid = true -- show raid frames

  -- Positioning 
  cfg.PlayerX = -244 -- Player frame's x-offset position from the relative point of the screen
  cfg.PlayerY = -240 -- Player frame's y-offset position from the relative point of the screen
  cfg.PlayerRelativePoint = "CENTER" -- Player frame's reference point of the screen used for X and Y offsets. Possible values are: "TOP"/"BOTTOM"/"LEFT"/"RIGHT"/"CENTER"/"TOPLEFT"/"ROPRIGHT"/"BOTTOMLEFT"/"BOTTOMRIGHT"
  cfg.TargetX = 0 -- Target frame's x-offset position from the relative point of the screen
  cfg.TargetY = -198 -- Target frame's y-offset position from the relative point of the screen
  cfg.TargetRelativePoint = "CENTER" -- Target frame's reference point of the screen used for X and Y offsets. Possible values are: "TOP"/"BOTTOM"/"LEFT"/"RIGHT"/"CENTER"/"TOPLEFT"/"ROPRIGHT"/"BOTTOMLEFT"/"BOTTOMRIGHT"
  cfg.TotX = 16 -- Target of target frame's x-offset position from the relative point of the screen
  cfg.TotY = 6 -- Target of target frame's y-offset position from the relative point of the screen
  cfg.TotRelativePoint = "TOPRIGHT" -- Target of target frame's reference point of the screen used for X and Y offsets. Possible values are: "TOP"/"BOTTOM"/"LEFT"/"RIGHT"/"CENTER"/"TOPLEFT"/"ROPRIGHT"/"BOTTOMLEFT"/"BOTTOMRIGHT"  cfg.PartyX = -290 -- Party Frames Horizontal Position
  cfg.FocusX = -350 -- Focus frame's x-offset position from the relative point of the screen
  cfg.FocusY = 490 -- Focus frame's y-offset position from the relative point of the screen
  cfg.FocusRelativePoint = "TOPRIGHT" -- Focus frame's reference point of the screen used for X and Y offsets.   
  cfg.FocusTargetX = 16
  cfg.FocusTargetY = 4
  cfg.FocusTargetRelativePoint = "TOPRIGHT" -- Focus target frame's reference point of the screen used for X and Y offsets.   
  cfg.PartyX = -480 -- Party Frames Horizontal Position
  cfg.PartyY = -180 -- Party Frames Vertical Position
  cfg.RaidX = 6 -- Party Frames Horizontal Position
  cfg.RaidY = -6 -- Party Frames Vertical Position
  cfg.BossX = 600 -- Boss Frames Horizontal Position
  cfg.BossY = -60 -- Boss Frames Vertical Position
  cfg.TankX = 30 -- Main Tank Frames Horizontal Position
  cfg.TankY = -230 -- Main Tank Frames Vertical Position
      
  -- Auras
  cfg.showTargetBuffs = true -- show target buffs
  cfg.showTargetDebuffs = true -- show target debuffs
  cfg.debuffsOnlyShowPlayer = true -- only show your debuffs on target
  cfg.buffsOnlyShowPlayer = false -- only show your buffs
  cfg.showBossBuffs = true -- show target buffs
  cfg.showBossDebuffs = true -- show target debuffs

  -- Plugins
  cfg.enableDebuffHighlight = true -- enable *dispellable* debuff highlight for raid frames
  cfg.showRaidDebuffs = true -- enable important debuff icons to show on raid units
  cfg.showAuraWatch = false -- enable display of HoTs and important player buffs/debuffs on raid frames (broken)
  cfg.CombatFeedback = false -- enable standard oUF_CombatFeedback
  cfg.FloatingCombatFeedback = true -- enable oUF_FloatingCombatFeedback by lightspark
  cfg.FountainMode = false -- enable fountain mode for oUF_CombatFeedback
  
  -- Misc
  cfg.showExperience = true -- show experience bar
  cfg.showRunebar = true -- show DK's rune bar
  cfg.showClassbar= true -- Shadow orbs, soul shards, holy power and chi
  cfg.RCheckIcon = true -- show raid check icon
  cfg.Castbars = true -- use built-in castbars
  cfg.ShowIncHeals = true -- Show incoming heals in player and raid frames
  cfg.showLFDIcons = true -- Show dungeon role icons in raid/party
  
  cfg.statusbar_texture = mediaFolder.."healthbar"
  cfg.powerbar_texture = mediaFolder.."powerbar"
  cfg.xpbar_texture = mediaFolder.."xpbar"
  cfg.backdrop_texture = mediaFolder.."backdrop"
  cfg.highlight_texture = mediaFolder.."raidbg"
  cfg.debuffhighlight_texture = mediaFolder.."debuff_highlight"
  cfg.backdrop_edge_texture = mediaFolder.."backdrop_edge"
  cfg.debuffBorder = mediaFolder.."iconborder"
  cfg.spark = mediaFolder.."spark"
  cfg.font = mediaFolder.."Neuropol.ttf"
  cfg.healthbarfontsize = 30
  cfg.namefont = mediaFolder.."ROADWAY.ttf"
  cfg.smallfont = mediaFolder.."Emblem.ttf"
  cfg.raidScale = 1 -- scale factor for raid frames
  cfg.partyScale = 1 -- scale factor for party frames
  cfg.scale = 1 -- scale factor for all other frames
  
  -----------------------------
  -- HANDOVER
  -----------------------------
  
  ns.cfg = cfg
