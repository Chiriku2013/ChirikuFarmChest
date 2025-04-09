repeat wait() until game:IsLoaded()

-- // GIỚI THIỆU
print("======================================")
print(" Script: Farm Chest Blox Fruits ")
print(" Style: Chiriku Roblox Hub | By Chiriku Roblox ")
print(" Features: Safe Fly, Server Hop, GUI Toggle")
print(" Executor: Delta X (Mobile supported)")
print("======================================")

-- // ANTI AFK
game.Players.LocalPlayer.Idled:Connect(function()
   game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- // UI
local farming = false

local gui = Instance.new("ScreenGui")
gui.Name = "ChestFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local btn = Instance.new("TextButton")
btn.Parent = gui
btn.Position = UDim2.new(0.5, -75, 0.1, 0)
btn.Size = UDim2.new(0,150,0,40)
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
btn.Text = "BẬT FARM CHEST"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 20
btn.BorderSizePixel = 0
btn.AutoButtonColor = true

btn.MouseButton1Click:Connect(function()
    farming = not farming
    btn.Text = farming and "TẮT FARM CHEST" or "BẬT FARM CHEST"
    btn.BackgroundColor3 = farming and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 255)
end)

-- // FLY TO FUNCTION
local TweenService = game:GetService("TweenService")
function flyTo(pos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    local distance = (hrp.Position - pos).Magnitude
    local time = distance / 120
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- // SERVER HOP
function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local req = (syn and syn.request) or http_request or request
    if not req then return end

    local servers = {}
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    local res = req({Url = url, Method = "GET"})
    local data = HttpService:JSONDecode(res.Body)

    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers then
            table.insert(servers, v.id)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceID, servers[math.random(1, #servers)], game.Players.LocalPlayer)
    end
end

-- // MAIN FARM
spawn(function()
    while wait() do
        if farming then
            local chests = {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") and v.Name == "Chest" then
                    table.insert(chests, v)
                end
            end

            if #chests == 0 then
                print("Không còn chest... Server hop")
                wait(2)
                serverHop()
            else
                for _, chest in pairs(chests) do
                    pcall(function()
                        flyTo(chest.Position)
                        wait(0.5)
                    end)
                end
            end

            wait(10)
        end
    end
end)