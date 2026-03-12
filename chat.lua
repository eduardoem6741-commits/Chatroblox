-- [[ CONFIG ]]
local FIREBASE_URL = "https://robloxglobalchat-217f7-default-rtdb.firebaseio.com/" 
local FIREBASE_AUTH = "h1ZsAk2DiVCnG82V36hBpw33d6x9WUAto5YHCnKM"
local TOGGLE_KEY = Enum.KeyCode.K

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- [[ UI ]]
if guiParent:FindFirstChild("EliteTerminal") then guiParent.EliteTerminal:Destroy() end
local ScreenGui = Instance.new("ScreenGui", guiParent); ScreenGui.Name = "EliteTerminal"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true

local UserList = Instance.new("ScrollingFrame", Main)
UserList.Size = UDim2.new(0, 150, 1, -20)
UserList.Position = UDim2.new(1, -160, 0, 10)
UserList.BackgroundTransparency = 0.5
UserList.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", UserList)

-- [[ LOGIC ]]
local function Register()
    pcall(function()
        HttpService:RequestAsync({
            Url = FIREBASE_URL .. "GlobalUsers/" .. LocalPlayer.UserId .. ".json?auth=" .. FIREBASE_AUTH,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({Name = LocalPlayer.Name, JobId = game.JobId, PlaceId = game.PlaceId, LastSeen = os.time()})
        })
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
