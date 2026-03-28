local addonName, GS = ...

-- HER ER MAGIEN DER LÅSER OP FOR NETVÆRKET MELLEM JER!
C_ChatInfo.RegisterAddonMessagePrefix("GetSchwiifty")

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
-- KUN FOR SCHWIIFTY: DEBUG VINDUE
-------------------------------------------------
if UnitName("player") == "Schwiifty" then
    GS.DebugFrame = CreateFrame("Frame", "GS_DebugFrame", UIParent, "BackdropTemplate")
    GS.DebugFrame:SetSize(450, 200)
    GS.DebugFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 20)
    GS.DebugFrame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1})
    GS.DebugFrame:SetBackdropColor(0, 0, 0, 0.8)
    GS.DebugFrame:SetBackdropBorderColor(1, 0, 0, 1)
    GS.DebugFrame:EnableMouse(true)
    GS.DebugFrame:SetMovable(true)
    GS.DebugFrame:RegisterForDrag("LeftButton")
    GS.DebugFrame:SetScript("OnDragStart", GS.DebugFrame.StartMoving)
    GS.DebugFrame:SetScript("OnDragStop", GS.DebugFrame.StopMovingOrSizing)
    
    GS.DebugFrame.title = GS.DebugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    GS.DebugFrame.title:SetPoint("TOP", 0, -5)
    GS.DebugFrame.title:SetText("Schwiifty Developer Log (Træk for at flytte)")
    
    GS.DebugLog = CreateFrame("ScrollingMessageFrame", nil, GS.DebugFrame)
    GS.DebugLog:SetPoint("TOPLEFT", 10, -25)
    GS.DebugLog:SetPoint("BOTTOMRIGHT", -10, 10)
    GS.DebugLog:SetMaxLines(100)
    GS.DebugLog:SetFontObject("ChatFontNormal")
    GS.DebugLog:SetJustifyH("LEFT")
    GS.DebugLog:SetFading(false)
    
    GS.Log = function(msg) GS.DebugLog:AddMessage(msg) end
else
    GS.Log = function(msg) end -- Gør ingenting for andre spillere
end

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
end)

-------------------------------------------------
-- DEN NYE AVANCEREDE "PROFESSION TYV"
-------------------------------------------------
local ProfScanner = CreateFrame("Frame")
ProfScanner:RegisterEvent("TRADE_SKILL_SHOW")
ProfScanner:SetScript("OnEvent", function()
    local profInfo = C_TradeSkillUI.GetBaseProfessionInfo()
    local link = C_TradeSkillUI.GetTradeSkillListLink()
    
    -- Hvis linket er nil (som f.eks. ved herbalism), ignorerer vi det
    if profInfo and profInfo.professionName and link then
        local myShortName = strsplit("-", UnitName("player"))
        
        GetSchwiiftyDB.MyProfessions[profInfo.professionName] = link
        GetSchwiiftyDB.GuildCrafters[myShortName] = GetSchwiiftyDB.GuildCrafters[myShortName] or {}
        GetSchwiiftyDB.GuildCrafters[myShortName][profInfo.professionName] = link
        
        print("|cFF00FFFF[Get Schwiifty]|r Profession link saved: " .. profInfo.professionName)
        
        local packet = "PROF;" .. myShortName .. ";" .. profInfo.professionName .. ";" .. link
        GS.Log("|cFF00FF00[SENDER]|r " .. packet)
        C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
        
        if GS.OpdaterCrafterTabel then GS.OpdaterCrafterTabel() end
    end
end)

local CraftingListener = CreateFrame("Frame")
CraftingListener:RegisterEvent("CHAT_MSG_ADDON")
CraftingListener:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if prefix == "GetSchwiifty" and GetSchwiiftyDB then
        
        -- Vi logger alt hvad der kommer ind
        local shortSender = strsplit("-", sender)
        GS.Log("|cFFFFFF00[MODTAGER FRA " .. shortSender .. "]|r " .. text)
        
        if string.sub(text, 1, 5) == "PROF;" then
            local _, pName, profName, link = strsplit(";", text, 4) 
            if pName and profName and link then
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
                        GS.Log("|cFF00FF00[SENDER (Svar på Sync)]|r " .. packet)
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
        if GS_AutoAnnounceCheck:GetChecked() and orderInfo and orderInfo.orderType == Enum.CraftingOrderType.Guild then
            SendChatMessage("I just placed a new Guild Crafting Order! Please take a look if you can craft it.", "GUILD")
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
    {navn = "Crafter Name", bredde = 130},
    {navn = "Guild Rank", bredde = 110},
    {navn = "Level / Class", bredde = 140},
    {navn = "Known Professions", bredde = 160},
    {navn = "Action", bredde = 250} -- Udvidet for at få plads til 3 knapper!
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
    if i % 2 == 0 then row:SetBackdropColor(1, 1, 1, 0.04) else row:SetBackdropColor(1, 1, 1, 0.01) end
    
    row.felter = {}
    local feltX = 0
    for j, info in ipairs(kolonner) do
        if j == 5 then 
            local whisperBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            whisperBtn:SetSize(70, 20)
            whisperBtn:SetPoint("LEFT", row, "LEFT", feltX, 0)
            whisperBtn:SetText("Whisper")
            whisperBtn:SetScript("OnClick", function(self)
                if self.spillerNavn then ChatFrame_OpenChat("/w " .. self.spillerNavn .. " Hey, can you craft something for me? ") end
            end)
            
            -- Knap til Profession 1
            local prof1Btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            prof1Btn:SetSize(85, 20)
            prof1Btn:SetPoint("LEFT", whisperBtn, "RIGHT", 5, 0)
            prof1Btn:SetScript("OnClick", function(self)
                if self.link then local ls = self.link:match("|H(.-)|h"); if ls then SetItemRef(ls, self.link, "LeftButton") end end
            end)
            
            -- Knap til Profession 2
            local prof2Btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            prof2Btn:SetSize(85, 20)
            prof2Btn:SetPoint("LEFT", prof1Btn, "RIGHT", 5, 0)
            prof2Btn:SetScript("OnClick", function(self)
                if self.link then local ls = self.link:match("|H(.-)|h"); if ls then SetItemRef(ls, self.link, "LeftButton") end end
            end)

            row.felter[j] = { whisper = whisperBtn, prof1 = prof1Btn, prof2 = prof2Btn }
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
            
            local crafterData = GetSchwiiftyDB.GuildCrafters[shortName]
            if crafterData and next(crafterData) then
                local pNames = {}
                local pLinks = {}
                local knownProfs = ""
                
                for pName, pLink in pairs(crafterData) do
                    table.insert(pNames, pName)
                    table.insert(pLinks, pLink)
                    knownProfs = knownProfs .. pName .. ", "
                end
                knownProfs = knownProfs:sub(1, -3) 
                row.felter[4]:SetText("|cff71d5ff" .. knownProfs .. "|r")
                
                -- Udfylder Knap 1
                if pNames[1] then
                    row.felter[5].prof1:Show()
                    row.felter[5].prof1:SetText(pNames[1]:sub(1, 10)) -- Forkorter navnet let, f.eks "Blacksmith"
                    row.felter[5].prof1.link = pLinks[1]
                else
                    row.felter[5].prof1:Hide()
                end
                
                -- Udfylder Knap 2
                if pNames[2] then
                    row.felter[5].prof2:Show()
                    row.felter[5].prof2:SetText(pNames[2]:sub(1, 10))
                    row.felter[5].prof2.link = pLinks[2]
                else
                    row.felter[5].prof2:Hide()
                end
            else
                row.felter[4]:SetText("|cFF888888Unknown|r")
                row.felter[5].prof1:Hide()
                row.felter[5].prof2:Hide()
            end
            
            row.felter[5].whisper.spillerNavn = shortName 
            
            row:Show()
            rowIndex = rowIndex + 1
        end
    end
end

RefreshCraftersBtn:SetScript("OnClick", function()
    GS.OpdaterCrafterTabel()
    local req = "SYNC_REQUEST"
    GS.Log("|cFF00FF00[SENDER]|r " .. req)
    C_ChatInfo.SendAddonMessage("GetSchwiifty", req, "GUILD")
end)