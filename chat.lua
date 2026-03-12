-- [[ CONFIG ]]
local FIREBASE_URL = "https://chatroblox-b1462-default-rtdb.firebaseio.com/" 
local FIREBASE_AUTH = "h1ZsAk2DiVCnG82V36hBpw33d6x9WUAto5YHCnKM" 
local TOGGLE_KEY = Enum.KeyCode.K

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- [[ UI CONSTRUCTION ]]
if guiParent:FindFirstChild("EliteTerminal_V5") then guiParent.EliteTerminal_V5:Destroy() end
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "EliteTerminal_V5"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 750, 0, 400); Main.Position = UDim2.new(0.5, -375, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

-- 1. LEFT SIDEBAR: COMMANDS
local CmdPanel = Instance.new("Frame", Main)
CmdPanel.Size = UDim2.new(0, 150, 1, -20); CmdPanel.Position = UDim2.new(0, 10, 0, 10)
CmdPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", CmdPanel)

local CmdTitle = Instance.new("TextLabel", CmdPanel)
CmdTitle.Size = UDim2.new(1, 0, 0, 25); CmdTitle.Text = "QUICK CMDS"; CmdTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
CmdTitle.Font = Enum.Font.Code; CmdTitle.BackgroundTransparency = 1

local CmdList = Instance.new("ScrollingFrame", CmdPanel)
CmdList.Size = UDim2.new(1, -10, 1, -35); CmdList.Position = UDim2.new(0, 5, 0, 30)
CmdList.BackgroundTransparency = 1; CmdList.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", CmdList).Padding = UDim.new(0, 5)

-- 2. CENTER: TERMINAL LOG
local LogArea = Instance.new("ScrollingFrame", Main)
LogArea.Size = UDim2.new(0, 410, 1, -85); LogArea.Position = UDim2.new(0, 170, 0, 40)
LogArea.BackgroundTransparency = 1; LogArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogArea).Padding = UDim.new(0, 2)

-- 3. RIGHT SIDEBAR: GLOBAL PLAYERS
local SidePanel = Instance.new("Frame", Main)
SidePanel.Size = UDim2.new(0, 150, 1, -20); SidePanel.Position = UDim2.new(1, -160, 0, 10)
SidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", SidePanel)

local UserTitle = Instance.new("TextLabel", SidePanel)
UserTitle.Size = UDim2.new(1, 0, 0, 25); UserTitle.Text = "GLOBAL USERS"; UserTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
UserTitle.Font = Enum.Font.Code; UserTitle.BackgroundTransparency = 1

local UserList = Instance.new("ScrollingFrame", SidePanel)
UserList.Size = UDim2.new(1, -10, 1, -35); UserList.Position = UDim2.new(0, 5, 0, 30)
UserList.BackgroundTransparency = 1; UserList.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", UserList).Padding = UDim.new(0, 5)

-- Input Bar
local Input = Instance.new("TextBox", Main)
Input.Size = UDim2.new(0, 410, 0, 35); Input.Position = UDim2.new(0, 170, 1, -40)
Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Input.TextColor3 = Color3.new(1,1,1)
Input.PlaceholderText = "> EXECUTE_"; Input.Font = Enum.Font.Code
Instance.new("UICorner", Input)

-- [[ HELPER FUNCTIONS ]]
local function AddLog(text, color)
    local l = Instance.new("TextLabel", LogArea)
    l.Size = UDim2.new(1, 0, 0, 18); l.Text = "[SYSTEM]: " .. text
    l.TextColor3 = color or Color3.new(0.8, 0.8, 0.8); l.BackgroundTransparency = 1
    l.Font = Enum.Font.Code; l.TextXAlignment = Enum.TextXAlignment.Left
    LogArea.CanvasPosition = Vector2.new(0, 9999)
end

-- [[ COMMANDS ]]
local function RunCmd(name, arg)
    if name == "speed" then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(arg) or 100
    elseif name == "jump" then LocalPlayer.Character.Humanoid.JumpPower = tonumber(arg) or 100
    elseif name == "re" then LocalPlayer:LoadCharacter()
    elseif name == "kill" then LocalPlayer.Character.Humanoid.Health = 0
    elseif name == "fly" then AddLog("Fly enabled (Simulation)", Color3.new(1,1,0))
    end
    AddLog("Executed: " .. name, Color3.new(0, 1, 0.5))
end

-- Create Cmd Buttons
local quickCmds = {"speed", "jump", "re", "kill", "fly"}
for _, name in pairs(quickCmds) do
    local b = Instance.new("TextButton", CmdList)
    b.Size = UDim2.new(1, 0, 0, 25); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = name:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
    b.MouseButton1Click:Connect(function() RunCmd(name) end)
    Instance.new("UICorner", b)
end

-- [[ NETWORK LOGIC ]]
local function CheckNetwork()
    local gameName = Market:GetProductInfo(game.PlaceId).Name
    -- Register Self
    pcall(function()
        HttpService:RequestAsync({
            Url = FIREBASE_URL .. "GlobalUsers/" .. LocalPlayer.UserId .. ".json?auth=" .. FIREBASE_AUTH,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({Name = LocalPlayer.Name, JobId = game.JobId, PlaceId = game.PlaceId, GameName = gameName, LastSeen = os.time()})
        })
    end)
    -- Refresh List
    local s, res = pcall(function() return HttpService:GetAsync(FIREBASE_URL .. "GlobalUsers.json?auth=" .. FIREBASE_AUTH) end)
    if s and res and res ~= "null" then
        for _, v in pairs(UserList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local data = HttpService:JSONDecode(res)
        for _, user in pairs(data) do
            if os.time() - (user.LastSeen or 0) < 600 then
                local b = Instance.new("TextButton", UserList)
                b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                b.Text = user.Name .. "\n" .. user.GameName; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10
                b.MouseButton1Click:Connect(function()
                    if user.JobId == game.JobId then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Players[user.Name].Character.HumanoidRootPart.CFrame
                    else
                        setclipboard("game:GetService('TeleportService'):TeleportToPlaceInstance("..user.PlaceId..", '"..user.JobId.."')")
                        AddLog("Join Code Copied!", Color3.new(1,1,0))
                    end
                end)
            end
        end
    end
end

Input.FocusLost:Connect(function(enter)
    if enter and Input.Text ~= "" then
        local args = string.split(Input.Text, " ")
        RunCmd(args[1]:lower(), args[2])
        Input.Text = ""
    end
end)

task.spawn(function() while task.wait(20) do CheckNetwork() end end)
CheckNetwork()
AddLog("Elite Pro Dashboard V5.1 Online.", Color3.new(0, 1, 0.5))
    end)
end

local function Refresh()
    for _, v in pairs(UserList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local success, res = pcall(function() return HttpService:GetAsync(FIREBASE_URL .. "GlobalUsers.json?auth=" .. FIREBASE_AUTH) end)
    if success and res and res ~= "null" then
        local data = HttpService:JSONDecode(res)
        for _, user in pairs(data) do
            if os.time() - user.LastSeen < 600 then
                local b = Instance.new("TextButton", UserList)
                b.Size = UDim2.new(1, 0, 0, 20)
                b.Text = user.Name
                b.MouseButton1Click:Connect(function()
                    if user.JobId == game.JobId then
                        local t = Players:FindFirstChild(user.Name)
                        if t and t.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end
                    else
                        setclipboard("game:GetService('TeleportService'):TeleportToPlaceInstance("..user.PlaceId..", '"..user.JobId.."')")
                    end
                end)
            end
        end
    end
end

-- [[ LOOPS ]]
task.spawn(function()
    while task.wait(30) do
        Register()
        Refresh()
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == TOGGLE_KEY then Main.Visible = not Main.Visible end
end)

Register()
Refresh()
print("Elite Global Loaded.")
