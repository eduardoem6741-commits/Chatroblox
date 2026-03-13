local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")
local UserInput = game:GetService("UserInputService")

-- 1. CONFIG
local API_URL = "https://robloxglobalchat-217f7-default-rtdb.firebaseio.com/chat.json"
local myUserId = 8615238851 
local specialTags = {[myUserId] = "👑 OWNER"}

local useAlias, hideGame, hidePlatform = false, false, false
local customAlias = "Mysterious User"
local platformIcon = (UserInput.TouchEnabled and not UserInput.KeyboardEnabled) and "📱" or "💻"
local successName, placeInfo = pcall(function() return Market:GetProductInfo(game.PlaceId) end)
local currentGameName = successName and placeInfo.Name or "Unknown Game"

if guiParent:FindFirstChild("DeltaElite") then guiParent.DeltaElite:Destroy() end

-- 2. MAIN UI
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "DeltaElite"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 300); Main.Position = UDim2.new(1, -360, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Main.Draggable = true; Main.Active = true
Instance.new("UICorner", Main)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Color3.fromRGB(0, 170, 255); MainStroke.Thickness = 2

-- Header
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, -70, 0, 35); Header.BackgroundTransparency = 1
Header.Text = " 🌐 ELITE GLOBAL"; Header.TextColor3 = Color3.fromRGB(0, 170, 255)
Header.Font = Enum.Font.GothamBold; Header.TextSize = 16

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 28, 0, 28); MinBtn.Position = UDim2.new(1, -68, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); MinBtn.Text = "_"; MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

local SettingsBtn = Instance.new("TextButton", Main)
SettingsBtn.Size = UDim2.new(0, 28, 0, 28); SettingsBtn.Position = UDim2.new(1, -35, 0, 5)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); SettingsBtn.Text = "⚙️"; SettingsBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SettingsBtn)

-- Chat Container
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

local ChatArea = Instance.new("ScrollingFrame", Container)
ChatArea.Size = UDim2.new(1, -20, 1, -50); ChatArea.Position = UDim2.new(0, 10, 0, 0)
ChatArea.BackgroundTransparency = 1; ChatArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatArea.ScrollBarThickness = 2
Instance.new("UIListLayout", ChatArea).Padding = UDim.new(0, 5)

local Input = Instance.new("TextBox", Container)
Input.Size = UDim2.new(1, -75, 0, 35); Input.Position = UDim2.new(0, 10, 1, -45)
Input.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Input.TextColor3 = Color3.new(1,1,1)
Input.PlaceholderText = "Type message..."; Instance.new("UICorner", Input)

local Send = Instance.new("TextButton", Container)
Send.Size = UDim2.new(0, 55, 0, 35); Send.Position = UDim2.new(1, -65, 1, -45)
Send.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Send.Text = "SEND"; Send.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Send)

-- Settings Panel
local SettingsPanel = Instance.new("Frame", Main)
SettingsPanel.Size = UDim2.new(1, 0, 1, -40); SettingsPanel.Position = UDim2.new(0, 0, 0, 40)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SettingsPanel.Visible = false; SettingsPanel.ZIndex = 10 
Instance.new("UICorner", SettingsPanel)

local SLayout = Instance.new("UIListLayout", SettingsPanel)
SLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; SLayout.Padding = UDim.new(0, 8)

local AliasBox = Instance.new("TextBox", SettingsPanel)
AliasBox.Size = UDim2.new(0, 260, 0, 35); AliasBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
AliasBox.TextColor3 = Color3.new(1,1,1); AliasBox.Text = customAlias; AliasBox.ZIndex = 11
Instance.new("UICorner", AliasBox)

local function createSBtn(txt, color)
    local b = Instance.new("TextButton", SettingsPanel)
    b.Size = UDim2.new(0, 260, 0, 35); b.BackgroundColor3 = color
    b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.ZIndex = 11
    Instance.new("UICorner", b); return b
end

local tAlias = createSBtn("Hide Name: OFF", Color3.fromRGB(180, 50, 50))
local tGame = createSBtn("Hide Game: OFF", Color3.fromRGB(180, 50, 50))
local tPlat = createSBtn("Hide Device: OFF", Color3.fromRGB(180, 50, 50))
local CloseSet = createSBtn("SAVE & BACK", Color3.fromRGB(0, 170, 255))

-- [[ LOGIC ]]
local IsMinimized = false

local function UpdateUI()
    if IsMinimized then
        Main.Size = UDim2.new(0, 350, 0, 35)
        Container.Visible = false
        SettingsPanel.Visible = false
    else
        Main.Size = UDim2.new(0, 350, 0, 300)
        if SettingsPanel.Visible then
            Container.Visible = false
        else
            Container.Visible = true
        end
    end
end

-- Button Triggers
MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    MinBtn.Text = IsMinimized and "□" or "_"
    UpdateUI()
end)

SettingsBtn.MouseButton1Click:Connect(function()
    if IsMinimized then IsMinimized = false; MinBtn.Text = "_" end
    SettingsPanel.Visible = not SettingsPanel.Visible
    UpdateUI()
end)

CloseSet.MouseButton1Click:Connect(function()
    customAlias = AliasBox.Text
    SettingsPanel.Visible = false
    UpdateUI()
end)

-- Setting Toggles (Individually connected for safety)
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

tPlat.MouseButton1Click:Connect(function()
    hidePlatform = not hidePlatform
    tPlat.Text = hidePlatform and "Hide Device: ON" or "Hide Device: OFF"
    tPlat.BackgroundColor3 = hidePlatform and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

-- [[ NETWORK ]]
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function addMsg(user, txt, g, i, tg)
    local msg = Instance.new("TextLabel", ChatArea)
    msg.Size = UDim2.new(1, 0, 0, 20); msg.Font = Enum.Font.GothamBold; msg.TextSize = 14
    msg.BackgroundTransparency = 1; msg.TextXAlignment = Enum.TextXAlignment.Left; msg.TextWrapped = true; msg.AutomaticSize = Enum.AutomaticSize.Y
    local st = Instance.new("UIStroke", msg); st.Thickness = 1.5; st.Color = Color3.new(0,0,0)
    msg.Text = (g ~= "Hidden" and "["..g.."] " or "") .. (tg ~= "" and "["..tg.."] " or "") .. i .. " " .. user .. ": " .. txt
    msg.TextColor3 = (tg == "👑 OWNER") and Color3.new(1, 1, 0) or (string.find(user, "You") and Color3.fromRGB(0,255,150) or Color3.new(1,1,1))
    ChatArea.CanvasPosition = Vector2.new(0, ChatArea.AbsoluteCanvasSize.Y + 50)
end

local function post(t)
    local dU = useAlias and customAlias or Players.LocalPlayer.Name
    local dG = hideGame and "Hidden" or currentGameName
    local dI = hidePlatform and "❓" or platformIcon
    local dT = specialTags[Players.LocalPlayer.UserId] or ""
    addMsg(dU.." (You)", t, dG, dI, dT)
    pcall(function() request({Url = API_URL, Method = "POST", Body = HttpService:JSONEncode({u=dU, t=t, g=dG, i=dI, tg=dT, s=os.time()})}) end)
end

Send.MouseButton1Click:Connect(function() if Input.Text ~= "" then post(Input.Text) Input.Text = "" end end)

task.spawn(function()
    local lastT = os.time()
    while task.wait(3) do
        pcall(function()
            local res = request({Url = API_URL, Method = "GET"})
            local data = HttpService:JSONDecode(res.Body)
            for _, m in pairs(data) do
                if m.s > lastT and m.u ~= Players.LocalPlayer.Name and m.u ~= customAlias then
                    addMsg(m.u, m.t, m.g, m.i, m.tg)
                    lastT = m.s
                end
            end
        end)
    end
end)
