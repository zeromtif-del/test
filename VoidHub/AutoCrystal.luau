--==============================================================
--  🔮 AUTO CRYSTAL — независимый скрипт
--  Своё меню, свои тумблеры, 4 режима открытия
--  Требует: запущенный основной кристалл-скрипт (для UI кристаллов)
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Убиваем старую версию
do
    local old = playerGui:FindFirstChild("AutoCrystalStandalone")
    if old then old:Destroy() end
end

--==============================================================
--  ССЫЛКИ ИГРЫ
--==============================================================
local rEvents = ReplicatedStorage:WaitForChild("rEvents", 30)
local openCrystalRemote = rEvents and rEvents:WaitForChild("openCrystalRemote", 30)
local mapCrystalsFolder = workspace:WaitForChild("mapCrystalsFolder", 30)

if not openCrystalRemote then
    warn("[AutoCrystal] openCrystalRemote не найден — жди загрузки игры")
    return
end
if not mapCrystalsFolder then
    warn("[AutoCrystal] mapCrystalsFolder не найден — жди загрузки карты")
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
--  МЕТОДЫ ОТКРЫТИЯ
--==============================================================

-- 📡 Метод 1: чистый Remote
local function tryRemote(name)
    local ok, a, b, c, d, e, f, stopReason = pcall(function()
        return openCrystalRemote:InvokeServer("openCrystal", name)
    end)

    if not ok then
        state.lastError = "Remote error: " .. tostring(a)
        return false, nil
    end

    if stopReason then
        return false, stopReason
    end

    return a ~= nil, nil
end

-- ✋ Метод 2: firetouchinterest (без телепорта)
local function tryTouch(name)
    local crystal = getCrystal(name)
    if not crystal then
        state.lastError = "Кристалл не найден"
        return false, nil
    end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then
        state.lastError = "Нет персонажа"
        return false, nil
    end

    local target = getInteractPart(crystal)
    if not target then
        state.lastError = "Нет части для touch"
        return false, nil
    end

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

-- 🎯 Метод 3: ProximityPrompt
local function tryPrompt(name)
    local crystal = getCrystal(name)
    if not crystal then
        state.lastError = "Кристалл не найден"
        return false, nil
    end

    local found = false
    for _, d in ipairs(crystal:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            found = true
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

-- 🚀 Метод 4: Teleport
local function tryTeleport(name)
    local crystal = getCrystal(name)
    if not crystal then
        state.lastError = "Кристалл не найден"
        return false, nil
    end

    local hrp = getHRP()
    local hum = getHumanoid()
    if not hrp or not hum or hum.Health <= 0 then
        state.lastError = "Персонаж мёртв"
        return false, nil
    end

    local target = getInteractPart(crystal)
    if not target then
        state.lastError = "Нет точки телепорта"
        return false, nil
    end

    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0), target.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.1)

    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0), target.Position)
    task.wait(0.12)

    return tryRemote(name)
end

--==============================================================
--  ГЛАВНАЯ ФУНКЦИЯ
--==============================================================
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
--  UI
--==============================================================
local COLORS = {
    bg = Color3.fromRGB(18, 18, 26),
    panel = Color3.fromRGB(28, 28, 40),
    card = Color3.fromRGB(32, 32, 44),
    cardHover = Color3.fromRGB(45, 45, 60),
    accent = Color3.fromRGB(140, 80, 255),
    accent2 = Color3.fromRGB(200, 130, 255),
    text = Color3.fromRGB(220, 220, 240),
    textDim = Color3.fromRGB(160, 160, 180),
    green = Color3.fromRGB(80, 220, 120),
    red = Color3.fromRGB(255, 100, 120),
    redBright = Color3.fromRGB(255, 80, 100),
}

local gui = Instance.new("ScreenGui")
gui.Name = "AutoCrystalStandalone"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Кнопка меню
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.fromOffset(140, 34)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
toggleBtn.Text = "🔮 AUTO CRYSTAL"
toggleBtn.TextColor3 = COLORS.text
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = COLORS.accent
toggleStroke.Thickness = 1
toggleStroke.Transparency = 0.4
toggleStroke.Parent = toggleBtn

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(420, 560)
mainFrame.BackgroundColor3 = COLORS.bg
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.accent
mainStroke.Thickness = 2
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

-- Header
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🔮 AUTO OPEN CRYSTAL"
title.TextColor3 = COLORS.text
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 45)
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.redBright
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Разделитель
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -30, 0, 1)
sep.Position = UDim2.new(0, 15, 0, 52)
sep.BackgroundColor3 = COLORS.accent
sep.BackgroundTransparency = 0.6
sep.BorderSizePixel = 0
sep.Parent = mainFrame

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -30, 0, 20)
statusLabel.Position = UDim2.new(0, 15, 0, 62)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚪ Остановлено"
statusLabel.TextColor3 = COLORS.textDim
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -30, 0, 20)
statsLabel.Position = UDim2.new(0, 15, 0, 82)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Открыто: 0 | Ошибок: 0"
statsLabel.TextColor3 = COLORS.textDim
statsLabel.TextSize = 12
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = mainFrame

local errLabel = Instance.new("TextLabel")
errLabel.Size = UDim2.new(1, -30, 0, 20)
errLabel.Position = UDim2.new(0, 15, 0, 102)
errLabel.BackgroundTransparency = 1
errLabel.Text = ""
errLabel.TextColor3 = COLORS.red
errLabel.TextSize = 12
errLabel.Font = Enum.Font.Gotham
errLabel.TextXAlignment = Enum.TextXAlignment.Left
errLabel.Parent = mainFrame

-- Список кристаллов
local listHeader = Instance.new("TextLabel")
listHeader.Size = UDim2.new(1, -30, 0, 20)
listHeader.Position = UDim2.new(0, 15, 0, 130)
listHeader.BackgroundTransparency = 1
listHeader.Text = "ВЫБЕРИ КРИСТАЛЛ:"
listHeader.TextColor3 = COLORS.accent
listHeader.TextSize = 12
listHeader.Font = Enum.Font.GothamBold
listHeader.TextXAlignment = Enum.TextXAlignment.Left
listHeader.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 0, 220)
scroll.Position = UDim2.new(0, 15, 0, 155)
scroll.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = COLORS.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = mainFrame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

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
    table.sort(names)

    for i, name in ipairs(names) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -8, 0, 32)
        b.BackgroundColor3 = (state.selectedName == name) and Color3.fromRGB(60, 40, 100) or COLORS.card
        b.Text = "  💎 " .. name
        b.TextColor3 = COLORS.text
        b.TextSize = 12
        b.Font = Enum.Font.GothamMedium
        b.AutoButtonColor = false
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.LayoutOrder = i
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

        b.MouseEnter:Connect(function()
            if state.selectedName ~= name then
                b.BackgroundColor3 = COLORS.cardHover
            end
        end)
        b.MouseLeave:Connect(function()
            if state.selectedName ~= name then
                b.BackgroundColor3 = COLORS.card
            end
        end)
        b.MouseButton1Click:Connect(function()
            state.selectedName = name
            for _, other in ipairs(crystalButtons) do
                other.BackgroundColor3 = COLORS.card
            end
            b.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
        end)

        table.insert(crystalButtons, b)
    end

    if #names == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -8, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет кристаллов"
        empty.TextColor3 = COLORS.textDim
        empty.TextSize = 12
        empty.Font = Enum.Font.Gotham
        empty.Parent = scroll
        table.insert(crystalButtons, empty)
    end
end

refreshList()

-- Авто-обновление списка
task.spawn(function()
    while gui.Parent do
        task.wait(5)
        if mainFrame.Visible then
            refreshList()
        end
    end
end)

-- Режимы
local modeHeader = Instance.new("TextLabel")
modeHeader.Size = UDim2.new(1, -30, 0, 20)
modeHeader.Position = UDim2.new(0, 15, 0, 385)
modeHeader.BackgroundTransparency = 1
modeHeader.Text = "РЕЖИМ ОТКРЫТИЯ:"
modeHeader.TextColor3 = COLORS.accent
modeHeader.TextSize = 12
modeHeader.Font = Enum.Font.GothamBold
modeHeader.TextXAlignment = Enum.TextXAlignment.Left
modeHeader.Parent = mainFrame

local modeHolder = Instance.new("Frame")
modeHolder.Size = UDim2.new(1, -30, 0, 64)
modeHolder.Position = UDim2.new(0, 15, 0, 408)
modeHolder.BackgroundTransparency = 1
modeHolder.Parent = mainFrame

local modeGrid = Instance.new("UIGridLayout")
modeGrid.CellSize = UDim2.new(0.5, -4, 0, 28)
modeGrid.CellPadding = UDim2.new(0, 8, 0, 8)
modeGrid.Parent = modeHolder

local modeButtons = {}
local modeList = {
    { id = "remote",   text = "📡 Remote" },
    { id = "touch",    text = "✋ Touch" },
    { id = "prompt",   text = "🎯 Prompt" },
    { id = "teleport", text = "🚀 Teleport" },
}

local function refreshModeButtons()
    for id, b in pairs(modeButtons) do
        if id == state.mode then
            b.BackgroundColor3 = COLORS.accent
            b.TextColor3 = Color3.new(1, 1, 1)
        else
            b.BackgroundColor3 = COLORS.card
            b.TextColor3 = COLORS.textDim
        end
    end
end

for _, m in ipairs(modeList) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = COLORS.card
    b.Text = m.text
    b.TextColor3 = COLORS.textDim
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = modeHolder
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        state.mode = m.id
        refreshModeButtons()
    end)

    modeButtons[m.id] = b
end

refreshModeButtons()

-- Задержка
local delayRow = Instance.new("Frame")
delayRow.Size = UDim2.new(1, -30, 0, 32)
delayRow.Position = UDim2.new(0, 15, 0, 478)
delayRow.BackgroundColor3 = COLORS.card
delayRow.BorderSizePixel = 0
delayRow.Parent = mainFrame
Instance.new("UICorner", delayRow).CornerRadius = UDim.new(0, 8)

local delayLbl = Instance.new("TextLabel")
delayLbl.Size = UDim2.new(0.6, -10, 1, 0)
delayLbl.Position = UDim2.new(0, 12, 0, 0)
delayLbl.BackgroundTransparency = 1
delayLbl.Text = "Задержка (сек)"
delayLbl.TextColor3 = COLORS.text
delayLbl.TextSize = 12
delayLbl.Font = Enum.Font.GothamMedium
delayLbl.TextXAlignment = Enum.TextXAlignment.Left
delayLbl.Parent = delayRow

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0.4, -12, 0, 22)
delayBox.Position = UDim2.new(0.6, 0, 0.5, -11)
delayBox.BackgroundColor3 = COLORS.bg
delayBox.Text = "0.2"
delayBox.TextColor3 = COLORS.text
delayBox.TextSize = 12
delayBox.Font = Enum.Font.Gotham
delayBox.ClearTextOnFocus = false
delayBox.Parent = delayRow
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)

delayBox.FocusLost:Connect(function(enter)
    if enter then
        local v = tonumber(delayBox.Text)
        if v and v >= 0.05 then
            state.delay = v
        end
    end
end)

-- Кнопка старт/стоп
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -30, 0, 42)
startBtn.Position = UDim2.new(0, 15, 1, -54)
startBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
startBtn.Text = "▶ ЗАПУСТИТЬ"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.TextSize = 14
startBtn.Font = Enum.Font.GothamBold
startBtn.AutoButtonColor = false
startBtn.Parent = mainFrame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 10)

local startStroke = Instance.new("UIStroke")
startStroke.Color = Color3.fromRGB(80, 220, 120)
startStroke.Thickness = 1
startStroke.Transparency = 0.6
startStroke.Parent = startBtn

--==============================================================
--  ОБНОВЛЕНИЕ UI
--==============================================================
task.spawn(function()
    while gui.Parent do
        if state.running then
            statusLabel.Text = ("🟢 Работает — %s (%s)"):format(
                state.selectedName or "—", state.mode)
            statusLabel.TextColor3 = COLORS.green
            startBtn.Text = "⏹ ОСТАНОВИТЬ"
            startBtn.BackgroundColor3 = Color3.fromRGB(150, 55, 60)
            startStroke.Color = Color3.fromRGB(255, 120, 120)
        else
            statusLabel.Text = "⚪ Остановлено"
            statusLabel.TextColor3 = COLORS.textDim
            startBtn.Text = "▶ ЗАПУСТИТЬ"
            startBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
            startStroke.Color = Color3.fromRGB(80, 220, 120)
        end

        statsLabel.Text = ("Открыто: %d | Ошибок: %d"):format(state.opened, state.failed)
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

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- F2 — открыть/закрыть меню
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ
--==============================================================
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        -- только если тащим за header (верхняя часть)
        if input.Position.Y - mainFrame.AbsolutePosition.Y < 50 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("[AutoCrystal] Загружено. F2 — меню. Кнопка: 🔮 AUTO CRYSTAL слева.")
