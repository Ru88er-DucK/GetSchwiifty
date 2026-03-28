local addonName, GS = ...

local InitFrame = CreateFrame("Frame")
InitFrame:RegisterEvent("ADDON_LOADED")
InitFrame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        GetSchwiiftyDB = GetSchwiiftyDB or {} 
    end
end)

-------------------------------------------------
-- HOVEDVINDUE (MODERNE DARK MODE SKELET)
-------------------------------------------------
-- Vi fjerner "BasicFrameTemplate" og bruger "BackdropTemplate" for et fladt look
GS.MainFrame = CreateFrame("Frame", "GS_MainFrame", UIParent, "BackdropTemplate")
GS.MainFrame:SetSize(950, 550) 
GS.MainFrame:SetPoint("CENTER", UIParent, "CENTER")
GS.MainFrame:SetMovable(true)
GS.MainFrame:EnableMouse(true)
GS.MainFrame:RegisterForDrag("LeftButton")
GS.MainFrame:SetScript("OnDragStart", GS.MainFrame.StartMoving)
GS.MainFrame:SetScript("OnDragStop", GS.MainFrame.StopMovingOrSizing)
GS.MainFrame:Hide()
tinsert(UISpecialFrames, "GS_MainFrame")

-- Den nye kulsorte baggrund med en skarp 1-pixel kant
GS.MainFrame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
GS.MainFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.95) -- Mørkegrå/sort med 95% opacity
GS.MainFrame:SetBackdropBorderColor(0, 0, 0, 1) -- Kulsort kant

-- En lækker, lidt lysere top-bar
local HeaderBar = CreateFrame("Frame", nil, GS.MainFrame, "BackdropTemplate")
HeaderBar:SetPoint("TOPLEFT", 1, -1)
HeaderBar:SetPoint("TOPRIGHT", -1, -1)
HeaderBar:SetHeight(30)
HeaderBar:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
HeaderBar:SetBackdropColor(0.15, 0.15, 0.15, 1)

GS.MainFrame.title = HeaderBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
GS.MainFrame.title:SetPoint("CENTER", HeaderBar, "CENTER", 0, 0)
GS.MainFrame.title:SetText("|cFF00FFFFGet Schwiifty|r") -- Farvet titel

-- Vi bygger vores egen lukkeknap til hjørnet
local CloseBtn = CreateFrame("Button", nil, HeaderBar, "UIPanelCloseButton")
CloseBtn:SetPoint("RIGHT", HeaderBar, "RIGHT", 0, 0)
CloseBtn:SetScript("OnClick", function() GS.MainFrame:Hide() end)

-------------------------------------------------
-- INDHOLDSRAMMER (CONTAINERS TIL MODULERNE)
-------------------------------------------------
GS.DungeonTabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.DungeonTabContainer:SetPoint("TOPLEFT", GS.MainFrame, "TOPLEFT", 10, -70)
GS.DungeonTabContainer:SetPoint("BOTTOMRIGHT", GS.MainFrame, "BOTTOMRIGHT", -10, 10)
GS.DungeonTabContainer:Show() 

GS.CraftingTabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.CraftingTabContainer:SetPoint("TOPLEFT", GS.MainFrame, "TOPLEFT", 10, -70)
GS.CraftingTabContainer:SetPoint("BOTTOMRIGHT", GS.MainFrame, "BOTTOMRIGHT", -10, 10)
GS.CraftingTabContainer:Hide()

GS.UITabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.UITabContainer:SetPoint("TOPLEFT", GS.MainFrame, "TOPLEFT", 10, -70)
GS.UITabContainer:SetPoint("BOTTOMRIGHT", GS.MainFrame, "BOTTOMRIGHT", -10, 10)
GS.UITabContainer:Hide()

-------------------------------------------------
-- MODERNE FANEBLADE (TABS)
-------------------------------------------------
-- Funktion til at bygge flade faner i stedet for de tykke standard knapper
local function CreateModernTab(name, parent, text, width)
    local btn = CreateFrame("Button", name, parent, "BackdropTemplate")
    btn:SetSize(width, 25)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
    })
    btn:SetBackdropBorderColor(0, 0, 0, 1)
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    
    btn:SetScript("OnEnter", function(self) if not self.isActive then self:SetBackdropColor(0.3, 0.3, 0.3, 1) end end)
    btn:SetScript("OnLeave", function(self) if not self.isActive then self:SetBackdropColor(0.2, 0.2, 0.2, 1) end end)
    
    return btn
end

local Tab1 = CreateModernTab("GS_Tab1", GS.MainFrame, "Dungeon", 100)
Tab1:SetPoint("TOPLEFT", GS.MainFrame, "TOPLEFT", 20, -35)

local Tab2 = CreateModernTab("GS_Tab2", GS.MainFrame, "Crafting", 100)
Tab2:SetPoint("LEFT", Tab1, "RIGHT", 5, 0)

local Tab3 = CreateModernTab("GS_Tab3", GS.MainFrame, "UI Trackers", 100)
Tab3:SetPoint("LEFT", Tab2, "RIGHT", 5, 0)

local Tabs = {Tab1, Tab2, Tab3}

local function SkiftFane(valgtFane, valgtTabBtn)
    GS.DungeonTabContainer:Hide()
    GS.CraftingTabContainer:Hide()
    GS.UITabContainer:Hide()
    
    -- Nulstil alle faner til "inaktiv" farve (mørkegrå)
    for _, tab in ipairs(Tabs) do
        tab.isActive = false
        tab:SetBackdropColor(0.2, 0.2, 0.2, 1)
        tab.text:SetTextColor(1, 0.82, 0) -- Guld
    end
    
    -- Sæt den valgte fane til "aktiv" farve (rødlig for at matche dit gamle tema)
    valgtTabBtn.isActive = true
    valgtTabBtn:SetBackdropColor(0.5, 0.1, 0.1, 1) 
    valgtTabBtn.text:SetTextColor(1, 1, 1) -- Hvid tekst
    
    if valgtFane == "Dungeon" then GS.DungeonTabContainer:Show()
    elseif valgtFane == "Crafting" then GS.CraftingTabContainer:Show()
    elseif valgtFane == "UI" then GS.UITabContainer:Show() end
end

Tab1:SetScript("OnClick", function(self) SkiftFane("Dungeon", self) end)
Tab2:SetScript("OnClick", function(self) SkiftFane("Crafting", self) end)
Tab3:SetScript("OnClick", function(self) SkiftFane("UI", self) end)

-- Sæt Dungeon som standard når vi starter
SkiftFane("Dungeon", Tab1)

-------------------------------------------------
-- CHAT KOMMANDO OG MINIMAP
-------------------------------------------------
SLASH_GETSCHWIIFTY1 = "/gs"
SLASH_GETSCHWIIFTY2 = "/getschwiifty"
SlashCmdList["GETSCHWIIFTY"] = function()
    if GS.MainFrame:IsShown() then GS.MainFrame:Hide() else 
        GS.MainFrame:Show() 
        if GS.SyncDungeonData then GS.SyncDungeonData() end
    end
end

-------------------------------------------------
-- MINIMAP IKON
-------------------------------------------------
local minimapBtn = CreateFrame("Button", "GS_MinimapButton", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("HIGH") -- NYT: Tvinger ikonet til at ligge over alt andet!
minimapBtn:SetFrameLevel(8)
minimapBtn:SetNormalTexture("Interface\\Icons\\inv_misc_key_03") 
minimapBtn:SetPushedTexture("Interface\\Icons\\inv_misc_key_03")
minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Hvis du vil have det til at starte et bestemt sted, kan du ændre tallene her:
minimapBtn:SetPoint("CENTER", Minimap, "CENTER", -78, -78)

local border = minimapBtn:CreateTexture(nil, "OVERLAY")
border:SetSize(52, 52)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", minimapBtn, "TOPLEFT", 0, 0)

minimapBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if GS.MainFrame:IsShown() then GS.MainFrame:Hide() else 
            GS.MainFrame:Show()
            if GS.SyncDungeonData then GS.SyncDungeonData() end 
        end
    end
end)

minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:LockHighlight()
    self:SetScript("OnUpdate", function(self)
        local xpos, ypos = GetCursorPosition()
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
        xpos = xmin - xpos / UIParent:GetScale() + 70
        ypos = ypos / UIParent:GetScale() - ymin - 70
        local angle = math.deg(math.atan2(ypos, xpos))
        local radius = 80
        self:SetPoint("CENTER", Minimap, "CENTER", -(radius * math.cos(math.rad(angle))), radius * math.sin(math.rad(angle)))
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self) 
    self:SetScript("OnUpdate", nil) 
    self:UnlockHighlight() 
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Get Schwiifty")
    GameTooltip:AddLine("Venstreklik for at åbne/lukke vinduet.", 1, 1, 1)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)