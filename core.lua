-- Vi opretter den fælles "kasse" (GS), som alle filerne kan dele
local addonName, GS = ...

local InitFrame = CreateFrame("Frame")
InitFrame:RegisterEvent("ADDON_LOADED")
InitFrame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        GetSchwiiftyDB = GetSchwiiftyDB or {} 
    end
end)

-------------------------------------------------
-- HOVEDVINDUE (SKELETTET)
-------------------------------------------------
GS.MainFrame = CreateFrame("Frame", "GS_MainFrame", UIParent, "BasicFrameTemplateWithInset")
GS.MainFrame:SetSize(950, 550) 
GS.MainFrame:SetPoint("CENTER", UIParent, "CENTER")
GS.MainFrame:SetMovable(true)
GS.MainFrame:EnableMouse(true)
GS.MainFrame:RegisterForDrag("LeftButton")
GS.MainFrame:SetScript("OnDragStart", GS.MainFrame.StartMoving)
GS.MainFrame:SetScript("OnDragStop", GS.MainFrame.StopMovingOrSizing)
GS.MainFrame:Hide()
tinsert(UISpecialFrames, "GS_MainFrame")

GS.MainFrame.title = GS.MainFrame:CreateFontString(nil, "OVERLAY")
GS.MainFrame.title:SetFontObject("GameFontHighlight")
GS.MainFrame.title:SetPoint("CENTER", GS.MainFrame.TitleBg, "CENTER", 0, 0)
GS.MainFrame.title:SetText("Get Schwiifty")

-------------------------------------------------
-- INDHOLDSRAMMER (CONTAINERS TIL MODULERNE)
-------------------------------------------------
-- Vi laver tre usynlige rammer inde i hovedvinduet. Modulerne fylder deres egen ramme ud.
GS.DungeonTabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.DungeonTabContainer:SetAllPoints(GS.MainFrame.InsetBg)
GS.DungeonTabContainer:Show() -- Starter med at være synlig

GS.CraftingTabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.CraftingTabContainer:SetAllPoints(GS.MainFrame.InsetBg)
GS.CraftingTabContainer:Hide()

GS.UITabContainer = CreateFrame("Frame", nil, GS.MainFrame)
GS.UITabContainer:SetAllPoints(GS.MainFrame.InsetBg)
GS.UITabContainer:Hide()

-------------------------------------------------
-- FANEBLADE (TABS) TIL AT SKIFTE MELLEM MODULER
-------------------------------------------------
local function SkiftFane(valgtFane)
    GS.DungeonTabContainer:Hide()
    GS.CraftingTabContainer:Hide()
    GS.UITabContainer:Hide()
    
    if valgtFane == "Dungeon" then GS.DungeonTabContainer:Show()
    elseif valgtFane == "Crafting" then GS.CraftingTabContainer:Show()
    elseif valgtFane == "UI" then GS.UITabContainer:Show() end
end

-- Dungeon Fane
local Tab1 = CreateFrame("Button", nil, GS.MainFrame, "UIPanelButtonTemplate")
Tab1:SetSize(100, 25)
Tab1:SetPoint("TOPLEFT", GS.MainFrame, "TOPLEFT", 60, -30)
Tab1:SetText("Dungeon")
Tab1:SetScript("OnClick", function() SkiftFane("Dungeon") end)

-- Crafting Fane
local Tab2 = CreateFrame("Button", nil, GS.MainFrame, "UIPanelButtonTemplate")
Tab2:SetSize(100, 25)
Tab2:SetPoint("LEFT", Tab1, "RIGHT", 5, 0)
Tab2:SetText("Crafting")
Tab2:SetScript("OnClick", function() SkiftFane("Crafting") end)

-- UI Fane
local Tab3 = CreateFrame("Button", nil, GS.MainFrame, "UIPanelButtonTemplate")
Tab3:SetSize(100, 25)
Tab3:SetPoint("LEFT", Tab2, "RIGHT", 5, 0)
Tab3:SetText("UI Trackers")
Tab3:SetScript("OnClick", function() SkiftFane("UI") end)

-------------------------------------------------
-- CHAT KOMMANDO OG MINIMAP
-------------------------------------------------
SLASH_GETSCHWIIFTY1 = "/gs"
SLASH_GETSCHWIIFTY2 = "/getschwiifty"
SlashCmdList["GETSCHWIIFTY"] = function()
    if GS.MainFrame:IsShown() then 
        GS.MainFrame:Hide() 
    else 
        GS.MainFrame:Show() 
        -- Vi beder Dungeon-modulet om at opdatere sig selv, hvis det er bygget
        if GS.SyncDungeonData then GS.SyncDungeonData() end
    end
end

local minimapBtn = CreateFrame("Button", "GS_MinimapButton", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)
minimapBtn:SetNormalTexture("Interface\\Icons\\inv_misc_key_03") 
minimapBtn:SetPushedTexture("Interface\\Icons\\inv_misc_key_03")
minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
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
minimapBtn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil); self:UnlockHighlight() end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Get Schwiifty")
    GameTooltip:AddLine("Left-click to open/close window.", 1, 1, 1)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

if LibStub then
    local ldb = LibStub("LibDataBroker-1.1", true)
    if ldb then
        ldb:NewDataObject("GetSchwiifty", {
            type = "data source", text = "Get Schwiifty", icon = "Interface\\Icons\\inv_misc_key_03",
            OnClick = function(clickedframe, button)
                if button == "LeftButton" then 
                    if GS.MainFrame:IsShown() then GS.MainFrame:Hide() else 
                        GS.MainFrame:Show()
                        if GS.SyncDungeonData then GS.SyncDungeonData() end
                    end 
                end
            end,
            OnTooltipShow = function(tooltip) tooltip:SetText("Get Schwiifty"); tooltip:AddLine("Click to open the overview!", 1, 1, 1) end,
        })
    end
end