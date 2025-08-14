local function ShowSplashScreen()
    local SplashUI = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local PlayersList = Instance.new("TextLabel")
    local LoadingBar = Instance.new("Frame")
    local InnerBar = Instance.new("Frame")
    local Footer = Instance.new("TextLabel")

    SplashUI.Name = "AeshiyoSplash"
    SplashUI.Parent = game:GetService("CoreGui")

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = SplashUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 250)

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.Text = "# LOADING MAP..."
    Title.TextColor3 = Color3.fromRGB(0, 255, 150)
    Title.TextSize = 20
    Title.Font = Enum.Font.SciFi
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.1, 0, 0.05, 0)
    Title.Size = UDim2.new(0.8, 0, 0, 25)

    PlayersList.Name = "PlayersList"
    PlayersList.Parent = MainFrame
    PlayersList.Text = "mame_65856686\nfrog6719\nMAX2dcdx\nvonichis88_vzbek\nashamur_ka\nleen_m19\nMalak_2201a\nyotes4123706\nacs0_0\n\nFriends Playing: 0"
    PlayersList.TextColor3 = Color3.fromRGB(180, 180, 180)
    PlayersList.TextSize = 14
    PlayersList.Font = Enum.Font.Code
    PlayersList.BackgroundTransparency = 1
    PlayersList.Position = UDim2.new(0.1, 0, 0.15, 0)
    PlayersList.Size = UDim2.new(0.8, 0, 0, 150)
    PlayersList.TextXAlignment = Enum.TextXAlignment.Left

    LoadingBar.Name = "LoadingBar"
    LoadingBar.Parent = MainFrame
    LoadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LoadingBar.BorderSizePixel = 0
    LoadingBar.Position = UDim2.new(0.1, 0, 0.8, 0)
    LoadingBar.Size = UDim2.new(0.8, 0, 0, 8)

    InnerBar.Name = "InnerBar"
    InnerBar.Parent = LoadingBar
    InnerBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    InnerBar.BorderColor3 = Color3.fromRGB(0, 150, 80)
    InnerBar.BorderSizePixel = 1
    InnerBar.Size = UDim2.new(0, 0, 1, 0)

    Footer.Name = "Footer"
    Footer.Parent = MainFrame
    Footer.Text = "aeshiyo  |  MENU  |  SHOP  |  DECLINE"
    Footer.TextColor3 = Color3.fromRGB(100, 255, 200)
    Footer.TextSize = 12
    Footer.Font = Enum.Font.SciFi
    Footer.BackgroundTransparency = 1
    Footer.Position = UDim2.new(0.1, 0, 0.9, 0)
    Footer.Size = UDim2.new(0.8, 0, 0, 20)

    for i = 1, 100 do
        InnerBar.Size = UDim2.new(i/100, 0, 1, 0)
        wait(0.03)
    end
    wait(0.5)
    SplashUI:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    Aimbot = {Enabled = false, FOV = 100, Smoothness = 20, TeamCheck = true, VisibleCheck = true, Keybind = Enum.UserInputType.MouseButton2},
    ESP = {Enabled = false, ShowTeam = false, ShowDistance = true, TextSize = 13},
    Misc = {AutoFarm = false, SpeedHack = false, SpeedMultiplier = 1.5}
}

ShowSplashScreen()

local function GetTeam(Player)
    if not Player.Character then return nil end
    local Shirt = Player.Character:FindFirstChildOfClass("Shirt")
    if Shirt then return Shirt.ShirtTemplate end
    return nil
end

local function IsEnemy(Player)
    if not Settings.Aimbot.TeamCheck then return true end
    return GetTeam(Player) ~= GetTeam(LocalPlayer)
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if IsEnemy(player) then
                local character = player.Character
                local rootPart = character.HumanoidRootPart
                if Settings.Aimbot.VisibleCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character, LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local origin = Camera.CFrame.Position
                    local direction = (rootPart.Position - origin).Unit * 1000
                    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
                    if raycastResult and not raycastResult.Instance:IsDescendantOf(character) then
                        continue
                    end
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local mouseLocation = Vector2.new(Mouse.X, Mouse.Y)
                    local playerLocation = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (mouseLocation - playerLocation).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Settings.Aimbot.Keybind and Settings.Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = target.Character.HumanoidRootPart
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not UserInputService:IsMouseButtonPressed(Settings.Aimbot.Keybind) then
                    connection:Disconnect()
                    return
                end
                local cameraCFrame = Camera.CFrame
                local targetPosition = rootPart.Position
                local smoothed = cameraCFrame:Lerp(CFrame.new(cameraCFrame.Position, targetPosition), Settings.Aimbot.Smoothness / 100)
                Camera.CFrame = smoothed
            end)
        end
    end
end)

local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Player = player,
        Drawings = {}
    }
    function esp:Update()
        if not self.Player.Character or not self.Player.Character:FindFirstChild("HumanoidRootPart") then
            self:Remove()
            return
        end
        if not IsEnemy(self.Player) and not Settings.ESP.ShowTeam then
            for _, drawing in pairs(self.Drawings) do
                drawing.Visible = false
            end
            return
        end
        local character = self.Player.Character
        local rootPart = character.HumanoidRootPart
        local head = character:FindFirstChild("Head")
        if not head then return end
        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            for _, drawing in pairs(self.Drawings) do
                drawing.Visible = false
            end
            return
        end
        if not self.Drawings.Text then
            self.Drawings.Text = Drawing.new("Text")
            self.Drawings.Text.Size = Settings.ESP.TextSize
            self.Drawings.Text.Outline = true
            self.Drawings.Text.Center = true
            self.Drawings.Text.Color = Color3.new(1, 1, 1)
        end
        self.Drawings.Text.Position = Vector2.new(screenPosition.X, screenPosition.Y)
        self.Drawings.Text.Text = player.Name .. (Settings.ESP.ShowDistance and (" (" .. math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude) .. "m)") or "")
        self.Drawings.Text.Visible = Settings.ESP.Enabled
    end
    function esp:Remove()
        for _, drawing in pairs(self.Drawings) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
    ESPObjects[player] = esp
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player]:Remove()
    end
end)

local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local AimbotToggle = Instance.new("TextButton")
    local ESPToggle = Instance.new("TextButton")
    local SpeedToggle = Instance.new("TextButton")

    ScreenGui.Name = "MM2HackGUI"
    ScreenGui.Parent = CoreGui

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    MainFrame.Size = UDim2.new(0, 200, 0, 200)
    MainFrame.Visible = false

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSans
    Title.Text = "MM2 Hack Menu"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18

    AimbotToggle.Name = "AimbotToggle"
    AimbotToggle.Parent = MainFrame
    AimbotToggle.Position = UDim2.new(0, 0, 0, 40)
    AimbotToggle.Size = UDim2.new(1, 0, 0, 30)
    AimbotToggle.Font = Enum.Font.SourceSans
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextSize = 16
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    ESPToggle.Name = "ESPToggle"
    ESPToggle.Parent = MainFrame
    ESPToggle.Position = UDim2.new(0, 0, 0, 80)
    ESPToggle.Size = UDim2.new(1, 0, 0, 30)
    ESPToggle.Font = Enum.Font.SourceSans
    ESPToggle.Text = "ESP: OFF"
    ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggle.TextSize = 16
    ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    SpeedToggle.Name = "SpeedToggle"
    SpeedToggle.Parent = MainFrame
    SpeedToggle.Position = UDim2.new(0, 0, 0, 120)
    SpeedToggle.Size = UDim2.new(1, 0, 0, 30)
    SpeedToggle.Font = Enum.Font.SourceSans
    SpeedToggle.Text = "Speed: OFF"
    SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedToggle.TextSize = 16
    SpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    AimbotToggle.MouseButton1Click:Connect(function()
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        AimbotToggle.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    end)

    ESPToggle.MouseButton1Click:Connect(function()
        Settings.ESP.Enabled = not Settings.ESP.Enabled
        ESPToggle.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    end)

    SpeedToggle.MouseButton1Click:Connect(function()
        Settings.Misc.SpeedHack = not Settings.Misc.SpeedHack
        SpeedToggle.Text = "Speed: " .. (Settings.Misc.SpeedHack and "ON" or "OFF")
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

CreateMenu()

RunService.RenderStepped:Connect(function()
    for _, esp in pairs(ESPObjects) do
        esp:Update()
    end
    if Settings.Misc.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Settings.Misc.SpeedMultiplier
    end
end)
