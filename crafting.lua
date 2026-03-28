local addonName, GS = ...

local LoadFrame = CreateFrame("Frame")
LoadFrame:RegisterEvent("ADDON_LOADED")
LoadFrame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        GetSchwiiftyDB = GetSchwiiftyDB or {}
        GetSchwiiftyDB.MyProfessions = GetSchwiiftyDB.MyProfessions or {} 
        GetSchwiiftyDB.GuildCrafters = GetSchwiiftyDB.GuildCrafters or {} 
        
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
-- DEN NYE AVANCEREDE "PROFESSION TYV"
-------------------------------------------------
local ProfScanner = CreateFrame("Frame")
ProfScanner:RegisterEvent("TRADE_SKILL_SHOW")
ProfScanner:SetScript("OnEvent", function()
    local profInfo = C_TradeSkillUI.GetBaseProfessionInfo()
    local link = C_TradeSkillUI.GetTradeSkillListLink()
    
    if profInfo and profInfo.professionName and link then
        -- Vi klipper servernavnet af vores eget navn for en sikkerheds skyld
        local myShortName = strsplit("-", UnitName("player"))
        
        GetSchwiiftyDB.MyProfessions[profInfo.professionName] = link
        
        -- Vi gemmer det også i Guild-listen under os selv med det samme
        GetSchwiiftyDB.GuildCrafters[myShortName] = GetSchwiiftyDB.GuildCrafters[myShortName] or {}
        GetSchwiiftyDB.GuildCrafters[myShortName][profInfo.professionName] = link
        
        -- Fortæl brugeren at vi har fanget det!
        print("|cFF00FFFF[Get Schwiifty]|r Profession link saved: " .. profInfo.professionName)
        
        local packet = "PROF;" .. myShortName .. ";" .. profInfo.professionName .. ";" .. link
        C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
        
        if GS.OpdaterCrafterTabel then GS.OpdaterCrafterTabel() end
    end
end)

local CraftingListener = CreateFrame("Frame")
CraftingListener:RegisterEvent("CHAT_MSG_ADDON")
CraftingListener:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if prefix == "GetSchwiifty" and GetSchwiiftyDB then
        if string.sub(text, 1, 5) == "PROF;" then
            local _, pName, profName, link = strsplit(";", text, 4) 
            if pName and profName and link then
                -- Sørger for at fjerne servernavnet fra senderen også
                local shortName = strsplit("-", pName)
                
                GetSchwiiftyDB.GuildCrafters[shortName] = GetSchwiiftyDB.GuildCrafters[shortName] or {}
                GetSchwiiftyDB.GuildCrafters[shortName][profName] = link
                
                if GS.OpdaterCrafterTabel then GS.OpdaterCrafterTabel() end
            end
        elseif text == "SYNC_REQUEST" then
            if GetSchwiiftyDB.MyProfessions then
                local myShortName = strsplit("-", UnitName("player"))
                for pName, pLink in pairs(GetSchwiiftyDB.MyProfessions) do
                    C_Timer.After(math.random() * 2, function()
                        local packet = "PROF;" .. myShortName .. ";" .. pName .. ";" .. pLink
                        C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
                    end)
                end
            end
        end
    end
end)

-------------------------------------------------
-- AUTO-ANNOUNCE LOGIK
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

local kolonner = {
    {navn = "Crafter Name", bredde = 140},
    {navn = "Guild Rank", bredde = 130},
    {navn = "Level / Class", bredde = 160},
    {navn = "Known Professions", bredde = 180},
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
    local row = CreateFrame("Frame", nil, GS.CraftingTabContainer, "BackdropTemplate")
    row:SetSize(910, 20)
    row:SetPoint("TOPLEFT", GS.CraftingTabContainer, "TOPLEFT", startX, rowY - ((i-1) * 20))
    
    row:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    if i % 2 == 0 then
        row:SetBackdropColor(1, 1, 1, 0.04) 
    else
        row:SetBackdropColor(1, 1, 1, 0.01) 
    end
    
    row.felter = {}
    local feltX = 0
    for j, info in ipairs(kolonner) do
        if j == 5 then 
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
                if self.crafterName then
                    local cData = GetSchwiiftyDB.GuildCrafters[self.crafterName]
                    if cData then
                        print("|cFF00FFFF[Get Schwiifty]|r Found recipes for " .. self.crafterName .. ":")
                        for pName, pLink in pairs(cData) do
                            print("- " .. pLink)
                            local linkString = pLink:match("|H(.-)|h")
                            if linkString then SetItemRef(linkString, pLink, "LeftButton") end
                        end
                    end
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
            
            -- HUSK AT KLIPPE SERVERNAVNET AF HER OGSÅ
            local shortName = strsplit("-", name)
            
            row.felter[1]:SetText(string.format("|c%s%s|r", hexColor, shortName))
            row.felter[2]:SetText(rankName)
            row.felter[3]:SetText("Lvl " .. level .. " " .. classDisplayName)
            
            -- Nu leder vi kun efter "Schwiifty", ikke "Schwiifty-TwistingNether"
            local crafterData = GetSchwiiftyDB.GuildCrafters[shortName]
            if crafterData and next(crafterData) then
                local knownProfs = ""
                for pName, _ in pairs(crafterData) do
                    knownProfs = knownProfs .. pName .. ", "
                end
                knownProfs = knownProfs:sub(1, -3) 
                
                row.felter[4]:SetText("|cff71d5ff" .. knownProfs .. "|r")
                row.felter[5].recipe:Enable()
                row.felter[5].recipe.crafterName = shortName
            else
                row.felter[4]:SetText("|cFF888888Unknown|r")
                row.felter[5].recipe:Disable()
                row.felter[5].recipe.crafterName = nil
            end
            
            row.felter[5].whisper.spillerNavn = shortName 
            
            row:Show()
            rowIndex = rowIndex + 1
        end
    end
end

RefreshCraftersBtn:SetScript("OnClick", function()
    GS.OpdaterCrafterTabel()
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD")
    print("|cFFFFFF00[Get Schwiifty]|r Requesting updated profession data from the guild...")
end)