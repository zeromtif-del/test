--==============================================================
--  🔮 AUTO CRYSTAL — v3
--  + Переключатель темы (Dark / Galaxy / Crimson / Light)
--  + Прозрачность окна (слайдер)
--  + Плавные анимации открытия/закрытия/наведения
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

do
    local old = playerGui:FindFirstChild("AutoCrystalStandalone")
    if old then old:Destroy() end
end

--==============================================================
--  ССЫЛКИ
--==============================================================
local rEvents = ReplicatedStorage:WaitForChild("rEvents", 30)
local openCrystalRemote = rEvents and rEvents:WaitForChild("openCrystalRemote", 30)
local mapCrystalsFolder = workspace:WaitForChild("mapCrystalsFolder", 30)

if not openCrystalRemote or not mapCrystalsFolder then
    warn("[AutoCrystal] Не найдены rEvents или mapCrystalsFolder")
    return
end

--==============================================================
--  ТЕМЫ
--==============================================================
local THEMES = {
    galaxy = {
        name = "🔮 Galaxy",
        bg         = Color3.fromRGB(14, 14, 20),
        bgDeep     = Color3.fromRGB(10, 10, 15),
        panel      = Color3.fromRGB(24, 24, 34),
        card       = Color3.fromRGB(32, 32, 44),
        cardHover  = Color3.fromRGB(46, 46, 62),
        cardActive = Color3.fromRGB(70, 45, 115),
        accent     = Color3.fromRGB(140, 80, 255),
        accent2    = Color3.fromRGB(200, 130, 255),
        accentDim  = Color3.fromRGB(80, 45, 150),
        text       = Color3.fromRGB(230, 230, 245),
        textDim    = Color3.fromRGB(150, 150, 175),
        textFaint  = Color3.fromRGB(100, 100, 120),
        green      = Color3.fromRGB(80, 220, 120),
        greenDark  = Color3.fromRGB(40, 120, 70),
        red        = Color3.fromRGB(255, 90, 110),
        redDark    = Color3.fromRGB(130, 45, 60),
        orange     = Color3.fromRGB(255, 180, 70),
    },
    crimson = {
        name = "🩸 Crimson",
        bg         = Color3.fromRGB(20, 10, 14),
        bgDeep     = Color3.fromRGB(14, 6, 9),
        panel      = Color3.fromRGB(34, 16, 22),
        card       = Color3.fromRGB(44, 22, 30),
        cardHover  = Color3.fromRGB(60, 30, 40),
        cardActive = Color3.fromRGB(120, 40, 60),
        accent     = Color3.fromRGB(220, 50, 80),
        accent2    = Color3.fromRGB(255, 110, 140),
        accentDim  = Color3.fromRGB(120, 30, 50),
        text       = Color3.fromRGB(245, 230, 235),
        textDim    = Color3.fromRGB(175, 140, 155),
        textFaint  = Color3.fromRGB(110, 80, 95),
        green      = Color3.fromRGB(80, 220, 120),
        greenDark  = Color3.fromRGB(40, 120, 70),
        red        = Color3.fromRGB(255, 80, 100),
        redDark    = Color3.fromRGB(130, 40, 50),
        orange     = Color3.fromRGB(255, 160, 80),
    },
    dark = {
        name = "🌑 Dark",
        bg         = Color3.fromRGB(15, 15, 18),
        bgDeep     = Color3.fromRGB(10, 10, 12),
        panel      = Color3.fromRGB(26, 26, 30),
        card       = Color3.fromRGB(36, 36, 42),
        cardHover  = Color3.fromRGB(52, 52, 60),
        cardActive = Color3.fromRGB(80, 80, 100),
        accent     = Color3.fromRGB(120, 130, 180),
        accent2    = Color3.fromRGB(160, 170, 220),
        accentDim  = Color3.fromRGB(60, 65, 90),
        text       = Color3.fromRGB(230, 230, 240),
        textDim    = Color3.fromRGB(150, 150, 165),
        textFaint  = Color3.fromRGB(100, 100, 115),
        green      = Color3.fromRGB(80, 220, 120),
        greenDark  = Color3.fromRGB(40, 120, 70),
        red        = Color3.fromRGB(255, 90, 110),
        redDark    = Color3.fromRGB(130, 45, 60),
        orange     = Color3.fromRGB(255, 180, 70),
    },
    light = {
        name = "☀️ Light",
        bg         = Color3.fromRGB(240, 240, 248),
        bgDeep     = Color3.fromRGB(225, 225, 238),
        panel      = Color3.fromRGB(255, 255, 255),
        card       = Color3.fromRGB(232, 232, 244),
        cardHover  = Color3.fromRGB(210, 210, 228),
        cardActive = Color3.fromRGB(180, 190, 240),
        accent     = Color3.fromRGB(70, 100, 220),
        accent2    = Color3.fromRGB(120, 150, 255),
        accentDim  = Color3.fromRGB(180, 195, 240),
        text       = Color3.fromRGB(25, 25, 45),
        textDim    = Color3.fromRGB(90, 90, 120),
        textFaint  = Color3.fromRGB(150, 150, 175),
        green      = Color3.fromRGB(30, 170, 80),
        greenDark  = Color3.fromRGB(20, 110, 50),
        red        = Color3.fromRGB(210, 40, 60),
        redDark    = Color3.fromRGB(150, 30, 45),
        orange     = Color3.fromRGB(220, 130, 30),
    },
}

local themeOrder = { "galaxy", "crimson", "dark", "light" }
local currentThemeKey = "galaxy"
local C = THEMES[currentThemeKey]

--==============================================================
--  СОСТОЯНИЕ
--==============================================================
local state = {
    running = false,
    selectedName = nil,
    delay = 0.2,
    mode = "remote",
    opened = 0,
    failed = 0,
    lastError = "",
    stopReason = nil,
    transparency = 0,     -- 0 = непрозрачное, 0.5 = полупрозрачное
    animationsEnabled = true,
}

-- Ссылки на все элементы, которым нужна перекраска
local themedElements = {}
local function registerThemed(element, prop, colorKey)
    table.insert(themedElements, {
        element = element,
        property = prop,
        colorKey = colorKey,
    })
end

--==============================================================
--  УТИЛИТЫ
--==============================================================
local function getCrystal(name)
    if not name then return nil end
    return mapCrystalsFolder:FindFirstChild(name)
end

local function getInteractPart(crystal)
    if not crystal then return nil end
    return crystal:FindFirstChild("PrimaryPart")
        or crystal:FindFirstChild("camLookPart")
        or crystal.PrimaryPart
        or crystal:FindFirstChildWhichIsA("BasePart", true)
end

local function tween(obj, t, props)
    if not state.animationsEnabled then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
        return
    end
    TweenService:Create(obj, t, props):Play()
end

--==============================================================
--  МЕТОДЫ ОТКРЫТИЯ
--==============================================================
local function tryRemote(name)
    local ok, a, b, c, d, e, f, stopReason = pcall(function()
        return openCrystalRemote:InvokeServer("openCrystal", name)
    end)
    if not ok then
        state.lastError = "Remote error: " .. tostring(a)
        return false, nil
    end
    if stopReason then return false, stopReason end
    return a ~= nil, nil
end

local function tryTouch(name)
    local crystal = getCrystal(name)
    if not crystal then
        state.lastError = "Кристалл не найден"
        return false, nil
    end
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false, nil end
    local target = getInteractPart(crystal)
    if not target then return false, nil end
    pcall(function()
        local lh = myChar:FindFirstChild("LeftHand")
        local rh = myChar:FindFirstChild("RightHand")
        firetouchinterest(target, myHRP, 0)
        firetouchinterest(target, myHRP, 1)
        if lh then
            firetouchinterest(target, lh, 0)
            firetouchinterest(target, lh, 1)
        end
        if rh then
            firetouchinterest(target, rh, 0)
            firetouchinterest(target, rh, 1)
        end
    end)
    task.wait(0.05)
    return tryRemote(name)
end

local function tryPrompt(name)
    local crystal = getCrystal(name)
    if not crystal then return false, nil end
    for _, d in ipairs(crystal:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            pcall(function()
                d.MaxActivationDistance = 100000
                d.HoldDuration = 0
                d.RequiresLineOfSight = false
            end)
            pcall(function()
                d:InputHoldBegin()
                task.wait(0.05)
                d:InputHoldEnd()
            end)
        end
    end
    task.wait(0.1)
    return tryRemote(name)
end

local function tryTeleport(name)
    local crystal = getCrystal(name)
    if not crystal then return false, nil end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        state.lastError = "Персонаж мёртв"
        return false, nil
    end
    local target = getInteractPart(crystal)
    if not target then return false, nil end
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0), target.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.1)
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0), target.Position)
    task.wait(0.12)
    return tryRemote(name)
end

local function openOnce(name)
    local ok, stopReason
    if state.mode == "remote" then
        ok, stopReason = tryRemote(name)
    elseif state.mode == "touch" then
        ok, stopReason = tryTouch(name)
    elseif state.mode == "prompt" then
        ok, stopReason = tryPrompt(name)
    elseif state.mode == "teleport" then
        ok, stopReason = tryTeleport(name)
    end
    if stopReason then
        state.stopReason = stopReason
        if stopReason == "NoCapacity" then
            state.lastError = "Нет свободного слота"
        elseif stopReason == "InsufficientCurrency" then
            state.lastError = "Недостаточно валюты"
        elseif stopReason == "GrantFailed" then
            state.lastError = "Ошибка выдачи"
        else
            state.lastError = "Стоп: " .. tostring(stopReason)
        end
        return false
    end
    if ok then
        state.lastError = ""
        state.stopReason = nil
    end
    return ok
end

local worker = nil
local function startWorker()
    if worker then return end
    worker = task.spawn(function()
        while state.running do
            if not state.selectedName then
                state.lastError = "Не выбран кристалл"
                task.wait(0.5)
                continue
            end
            local ok = openOnce(state.selectedName)
            if ok then
                state.opened = state.opened + 1
            else
                state.failed = state.failed + 1
                if state.stopReason == "NoCapacity"
                    or state.stopReason == "InsufficientCurrency"
                    or state.stopReason == "GrantFailed" then
                    state.running = false
                    break
                end
                if state.failed >= 5 and state.opened == 0 then
                    state.lastError = "Смени режим открытия"
                    state.running = false
                    break
                end
            end
            task.wait(state.delay)
        end
        worker = nil
    end)
end

local function stopWorker()
    state.running = false
    if worker then
        pcall(function() task.cancel(worker) end)
        worker = nil
    end
end

--==============================================================
--  СОРТИРОВКА
--==============================================================
local CRYSTAL_ORDER = {
    "Common Crystal", "Uncommon Crystal", "Rare Crystal",
    "Epic Crystal", "Legendary Crystal", "Mythical Crystal",
    "Secret Crystal", "Eternal Crystal", "Godly Crystal",
    "Industrial Crystal", "Overcharged Crystal", "Hallowed Crystal",
}
local function getCrystalRank(name)
    for i, cn in ipairs(CRYSTAL_ORDER) do
        if string.find(name:lower(), cn:lower(), 1, true) then return i end
    end
    return 999
end

--==============================================================
--  GUI
--==============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoCrystalStandalone"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==============================================================
--  КНОПКА МЕНЮ
--==============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.fromOffset(150, 36)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -17)
toggleBtn.BackgroundColor3 = C.card
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = C.accent
toggleStroke.Thickness = 1.5
toggleStroke.Transparency = 0.35
toggleStroke.Parent = toggleBtn

local toggleGrad = Instance.new("UIGradient")
toggleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentDim),
    ColorSequenceKeypoint.new(1, C.card),
})
toggleGrad.Rotation = 45
toggleGrad.Parent = toggleBtn

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.fromOffset(24, 24)
toggleIcon.Position = UDim2.new(0, 8, 0.5, -12)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "🔮"
toggleIcon.TextSize = 16
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleBtn

local toggleText = Instance.new("TextLabel")
toggleText.Size = UDim2.new(1, -40, 1, 0)
toggleText.Position = UDim2.new(0, 36, 0, 0)
toggleText.BackgroundTransparency = 1
toggleText.Text = "AUTO CRYSTAL"
toggleText.TextColor3 = C.text
toggleText.TextSize = 12
toggleText.Font = Enum.Font.GothamBold
toggleText.TextXAlignment = Enum.TextXAlignment.Left
toggleText.Parent = toggleBtn

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(8, 8)
statusDot.Position = UDim2.new(1, -16, 0.5, -4)
statusDot.BackgroundColor3 = C.textFaint
statusDot.BorderSizePixel = 0
statusDot.Parent = toggleBtn
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

registerThemed(toggleBtn, "BackgroundColor3", "card")
registerThemed(toggleStroke, "Color", "accent")
registerThemed(toggleText, "TextColor3", "text")
registerThemed(statusDot, "BackgroundColor3", "textFaint")

toggleBtn.MouseEnter:Connect(function()
    tween(toggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.cardHover })
    tween(toggleStroke, TweenInfo.new(0.15), { Transparency = 0 })
end)
toggleBtn.MouseLeave:Connect(function()
    tween(toggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.card })
    tween(toggleStroke, TweenInfo.new(0.15), { Transparency = 0.35 })
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ КНОПКИ
--==============================================================
local draggingToggle = false
local toggleDragStart, toggleStartPos, toggleClickStart

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        toggleDragStart = input.Position
        toggleStartPos = toggleBtn.Position
        toggleClickStart = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingToggle then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - toggleDragStart
        toggleBtn.Position = UDim2.new(
            toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if toggleClickStart then
        local moved = (input.Position - toggleClickStart).Magnitude
        if moved < 6 then
            -- это был клик
            if mainFrame.Visible then
                closeMenu()
            else
                openMenu()
            end
        end
        toggleClickStart = nil
    end
    draggingToggle = false
end)

--==============================================================
--  ОСНОВНОЕ ОКНО
--==============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(0, 0)   -- для анимации
mainFrame.BackgroundColor3 = C.bg
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.bg),
    ColorSequenceKeypoint.new(1, C.bgDeep),
})
mainGrad.Rotation = 90
mainGrad.Parent = mainFrame

registerThemed(mainFrame, "BackgroundColor3", "bg")
registerThemed(mainStroke, "Color", "accent")

--==============================================================
--  ВНУТРЕННИЙ КОНТЕЙНЕР (не сжимается при анимации)
--==============================================================
local innerContainer = Instance.new("Frame")
innerContainer.Name = "Inner"
innerContainer.Size = UDim2.fromOffset(440, 660)
innerContainer.Position = UDim2.fromOffset(0, 0)
innerContainer.BackgroundTransparency = 1
innerContainer.Parent = mainFrame

--==============================================================
--  HEADER
--==============================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = C.bgDeep
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
header.Parent = innerContainer
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

registerThemed(header, "BackgroundColor3", "bgDeep")

local headerIcon = Instance.new("TextLabel")
headerIcon.Size = UDim2.fromOffset(40, 40)
headerIcon.Position = UDim2.new(0, 14, 0.5, -20)
headerIcon.BackgroundColor3 = C.accent
headerIcon.Text = "🔮"
headerIcon.TextSize = 22
headerIcon.Font = Enum.Font.GothamBold
headerIcon.Parent = header
Instance.new("UICorner", headerIcon).CornerRadius = UDim.new(0, 10)

local headerIconGrad = Instance.new("UIGradient")
headerIconGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
})
headerIconGrad.Rotation = 45
headerIconGrad.Parent = headerIcon

registerThemed(headerIcon, "BackgroundColor3", "accent")

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 22)
title.Position = UDim2.new(0, 66, 0, 14)
title.BackgroundTransparency = 1
title.Text = "AUTO CRYSTAL"
title.TextColor3 = C.text
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header
registerThemed(title, "TextColor3", "text")

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -100, 0, 16)
subtitle.Position = UDim2.new(0, 66, 0, 36)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Auto Open Crystal · F2"
subtitle.TextColor3 = C.textFaint
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header
registerThemed(subtitle, "TextColor3", "textFaint")

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = C.redDark
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.red
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
registerThemed(closeBtn, "BackgroundColor3", "redDark")
registerThemed(closeBtn, "TextColor3", "red")

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.red,
        TextColor3 = Color3.new(1,1,1),
    })
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.redDark,
        TextColor3 = C.red,
    })
end)

--==============================================================
--  СТАТУС-ПАНЕЛЬ
--==============================================================
local statusPanel = Instance.new("Frame")
statusPanel.Size = UDim2.new(1, -28, 0, 70)
statusPanel.Position = UDim2.new(0, 14, 0, 78)
statusPanel.BackgroundColor3 = C.panel
statusPanel.BorderSizePixel = 0
statusPanel.Parent = innerContainer
Instance.new("UICorner", statusPanel).CornerRadius = UDim.new(0, 12)
registerThemed(statusPanel, "BackgroundColor3", "panel")

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = C.accentDim
statusStroke.Thickness = 1
statusStroke.Transparency = 0.5
statusStroke.Parent = statusPanel
registerThemed(statusStroke, "Color", "accentDim")

local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.fromOffset(4, 42)
statusIndicator.Position = UDim2.new(0, 12, 0.5, -21)
statusIndicator.BackgroundColor3 = C.textFaint
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusPanel
Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(1, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -110, 0, 18)
statusLabel.Position = UDim2.new(0, 26, 0, 12)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Остановлено"
statusLabel.TextColor3 = C.textDim
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusPanel
registerThemed(statusLabel, "TextColor3", "textDim")

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -110, 0, 16)
statsLabel.Position = UDim2.new(0, 26, 0, 32)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Открыто: 0 · Ошибок: 0"
statsLabel.TextColor3 = C.textFaint
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statusPanel
registerThemed(statsLabel, "TextColor3", "textFaint")

local errLabel = Instance.new("TextLabel")
errLabel.Size = UDim2.new(1, -110, 0, 14)
errLabel.Position = UDim2.new(0, 26, 0, 48)
errLabel.BackgroundTransparency = 1
errLabel.Text = ""
errLabel.TextColor3 = C.red
errLabel.TextSize = 10
errLabel.Font = Enum.Font.Gotham
errLabel.TextXAlignment = Enum.TextXAlignment.Left
errLabel.Parent = statusPanel
registerThemed(errLabel, "TextColor3", "red")

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.fromOffset(70, 40)
counterLabel.Position = UDim2.new(1, -82, 0.5, -20)
counterLabel.BackgroundColor3 = C.card
counterLabel.Text = "0"
counterLabel.TextColor3 = C.accent2
counterLabel.TextSize = 22
counterLabel.Font = Enum.Font.GothamBold
counterLabel.Parent = statusPanel
Instance.new("UICorner", counterLabel).CornerRadius = UDim.new(0, 8)
registerThemed(counterLabel, "BackgroundColor3", "card")
registerThemed(counterLabel, "TextColor3", "accent2")

--==============================================================
--  СПИСОК КРИСТАЛЛОВ
--==============================================================
local listHeader = Instance.new("TextLabel")
listHeader.Size = UDim2.new(1, -30, 0, 18)
listHeader.Position = UDim2.new(0, 15, 0, 156)
listHeader.BackgroundTransparency = 1
listHeader.Text = "ВЫБЕРИ КРИСТАЛЛ"
listHeader.TextColor3 = C.accent
listHeader.TextSize = 11
listHeader.Font = Enum.Font.GothamBold
listHeader.TextXAlignment = Enum.TextXAlignment.Left
listHeader.Parent = innerContainer
registerThemed(listHeader, "TextColor3", "accent")

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -30, 0, 18)
countLabel.Position = UDim2.new(0, 15, 0, 156)
countLabel.BackgroundTransparency = 1
countLabel.Text = "0"
countLabel.TextColor3 = C.textFaint
countLabel.TextSize = 11
countLabel.Font = Enum.Font.Gotham
countLabel.TextXAlignment = Enum.TextXAlignment.Right
countLabel.Parent = innerContainer
registerThemed(countLabel, "TextColor3", "textFaint")

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 0, 200)
scroll.Position = UDim2.new(0, 15, 0, 178)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = C.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = innerContainer
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
registerThemed(scroll, "BackgroundColor3", "panel")
registerThemed(scroll, "ScrollBarImageColor3", "accent")

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft = UDim.new(0, 6)
listPad.PaddingRight = UDim.new(0, 6)
listPad.PaddingTop = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 6)
listPad.Parent = scroll

local crystalButtons = {}

local function refreshList()
    for _, b in ipairs(crystalButtons) do b:Destroy() end
    crystalButtons = {}

    local names = {}
    for _, c in ipairs(mapCrystalsFolder:GetChildren()) do
        if c:IsA("Model") and c.PrimaryPart then
            table.insert(names, c.Name)
        end
    end
    table.sort(names, function(a, b) return getCrystalRank(a) < getCrystalRank(b) end)
    countLabel.Text = ("%d найдено"):format(#names)

    for i, name in ipairs(names) do
        local isSelected = (state.selectedName == name)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -8, 0, 34)
        b.BackgroundColor3 = isSelected and C.cardActive or C.card
        b.Text = ""
        b.AutoButtonColor = false
        b.LayoutOrder = i
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

        if isSelected then
            local selStroke = Instance.new("UIStroke")
            selStroke.Color = C.accent
            selStroke.Thickness = 1.5
            selStroke.Parent = b
        end

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromOffset(20, 20)
        icon.Position = UDim2.new(0, 10, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Text = "💎"
        icon.TextSize = 13
        icon.Font = Enum.Font.GothamBold
        icon.Parent = b

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -60, 1, 0)
        nameLbl.Position = UDim2.new(0, 34, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = name
        nameLbl.TextColor3 = C.text
        nameLbl.TextSize = 12
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Parent = b
        registerThemed(nameLbl, "TextColor3", "text")

        local check = Instance.new("TextLabel")
        check.Size = UDim2.fromOffset(24, 24)
        check.Position = UDim2.new(1, -30, 0.5, -12)
        check.BackgroundTransparency = 1
        check.Text = isSelected and "✓" or ""
        check.TextColor3 = C.accent2
        check.TextSize = 14
        check.Font = Enum.Font.GothamBold
        check.Parent = b

        b.MouseEnter:Connect(function()
            if state.selectedName ~= name then
                tween(b, TweenInfo.new(0.12), { BackgroundColor3 = C.cardHover })
            end
        end)
        b.MouseLeave:Connect(function()
            if state.selectedName ~= name then
                tween(b, TweenInfo.new(0.12), { BackgroundColor3 = C.card })
            end
        end)
        b.MouseButton1Click:Connect(function()
            state.selectedName = name
            refreshList()
        end)

        table.insert(crystalButtons, b)
    end

    if #names == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -8, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет кристаллов"
        empty.TextColor3 = C.textFaint
        empty.TextSize = 12
        empty.Font = Enum.Font.Gotham
        empty.Parent = scroll
        table.insert(crystalButtons, empty)
    end
end

refreshList()

task.spawn(function()
    while gui.Parent do
        task.wait(5)
        if mainFrame.Visible then refreshList() end
    end
end)

--==============================================================
--  РЕЖИМЫ
--==============================================================
local modeHeader = Instance.new("TextLabel")
modeHeader.Size = UDim2.new(1, -30, 0, 18)
modeHeader.Position = UDim2.new(0, 15, 0, 388)
modeHeader.BackgroundTransparency = 1
modeHeader.Text = "РЕЖИМ ОТКРЫТИЯ"
modeHeader.TextColor3 = C.accent
modeHeader.TextSize = 11
modeHeader.Font = Enum.Font.GothamBold
modeHeader.TextXAlignment = Enum.TextXAlignment.Left
modeHeader.Parent = innerContainer
registerThemed(modeHeader, "TextColor3", "accent")

local modeHolder = Instance.new("Frame")
modeHolder.Size = UDim2.new(1, -30, 0, 68)
modeHolder.Position = UDim2.new(0, 15, 0, 410)
modeHolder.BackgroundTransparency = 1
modeHolder.Parent = innerContainer

local modeGrid = Instance.new("UIGridLayout")
modeGrid.CellSize = UDim2.new(0.5, -4, 0, 30)
modeGrid.CellPadding = UDim2.new(0, 8, 0, 8)
modeGrid.Parent = modeHolder

local modeButtons = {}
local modeList = {
    { id = "remote",   text = "📡 Remote",   color = "accent" },
    { id = "touch",    text = "✋ Touch",    color = "green" },
    { id = "prompt",   text = "🎯 Prompt",   color = "orange" },
    { id = "teleport", text = "🚀 Teleport", color = "accent2" },
}

local function refreshModeButtons()
    for id, b in pairs(modeButtons) do
        if id == state.mode then
            local colorKey = b:GetAttribute("ColorKey") or "accent"
            b.BackgroundColor3 = C[colorKey] or C.accent
            b.TextColor3 = Color3.new(1, 1, 1)
        else
            b.BackgroundColor3 = C.card
            b.TextColor3 = C.textDim
        end
    end
end

for _, m in ipairs(modeList) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = C.card
    b.Text = m.text
    b.TextColor3 = C.textDim
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = modeHolder
    b:SetAttribute("ColorKey", m.color)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local st = Instance.new("UIStroke")
    st.Color = C[m.color] or C.accent
    st.Thickness = 1.5
    st.Transparency = 0.8
    st.Parent = b

    b.MouseEnter:Connect(function()
        if state.mode ~= m.id then
            tween(b, TweenInfo.new(0.12), { BackgroundColor3 = C.cardHover })
        end
    end)
    b.MouseLeave:Connect(function()
        if state.mode ~= m.id then
            tween(b, TweenInfo.new(0.12), { BackgroundColor3 = C.card })
        end
    end)
    b.MouseButton1Click:Connect(function()
        state.mode = m.id
        refreshModeButtons()
    end)

    modeButtons[m.id] = b
end

refreshModeButtons()

--==============================================================
--  ЗАДЕРЖКА
--==============================================================
local delayRow = Instance.new("Frame")
delayRow.Size = UDim2.new(1, -30, 0, 34)
delayRow.Position = UDim2.new(0, 15, 0, 486)
delayRow.BackgroundColor3 = C.panel
delayRow.BorderSizePixel = 0
delayRow.Parent = innerContainer
Instance.new("UICorner", delayRow).CornerRadius = UDim.new(0, 8)
registerThemed(delayRow, "BackgroundColor3", "panel")

local delayLbl = Instance.new("TextLabel")
delayLbl.Size = UDim2.new(0.6, -10, 1, 0)
delayLbl.Position = UDim2.new(0, 12, 0, 0)
delayLbl.BackgroundTransparency = 1
delayLbl.Text = "⏱ Задержка (сек)"
delayLbl.TextColor3 = C.text
delayLbl.TextSize = 12
delayLbl.Font = Enum.Font.GothamMedium
delayLbl.TextXAlignment = Enum.TextXAlignment.Left
delayLbl.Parent = delayRow
registerThemed(delayLbl, "TextColor3", "text")

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0.4, -12, 0, 24)
delayBox.Position = UDim2.new(0.6, 0, 0.5, -12)
delayBox.BackgroundColor3 = C.bgDeep
delayBox.Text = "0.2"
delayBox.TextColor3 = C.text
delayBox.TextSize = 12
delayBox.Font = Enum.Font.Gotham
delayBox.ClearTextOnFocus = false
delayBox.Parent = delayRow
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)
registerThemed(delayBox, "BackgroundColor3", "bgDeep")
registerThemed(delayBox, "TextColor3", "text")

local delayStroke = Instance.new("UIStroke")
delayStroke.Color = C.accent
delayStroke.Thickness = 1
delayStroke.Transparency = 0.7
delayStroke.Parent = delayBox
registerThemed(delayStroke, "Color", "accent")

delayBox.FocusLost:Connect(function(enter)
    if enter then
        local v = tonumber(delayBox.Text)
        if v and v >= 0.05 then state.delay = v end
    end
end)

--==============================================================
--  НАСТРОЙКИ (тема + прозрачность + анимации)
--==============================================================
local settingsHeader = Instance.new("TextLabel")
settingsHeader.Size = UDim2.new(1, -30, 0, 18)
settingsHeader.Position = UDim2.new(0, 15, 0, 530)
settingsHeader.BackgroundTransparency = 1
settingsHeader.Text = "НАСТРОЙКИ"
settingsHeader.TextColor3 = C.accent
settingsHeader.TextSize = 11
settingsHeader.Font = Enum.Font.GothamBold
settingsHeader.TextXAlignment = Enum.TextXAlignment.Left
settingsHeader.Parent = innerContainer
registerThemed(settingsHeader, "TextColor3", "accent")

-- Кнопка смены темы
local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(0.5, -18, 0, 30)
themeBtn.Position = UDim2.new(0, 15, 0, 552)
themeBtn.BackgroundColor3 = C.card
themeBtn.Text = "🎨 " .. C.name
themeBtn.TextColor3 = C.text
themeBtn.TextSize = 11
themeBtn.Font = Enum.Font.GothamBold
themeBtn.AutoButtonColor = false
themeBtn.Parent = innerContainer
Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 8)
registerThemed(themeBtn, "BackgroundColor3", "card")
registerThemed(themeBtn, "TextColor3", "text")

local themeStroke = Instance.new("UIStroke")
themeStroke.Color = C.accent
themeStroke.Thickness = 1.5
themeStroke.Transparency = 0.6
themeStroke.Parent = themeBtn
registerThemed(themeStroke, "Color", "accent")

-- Кнопка анимаций
local animBtn = Instance.new("TextButton")
animBtn.Size = UDim2.new(0.5, -18, 0, 30)
animBtn.Position = UDim2.new(0.5, 3, 0, 552)
animBtn.BackgroundColor3 = C.card
animBtn.Text = "✨ Анимации: ВКЛ"
animBtn.TextColor3 = C.text
animBtn.TextSize = 11
animBtn.Font = Enum.Font.GothamBold
animBtn.AutoButtonColor = false
animBtn.Parent = innerContainer
Instance.new("UICorner", animBtn).CornerRadius = UDim.new(0, 8)
registerThemed(animBtn, "BackgroundColor3", "card")
registerThemed(animBtn, "TextColor3", "text")

local animStroke = Instance.new("UIStroke")
animStroke.Color = C.green
animStroke.Thickness = 1.5
animStroke.Transparency = 0.6
animStroke.Parent = animBtn

-- Слайдер прозрачности
local transpRow = Instance.new("Frame")
transpRow.Size = UDim2.new(1, -30, 0, 44)
transpRow.Position = UDim2.new(0, 15, 0, 590)
transpRow.BackgroundColor3 = C.panel
transpRow.BorderSizePixel = 0
transpRow.Parent = innerContainer
Instance.new("UICorner", transpRow).CornerRadius = UDim.new(0, 8)
registerThemed(transpRow, "BackgroundColor3", "panel")

local transpLbl = Instance.new("TextLabel")
transpLbl.Size = UDim2.new(0.5, -10, 0, 16)
transpLbl.Position = UDim2.new(0, 12, 0, 4)
transpLbl.BackgroundTransparency = 1
transpLbl.Text = "🪟 Прозрачность"
transpLbl.TextColor3 = C.text
transpLbl.TextSize = 12
transpLbl.Font = Enum.Font.GothamMedium
transpLbl.TextXAlignment = Enum.TextXAlignment.Left
transpLbl.Parent = transpRow
registerThemed(transpLbl, "TextColor3", "text")

local transpVal = Instance.new("TextLabel")
transpVal.Size = UDim2.new(0.5, -10, 0, 16)
transpVal.Position = UDim2.new(0.5, 0, 0, 4)
transpVal.BackgroundTransparency = 1
transpVal.Text = "0%"
transpVal.TextColor3 = C.accent2
transpVal.TextSize = 12
transpVal.Font = Enum.Font.GothamBold
transpVal.TextXAlignment = Enum.TextXAlignment.Right
transpVal.Parent = transpRow
registerThemed(transpVal, "TextColor3", "accent2")

local transpTrack = Instance.new("Frame")
transpTrack.Size = UDim2.new(1, -24, 0, 8)
transpTrack.Position = UDim2.new(0, 12, 0, 28)
transpTrack.BackgroundColor3 = C.bgDeep
transpTrack.BorderSizePixel = 0
transpTrack.Parent = transpRow
Instance.new("UICorner", transpTrack).CornerRadius = UDim.new(1, 0)
registerThemed(transpTrack, "BackgroundColor3", "bgDeep")

local transpFill = Instance.new("Frame")
transpFill.Size = UDim2.new(0, 0, 1, 0)
transpFill.BackgroundColor3 = C.accent
transpFill.BorderSizePixel = 0
transpFill.Parent = transpTrack
Instance.new("UICorner", transpFill).CornerRadius = UDim.new(1, 0)
registerThemed(transpFill, "BackgroundColor3", "accent")

local transpKnob = Instance.new("Frame")
transpKnob.Size = UDim2.fromOffset(16, 16)
transpKnob.AnchorPoint = Vector2.new(0.5, 0.5)
transpKnob.Position = UDim2.new(0, 0, 0.5, 0)
transpKnob.BackgroundColor3 = Color3.new(1, 1, 1)
transpKnob.BorderSizePixel = 0
transpKnob.ZIndex = 2
transpKnob.Parent = transpTrack
Instance.new("UICorner", transpKnob).CornerRadius = UDim.new(1, 0)

local transpDragging = false
local function applyTransparency(v)
    v = math.clamp(v, 0, 90) / 100
    state.transparency = v
    transpFill.Size = UDim2.new(v, 0, 1, 0)
    transpKnob.Position = UDim2.new(v, 0, 0.5, 0)
    transpVal.Text = ("%d%%"):format(math.floor(v * 100))

    -- Применяем прозрачность ко всем фонам окна
    local alpha = v
    mainFrame.BackgroundTransparency = alpha * 0.7
    header.BackgroundTransparency = math.min(0.95, 0.3 + alpha * 0.6)
    statusPanel.BackgroundTransparency = alpha * 0.8
    scroll.BackgroundTransparency = alpha * 0.8
    delayRow.BackgroundTransparency = alpha * 0.8
    transpRow.BackgroundTransparency = alpha * 0.8
    counterLabel.BackgroundTransparency = alpha * 0.8
end

local function setTranspFromX(x)
    local trackX = transpTrack.AbsolutePosition.X
    local trackW = transpTrack.AbsoluteSize.X
    if trackW <= 0 then return end
    local ratio = math.clamp((x - trackX) / trackW, 0, 1)
    applyTransparency(ratio * 100)
end

local transpHit = Instance.new("TextButton")
transpHit.Size = UDim2.new(1, -24, 0, 20)
transpHit.Position = UDim2.new(0, 12, 0, 22)
transpHit.BackgroundTransparency = 1
transpHit.Text = ""
transpHit.Parent = transpRow

transpHit.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        transpDragging = true
        setTranspFromX(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not transpDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        setTranspFromX(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        transpDragging = false
    end
end)

applyTransparency(0)

--==============================================================
--  КНОПКА СТАРТ/СТОП
--==============================================================
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -30, 0, 46)
startBtn.Position = UDim2.new(0, 15, 0, 644)
startBtn.BackgroundColor3 = C.green
startBtn.Text = ""
startBtn.AutoButtonColor = false
startBtn.Parent = innerContainer
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 12)

local startGrad = Instance.new("UIGradient")
startGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.green),
    ColorSequenceKeypoint.new(1, C.greenDark),
})
startGrad.Rotation = 90
startGrad.Parent = startBtn

local startText = Instance.new("TextLabel")
startText.Size = UDim2.fromScale(1, 1)
startText.BackgroundTransparency = 1
startText.Text = "▶  ЗАПУСТИТЬ"
startText.TextColor3 = Color3.new(1, 1, 1)
startText.TextSize = 14
startText.Font = Enum.Font.GothamBold
startText.Parent = startBtn

startBtn.MouseEnter:Connect(function()
    tween(startBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 })
end)
startBtn.MouseLeave:Connect(function()
    tween(startBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
end)

--==============================================================
--  ПРИМЕНЕНИЕ ТЕМЫ
--==============================================================
local function applyTheme(key)
    if not THEMES[key] then return end
    currentThemeKey = key
    C = THEMES[key]

    -- обновляем ВСЕ зарегистрированные элементы
    for _, entry in ipairs(themedElements) do
        if entry.element and entry.element.Parent then
            local newColor = C[entry.colorKey]
            if newColor then
                tween(entry.element, TweenInfo.new(0.25), {
                    [entry.property] = newColor,
                })
            end
        end
    end

    -- градиент кнопки меню
    toggleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accentDim),
        ColorSequenceKeypoint.new(1, C.card),
    })

    -- градиент иконки
    headerIconGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(1, C.accent2),
    })

    -- главный градиент окна
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.bg),
        ColorSequenceKeypoint.new(1, C.bgDeep),
    })

    -- градиент кнопки старта
    if state.running then
        startGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.red),
            ColorSequenceKeypoint.new(1, C.redDark),
        })
    else
        startGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.green),
            ColorSequenceKeypoint.new(1, C.greenDark),
        })
    end

    -- обновить кнопки режимов
    refreshModeButtons()

    -- обновить название в кнопке
    themeBtn.Text = "🎨 " .. C.name

    -- обновить список кристаллов
    refreshList()

    -- переприменить прозрачность
    applyTransparency(state.transparency * 100)
end

themeBtn.MouseButton1Click:Connect(function()
    local idx = 1
    for i, k in ipairs(themeOrder) do
        if k == currentThemeKey then idx = i break end
    end
    local nextIdx = (idx % #themeOrder) + 1
    applyTheme(themeOrder[nextIdx])
end)

themeBtn.MouseEnter:Connect(function()
    tween(themeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.cardHover })
end)
themeBtn.MouseLeave:Connect(function()
    tween(themeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.card })
end)

--==============================================================
--  ANIMATIONS TOGGLE
--==============================================================
animBtn.MouseButton1Click:Connect(function()
    state.animationsEnabled = not state.animationsEnabled
    animBtn.Text = "✨ Анимации: " .. (state.animationsEnabled and "ВКЛ" or "ВЫКЛ")
    animStroke.Color = state.animationsEnabled and C.green or C.red
end)

animBtn.MouseEnter:Connect(function()
    tween(animBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.cardHover })
end)
animBtn.MouseLeave:Connect(function()
    tween(animBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.card })
end)

--==============================================================
--  ОТКРЫТИЕ / ЗАКРЫТИЕ
--==============================================================
local isAnimating = false

local function openMenu()
    if mainFrame.Visible or isAnimating then return end
    isAnimating = true
    mainFrame.Visible = true

    if state.animationsEnabled then
        mainFrame.Size = UDim2.fromOffset(0, 0)
        mainFrame.BackgroundTransparency = 1
        mainStroke.Transparency = 1

        tween(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(440, 660),
            BackgroundTransparency = state.transparency * 0.7,
        })
        tween(mainStroke, TweenInfo.new(0.3), {
            Transparency = 0.4,
        })

        task.wait(0.3)
    else
        mainFrame.Size = UDim2.fromOffset(440, 660)
    end
    isAnimating = false
end

local function closeMenu()
    if not mainFrame.Visible or isAnimating then return end
    isAnimating = true

    if state.animationsEnabled then
        tween(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
        })
        tween(mainStroke, TweenInfo.new(0.2), { Transparency = 1 })
        task.wait(0.2)
    end
    mainFrame.Visible = false
    isAnimating = false
end

closeBtn.MouseButton1Click:Connect(closeMenu)

-- F2
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        if mainFrame.Visible then closeMenu() else openMenu() end
    end
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ ОКНА
--==============================================================
local draggingFrame = false
local frameDragStart, frameStartPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        frameDragStart = input.Position
        frameStartPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingFrame then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - frameDragStart
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = false
    end
end)

--==============================================================
--  СТАРТ / СТОП
--==============================================================
startBtn.MouseButton1Click:Connect(function()
    if state.running then
        stopWorker()
    else
        if not state.selectedName then
            state.lastError = "Сначала выбери кристалл"
            return
        end
        state.running = true
        state.opened = 0
        state.failed = 0
        state.lastError = ""
        state.stopReason = nil
        startWorker()
    end
end)

--==============================================================
--  ОБНОВЛЕНИЕ UI
--==============================================================
task.spawn(function()
    while gui.Parent do
        if state.running then
            statusLabel.Text = ("Работает · %s"):format(state.selectedName or "—")
            statusLabel.TextColor3 = C.green
            statusIndicator.BackgroundColor3 = C.green
            startText.Text = "⏹  ОСТАНОВИТЬ"
            startGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C.red),
                ColorSequenceKeypoint.new(1, C.redDark),
            })
            statusDot.BackgroundColor3 = C.green
        else
            statusLabel.Text = "Остановлено"
            statusLabel.TextColor3 = C.textDim
            statusIndicator.BackgroundColor3 = C.textFaint
            startText.Text = "▶  ЗАПУСТИТЬ"
            startGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C.green),
                ColorSequenceKeypoint.new(1, C.greenDark),
            })
            statusDot.BackgroundColor3 = C.textFaint
        end

        statsLabel.Text = ("Открыто: %d · Ошибок: %d"):format(state.opened, state.failed)
        counterLabel.Text = tostring(state.opened)
        errLabel.Text = state.lastError ~= "" and ("⚠ " .. state.lastError) or ""

        task.wait(0.3)
    end
end)

print("[AutoCrystal v3] Загружено. F2 — меню. 4 темы + прозрачность + анимации.")
