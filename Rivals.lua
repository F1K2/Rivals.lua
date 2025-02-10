local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Pour détecter les entrées de souris
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rivals",
    Icon = 0,
    LoadingTitle = "Rivals V2",
    LoadingSubtitle = "Shadow & Kazik's",
    Theme = "AmberGlow",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil,
       FileName = "Kyze"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = true, -- Set this to true to use our key system
    KeySettings = {
        Title = "Rivals V2",
        Subtitle = "Systeme de Key",
        Note = "Les key Sont payantes", -- Use this to tell the user how to get a key
        FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
        SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
        GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
        Key = {"https://pastebin.com/raw/bN2mKzkg"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458) -- Nouveau tab pour les paramètres

local Configuration = { 
    ESP = false, 
    ShowHealth = false, 
    ShowDistance = false, 
    ShowTracers = false, 
    Aimbot = false,
    Fly = false,
    FOV = 70,
    AimbotFOV = 100
}

-- Variable pour stocker les couleurs sélectionnées
Configuration.ESPColor = Color3.fromRGB(0, 255, 0) -- Vert par défaut
Configuration.TracerColor = Color3.fromRGB(255, 0, 0) -- Rouge par défaut

-- Ajout du mode Fly
local function Fly()
    local plr = Players.LocalPlayer
    local character = plr.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local flying = true
    local bg = Instance.new("BodyGyro", humanoidRootPart)
    local bv = Instance.new("BodyVelocity", humanoidRootPart)
    
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = humanoidRootPart.CFrame
    
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    game.StarterGui:SetCore("SendNotification", {Title="Fly Activated", Text="WeAreDevs.net", Duration=1})
    
    local function stopFly()
        flying = false
        bg:Destroy()
        bv:Destroy()
        plr.Character.Humanoid.PlatformStand = false
        game.StarterGui:SetCore("SendNotification", {Title="Fly Deactivated", Text="WeAreDevs.net", Duration=1})
    end
    
    local function flyLoop()
        while flying do
            RunService.RenderStepped:Wait()
            humanoidRootPart.Velocity = Vector3.new(0, 5, 0)
        end
    end
    
    task.spawn(flyLoop)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.E then
            if flying then
                stopFly()
            else
                Fly()
            end
        end
    end)
end

local Toggle = SettingsTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly", -- A flag is the identifier for the configuration file
    Callback = function(Value)
        Configuration.Fly = Value
        if Value then
            Fly()
        end
    end,
 })

-- Dictionnaire pour stocker les tracers de chaque joueur
local playerTracers = {}

-- Fonction pour dessiner les lignes tracées vers chaque joueur
local function TracersFunction()
    -- Créer un tracer pour chaque joueur existant dans la scène
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Configuration.TracerColor
            line.Transparency = 0.5
            line.Visible = false
            playerTracers[player] = line
        end
    end

    -- Suivre les changements dans les joueurs
    Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Configuration.TracerColor
            line.Transparency = 0.5
            line.Visible = false
            playerTracers[player] = line
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        -- Supprimer le tracer du joueur qui se déconnecte
        if playerTracers[player] then
            playerTracers[player]:Remove()
            playerTracers[player] = nil
        end
    end)

    -- Fonction qui s'exécute à chaque frame
    RunService.RenderStepped:Connect(function()
        if not Configuration.ShowTracers then
            -- Masquer tous les tracers si la configuration est désactivée
            for _, line in pairs(playerTracers) do
                line.Visible = false
            end
            return
        end

        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character
        if not character then return end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        -- Pour chaque joueur, dessiner un tracer vers leur HumanoidRootPart
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local target = player.Character:FindFirstChild("HumanoidRootPart")
                if target and playerTracers[player] then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                    if onScreen then
                        -- Positionner et dessiner le tracer
                        local line = playerTracers[player]
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Bas de l'écran
                        line.To = Vector2.new(screenPos.X, screenPos.Y)
                        line.Visible = Configuration.ShowTracers -- Utiliser l'état de la configuration pour afficher/masquer
                    else
                        -- Si le joueur est hors écran, cacher le tracer
                        playerTracers[player].Visible = false
                    end
                else
                    playerTracers[player].Visible = false
                end
            end
        end
    end)
end

-- Fonction ESP
local function ESPFunction()
    while Configuration.ESP do
        RunService.RenderStepped:Wait()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local highlight = character:FindFirstChild("EnemyHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight", character)
                        highlight.Name = "EnemyHighlight"
                    end
                    highlight.FillColor = Configuration.ESPColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                end
            end
        end
    end

    -- Désactiver l'ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("EnemyHighlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Fonction Health Bar
local function HealthBarFunction()
    while Configuration.ShowHealth do
        RunService.RenderStepped:Wait()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoidRootPart then
                    local healthTag = character:FindFirstChild("HealthTag")
                    if not healthTag then
                        healthTag = Instance.new("BillboardGui", character)
                        healthTag.Name = "HealthTag"
                        healthTag.Size = UDim2.new(2, 0, 1, 0)
                        healthTag.StudsOffset = Vector3.new(0, 3, 0)
                        healthTag.AlwaysOnTop = true
                        local textLabel = Instance.new("TextLabel", healthTag)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.TextScaled = true
                    end
                    healthTag.TextLabel.Text = "❤️ " .. math.floor(humanoid.Health)
                end
            end
        end
    end

    -- Supprimer les health bars lorsque le toggle est OFF
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local healthTag = player.Character:FindFirstChild("HealthTag")
            if healthTag then
                healthTag:Destroy()
            end
        end
    end
end

-- Fonction Distance
local function DistanceFunction()
    while Configuration.ShowDistance do
        RunService.RenderStepped:Wait()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- Calculer la distance entre le joueur local et le joueur cible
                    local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    -- Créer ou mettre à jour le tag de distance
                    local distanceTag = character:FindFirstChild("DistanceTag")
                    if not distanceTag then
                        distanceTag = Instance.new("BillboardGui", character)
                        distanceTag.Name = "DistanceTag"
                        distanceTag.Size = UDim2.new(2, 0, 1, 0)
                        distanceTag.StudsOffset = Vector3.new(0, 3, 0)  -- Ajuste l'offset pour que le tag soit visible au-dessus
                        distanceTag.AlwaysOnTop = true

                        -- Ajouter un TextLabel pour afficher la distance
                        local textLabel = Instance.new("TextLabel", distanceTag)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.TextScaled = true
                    end

                    -- Mettre à jour le texte du tag de distance
                    distanceTag.TextLabel.Text = "".. math.floor(distance) .. " Mètres"
                end
            end
        end
    end

    -- Supprimer les tags de distance lorsque le toggle est OFF
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local distanceTag = player.Character:FindFirstChild("DistanceTag")
            if distanceTag then
                distanceTag:Destroy()
            end
        end
    end
end


-- Fonction Aimbot
local function AimbotFunction()
    local aimbotActive = false
    local closestPlayer = nil

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
            aimbotActive = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimbotActive = false
        end
    end)

    while Configuration.Aimbot do
        RunService.RenderStepped:Wait()

        if aimbotActive then
            closestPlayer = nil
            local closestDistance = Configuration.AimbotFOV

            -- Recherche du joueur le plus proche dans le FOV
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local character = player.Character
                    local targetPart = character:FindFirstChild(Configuration.AimbotTarget)  -- Cible dynamique selon le dropdown
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Si l'ennemi est dans le FOV
                        if distance < closestDistance then
                            closestPlayer = player
                            closestDistance = distance
                        end
                    end
                end
            end

            if closestPlayer then
                local targetPosition = closestPlayer.Character[Configuration.AimbotTarget].Position  -- Utilisation de la cible sélectionnée
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            end
        end
    end
end

-- Dessin du cercle FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local function UpdateFOVCircle()
    FOVCircle.Radius = Configuration.AimbotFOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Configuration.Aimbot
end

-- Fonction Aimbot avec activation dans le FOV
local function AimbotFunction()
    local aimbotActive = false
    local closestPlayer = nil

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
            aimbotActive = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimbotActive = false
        end
    end)

    while Configuration.Aimbot do
        RunService.RenderStepped:Wait()

        if aimbotActive then
            closestPlayer = nil
            local closestDistance = Configuration.AimbotFOV

            -- Recherche du joueur le plus proche dans le FOV
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local character = player.Character
                    local humanoidRootPart = character.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    -- Si l'ennemi est dans le FOV
                    if distance < closestDistance then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end

            if closestPlayer then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            end
        end
        UpdateFOVCircle()
    end
end

AimbotTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 800},
    Increment = 5,
    CurrentValue = Configuration.AimbotFOV,
    Flag = "AimbotFOVSlider",
    Callback = function(Value)
        Configuration.AimbotFOV = Value
        UpdateFOVCircle()
    end,
})

RunService.RenderStepped:Connect(UpdateFOVCircle)

-- Toggle ESP
ESPTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Configuration.ESP = Value
        if Value then
            task.spawn(ESPFunction)
        else
            ESPFunction()
        end
    end,
})

local ColorPicker = ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ESPColor", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Configuration.ESPColor = Value
    end
})

-- Toggle Health Bar
ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "HealthBar",
    Callback = function(Value)
        Configuration.ShowHealth = Value
        if Value then
            task.spawn(HealthBarFunction)
        else
            HealthBarFunction()
        end
    end,
})

-- Toggle Distance
ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Flag = "Distance",
    Callback = function(Value)
        Configuration.ShowDistance = Value
        if Value then
            task.spawn(DistanceFunction)
        else
            DistanceFunction()
        end
    end,
})

-- Crée un toggle pour activer ou désactiver les tracers
local Toggle = ESPTab:CreateToggle({
    Name = "Tracers", -- Nom du toggle
    CurrentValue = false, -- Valeur initiale (désactivée)
    Flag = "tracersToggle", -- Un identifiant unique pour la configuration
    Callback = function(Value)
        -- Mettre à jour la visibilité des tracers en fonction de l'état du toggle
        Configuration.ShowTracers = Value
        if not Value then
            -- Si le toggle est désactivé, masquer tous les tracers
            for _, line in pairs(playerTracers) do
                line.Visible = false
            end
        end
    end,
})

-- Appeler la fonction TracersFunction pour activer la logique des tracers
TracersFunction()

local ColorPicker = ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "TracerColor", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Configuration.TracerColor = Value
        -- Appliquer la couleur aux tracers déjà existants
        for _, line in pairs(playerTracers) do
            line.Color = Value
        end
    end
})

-- Toggle Aimbot
AimbotTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        Configuration.Aimbot = Value
        if Value then
            task.spawn(AimbotFunction)
        else
            Configuration.Aimbot = false
        end
    end,
})

-- Dropdown pour choisir la cible de l'Aimbot
local Dropdown = AimbotTab:CreateDropdown({
    Name = "Aimbot Target",
    Options = {"Head", "Torso", "HumanoidRootPart"},  -- Options pour sélectionner la cible
    CurrentOption = "Head",  -- Valeur initiale
    MultipleOptions = false,
    Flag = "AimbotTarget",  -- Sauvegarde de la sélection dans les configurations
    Callback = function(selectedTarget)
        Configuration.AimbotTarget = selectedTarget
    end,
})

local Toggle = SettingsTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",  -- Sauvegarde de l'état
    Callback = function(value)
        -- Toggle infinite jump on or off
        _G.infinjump = not _G.infinjump
    
        -- Ensure the script runs only once to save resources
        if _G.infinJumpStarted == nil then
            _G.infinJumpStarted = false
        
            -- Infinite jump logic
            local plr = game:GetService("Players").LocalPlayer
            local m = plr:GetMouse()
        
            m.KeyDown:Connect(function(k)
                if _G.infinjump then
                    if k:byte() == 32 then -- 32 corresponds to the space key
                        local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            task.wait(0.1) -- Prevent issues with instant state change, using task.wait instead of wait
                            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
                        end
                    end
                end
            end)
        end
    end
})

-- Déclare la variable pour stocker l'état du noclip
local noclipEnabled = false

-- Fonction pour activer le noclip
local function enableNoclip()
    noclipEnabled = true
    humanoid.PlatformStand = true -- Désactive les interactions de la plateforme

    -- Désactive la collision de toutes les parties du personnage
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Fonction pour désactiver le noclip
local function disableNoclip()
    noclipEnabled = false
    humanoid.PlatformStand = false -- Réactive les interactions de la plateforme

    -- Réactive la collision de toutes les parties du personnage
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- Fonction pour gérer le mouvement en mode noclip
local function noclipMovement()
    runService.RenderStepped:Connect(function()
        if noclipEnabled then
            -- Déplacer le personnage librement sans collision
            local velocity = humanoid.RootPart.Velocity
            humanoid:Move(Vector3.new(0, velocity.Y, 0))
            humanoid:Move(Vector3.new(velocity.X, 0, velocity.Z))
            humanoid.WalkSpeed = 100 -- Optionnel : définir une vitesse élevée pendant le noclip
        end
    end)
end

-- Création du Toggle dans l'interface utilisateur
local Toggle = SettingsTab:CreateToggle({
    Name = "Noclip", -- Le nom du toggle
    CurrentValue = false, -- Valeur initiale
    Flag = "noclipToggle", -- Un identifiant unique pour la sauvegarde de configuration
    Callback = function(Value)
        if Value then
            enableNoclip() -- Activer le noclip si la valeur est vraie
        else
            disableNoclip() -- Désactiver le noclip si la valeur est fausse
        end
    end,
 })

local TeleportEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TeleportEnabled = false

-- Fonction pour trouver le joueur le plus proche
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("[DEBUG] LocalPlayer HumanoidRootPart not found!")
        return nil
    end

    local localPosition = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = player.Character.HumanoidRootPart.Position
            local distance = (localPosition - targetPosition).Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    if closestPlayer then
        print("[DEBUG] Closest player found:", closestPlayer.Name, "Distance:", shortestDistance)
    else
        print("[DEBUG] No players found!")
    end

    return closestPlayer
end

-- Création du Toggle
local Toggle = MiscTab:CreateToggle({
    Name = "Teleport to Closest Player",
    CurrentValue = false,
    Flag = "TeleportToggle",
    Callback = function(Value)
        TeleportEnabled = Value
        print("[DEBUG] Teleport Enabled:", TeleportEnabled)
    end,
})

-- Mise à jour à chaque frame
RunService.Heartbeat:Connect(function()
    if TeleportEnabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                print("[DEBUG] Teleporting to:", targetPlayer.Name)
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end)
        end
    end
end)

local Paragraph = SettingsTab:CreateParagraph({Title = "Bug !", Content = "Le NOCLIP ne marche pas pour le moment ne l'activer pas sinon vous serez buger"})
local Paragraph = SettingsTab:CreateParagraph({Title = "Bug !", Content = "Le FLY ne marche pas pour le moment ne l'activer pas sinon vous serez buger"})
local Paragraph = AimbotTab:CreateParagraph({Title = "Astuce", Content = "Si vous voulez mettre full balles mettre la fov a 800"})
local Paragraph = AimbotTab:CreateParagraph({Title = "bug !", Content = "Le aimbot target ne marche pas bien "})
local Paragraph = ESPTab:CreateParagraph({Title = "Health", Content = "La barre de Vie est petite"})
local Paragraph = ESPTab:CreateParagraph({Title = "Distance", Content = "La Distance est petite"})

--! Player Events Handler

local OnTeleport; OnTeleport = Player.OnTeleport:Connect(function()
    if DEBUG or not Fluent or not getfenv().queue_on_teleport then
        OnTeleport:Disconnect()
    else
        getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/F1K2/Kyze/refs/heads/main/kyze.lua\", true))()")
        OnTeleport:Disconnect()
    end
end)

local PlayerAdded; PlayerAdded = Players.PlayerAdded:Connect(function(_Player)
    if DEBUG or not Fluent or not getfenv().Drawing or not getfenv().Drawing.new then
        PlayerAdded:Disconnect()
    else
        Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded), _Player.CharacterRemoving:Connect(CharacterRemoving) }
    end
end)

local PlayerRemoving; PlayerRemoving = Players.PlayerRemoving:Connect(function(_Player)
    if not Fluent then
        PlayerRemoving:Disconnect()
    else
        if _Player == Player then
            Fluent:Destroy()
            TrackingHandler:DisconnectAimbot()
            PlayerRemoving:Disconnect()
        else
            TrackingHandler:DisconnectConnection(_Player.UserId)
            TrackingHandler:DisconnectTracking(_Player.UserId)
        end
    end
end)
