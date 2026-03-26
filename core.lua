local prefix = "GetSchwiifty"
C_ChatInfo.RegisterAddonMessagePrefix(prefix)

local isListed = false
local myCurrentDataPacket = ""

local InitFrame = CreateFrame("Frame")
InitFrame:RegisterEvent("ADDON_LOADED")
InitFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "GetSchwiifty" then
        GetSchwiiftyDB = GetSchwiiftyDB or {} 
    end
end)

-------------------------------------------------
-- BRUGERGRÆNSEFLADE (UI) - HOVEDVINDUE
-------------------------------------------------
local MainFrame = CreateFrame("Frame", "GS_MainFrame", UIParent, "BasicFrameTemplateWithInset")
MainFrame:SetSize(950, 550) 
MainFrame:SetPoint("CENTER", UIParent, "CENTER")
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)

MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY")
MainFrame.title:SetFontObject("GameFontHighlight")
MainFrame.title:SetPoint("CENTER", MainFrame.TitleBg, "CENTER", 0, 0)
MainFrame.title:SetText("Get Schwiifty")

MainFrame:Hide()
tinsert(UISpecialFrames, "GS_MainFrame")

SLASH_GETSCHWIIFTY1 = "/gs"
SLASH_GETSCHWIIFTY2 = "/getschwiifty"
SlashCmdList["GETSCHWIIFTY"] = function()
    if MainFrame:IsShown() then 
        MainFrame:Hide() 
    else 
        MainFrame:Show() 
        C_GuildInfo.GuildRoster() 
        C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD")
        if OpdaterTabel then OpdaterTabel() end 
    end
end

-------------------------------------------------
-- VALG AF ROLLER, NIVEAU OG KOMMENTAR
-------------------------------------------------
local RoleText = GS_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
RoleText:SetPoint("TOPLEFT", GS_MainFrame, "TOPLEFT", 20, -40)
RoleText:SetText("Select your roles:")

local TankCheck = CreateFrame("CheckButton", "GS_TankCheck", GS_MainFrame, "UICheckButtonTemplate")
TankCheck:SetPoint("TOPLEFT", RoleText, "BOTTOMLEFT", 0, -10)
TankCheck.text = TankCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
TankCheck.text:SetPoint("LEFT", TankCheck, "RIGHT", 5, 0)
TankCheck.text:SetText("Tank")

local HealerCheck = CreateFrame("CheckButton", "GS_HealerCheck", GS_MainFrame, "UICheckButtonTemplate")
HealerCheck:SetPoint("TOPLEFT", TankCheck, "BOTTOMLEFT", 0, -5)
HealerCheck.text = HealerCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HealerCheck.text:SetPoint("LEFT", HealerCheck, "RIGHT", 5, 0)
HealerCheck.text:SetText("Healer")

local DPSCheck = CreateFrame("CheckButton", "GS_DPSCheck", GS_MainFrame, "UICheckButtonTemplate")
DPSCheck:SetPoint("TOPLEFT", HealerCheck, "BOTTOMLEFT", 0, -5)
DPSCheck.text = DPSCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
DPSCheck.text:SetPoint("LEFT", DPSCheck, "RIGHT", 5, 0)
DPSCheck.text:SetText("DPS")

local LevelText = GS_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
LevelText:SetPoint("TOPLEFT", GS_MainFrame, "TOPLEFT", 180, -40)
LevelText:SetText("Select Key Level:")

local FraDropDown = CreateFrame("Frame", "GS_FraDropDown", GS_MainFrame, "UIDropDownMenuTemplate")
FraDropDown:SetPoint("TOPLEFT", LevelText, "BOTTOMLEFT", -15, -10)
UIDropDownMenu_SetWidth(FraDropDown, 60)
UIDropDownMenu_SetText(FraDropDown, "From: 2")

local function FraDropDown_OnClick(self, arg1, arg2, checked) UIDropDownMenu_SetText(FraDropDown, "From: " .. arg1) end
local function FraDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i = 2, 20 do info.text = tostring(i); info.arg1 = i; info.func = FraDropDown_OnClick; UIDropDownMenu_AddButton(info) end
end
UIDropDownMenu_Initialize(FraDropDown, FraDropDown_Menu)

local TilDropDown = CreateFrame("Frame", "GS_TilDropDown", GS_MainFrame, "UIDropDownMenuTemplate")
TilDropDown:SetPoint("LEFT", FraDropDown, "RIGHT", -10, 0)
UIDropDownMenu_SetWidth(TilDropDown, 60)
UIDropDownMenu_SetText(TilDropDown, "To: 10")

local function TilDropDown_OnClick(self, arg1, arg2, checked) UIDropDownMenu_SetText(TilDropDown, "To: " .. arg1) end
local function TilDropDown_Menu(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i = 2, 20 do info.text = tostring(i); info.arg1 = i; info.func = TilDropDown_OnClick; UIDropDownMenu_AddButton(info) end
end
UIDropDownMenu_Initialize(TilDropDown, TilDropDown_Menu)

local IntentText = GS_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
IntentText:SetPoint("TOPLEFT", GS_FraDropDown, "BOTTOMLEFT", 15, -10)
IntentText:SetText("What is your goal?")

local IntentDropDown = CreateFrame("Frame", "GS_IntentDropDown", GS_MainFrame, "UIDropDownMenuTemplate")
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

local CommentText = GS_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
CommentText:SetPoint("TOPLEFT", GS_MainFrame, "TOPLEFT", 380, -100)
CommentText:SetText("Short comment (optional):")

local CommentBox = CreateFrame("EditBox", "GS_CommentBox", GS_MainFrame, "InputBoxTemplate")
CommentBox:SetSize(180, 20)
CommentBox:SetPoint("TOPLEFT", CommentText, "BOTTOMLEFT", 5, -5)
CommentBox:SetAutoFocus(false)
CommentBox:SetMaxLetters(25)

-------------------------------------------------
-- TILMELD, AFMELD OG OPDATER KNAPPER
-------------------------------------------------
local SubmitButton = CreateFrame("Button", "GS_SubmitButton", GS_MainFrame, "UIPanelButtonTemplate")
SubmitButton:SetSize(150, 40)
SubmitButton:SetPoint("BOTTOM", GS_MainFrame, "BOTTOM", -160, 20)
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

local UnlistButton = CreateFrame("Button", "GS_UnlistButton", GS_MainFrame, "UIPanelButtonTemplate")
UnlistButton:SetSize(150, 40)
UnlistButton:SetPoint("LEFT", SubmitButton, "RIGHT", 20, 0)
UnlistButton:SetText("Unlist")

UnlistButton:SetScript("OnClick", function()
    isListed = false
    myCurrentDataPacket = ""
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "REMOVE", "GUILD")
    print("|cFFFF0000[Get Schwiifty]|r You have been removed from the list!")
end)

local SyncButton = CreateFrame("Button", "GS_SyncButton", GS_MainFrame, "UIPanelButtonTemplate")
SyncButton:SetSize(120, 40)
SyncButton:SetPoint("LEFT", UnlistButton, "RIGHT", 20, 0)
SyncButton:SetText("Refresh List")

SyncButton:SetScript("OnClick", function()
    C_GuildInfo.GuildRoster() 
    C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD")
    print("|cFFFFFF00[Get Schwiifty]|r Fetching latest data from the guild...")
end)

-------------------------------------------------
-- SPILLERLISTE (KOLONNER, RÆKKER OG SORTERING)
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

OpdaterTabel = nil 

local currentX = startX
for i, info in ipairs(kolonner) do
    local btn = CreateFrame("Button", nil, GS_MainFrame)
    btn:SetSize(info.bredde, 20)
    btn:SetPoint("TOPLEFT", GS_MainFrame, "TOPLEFT", currentX, headerY)
    
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

local numRows = 12
local raekker = {}
local rowY = headerY - 25

for i = 1, numRows do
    local row = CreateFrame("Frame", nil, GS_MainFrame)
    row:SetSize(910, 20) 
    row:SetPoint("TOPLEFT", GS_MainFrame, "TOPLEFT", startX, rowY - ((i-1) * 20))
    
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
    if not GetSchwiiftyDB then return end
    for name, data in pairs(GetSchwiiftyDB) do
        if nu - data.timestamp > 7200 then
            GetSchwiiftyDB[name] = nil
        end
    end
end

OpdaterTabel = function()
    if not GetSchwiiftyDB then return end
    RensGammelData() 
    for i = 1, numRows do raekker[i]:Hide() end
    
    local sorteretListe = {}
    for playerName, data in pairs(GetSchwiiftyDB) do
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
    end
end

-------------------------------------------------
-- NETVÆRK (LYTTEREN DER FANGER DATA)
-------------------------------------------------
local LytterFrame = CreateFrame("Frame")
LytterFrame:RegisterEvent("CHAT_MSG_ADDON")
LytterFrame:SetScript("OnEvent", function(self, event, msgPrefix, text, channel, sender)
    if msgPrefix == "GetSchwiifty" then
        if not GetSchwiiftyDB then return end
        
        if string.sub(text, 1, 6) == "REMOVE" then
            local _, targetName = strsplit(";", text)
            GetSchwiiftyDB[targetName or sender] = nil
            if OpdaterTabel then OpdaterTabel() end
            
        elseif text == "SYNC_REQUEST" then
            RensGammelData() 
            C_Timer.After(math.random() * 1.5, function()
                for name, data in pairs(GetSchwiiftyDB) do
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
                GetSchwiiftyDB[finalName] = {
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
-- MINIMAP OG TITAN PANEL
-------------------------------------------------
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
        if GS_MainFrame:IsShown() then GS_MainFrame:Hide() else GS_MainFrame:Show(); C_GuildInfo.GuildRoster(); C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD"); if OpdaterTabel then OpdaterTabel() end end
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
                if button == "LeftButton" then if GS_MainFrame:IsShown() then GS_MainFrame:Hide() else GS_MainFrame:Show(); C_GuildInfo.GuildRoster(); C_ChatInfo.SendAddonMessage("GetSchwiifty", "SYNC_REQUEST", "GUILD"); if OpdaterTabel then OpdaterTabel() end end end
            end,
            OnTooltipShow = function(tooltip) tooltip:SetText("Get Schwiifty"); tooltip:AddLine("Click to open the overview!", 1, 1, 1) end,
        })
    end
end