-- [[ CONFIGURATION ]]
local FIREBASE_URL = "https://robloxglobalchat-217f7-default-rtdb.firebaseio.com/" -- Ensure it ends with /
local FIREBASE_AUTH = "h1ZsAk2DiVCnG82V36hBpw33d6x9WUAto5YHCnKM"
local TOGGLE_KEY = Enum.KeyCode.K

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- [[ DATABASE UTILS ]]
local networkPath = FIREBASE_URL .. "GlobalUsers/" .. LocalPlayer.UserId .. ".json?auth=" .. FIREBASE_AUTH

local function RegisterUser()
    pcall(function()
        HttpService:RequestAsync({
            Url = networkPath,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                Name = LocalPlayer.Name,
                JobId = game.JobId,
                PlaceId = game.PlaceId,
                LastSeen = os.time()
            })
        })
    end)
end

local function GetGlobalUsers()
    local success, res = pcall(function()
        return HttpService:GetAsync(FIREBASE_URL .. "GlobalUsers.json?auth=" .. FIREBASE_AUTH)
    end)
    if success and res and res ~= "null" then
        return HttpService:JSONDecode(res)
    end
    return {}
end

-- [[ UI SETUP ]]
if guiParent:FindFirstChild("EliteTerminal_Global") then guiParent.EliteTerminal_Global:Destroy() end
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "EliteTerminal_Global"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 550, 0, 320)
Main.Position = UDim2.new(0.5, -275, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- [[ LOG AREA ]]
local LogArea = Instance.new("ScrollingFrame", Main)
LogArea.Size = UDim2.new(0, 360, 1, -75)
LogArea.Position = UDim2.new(0, 10, 0, 35)
LogArea.BackgroundTransparency = 1
LogArea.ScrollBarThickness = 1
LogArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogArea).Padding = UDim.new(0, 2)

-- [[ GLOBAL SIDEBAR ]]
local SidePanel = Instance.new("Frame", Main)
SidePanel.Size = UDim2.new(0, 160, 1, -45)
SidePanel.Position = UDim2.new(1, -170, 0, 35)
SidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", SidePanel)

local SideTitle = Instance.new("TextLabel", SidePanel)
SideTitle.Size = UDim2.new(1, 0, 0, 25)
SideTitle.Text = "SCRIPT USERS"
SideTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
SideTitle.Font = Enum.Font.Code
SideTitle.TextSize = 12
SideTitle.BackgroundTransparency = 1

local UserList = Instance.new("ScrollingFrame", SidePanel)
UserList.Size = UDim2.new(1, -10, 1, -30)
UserList.Position = UDim2.new(0, 5, 0, 25)
UserList.BackgroundTransparency = 1
UserList.ScrollBarThickness = 1
UserList.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", UserList).Padding = UDim.new(0, 2)

-- [[ TERMINAL FUNCTIONS ]]
local function Print(text, color)
    local label = Instance.new("TextLabel", LogArea)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Text = "> " .. text
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    LogArea.CanvasPosition = Vector2.new(0, 9999)
end

local function RefreshGlobalList()
    for _, v in pairs(UserList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local users = GetGlobalUsers()
    
    for id, data in pairs(users) do
        -- Only show users active in the last 10 minutes
        if os.time() - data.LastSeen < 600 then
            local btn = Instance.new("TextButton", UserList)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.BackgroundColor3 = (data.Name == LocalPlayer.Name) and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(25, 25, 30)
            btn.Text = data.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Code
            btn.TextSize = 11
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                if data.JobId == game.JobId then
                    local target = Players:FindFirstChild(data.Name)
                    if target and target.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                        Print("Teleported to local user: " .. data.Name, Color3.new(0,1,0))
                    end
                else
                    setclipboard("game:GetService('TeleportService'):TeleportToPlaceInstance("..data.PlaceId..", '"..data.JobId.."')")
                    Print("Join script for " .. data.Name .. " copied to clipboard!", Color3.new(1,1,0))
                end
            end)
        end
    end
end

-- [[ LOOPS ]]
task.spawn(function()
    while task.wait(30) do
        RegisterUser()
        RefreshGlobalList()
    end
end)

RegisterUser()
RefreshGlobalList()

Print("Elite Global Terminal V4.4 Active.", Color3.fromRGB(0, 255, 150))
