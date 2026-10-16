--==============================================================
--  🔮 AUTO CRYSTAL — v2 (новый UI + drag)
--  Требует: запущенный основной кристалл-скрипт (для UI кристаллов)
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

if not openCrystalRemote then
    warn("[AutoCrystal] openCrystalRemote не найден")
    return
end
if not mapCrystalsFolder then
    warn("[AutoCrystal] mapCrystalsFolder не найден")
    return
end

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
    sortMode = "alphabet",  -- alphabet / cheapest / rarity
}

--==============================================================
--  ПАЛИТРА
--==============================================================
local C = {
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
}

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

local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

--==============================================================
--  МЕТОДЫ ОТКРЫТИЯ (без изменений)
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
    local hrp = getHRP()
    local hum = getHumanoid()
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

--==============================================================
--  WORKER
--==============================================================
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
--  АВТО-СОРТИРОВКА КРИСТАЛЛОВ
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
--  КНОПКА МЕНЮ (перетаскиваемая, красивая)
--==============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoCrystalStandalone"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Позиция кнопки (сохраняется в памяти скрипта)
local togglePos = UDim2.new(0, 20, 0.5, -17)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.fromOffset(150, 36)
toggleBtn.Position = togglePos
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

-- Иконка
local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.fromOffset(24, 24)
toggleIcon.Position = UDim2.new(0, 8, 0.5, -12)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "🔮"
toggleIcon.TextSize = 16
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleBtn

-- Текст
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

-- Индикатор статуса (точка справа)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(8, 8)
statusDot.Position = UDim2.new(1, -16, 0.5, -4)
statusDot.BackgroundColor3 = C.textFaint
statusDot.BorderSizePixel = 0
statusDot.Parent = toggleBtn
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

-- Hover-эффект
toggleBtn.MouseEnter:Connect(function()
    if not draggingToggle then
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.cardHover,
        }):Play()
        TweenService:Create(toggleStroke, TweenInfo.new(0.15), {
            Transparency = 0,
        }):Play()
    end
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.card,
    }):Play()
    TweenService:Create(toggleStroke, TweenInfo.new(0.15), {
        Transparency = 0.35,
    }):Play()
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ КНОПКИ
--==============================================================
local draggingToggle = false
local dragStart, startPos
local clickStartPos = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        clickStartPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingToggle then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        togglePos = toggleBtn.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        -- Проверяем: это был клик или drag?
        if clickStartPos then
            local moved = (input.Position - clickStartPos).Magnitude
            if moved < 6 and not draggingToggle then
                -- клик
            end
            clickStartPos = nil
        end
        draggingToggle = false
    end
end)

--==============================================================
--  ОСНОВНОЕ ОКНО
--==============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(440, 600)
mainFrame.BackgroundColor3 = C.bg
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 22, 38)),
    ColorSequenceKeypoint.new(1, C.bgDeep),
})
mainGrad.Rotation = 90
mainGrad.Parent = mainFrame

--==============================================================
--  HEADER
--==============================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = C.bgDeep
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

-- обрезаем нижние углы
local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 16)
headerMask.Position = UDim2.new(0, 0, 1, -16)
headerMask.BackgroundColor3 = C.bgDeep
headerMask.BackgroundTransparency = 0.3
headerMask.BorderSizePixel = 0
headerMask.ZIndex = 2
headerMask.Parent = header

-- Иконка в шапке
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

-- Заголовок
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

-- Подзаголовок
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

-- Кнопка закрытия
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

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.red,
        TextColor3 = Color3.new(1,1,1),
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.redDark,
        TextColor3 = C.red,
    }):Play()
end)

--==============================================================
--  СТАТУС-ПАНЕЛЬ
--==============================================================
local statusPanel = Instance.new("Frame")
statusPanel.Size = UDim2.new(1, -28, 0, 70)
statusPanel.Position = UDim2.new(0, 14, 0, 78)
statusPanel.BackgroundColor3 = C.panel
statusPanel.BorderSizePixel = 0
statusPanel.Parent = mainFrame
Instance.new("UICorner", statusPanel).CornerRadius = UDim.new(0, 12)

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = C.accentDim
statusStroke.Thickness = 1
statusStroke.Transparency = 0.5
statusStroke.Parent = statusPanel

-- Индикатор слева
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.fromOffset(4, 42)
statusIndicator.Position = UDim2.new(0, 12, 0.5, -21)
statusIndicator.BackgroundColor3 = C.textFaint
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusPanel
Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(1, 0)

-- Статус
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

-- Статистика
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -110, 0, 16)
statsLabel.Position = UDim2.new(0, 26, 0, 32)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Открыто: 0 | Ошибок: 0"
statsLabel.TextColor3 = C.textFaint
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statusPanel

-- Ошибка
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

-- Счётчик справа
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
listHeader.Parent = mainFrame

-- Счётчик найденных
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -30, 0, 18)
countLabel.Position = UDim2.new(0, 15, 0, 156)
countLabel.BackgroundTransparency = 1
countLabel.Text = "0"
countLabel.TextColor3 = C.textFaint
countLabel.TextSize = 11
countLabel.Font = Enum.Font.Gotham
countLabel.TextXAlignment = Enum.TextXAlignment.Right
countLabel.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 0, 230)
scroll.Position = UDim2.new(0, 15, 0, 178)
scroll.BackgroundColor3 = C.panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = C.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = mainFrame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)

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
    for _, b in ipairs(crystalButtons) do
        b:Destroy()
    end
    crystalButtons = {}

    local names = {}
    for _, c in ipairs(mapCrystalsFolder:GetChildren()) do
        if c:IsA("Model") and c.PrimaryPart then
            table.insert(names, c.Name)
        end
    end
    table.sort(names, function(a, b)
        return getCrystalRank(a) < getCrystalRank(b)
    end)

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

        -- Иконка 💎
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromOffset(20, 20)
        icon.Position = UDim2.new(0, 10, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Text = "💎"
        icon.TextSize = 13
        icon.Font = Enum.Font.GothamBold
        icon.Parent = b

        -- Название
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

        -- Галочка справа
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
                TweenService:Create(b, TweenInfo.new(0.12), {
                    BackgroundColor3 = C.cardHover,
                }):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            if state.selectedName ~= name then
                TweenService:Create(b, TweenInfo.new(0.12), {
                    BackgroundColor3 = C.card,
                }):Play()
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
        if mainFrame.Visible then
            refreshList()
        end
    end
end)

--==============================================================
--  РЕЖИМЫ
--==============================================================
local modeHeader = Instance.new("TextLabel")
modeHeader.Size = UDim2.new(1, -30, 0, 18)
modeHeader.Position = UDim2.new(0, 15, 0, 420)
modeHeader.BackgroundTransparency = 1
modeHeader.Text = "РЕЖИМ ОТКРЫТИЯ"
modeHeader.TextColor3 = C.accent
modeHeader.TextSize = 11
modeHeader.Font = Enum.Font.GothamBold
modeHeader.TextXAlignment = Enum.TextXAlignment.Left
modeHeader.Parent = mainFrame

local modeHolder = Instance.new("Frame")
modeHolder.Size = UDim2.new(1, -30, 0, 68)
modeHolder.Position = UDim2.new(0, 15, 0, 442)
modeHolder.BackgroundTransparency = 1
modeHolder.Parent = mainFrame

local modeGrid = Instance.new("UIGridLayout")
modeGrid.CellSize = UDim2.new(0.5, -4, 0, 30)
modeGrid.CellPadding = UDim2.new(0, 8, 0, 8)
modeGrid.Parent = modeHolder

local modeButtons = {}
local modeList = {
    { id = "remote",   text = "📡 Remote",   color = C.accent },
    { id = "touch",    text = "✋ Touch",    color = Color3.fromRGB(100, 180, 255) },
    { id = "prompt",   text = "🎯 Prompt",   color = Color3.fromRGB(255, 180, 70) },
    { id = "teleport", text = "🚀 Teleport", color = Color3.fromRGB(80, 220, 120) },
}

local function refreshModeButtons()
    for id, b in pairs(modeButtons) do
        if id == state.mode then
            b.BackgroundColor3 = b:GetAttribute("AccentColor") or C.accent
            b.TextColor3 = Color3.new(1, 1, 1)
            local st = b:FindFirstChildOfClass("UIStroke")
            if st then st.Transparency = 0 end
        else
            b.BackgroundColor3 = C.card
            b.TextColor3 = C.textDim
            local st = b:FindFirstChildOfClass("UIStroke")
            if st then st.Transparency = 0.8 end
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
    b:SetAttribute("AccentColor", m.color)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local st = Instance.new("UIStroke")
    st.Color = m.color
    st.Thickness = 1.5
    st.Transparency = 0.8
    st.Parent = b

    b.MouseEnter:Connect(function()
        if state.mode ~= m.id then
            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = C.cardHover,
            }):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if state.mode ~= m.id then
            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = C.card,
            }):Play()
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
delayRow.Position = UDim2.new(0, 15, 0, 518)
delayRow.BackgroundColor3 = C.panel
delayRow.BorderSizePixel = 0
delayRow.Parent = mainFrame
Instance.new("UICorner", delayRow).CornerRadius = UDim.new(0, 8)

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

local delayStroke = Instance.new("UIStroke")
delayStroke.Color = C.accent
delayStroke.Thickness = 1
delayStroke.Transparency = 0.7
delayStroke.Parent = delayBox

delayBox.FocusLost:Connect(function(enter)
    if enter then
        local v = tonumber(delayBox.Text)
        if v and v >= 0.05 then
            state.delay = v
        end
    end
end)

--==============================================================
--  КНОПКА СТАРТ/СТОП
--==============================================================
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -30, 0, 46)
startBtn.Position = UDim2.new(0, 15, 1, -58)
startBtn.BackgroundColor3 = C.green
startBtn.Text = ""
startBtn.AutoButtonColor = false
startBtn.Parent = mainFrame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 12)

local startGrad = Instance.new("UIGradient")
startGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.green),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 180, 90)),
})
startGrad.Rotation = 90
startGrad.Parent = startBtn

local startStroke = Instance.new("UIStroke")
startStroke.Color = Color3.new(1, 1, 1)
startStroke.Thickness = 1
startStroke.Transparency = 0.8
startStroke.Parent = startBtn

local startText = Instance.new("TextLabel")
startText.Size = UDim2.fromScale(1, 1)
startText.BackgroundTransparency = 1
startText.Text = "▶  ЗАПУСТИТЬ"
startText.TextColor3 = Color3.new(1, 1, 1)
startText.TextSize = 14
startText.Font = Enum.Font.GothamBold
startText.Parent = startBtn

startBtn.MouseEnter:Connect(function()
    TweenService:Create(startBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.15,
    }):Play()
end)
startBtn.MouseLeave:Connect(function()
    TweenService:Create(startBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 0,
    }):Play()
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
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 180, 90)),
            })
            statusDot.BackgroundColor3 = C.textFaint
        end

        statsLabel.Text = ("Открыто: %d · Ошибок: %d"):format(state.opened, state.failed)
        counterLabel.Text = tostring(state.opened)
        errLabel.Text = state.lastError ~= "" and ("⚠ " .. state.lastError) or ""

        task.wait(0.3)
    end
end)

--==============================================================
--  КЛИКИ
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

-- Клик по кнопке меню (не drag)
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- F2 — открыть/закрыть
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ ОКНА (за header)
--==============================================================
local draggingFrame = false
local dragFrameStart, frameStartPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragFrameStart = input.Position
        frameStartPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not draggingFrame then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragFrameStart
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

print("[AutoCrystal] v2 загружено. F2 — меню. Кнопку можно тащить.")
