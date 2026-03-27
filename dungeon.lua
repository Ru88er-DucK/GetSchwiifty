local addonName, GS = ...

local isListed = false
local myCurrentDataPacket = ""

local LoadFrame = CreateFrame("Frame")
LoadFrame:RegisterEvent("ADDON_LOADED")
LoadFrame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        GetSchwiiftyDB = GetSchwiiftyDB or {}
        GetSchwiiftyDB.MPlus = GetSchwiiftyDB.MPlus or {} 
    end
end)

-------------------------------------------------
-- VALG AF ROLLER, NIVEAU OG KOMMENTAR
-------------------------------------------------
local RoleText = GS.DungeonTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
RoleText:SetPoint("TOPLEFT", GS.DungeonTabContainer, "TOPLEFT", 20, -50) 
RoleText:SetText("Select your roles:")

local TankCheck = CreateFrame("CheckButton", "GS_TankCheck", GS.DungeonTabContainer, "UICheckButtonTemplate")
TankCheck:SetPoint("TOPLEFT", RoleText, "BOTTOMLEFT", 0, -10)
TankCheck.text = TankCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
TankCheck.text:SetPoint("LEFT", TankCheck, "RIGHT", 5, 0)
TankCheck.text:SetText("Tank")

local HealerCheck = CreateFrame("CheckButton", "GS_HealerCheck", GS.DungeonTabContainer, "UICheckButtonTemplate")
HealerCheck:SetPoint("TOPLEFT", TankCheck, "BOTTOMLEFT", 0, -5)
HealerCheck.text = HealerCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HealerCheck.text:SetPoint("LEFT", HealerCheck, "RIGHT", 5, 0)
HealerCheck.text:SetText("Healer")

local DPSCheck = CreateFrame("CheckButton", "GS_DPSCheck", GS.DungeonTabContainer, "UICheckButtonTemplate")
DPSCheck:SetPoint("TOPLEFT", HealerCheck, "BOTTOMLEFT", 0, -5)
DPSCheck.text = DPSCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
DPSCheck.text:SetPoint("LEFT", DPSCheck, "RIGHT", 5, 0)
DPSCheck.text:SetText("DPS")

local LevelText = GS.DungeonTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
LevelText:SetPoint("TOPLEFT", GS.DungeonTabContainer, "TOPLEFT", 180, -50)
LevelText:SetText("Select Key Level:")

local FraDropDown = CreateFrame("Frame", "GS_FraDropDown", GS.DungeonTabContainer, "UIDropDownMenuTemplate")
FraDropDown:SetPoint("TOPLEFT", LevelText, "BOTTOMLEFT", -15, -10)
UIDropDownMenu_SetWidth(FraDropDown, 60)
UIDropDownMenu_SetText(FraDropDown, "From: 2")

local function FraDropDown_OnClick(self, arg1, arg2, checked) UIDropDownMenu_SetText(FraDropDown, "From: " .. arg1) end
local function FraDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i = 2, 20 do info.text = tostring(i); info.arg1 = i; info.func = FraDropDown_OnClick; UIDropDownMenu_AddButton(info) end
end
UIDropDownMenu_Initialize(FraDropDown, FraDropDown_Menu)

local TilDropDown = CreateFrame("Frame", "GS_TilDropDown", GS.DungeonTabContainer, "UIDropDownMenuTemplate")
TilDropDown:SetPoint("LEFT", FraDropDown, "RIGHT", -10, 0)
UIDropDownMenu_SetWidth(TilDropDown, 60)
UIDropDownMenu_SetText(TilDropDown, "To: 10")

local function TilDropDown_OnClick(self, arg1, arg2, checked) UIDropDownMenu_SetText(TilDropDown, "To: " .. arg1) end
local function TilDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i = 2, 20 do info.text = tostring(i); info.arg1 = i; info.func = TilDropDown_OnClick; UIDropDownMenu_AddButton(info) end
end
UIDropDownMenu_Initialize(TilDropDown, TilDropDown_Menu)

local IntentText = GS.DungeonTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
IntentText:SetPoint("TOPLEFT", GS_FraDropDown, "BOTTOMLEFT", 15, -10)
IntentText:SetText("What is your goal?")

local IntentDropDown = CreateFrame("Frame", "GS_IntentDropDown", GS.DungeonTabContainer, "UIDropDownMenuTemplate")
IntentDropDown:SetPoint("TOPLEFT", IntentText, "BOTTOMLEFT", -15, -10)
UIDropDownMenu_SetWidth(IntentDropDown, 150)
UIDropDownMenu_SetText(IntentDropDown, "Select intention...")

local intentioner = {"Only within bracket", "MUST be push", "CAN be push", "Offering boost", "Seeking boost"}
local function IntentDropDown_OnClick(self, arg1, arg2, checked) UIDropDownMenu_SetText(IntentDropDown, arg1) end
local function IntentDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for _, intent in ipairs(intentioner) do info.text = intent; info.arg1 = intent; info.func = IntentDropDown_OnClick; UIDropDownMenu_AddButton(info) end
end
UIDropDownMenu_Initialize(IntentDropDown, IntentDropDown_Menu)

local CommentText = GS.DungeonTabContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
CommentText:SetPoint("TOPLEFT", GS.DungeonTabContainer, "TOPLEFT", 380, -110)
CommentText:SetText("Short comment (optional):")

local CommentBox = CreateFrame("EditBox", "GS_CommentBox", GS.DungeonTabContainer, "InputBoxTemplate")
CommentBox:SetSize(180, 20)
CommentBox:SetPoint("TOPLEFT", CommentText, "BOTTOMLEFT", 5, -5)
CommentBox:SetAutoFocus(false)
CommentBox:SetMaxLetters(25)

-------------------------------------------------
-- TILMELD, AFMELD OG OPDATER KNAPPER
-------------------------------------------------
local SubmitButton = CreateFrame("Button", "GS_SubmitButton", GS.DungeonTabContainer, "UIPanelButtonTemplate")
SubmitButton:SetSize(150, 40)
SubmitButton:SetPoint("BOTTOM", GS.DungeonTabContainer, "BOTTOM", -160, 20)
SubmitButton:SetText("Sign Up / Send")

SubmitButton:SetScript("OnClick", function()
    local roles = ""
    if GS_TankCheck:GetChecked() then roles = roles .. "Tank " end
    if GS_HealerCheck:GetChecked() then roles = roles .. "Healer " end
    if GS_DPSCheck:GetChecked() then roles = roles .. "DPS " end
    if roles == "" then roles = "None" else roles = string.trim(roles) end

    local minKeyText = UIDropDownMenu_GetText(GS_FraDropDown) or "2"
    local minKey = string.match(minKeyText, "%d+") or "2" 
    local maxKeyText = UIDropDownMenu_GetText(GS_TilDropDown) or "10"
    local maxKey = string.match(maxKeyText, "%d+") or "10"
    local intent = UIDropDownMenu_GetText(GS_IntentDropDown) or "No intention"

    local score = C_ChallengeMode.GetOverallDungeonScore() or 0
    local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel() or 0
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local mapName = "No Key"
    if mapID then mapName = C_ChallengeMode.GetMapUIInfo(mapID) end
    
    local _, classToken = UnitClass("player")
    local timestamp = time() 
    
    local rawComment = GS_CommentBox:GetText() or ""
    local safeComment = string.gsub(rawComment, ";", ",") 
    if safeComment == "" then safeComment = "-" end
    
    local dataPacket = string.format("%s;%s;%s;%s;%s;%s;%s;%s;%s;%s", roles, minKey, maxKey, intent, score, mapName, keyLevel, classToken, timestamp, safeComment)

    isListed = true
    myCurrentDataPacket = dataPacket

    C_ChatInfo.SendAddonMessage("GetSchwiifty", dataPacket, "GUILD")
    print("|cFF00FFFF[Get Schwiifty]|r You are now listed for M+!")
end)

local UnlistButton = CreateFrame("Button", "GS_UnlistButton", GS.DungeonTabContainer, "UIPanelButtonTemplate")
UnlistButton:SetSize(150, 40)
UnlistButton:SetPoint("LEFT", SubmitButton, "RIGHT", 20, 0)
UnlistButton:SetText("Unlist")

UnlistButton:SetScript("OnClick", function()
    isListed = false
    myCurrentDataPacket = ""
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "REMOVE", "GUILD")
    print("|cFFFF0000[Get Schwiifty]|r You have been removed from the list!")
end)

local SyncButton = CreateFrame("Button", "GS_SyncButton", GS.DungeonTabContainer, "UIPanelButtonTemplate")
SyncButton:SetSize(120, 40)
SyncButton:SetPoint("LEFT", UnlistButton, "RIGHT", 20, 0)
SyncButton:SetText("Refresh List")

SyncButton:SetScript("OnClick", function()
    C_GuildInfo.GuildRoster() 
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD")
    print("|cFFFFFF00[Get Schwiifty]|r Fetching latest data from the guild...")
end)

-------------------------------------------------
-- SCROLL FRAME OG SPILLERLISTE
-------------------------------------------------
local headerY = -180
local startX = 20
local currentSortKey = "score" 
local sortReversed = true

local kolonner = {
    {navn = "Name", bredde = 130, sortKey = "navn"},
    {navn = "Role", bredde = 80, sortKey = "roles"},
    {navn = "Level", bredde = 50, sortKey = "minKey"},
    {navn = "Goal", bredde = 130, sortKey = "intent"},
    {navn = "Score", bredde = 50, sortKey = "score"},
    {navn = "Key", bredde = 140, sortKey = "keyLevel"},
    {navn = "User Note", bredde = 130, sortKey = nil},
    {navn = "Guild Note", bredde = 120, sortKey = nil},
    {navn = "Invite", bredde = 60, sortKey = nil} 
}

local OpdaterTabel = nil 

local currentX = startX
for i, info in ipairs(kolonner) do
    local btn = CreateFrame("Button", nil, GS.DungeonTabContainer)
    btn:SetSize(info.bredde, 20)
    btn:SetPoint("TOPLEFT", GS.DungeonTabContainer, "TOPLEFT", currentX, headerY)
    
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", btn, "LEFT", 0, 0)
    text:SetText(info.navn)
    
    if info.sortKey then
        btn:SetScript("OnClick", function()
            if currentSortKey == info.sortKey then sortReversed = not sortReversed else
                currentSortKey = info.sortKey; sortReversed = false
                if info.sortKey == "score" or info.sortKey == "keyLevel" then sortReversed = true end
            end
            if OpdaterTabel then OpdaterTabel() end
        end)
    end
    currentX = currentX + info.bredde
end

-- SCROLL SYSTEMET
local ScrollFrame = CreateFrame("ScrollFrame", "GS_DungeonScrollFrame", GS.DungeonTabContainer, "UIPanelScrollFrameTemplate")
ScrollFrame:SetSize(890, 240) -- Justeret til at passe mellem overskrifter og knapper i bunden
ScrollFrame:SetPoint("TOPLEFT", GS.DungeonTabContainer, "TOPLEFT", startX, headerY - 25)

-- Containeren inde i ScrollFrame, der holder selve rækkerne
local ScrollChild = CreateFrame("Frame")
ScrollChild:SetSize(890, 240)
ScrollFrame:SetScrollChild(ScrollChild)

-- Vi bygger 30 usynlige rækker nu i stedet for 12, så der er masser af plads i vinduet
local numRows = 30
local raekker = {}
local rowHeight = 25

for i = 1, numRows do
    local row = CreateFrame("Frame", nil, ScrollChild)
    row:SetSize(890, rowHeight) 
    row:SetPoint("TOPLEFT", ScrollChild, "TOPLEFT", 0, -((i-1) * rowHeight))
    
    row.felter = {}
    local feltX = 0
    for j, info in ipairs(kolonner) do
        if j == 9 then 
            local invBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            invBtn:SetSize(55, 20)
            invBtn:SetPoint("LEFT", row, "LEFT", feltX, 0)
            invBtn:SetText("Invite")
            invBtn:SetScript("OnClick", function(self)
                if self.spillerNavn then
                    C_PartyInfo.InviteUnit(self.spillerNavn)
                    print("|cFF00FFFF[Get Schwiifty]|r Inviting " .. self.spillerNavn .. "...")
                end
            end)
            row.felter[j] = invBtn
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

local function RensGammelData()
    local nu = time()
    if not GetSchwiiftyDB or not GetSchwiiftyDB.MPlus then return end
    for name, data in pairs(GetSchwiiftyDB.MPlus) do
        if nu - data.timestamp > 7200 then
            GetSchwiiftyDB.MPlus[name] = nil
        end
    end
end

OpdaterTabel = function()
    if not GetSchwiiftyDB or not GetSchwiiftyDB.MPlus then return end
    RensGammelData() 
    for i = 1, numRows do raekker[i]:Hide() end
    
    local sorteretListe = {}
    for playerName, data in pairs(GetSchwiiftyDB.MPlus) do
        local spillerKopi = {}
        for k, v in pairs(data) do spillerKopi[k] = v end
        spillerKopi.navn = playerName 
        table.insert(sorteretListe, spillerKopi)
    end
    
    table.sort(sorteretListe, function(a, b)
        local valA = a[currentSortKey]
        local valB = b[currentSortKey]
        
        if currentSortKey == "keyLevel" or currentSortKey == "minKey" then
            valA = tonumber(valA) or 0; valB = tonumber(valB) or 0
        end
        
        if valA == valB then return false end
        if sortReversed then return valA > valB else return valA < valB end
    end)
    
    local totalShownRows = 0
    for i, data in ipairs(sorteretListe) do
        if i > numRows then break end
        
        local row = raekker[i]
        local colorInfo = RAID_CLASS_COLORS[data.classToken]
        local hexColor = colorInfo and colorInfo.colorStr or "ffffffff"
        local kortNavn = strsplit("-", data.navn)
        
        local isOnline = false
        local guildNote = "-"
        
        for guildIndex = 1, GetNumGuildMembers() do
            local rosterName, _, _, _, _, _, publicNote, _, onlineStatus = GetGuildRosterInfo(guildIndex)
            if rosterName == data.navn then 
                isOnline = onlineStatus
                if publicNote and publicNote ~= "" then guildNote = publicNote end
                break 
            end
        end
        
        local statusDot = isOnline and "|cFF00FF00●|r " or "|cFFFF0000●|r "
        
        row.felter[1]:SetText(string.format("%s|c%s%s|r", statusDot, hexColor, kortNavn))
        row.felter[2]:SetText(data.roles)
        row.felter[3]:SetText(data.minKey .. "-" .. data.maxKey)
        row.felter[4]:SetText(data.intent)
        row.felter[5]:SetText("|cFFFF8000" .. data.score .. "|r")
        row.felter[6]:SetText(data.mapName .. " (+" .. data.keyLevel .. ")")
        row.felter[7]:SetText(data.comment) 
        row.felter[8]:SetText("|cFFDDDDDD" .. guildNote .. "|r") 
        row.felter[9].spillerNavn = data.navn 
        
        row:Show()
        totalShownRows = i
    end
    
    -- Fortæller scrollvinduet, hvor langt indholdet er, så elevatoren virker rigtigt
    ScrollChild:SetHeight(math.max(totalShownRows * rowHeight, ScrollFrame:GetHeight()))
end

-------------------------------------------------
-- NETVÆRK (LYTTEREN DER FANGER DATA)
-------------------------------------------------
local LytterFrame = CreateFrame("Frame")
LytterFrame:RegisterEvent("CHAT_MSG_ADDON")
LytterFrame:SetScript("OnEvent", function(self, event, msgPrefix, text, channel, sender)
    if msgPrefix == "GetSchwiifty" then
        if not GetSchwiiftyDB then return end
        GetSchwiiftyDB.MPlus = GetSchwiiftyDB.MPlus or {} 
        
        if string.sub(text, 1, 5) == "PROF;" then return end
        
        if string.sub(text, 1, 6) == "REMOVE" then
            local _, targetName = strsplit(";", text)
            GetSchwiiftyDB.MPlus[targetName or sender] = nil
            if OpdaterTabel then OpdaterTabel() end
            
        elseif text == "SYNC_REQUEST" then
            RensGammelData() 
            C_Timer.After(math.random() * 1.5, function()
                for name, data in pairs(GetSchwiiftyDB.MPlus) do
                    local packet = string.format("%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s", 
                        data.roles, data.minKey, data.maxKey, data.intent, 
                        data.score, data.mapName, data.keyLevel, data.classToken, 
                        data.timestamp, data.comment, name)
                    C_ChatInfo.SendAddonMessage("GetSchwiifty", packet, "GUILD")
                end
            end)
            
        else
            local roles, minKey, maxKey, intent, score, mapName, keyLevel, classToken, timestamp, comment, pName = strsplit(";", text)
            if roles and timestamp then
                local finalName = pName or sender
                GetSchwiiftyDB.MPlus[finalName] = {
                    roles = roles, minKey = minKey, maxKey = maxKey, intent = intent, 
                    score = tonumber(score) or 0, mapName = mapName, keyLevel = keyLevel, 
                    classToken = classToken or "PRIEST", timestamp = tonumber(timestamp) or time(),
                    comment = comment or "-"
                }
                if OpdaterTabel then OpdaterTabel() end
            end
        end
    end
end)

-------------------------------------------------
-- FORBINDELSE TIL CORE.LUA
-------------------------------------------------
GS.SyncDungeonData = function()
    C_GuildInfo.GuildRoster()
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD")
    if OpdaterTabel then OpdaterTabel() end
end