--==[ Chest Farm Script | Smart Server Hop | By Chiriku Roblox ]==--
repeat wait() until game:IsLoaded()

-- SETTINGS
getgenv().Team = "Marines"
getgenv().Speed = 350
getgenv().Enabled = getgenv().Enabled or false
getgenv().TotalMoney = getgenv().TotalMoney or 0

-- NOTIFY GIỚI THIỆU
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Chest Farm | By Chiriku Roblox",
        Text = "Đang tải... Chờ 2s để bắt đầu farm chest!",
        Duration = 5
    })
end)

-- ANTI AFK
spawn(function()
    local vu = game:GetService("VirtualUser")
    game.Players.LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- AUTO TEAM
spawn(function()
    while not game.Players.LocalPlayer.Team or game.Players.LocalPlayer.Team.Name ~= getgenv().Team do
        for i,v in pairs(game:GetService("Teams"):GetChildren()) do
            if v.Name == getgenv().Team then
                game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("SetTeam", getgenv().Team)
            end
        end
        wait(2)
    end
end)

-- UI
if game.CoreGui:FindFirstChild("ChestFarmUI") then game.CoreGui.ChestFarmUI:Destroy() end
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestFarmUI"

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 140, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 100)
toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggle.TextColor3 = Color3.fromRGB(255, 255, 0)
toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
toggle.TextSize = 16
toggle.Font = Enum.Font.SourceSansBold
toggle.BorderSizePixel = 0

local moneyLabel = Instance.new("TextLabel", gui)
moneyLabel.Size = UDim2.new(0, 200, 0, 30)
moneyLabel.Position = UDim2.new(0, 10, 0, 145)
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
moneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
moneyLabel.TextSize = 16
moneyLabel.Font = Enum.Font.SourceSansBold

toggle.MouseButton1Click:Connect(function()
    getgenv().Enabled = not getgenv().Enabled
    toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
end)

-- SAVE SETTINGS ON TELEPORT
queue_on_teleport([[
    getgenv().Team = "]]..getgenv().Team..[["
    getgenv().Speed = ]]..getgenv().Speed..[[
    getgenv().TotalMoney = ]]..getgenv().TotalMoney..[[
    getgenv().Enabled = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/ChirikuFarmChest/refs/heads/main/ChirikuFarmChest.lua"))()
]])

-- ISLAND LOCATIONS (SEA 1/2/3)
local SeaIslands = {
    [1] = {
        Vector3.new(104, 16, 1573),     -- Starter Island
        Vector3.new(1064, 16, 1407),    -- Jungle
        Vector3.new(-1203, 4, 391),     -- Pirate Village
        Vector3.new(1143, 4, -4322),    -- Desert
        Vector3.new(-655, 7, 1430),     -- Middle Island
        Vector3.new(-1601, 17, -2755),  -- Frozen Village
        Vector3.new(-3834, 6, -2885),   -- Marine Fortress
        Vector3.new(3657, 38, -3215),   -- Skylands
        Vector3.new(4874, 5, -2623),    -- Prison
        Vector3.new(-5403, 10, -2660),  -- Colosseum
        Vector3.new(-5246, 7, -2272),   -- Magma Village
        Vector3.new(6073, 39, -3900),   -- Underwater City
        Vector3.new(5133, 4, 4054),     -- Fountain City
    },
    [2] = {
        Vector3.new(-393, 73, 258),     -- Kingdom of Rose
        Vector3.new(-469, 73, 603),     -- Usoap's Island
        Vector3.new(17, 74, 295),       -- Cafe
        Vector3.new(228, 8, 915),       -- Don Swan's Mansion
        Vector3.new(-1036, 198, -1050), -- Green Zone
        Vector3.new(-5345, 8, -712),    -- Graveyard
        Vector3.new(5443, 602, 752),    -- Snow Mountain
        Vector3.new(2174, 39, 909),     -- Hot and Cold
        Vector3.new(-6330, 16, -1247),  -- Cursed Ship
        Vector3.new(5400, 80, -640),    -- Ice Castle
        Vector3.new(-6105, 16, -5047),  -- Forgotten Island
        Vector3.new(5981, 5, -2317),    -- Dark Arena
    },
    [3] = {
        Vector3.new(-262, 20, 5301),    -- Port Town
        Vector3.new(-2850, 20, 5340),   -- Hydra Island
        Vector3.new(-12498, 332, 7879), -- Castle on the Sea
        Vector3.new(-9500, 20, -900),   -- Floating Turtle
        Vector3.new(6044, 20, -134),    -- Great Tree
        Vector3.new(2575, 7, 850),      -- Haunted Castle
        Vector3.new(-6100, 16, -2400),  -- Sea of Treats
        Vector3.new(1575, 16, -1333),   -- Tiki Outpost
    }
}

-- GET SEA
function GetCurrentSea()
    local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if workspace:FindFirstChild("ShipWreck") then
        return 3
    elseif workspace:FindFirstChild("ForgottenIsland") then
        return 2
    else
        return 1
    end
end

-- GET CHESTS
function GetAllChests()
    local chests = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("chest") and v:FindFirstChildWhichIsA("BasePart") then
            local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
            if part and v:FindFirstChildWhichIsA("TouchTransmitter", true) then
                table.insert(chests, part)
            end
        end
    end
    return chests
end

-- BAY
function TweenTo(pos)
    local TweenService = game:GetService("TweenService")
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local dist = (hrp.Position - pos).Magnitude
    local time = dist / getgenv().Speed
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))}
    local tween = TweenService:Create(hrp, info, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- SMART SERVER HOP
function SmartHop()
    local chests = GetAllChests()
    if #chests == 0 then
        local currentSea = GetCurrentSea()
        local islands = SeaIslands[currentSea]

        -- Kiểm tra đảo đã hết chest và nhảy sang server khác
        local function CheckIslandsAndHop()
            for _, island in ipairs(islands) do
                TweenTo(island)
                wait(2)  -- Đợi 2s để kiểm tra
                if #GetAllChests() > 0 then
                    return true
                end
            end
            return false
        end
        
        -- Thực hiện nhảy server
        if not CheckIslandsAndHop() then
            -- Smart hop tới server khác nếu không còn chest
            local oldServerID = game:GetService("SocialService"):GetOnlinePlayerCount()
            local success, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
            if not success then
                print("Error when hopping server: " .. err)
            end
        end
    end
end

-- FARM
spawn(function()
    while wait(1) do
        if getgenv().Enabled then
            local found = false
            local sea = GetCurrentSea()
            for _,island in pairs(SeaIslands[sea]) do
                if not getgenv().Enabled then break end
                TweenTo(island)
                wait(2)
                local chests = GetAllChests()
                table.sort(chests, function(a,b)
                    return (a.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                           (b.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                end)
                for _,chest in pairs(chests) do
                    if not getgenv().Enabled then break end
