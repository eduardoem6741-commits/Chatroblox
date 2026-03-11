-- DELTA GLOBAL CHAT: ADMIN ELITE (FIXED TOGGLES)
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")
local UserInput = game:GetService("UserInputService")

-- 1. ADMIN CONFIGURATION
local API_URL = "https://robloxglobalchat-217f7-default-rtdb.firebaseio.com/chat.json"
local myUserId = 8615238851 

local specialTags = {
    [myUserId] = "👑 OWNER",
}

-- Settings State
local useAlias = false
local hideGame = false
local hidePlatform = false -- NEW SEPARATE TOGGLE
local customAlias = "Mysterious User"
local platformIcon = (UserInput.TouchEnabled and not UserInput.KeyboardEnabled) and "📱" or "💻"

local successName, placeInfo = pcall(function() return Market:GetProductInfo(game.PlaceId) end)
local currentGameName = successName and placeInfo.Name or "Unknown Game"

if guiParent:FindFirstChild("DeltaElite") then guiParent.DeltaElite:Destroy() end

-- 2. UI DESIGN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaElite"
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 300) -- Made taller for the extra button
Main.Position = UDim2.new(1, -360, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.Draggable = true
Main.Active = true
Main.Parent = ScreenGui
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 2
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -40, 0, 35)
Header.BackgroundTransparency = 1
Header.Text = " 🌐 ELITE GLOBAL"
Header.TextColor3 = Color3.fromRGB(0, 170, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.Parent = Main

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 28, 0, 28)
SettingsBtn.Position = UDim2.new(1, -35, 0, 5)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.new(1,1,1)
SettingsBtn.Parent = Main
Instance.new("UICorner", SettingsBtn)

-- Settings Panel
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(1, 0, 1, 0)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 10
SettingsPanel.Parent = Main
Instance.new("UICorner", SettingsPanel)

local AliasInput = Instance.new("TextBox")
AliasInput.Size = UDim2.new(0, 240, 0, 30)
AliasInput.Position = UDim2.new(0.5, -120, 0.08, 0)
AliasInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
AliasInput.TextColor3 = Color3.new(1,1,1)
AliasInput.PlaceholderText = "Set Custom Alias..."
AliasInput.Text = customAlias
AliasInput.ZIndex = 11
AliasInput.Parent = SettingsPanel
Instance.new("UICorner", AliasInput)

local function createBtn(text, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 240, 0, 30)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.ZIndex = 11
    b.Font = Enum.Font.Gotham
    b.Parent = SettingsPanel
    Instance.new("UICorner", b)
    return b
end

local tAlias = createBtn("Hide Name: OFF", UDim2.new(0.5, -120, 0.23, 0), Color3.fromRGB(180, 40, 40))
local tGame = createBtn("Hide Game: OFF", UDim2.new(0.5, -120, 0.36, 0), Color3.fromRGB(180, 40, 40))
local tPlat = createBtn("Hide Device: OFF", UDim2.new(0.5, -120, 0.49, 0), Color3.fromRGB(180, 40, 40))
local tClear = createBtn("Clear My Screen", UDim2.new(0.5, -120, 0.62, 0), Color3.fromRGB(60, 60, 70))
local tAdminClear = createBtn("🔥 GLOBAL WIPE", UDim2.new(0.5, -120, 0.75, 0), Color3.fromRGB(100, 0, 0))
tAdminClear.Visible = (Players.LocalPlayer.UserId == myUserId)

local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0, 80, 0, 25)
CloseSettings.Position = UDim2.new(0.5, -40, 0.94, -10)
CloseSettings.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CloseSettings.Text = "SAVE"
CloseSettings.TextColor3 = Color3.new(1,1,1)
CloseSettings.ZIndex = 11
CloseSettings.Parent = SettingsPanel
Instance.new("UICorner", CloseSettings)

-- Chat Area
local ChatArea = Instance.new("ScrollingFrame")
ChatArea.Size = UDim2.new(1, -20, 1, -100)
ChatArea.Position = UDim2.new(0, 10, 0, 45)
ChatArea.BackgroundTransparency = 1
ChatArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatArea.ScrollBarThickness = 2
ChatArea.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Parent = ChatArea
UIList.Padding = UDim.new(0, 4)

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -70, 0, 35)
Input.Position = UDim2.new(0, 10, 1, -45)
Input.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Input.TextColor3 = Color3.new(1,1,1)
Input.PlaceholderText = "Type here..."
Input.Parent = Main
Instance.new("UICorner", Input)

local Send = Instance.new("TextButton")
Send.Size = UDim2.new(0, 55, 0, 35)
Send.Position = UDim2.new(1, -65, 1, -45)
Send.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Send.Text = "SEND"
Send.TextColor3 = Color3.new(1,1,1)
Send.Parent = Main
Instance.new("UICorner", Send)

-- 3. CORE LOGIC
local function addMsg(user, txt, gameName, icon, tag)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 18)
    local gT = (gameName and gameName ~= "Hidden") and "["..gameName.."] " or ""
    local sT = (tag and tag ~= "") and "["..tag.."] " or ""
    local pI = (icon and icon ~= "❓") and icon.." " or ""
    
    msg.Text = gT .. sT .. pI .. user .. ": " .. txt
    
    if tag == "👑 OWNER" then
        task.spawn(function()
            while msg and msg.Parent do
                msg.TextColor3 = Color3.fromHSV(tick()%5/5, 0.8, 1)
                task.wait(0.05)
            end
        end)
    elseif user == Players.LocalPlayer.Name or user == customAlias then
        msg.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        msg.TextColor3 = Color3.new(1, 1, 1)
    end
    
    msg.BackgroundTransparency = 1
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.Parent = ChatArea
    ChatArea.CanvasPosition = Vector2.new(0, 9999)
end

local function post(txt)
    local dU = useAlias and customAlias or Players.LocalPlayer.Name
    local dG = hideGame and "Hidden" or currentGameName
    local dI = hidePlatform and "❓" or platformIcon -- Independent Platform Check
    local dT = specialTags[Players.LocalPlayer.UserId] or ""
    
    local data = HttpService:JSONEncode({u=dU, t=txt, g=dG, i=dI, tg=dT, s=os.time()})
    addMsg(dU.." (You)", txt, dG, dI, dT)
    pcall(function() request({Url = API_URL, Method = "POST", Body = data}) end)
end

local lastT = os.time()
local function update()
    pcall(function()
        local res = request({Url = API_URL, Method = "GET"})
        local data = HttpService:JSONDecode(res.Body)
        if not data then 
            for _, c in pairs(ChatArea:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
            lastT = os.time()
            return 
        end
        for _, m in pairs(data) do
            if m.s > lastT then
                if m.u ~= Players.LocalPlayer.Name and m.u ~= customAlias then
                    addMsg(m.u, m.t, m.g, m.i, m.tg)
                end
                lastT = m.s
            end
        end
    end)
end

-- 4. CONNECTIONS
SettingsBtn.MouseButton1Click:Connect(function() SettingsPanel.Visible = true end)
CloseSettings.MouseButton1Click:Connect(function() customAlias = AliasInput.Text SettingsPanel.Visible = false end)

tAlias.MouseButton1Click:Connect(function()
    useAlias = not useAlias
    tAlias.Text = useAlias and "Hide Name: ON" or "Hide Name: OFF"
    tAlias.BackgroundColor3 = useAlias and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

tGame.MouseButton1Click:Connect(function()
    hideGame = not hideGame
    tGame.Text = hideGame and "Hide Game: ON" or "Hide Game: OFF"
    tGame.BackgroundColor3 = hideGame and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

tPlat.MouseButton1Click:Connect(function() -- FIXED BUTTON
    hidePlatform = not hidePlatform
    tPlat.Text = hidePlatform and "Hide Device: ON" or "Hide Device: OFF"
    tPlat.BackgroundColor3 = hidePlatform and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

tClear.MouseButton1Click:Connect(function()
    for _, child in pairs(ChatArea:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
end)

tAdminClear.MouseButton1Click:Connect(function()
    pcall(function() request({Url = API_URL, Method = "DELETE"}) end)
end)

Send.MouseButton1Click:Connect(function() if Input.Text ~= "" then post(Input.Text) Input.Text = "" end end)
task.spawn(function() while task.wait(3) do update() end end)
addMsg("System", "Toggles Fixed. Ready for use!", "", "🛠️", "")
