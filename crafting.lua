local addonName, GS = ...

-- Sikre databaser
local LoadFrame = CreateFrame("Frame")
LoadFrame:RegisterEvent("ADDON_LOADED")
LoadFrame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        GetSchwiiftyDB = GetSchwiiftyDB or {}
        GetSchwiiftyDB.Crafters = GetSchwiiftyDB.Crafters or {} -- Her gemmer vi alle profession links
        if GetSchwiiftyDB.AutoAnnounceGuildOrders and GS_AutoAnnounceCheck then
            GS_AutoAnnounceCheck:SetChecked(true)
        end
    end
end)

-------------------------------------------------
-- CRAFTING UI - OVERSKRIFT & AUTO-ANNOUNCE
-------------------------------------------------
local CraftingTitle = GS.CraftingTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
CraftingTitle:SetPoint("TOPLEFT", GS.CraftingTabContainer, "TOPLEFT", 20, -40)
CraftingTitle:SetText("Guild Crafting Hub")

GS_AutoAnnounceCheck = CreateFrame("CheckButton", "GS_AutoAnnounceCheck", GS.CraftingTabContainer, "UICheckButtonTemplate")
GS_AutoAnnounceCheck:SetPoint("TOPLEFT", CraftingTitle, "BOTTOMLEFT", 0, -10)
GS_AutoAnnounceCheck.text = GS_AutoAnnounceCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GS_AutoAnnounceCheck.text:SetPoint("LEFT", GS_AutoAnnounceCheck, "RIGHT", 5, 0)
GS_AutoAnnounceCheck.text:SetText("Automatically announce my Guild Crafting Orders in /g")

GS_AutoAnnounceCheck:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    GetSchwiiftyDB.AutoAnnounceGuildOrders = isChecked
    if isChecked then
        print("|cFF00FFFF[Get Schwiifty]|r Auto-announce turned ON.")
    else
        print("|cFFFF0000[Get Schwiifty]|r Auto-announce turned OFF.")
    end
end)

-------------------------------------------------
-- DEN USYNLIGE "PROFESSION TYV" OG P2P LYTTER
-------------------------------------------------
-- 1. Fanger dit link når du åbner din profession
local ProfScanner = CreateFrame("Frame")
ProfScanner:RegisterEvent("TRADE_SKILL_SHOW")
ProfScanner:SetScript("OnEvent", function()
    local link = C_TradeSkillUI.GetTradeSkillListLink()
    if link then
        GetSchwiiftyDB.MyProfLink = link
        local packet = "PROF;" .. UnitName("player") .. ";" .. link
        C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
    end
end)

-- 2. Lytter efter andres links på netværket
local CraftingListener = CreateFrame("Frame")
CraftingListener:RegisterEvent("CHAT_MSG_ADDON")
CraftingListener:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if prefix == "GetSchwiifty" and GetSchwiiftyDB then
        if string.sub(text, 1, 5) == "PROF;" then
            local _, pName, link = strsplit(";", text, 3) 
            if pName and link then
                local finalName = pName or sender
                GetSchwiiftyDB.Crafters[finalName] = link
                if GS.OpdaterCrafterTabel then GS.OpdaterCrafterTabel() end
            end
        elseif text == "SYNC_REQUEST" then
            if GetSchwiiftyDB.MyProfLink then
                C_Timer.After(math.random() * 2, function()
                    local packet = "PROF;" .. UnitName("player") .. ";" .. GetSchwiiftyDB.MyProfLink
                    C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
                end)
            end
        end
    end
end)

-------------------------------------------------
-- AUTO-ANNOUNCE LOGIK FOR CRAFTING ORDERS
-------------------------------------------------
if C_CraftingOrders and C_CraftingOrders.PlaceNewOrder then
    hooksecurefunc(C_CraftingOrders, "PlaceNewOrder", function(orderInfo)
        if GS_AutoAnnounceCheck:GetChecked() then
            if orderInfo and orderInfo.orderType == Enum.CraftingOrderType.Guild then
                local besked = "I just placed a new Guild Crafting Order! Please take a look if you can craft it."
                SendChatMessage(besked, "GUILD")
            end
        end
    end)
end

-------------------------------------------------
-- OPDATER KNAP
-------------------------------------------------
local RefreshCraftersBtn = CreateFrame("Button", nil, GS.CraftingTabContainer, "UIPanelButtonTemplate")
RefreshCraftersBtn:SetSize(150, 30)
RefreshCraftersBtn:SetPoint("TOPRIGHT", GS.CraftingTabContainer, "TOPRIGHT", -20, -40)
RefreshCraftersBtn:SetText("Refresh Crafters")

-------------------------------------------------
-- CRAFTER LISTE (KOLONNER OG RÆKKER)
-------------------------------------------------
local headerY = -110 
local startX = 20

-- Vi har tilføjet en kolonne og justeret bredden for at få plads til to knapper!
local kolonner = {
    {navn = "Crafter Name", bredde = 140},
    {navn = "Guild Rank", bredde = 130},
    {navn = "Level / Class", bredde = 160},
    {navn = "Profession", bredde = 180},
    {navn = "Action", bredde = 160} 
}

local currentX = startX
for i, info in ipairs(kolonner) do
    local text = GS.CraftingTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", GS.CraftingTabContainer, "TOPLEFT", currentX, headerY)
    text:SetJustifyH("LEFT")
    text:SetWidth(info.bredde)
    text:SetText(info.navn)
    currentX = currentX + info.bredde
end

local numRows = 14
local raekker = {}
local rowY = headerY - 25

for i = 1, numRows do
    local row = CreateFrame("Frame", nil, GS.CraftingTabContainer)
    row:SetSize(910, 20)
    row:SetPoint("TOPLEFT", GS.CraftingTabContainer, "TOPLEFT", startX, rowY - ((i-1) * 20))
    
    row.felter = {}
    local feltX = 0
    for j, info in ipairs(kolonner) do
        if j == 5 then 
            -- To knapper i den sidste kolonne!
            local whisperBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            whisperBtn:SetSize(75, 20)
            whisperBtn:SetPoint("LEFT", row, "LEFT", feltX, 0)
            whisperBtn:SetText("Whisper")
            whisperBtn:SetScript("OnClick", function(self)
                if self.spillerNavn then ChatFrame_OpenChat("/w " .. self.spillerNavn .. " Hey, can you craft something for me? ") end
            end)
            
            local recipeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            recipeBtn:SetSize(75, 20)
            recipeBtn:SetPoint("LEFT", whisperBtn, "RIGHT", 5, 0)
            recipeBtn:SetText("Recipes")
            recipeBtn:SetScript("OnClick", function(self)
                if self.link then
                    -- Magien der simulerer et klik på et profession link i chatten
                    local linkString = self.link:match("|H(.-)|h")
                    if linkString then SetItemRef(linkString, self.link, "LeftButton") end
                end
            end)

            row.felter[j] = { whisper = whisperBtn, recipe = recipeBtn }
        else
            local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fs:SetSize(info.bredde - 5, 20)
            fs:SetPoint("LEFT", row, "LEFT", feltX, 0)
            fs:SetJustifyH("LEFT")
            fs:SetWordWrap(false)
            row.felter[j] = fs
        end
        feltX = feltX + info.bredde
    end
    row:Hide()
    raekker[i] = row
end

-------------------------------------------------
-- LOGIK TIL AT FYLDE TABELLEN
-------------------------------------------------
GS.OpdaterCrafterTabel = function()
    if not GetSchwiiftyDB then return end
    for i = 1, numRows do raekker[i]:Hide() end
    
    C_GuildInfo.GuildRoster() 
    local totalMembers = GetNumGuildMembers()
    local rowIndex = 1
    
    for i = 1, totalMembers do
        if rowIndex > numRows then break end 
        
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, classToken = GetGuildRosterInfo(i)
        
        if isOnline then
            local row = raekker[rowIndex]
            local colorInfo = RAID_CLASS_COLORS[classToken]
            local hexColor = colorInfo and colorInfo.colorStr or "ffffffff"
            local shortName = strsplit("-", name)
            
            row.felter[1]:SetText(string.format("|c%s%s|r", hexColor, shortName))
            row.felter[2]:SetText(rankName)
            row.felter[3]:SetText("Lvl " .. level .. " " .. classDisplayName)
            
            -- Tjek om vi har stjålet deres profession link!
            local profLink = GetSchwiiftyDB.Crafters[name]
            if profLink then
                local linkText = profLink:match("%[(.-)%]") or "Profession"
                row.felter[4]:SetText("|cff71d5ff[" .. linkText .. "]|r")
                row.felter[5].recipe:Enable()
                row.felter[5].recipe.link = profLink
            else
                row.felter[4]:SetText("|cFF888888Unknown|r")
                row.felter[5].recipe:Disable()
                row.felter[5].recipe.link = nil
            end
            
            row.felter[5].whisper.spillerNavn = name 
            
            row:Show()
            rowIndex = rowIndex + 1
        end
    end
end

RefreshCraftersBtn:SetScript("OnClick", function()
    GS.OpdaterCrafterTabel()
    print("|cFFFFFF00[Get Schwiifty]|r Refreshing guild roster...")
end)