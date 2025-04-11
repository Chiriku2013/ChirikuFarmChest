-- Script Farm Chest Pro (Skull Hub Style) | By ChatGPT
if not game:IsLoaded() then game.Loaded:Wait() end

-- Anti AFK
pcall(function()
    local vu = game:service("VirtualUser")
    game:service("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto Join Team
getgenv().Team = "Marines"
repeat wait()
    for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "Team" then
            if getgenv().Team == "Pirates" then
                v:WaitForChild("Frame"):WaitForChild("Pirates").MouseButton1Click:Fire()
            else
                v:WaitForChild("Frame"):WaitForChild("Marines").MouseButton1Click:Fire()
            end
        end
    end
until game.Players.LocalPlayer.Team ~= nil

-- UI Setup
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Chest Farm | Skull Style",
    HidePremium = false,
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "Script by Chiriku Roblox"
})

-- Variables
local ChestFarm = false
local FlySpeed = 350
local FastAttack = true

-- Chest ESP
function ESPChest()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("TouchInterest") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("chest") and not v:FindFirstChild("ESP") then
            local bill = Instance.new("BillboardGui", v)
            bill.Name = "ESP"
            bill.Size = UDim2.new(0,100,0,40)
            bill.AlwaysOnTop = true
            bill.Adornee = v.HumanoidRootPart

            local txt = Instance.new("TextLabel", bill)
            txt.Size = UDim2.new(1,0,1,0)
            txt.Text = "[Chest] | "..math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude).."m"
            txt.TextColor3 = Color3.new(1,1,0)
            txt.BackgroundTransparency = 1
            txt.TextScaled = true
        end
    end
end

-- Fast Attack (Simple)
function DoFastAttack()
    if FastAttack then
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, "Z", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "Z", false, game)
    end
end

-- Chest Farm Loop
function FarmChest()
    while ChestFarm do wait()
        ESPChest()
        local nearest = nil
        local shortest = math.huge
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("TouchInterest") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("chest") then
                local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if mag < shortest then
                    shortest = mag
                    nearest = v
                end
            end
        end
        if nearest then
            repeat wait()
                pcall(function()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                end)
            until not nearest.Parent or (nearest:FindFirstChild("TouchInterest") == nil) or not ChestFarm
        else
            -- Auto Hop Server
            local Http = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local Servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100"))
            for _,v in pairs(Servers.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                    break
                end
            end
        end
    end
end

-- Notify When Found FOD or Chalice
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "Fist of Darkness" or obj.Name == "God's Chalice" then
        OrionLib:MakeNotification({
            Name = "Hiếm!",
            Content = obj.Name.." đã xuất hiện!",
            Image = "rbxassetid://6031075938",
            Time = 8
        })
    end
end)

-- Tabs & Toggles
local Tab = Window:MakeTab({Name = "Farm", Icon = "rbxassetid://6031225922", PremiumOnly = false})

Tab:AddToggle({
    Name = "Bật Farm Chest",
    Default = false,
    Callback = function(Value)
        ChestFarm = Value
        if Value then
            FarmChest()
        end
    end
})

Tab:AddSlider({
    Name = "Tốc độ bay",
    Min = 100,
    Max = 600,
    Default = 350,
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        FlySpeed = Value
    end    
})

Tab:AddToggle({
    Name = "Fast Attack (Z)",
    Default = true,
    Callback = function(Value)
        FastAttack = Value
    end
})

OrionLib:Init()
