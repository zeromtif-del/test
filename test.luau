--==============================================================
--  МЕНЮ ТЕЛЕПОРТАЦИИ — 2 ВКЛАДКИ
--  Вкладка 1: только предустановленные точки (из кода, менять нельзя)
--  Вкладка 2: пользовательские точки (можно добавлять/удалять)
--  Открытие: T или кнопка ☰
--  Всё в одном LocalScript
--==============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
--  НАСТРОЙКИ
--==============================================================
local CONFIG = {
    accentColor   = Color3.fromRGB(88, 132, 255),
    accentColor2  = Color3.fromRGB(180, 88, 255),
    bgColor       = Color3.fromRGB(20, 22, 30),
    textColor     = Color3.fromRGB(240, 240, 250),
    openKey       = Enum.KeyCode.F1,
    menuSize = UDim2.fromOffset(640, 660),
    buttonHeight  = 46,
    buttonSpacing = 8,
}

--==============================================================
--  🔧 ОБЩИЕ ФУНКЦИИ ДЛЯ ТРЕНАЖЁРОВ (используются Auto и Fast Strength)
--==============================================================
local MachineHelper = {}
do
    local VIM = game:GetService("VirtualInputManager")

    -- Найти модель по подстроке в имени
    function MachineHelper.findByName(substr)
        local mf = workspace:FindFirstChild("machinesFolder")
        if not mf then return nil end
        local lower = substr:lower()
        for _, m in ipairs(mf:GetChildren()) do
            if string.find(m.Name:lower(), lower, 1, true) then
                return m
            end
        end
        return nil
    end

-- Найти именно Industrial Bar Lift
function MachineHelper.findIndustrialLift()
    local mf = workspace:FindFirstChild("machinesFolder")
    if not mf then return nil end

    -- 1. Точное имя
    local exact = mf:FindFirstChild("Industrial Bar Lift")
    if exact then return exact end

    -- 2. По подстроке "industrial" + "bar" + "lift"
    for _, m in ipairs(mf:GetChildren()) do
        local ln = m.Name:lower()
        if string.find(ln, "industrial", 1, true)
            and string.find(ln, "bar", 1, true)
            and string.find(ln, "lift", 1, true) then
            return m
        end
    end

    -- 3. Фолбэк — просто industrial + lift
    for _, m in ipairs(mf:GetChildren()) do
        local ln = m.Name:lower()
        if string.find(ln, "industrial", 1, true)
            and string.find(ln, "lift", 1, true) then
            return m
        end
    end

    return nil
end

    -- Сесть на тренажёр через E
    function MachineHelper.enter(machine)
        if not machine or not machine.Parent then return false end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = MachineHelper.getInteractSeat(machine)
        if not hrp or not seat or not hum then return false end

        hrp.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.4)
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.4)
        return true
    end
end

--==============================================================
--  🔒 ВКЛАДКА 1: ПРЕДУСТАНОВЛЕННЫЕ ТОЧКИ (менять нельзя, только ты)
--  Дописывай свои локации здесь.
--==============================================================
local FIXED_LOCATIONS = {
    { name = "spawn",     position = Vector3.new(-96, 7, 234) },
    { name = "tiny island",       position = Vector3.new(-38, 4, 1884) },
    { name = "frost gym",      position = Vector3.new(-2623, 3, -409) },
    { name = "mythical gym",      position = Vector3.new(2251, 3, 1073) },
    { name = "eternal gym",     position = Vector3.new(-6763, 3, -1285) },
    { name = "legends gym",    position = Vector3.new(4597, 988, -3897) },
    { name = "muscle king gym", position = Vector3.new(-8626, 17, -5730) },
    { name = "jungle gym", position = Vector3.new(-8686, 7, 2392) },
    { name = "industrial gym", position = Vector3.new(-5563, 60, 4942) },
    { name = "overcharged gym", position = Vector3.new(-3087, 154, 4995) },
    { name = "hallowed gym", position = Vector3.new(5538, 85, 5872) },
    { name = "2.5k strength",  position = Vector3.new(-2, 7, -246) },
    { name = "boss arena", position = Vector3.new(-7, 16, -1267) },
    { name = "pet enchant", position = Vector3.new(71, 15, 407) },
    { name = "secret area", position = Vector3.new(1953, 2, 6182) },
    { name = "RIP pet glitch's", position = Vector3.new(-493, 7, -205) },
    { name = "stand head", position = Vector3.new(0, 90, 237) },

}

--==============================================================
--  ⭐ ВКЛАДКА 2: ПОЛЬЗОВАТЕЛЬСКИЕ ТОЧКИ (пусто изначально)
--==============================================================
local CUSTOM_LOCATIONS = {}

--==============================================================
--  СОЗДАНИЕ GUI
--==============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

---------------------------------------------------------------
-- Кнопка-открывашка
---------------------------------------------------------------
--==============================================================
--  КНОПКА-ОТКРЫВАШКА (простая текстовая)
--==============================================================
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(90, 34)
toggleButton.Position = UDim2.new(0.5, -45, 0, 14)   -- центр сверху
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.Text = "MENU"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.Code
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(90, 90, 90)
toggleStroke.Thickness = 1
toggleStroke.Parent = toggleButton

---------------------------------------------------------------
-- Главное окно
---------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)         -- 🔥 центрируем точкой, а не offset
mainFrame.Position = UDim2.fromScale(0.5, 0.5)         -- 🔥 всегда по центру
mainFrame.Size = CONFIG.menuSize
mainFrame.BackgroundColor3 = CONFIG.bgColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

--==============================================================
--  📱 АВТО-МАСШТАБ (телефоны, маленькие экраны)
--==============================================================
local menuScale = Instance.new("UIScale")
menuScale.Scale = 1
menuScale.Parent = mainFrame

local function updateMenuScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize

    local designW = CONFIG.menuSize.X.Offset
    local designH = CONFIG.menuSize.Y.Offset

    -- Не больше 92% экрана по каждой оси
    local sx = (vp.X * 0.92) / designW
    local sy = (vp.Y * 0.92) / designH
    local scale = math.min(sx, sy, 1)   -- больше 1 не увеличиваем

    -- На тач-устройствах (телефон/планшет) — ещё чуть меньше
    local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isTouch then
        scale = scale * 0.9
    end

    menuScale.Scale = scale
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMenuScale)
end
updateMenuScale()

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.accentColor
mainStroke.Thickness = 2
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 30, 44)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 18, 26)),
})
mainGradient.Rotation = 90
mainGradient.Parent = mainFrame

---------------------------------------------------------------
-- Заголовок
---------------------------------------------------------------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 44)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "teleportation"
title.TextColor3 = CONFIG.textColor
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.accentColor),
    ColorSequenceKeypoint.new(1, CONFIG.accentColor2),
})
titleGradient.Parent = title

---------------------------------------------------------------
-- Кнопка закрытия
---------------------------------------------------------------
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.Position = UDim2.new(1, -46, 0, 14)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
closeButton.Text = "close"
closeButton.TextColor3 = Color3.fromRGB(255, 120, 120)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.Parent = mainFrame

Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)

---------------------------------------------------------------
-- Разделитель
---------------------------------------------------------------
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -30, 0, 1)
separator.Position = UDim2.new(0, 15, 0, 62)
separator.BackgroundColor3 = CONFIG.accentColor
separator.BackgroundTransparency = 0.6
separator.BorderSizePixel = 0
separator.Parent = mainFrame

---------------------------------------------------------------
-- ПАНЕЛЬ ВКЛАДОК
---------------------------------------------------------------
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 44)
tabBar.Position = UDim2.new(0, 10, 0, 72)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 12)

local tabBarGradient = Instance.new("UIGradient")
tabBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 34, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 34)),
})
tabBarGradient.Rotation = 90
tabBarGradient.Parent = tabBar

-- Индикатор-подсветка активной вкладки (двигается плавно)
local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(1/8, -4, 1, -6)
tabIndicator.Position = UDim2.new(0, 3, 0, 3)
tabIndicator.BackgroundColor3 = CONFIG.accentColor
tabIndicator.BorderSizePixel = 0
tabIndicator.ZIndex = 2
tabIndicator.Parent = tabBar
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0, 10)

local tabIndicatorGradient = Instance.new("UIGradient")
tabIndicatorGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.accentColor),
    ColorSequenceKeypoint.new(1, CONFIG.accentColor2),
})
tabIndicatorGradient.Rotation = 45
tabIndicatorGradient.Parent = tabIndicator

local function makeTabButton(text, xOffset)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, 0, 1, 0)
    b.Position = UDim2.new(0, xOffset, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = text
    b.TextColor3 = Color3.fromRGB(160, 165, 190)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.ZIndex = 3
    b.Parent = tabBar
    return b
end

local tab1Button = makeTabButton("📍 Лок", 0)
local tab2Button = makeTabButton("⭐ Точки", 0)
local tab3Button = makeTabButton("⚙️ Фарм", 0)
local tab4Button = makeTabButton("🎮 Утил", 0)
local tab5Button = makeTabButton("⚔️ PvP", 0)
local tab6Button = makeTabButton("🤖 Авто", 0)
local tab7Button = makeTabButton("📦 Инв", 0)
local tab8Button = makeTabButton("📊 Статы", 0)

local TAB_W = 1/8
local tabButtonsAll = {tab1Button, tab2Button, tab3Button, tab4Button,
                       tab5Button, tab6Button, tab7Button, tab8Button}
for i, b in ipairs(tabButtonsAll) do
    b.Size = UDim2.new(TAB_W, 0, 1, 0)
    b.Position = UDim2.new(TAB_W * (i-1), 0, 0, 0)
    b.TextSize = 12
end

---------------------------------------------------------------
-- КОНТЕЙНЕР КОНТЕНТА (под вкладками)
---------------------------------------------------------------
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -20, 1, -180)
contentHolder.Position = UDim2.new(0, 10, 0, 124)
contentHolder.BackgroundTransparency = 1
contentHolder.ClipsDescendants = true
contentHolder.Parent = mainFrame

-- Внутренние функции для создания списка в каждой вкладке
local function makeScrollingList(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = CONFIG.accentColor
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, CONFIG.buttonSpacing)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = scroll

    return scroll, layout
end

local tabFrames = {}
local scrolls = {}
for i = 1, 8 do
    local f = Instance.new("Frame")
    f.Size = UDim2.fromScale(1, 1)
    f.BackgroundTransparency = 1
    f.Visible = (i == 1)
    f.Parent = contentHolder
    tabFrames[i] = f
    scrolls[i] = makeScrollingList(f)
end

local tab1Frame, tab2Frame, tab3Frame = tabFrames[1], tabFrames[2], tabFrames[3]
local tab4Frame, tab5Frame, tab6Frame = tabFrames[4], tabFrames[5], tabFrames[6]
local tab7Frame, tab8Frame = tabFrames[7], tabFrames[8]

local scroll1, scroll2, scroll3 = scrolls[1], scrolls[2], scrolls[3]
local scroll4, scroll5, scroll6 = scrolls[4], scrolls[5], scrolls[6]
local scroll7, scroll8 = scrolls[7], scrolls[8]
---------------------------------------------------------------
-- ПАНЕЛЬ ДЕЙСТВИЙ ДЛЯ ВКЛАДКИ 2 (добавить/выбрать/очистить)
---------------------------------------------------------------
local actionBar = Instance.new("Frame")
actionBar.Size = UDim2.new(1, -20, 0, 46)
actionBar.Position = UDim2.new(0, 10, 1, -56)
actionBar.BackgroundTransparency = 1
actionBar.Visible = false   -- показываем только на вкладке 2
actionBar.Parent = mainFrame

local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.Padding = UDim.new(0, 6)
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionLayout.Parent = actionBar

local function makeActionButton(text, w, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 1, 0)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = actionBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke")
    st.Color = Color3.new(1, 1, 1)
    st.Transparency = 0.7
    st.Parent = b
    return b
end

local addPointBtn  = makeActionButton("current",  135, Color3.fromRGB(50, 120, 80))
local pickPointBtn = makeActionButton("choose",    110, Color3.fromRGB(60, 90, 180))
local clearAllBtn  = makeActionButton("clear",   110, Color3.fromRGB(120, 50, 60))

---------------------------------------------------------------
-- ТЕКСТ-ЗАГЛУШКА ПРИ ПУСТОМ СПИСКЕ
---------------------------------------------------------------
local function makeEmptyLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 80)
    l.Position = UDim2.new(0, 10, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(150, 150, 175)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local emptyTab1 = makeEmptyLabel(scroll1, "Список локаций пуст.\nДобавь их в коде.")
local emptyTab2 = makeEmptyLabel(scroll2, "Твоих точек пока нет.\nНажми «current» или «choose» внизу,\nчтобы добавить первую точку.")

--==============================================================
--  УТИЛИТЫ
--==============================================================
local function getHRP()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position)
    local char = player.Character
    if not char then return end
    char:PivotTo(CFrame.new(position))
end

local function flashScreen()
    local flash = Instance.new("Frame")
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundColor3 = CONFIG.accentColor
    flash.BackgroundTransparency = 0.4
    flash.BorderSizePixel = 0
    flash.ZIndex = 10
    flash.Parent = screenGui
    Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 16)
    TweenService:Create(flash, TweenInfo.new(0.35), {
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.35, function() flash:Destroy() end)
end

--==============================================================
--  СОЗДАНИЕ КНОПКИ ТЕЛЕПОРТА
--  allowDelete = true → появляется ✕ для удаления (только вкладка 2)
--==============================================================
local function createTeleportButton(data, parentScroll, order, allowDelete, indexRef)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, CONFIG.buttonHeight)
    btn.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = parentScroll

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = btn

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.accentColor),
        ColorSequenceKeypoint.new(1, CONFIG.accentColor2),
    })
    grad.Transparency = NumberSequence.new(1)
    grad.Parent = btn

    -- Иконка слева (маленький кружок-маркер)
    local marker = Instance.new("Frame")
    marker.Size = UDim2.fromOffset(8, 8)
    marker.Position = UDim2.new(0, 14, 0.5, -4)
    marker.BackgroundColor3 = CONFIG.accentColor
    marker.BorderSizePixel = 0
    marker.Parent = btn
    Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)

    -- Название
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -130, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.name
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn

    -- Кнопка удаления (только для пользовательских)
    if allowDelete then
        local del = Instance.new("TextButton")
        del.Size = UDim2.fromOffset(28, 28)
        del.Position = UDim2.new(1, -34, 0.5, -14)
        del.BackgroundColor3 = Color3.fromRGB(80, 35, 45)
        del.Text = "✕"
        del.TextColor3 = Color3.fromRGB(255, 140, 140)
        del.TextSize = 14
        del.Font = Enum.Font.GothamBold
        del.AutoButtonColor = true
        del.ZIndex = 5
        del.Parent = btn
        Instance.new("UICorner", del).CornerRadius = UDim.new(1, 0)

        del.MouseButton1Click:Connect(function()
            table.remove(CUSTOM_LOCATIONS, indexRef)
            if _G.__RebuildTab2 then _G.__RebuildTab2() end
        end)
    end

    local tInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- --- КЛИК = ТЕЛЕПОРТ ---
    btn.MouseButton1Click:Connect(function()
        teleportTo(data.position)
        flashScreen()
    end)

    return btn
end

--==============================================================
--  ПЕРЕРИСОВКА СПИСКОВ
--==============================================================
local function clearList(scroll)
    for _, ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
end

local function rebuildTab1()
    clearList(scroll1)
    emptyTab1.Visible = (#FIXED_LOCATIONS == 0)
    for i, data in ipairs(FIXED_LOCATIONS) do
        createTeleportButton(data, scroll1, i, false)   -- 🔒 без удаления
    end
end

local function rebuildTab2()
    clearList(scroll2)
    emptyTab2.Visible = (#CUSTOM_LOCATIONS == 0)
    for i, data in ipairs(CUSTOM_LOCATIONS) do
        createTeleportButton(data, scroll2, i, true, i) -- ✕ удалить
    end
end

_G.__RebuildTab2 = rebuildTab2   -- чтобы кнопка удаления внутри могла вызвать

rebuildTab1()
rebuildTab2()

--==============================================================
--  ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК (с анимацией индикатора)
--==============================================================
local currentTab = 1

local function switchTab(tabNum)
    if tabNum == currentTab then return end
    currentTab = tabNum

    local targetX = UDim2.new((tabNum - 1) / 8, tabNum == 1 and 3 or 1, 0, 3)

    TweenService:Create(tabIndicator, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetX,
    }):Play()

    local activeColor = Color3.new(1, 1, 1)
    local inactiveColor = Color3.fromRGB(160, 165, 190)

    for i, b in ipairs(tabButtonsAll) do
        TweenService:Create(b, TweenInfo.new(0.2), {
            TextColor3 = (tabNum == i) and activeColor or inactiveColor,
        }):Play()
    end

    for i, f in ipairs(tabFrames) do
        f.Visible = (i == tabNum)
    end
    actionBar.Visible = (tabNum == 2)

    local activeFrame = tabFrames[tabNum]
    activeFrame.Position = UDim2.new(0, (tabNum == 1) and -10 or 10, 0, 0)
    TweenService:Create(activeFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
end

for i, b in ipairs(tabButtonsAll) do
    b.MouseButton1Click:Connect(function() switchTab(i) end)
end

tab1Button.TextColor3 = Color3.new(1, 1, 1)

--==============================================================
--  ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЬСКОЙ ТОЧКИ (окно ввода имени)
--==============================================================
local function promptAddPoint(defaultName, position)
    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "TP_InputPrompt"
    inputGui.ResetOnSpawn = false
    inputGui.DisplayOrder = 100
    inputGui.Parent = playerGui

    local bg = Instance.new("TextButton")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Text = ""
    bg.AutoButtonColor = false
    bg.Parent = inputGui

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(380, 190)
    box.Position = UDim2.new(0.5, -190, 0.5, -95)
    box.BackgroundColor3 = CONFIG.bgColor
    box.BorderSizePixel = 0
    box.Parent = inputGui
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

    local st = Instance.new("UIStroke")
    st.Color = CONFIG.accentColor
    st.Thickness = 2
    st.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 0, 30)
    lbl.Position = UDim2.new(0, 15, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Название твоей точки:"
    lbl.TextColor3 = CONFIG.textColor
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = box

    local coordsLbl = Instance.new("TextLabel")
    coordsLbl.Size = UDim2.new(1, -30, 0, 18)
    coordsLbl.Position = UDim2.new(0, 15, 0, 42)
    coordsLbl.BackgroundTransparency = 1
    coordsLbl.Text = string.format("Позиция: %d, %d, %d",
        math.floor(position.X), math.floor(position.Y), math.floor(position.Z))
    coordsLbl.TextColor3 = Color3.fromRGB(150, 155, 180)
    coordsLbl.TextSize = 12
    coordsLbl.Font = Enum.Font.Gotham
    coordsLbl.TextXAlignment = Enum.TextXAlignment.Left
    coordsLbl.Parent = box

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -30, 0, 40)
    textBox.Position = UDim2.new(0, 15, 0, 68)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
    textBox.Text = defaultName or ""
    textBox.PlaceholderText = "Например: 🏠 Моя база"
    textBox.TextColor3 = CONFIG.textColor
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    textBox.TextSize = 15
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = box
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = CONFIG.accentColor
    tbStroke.Transparency = 0.5
    tbStroke.Parent = textBox

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.fromOffset(110, 36)
    okBtn.Position = UDim2.new(1, -260, 1, -50)
    okBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
    okBtn.Text = "✓ Добавить"
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.TextSize = 14
    okBtn.Font = Enum.Font.GothamBold
    okBtn.Parent = box
    Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 8)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.fromOffset(110, 36)
    cancelBtn.Position = UDim2.new(1, -140, 1, -50)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(90, 45, 55)
    cancelBtn.Text = "✕ Отмена"
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.TextSize = 14
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Parent = box
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

    -- Анимация появления
    box.Size = UDim2.fromOffset(0, 0)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(380, 190),
        Position = UDim2.new(0.5, -190, 0.5, -95),
    }):Play()

    task.defer(function() textBox:CaptureFocus() end)

    local done = false
    local function finish(save)
        if done then return end
        done = true
        if save then
            local name = textBox.Text
            if name == "" then name = defaultName or "Точка" end
            table.insert(CUSTOM_LOCATIONS, { name = name, position = position })
            rebuildTab2()
        end
        inputGui:Destroy()
    end

    okBtn.MouseButton1Click:Connect(function() finish(true) end)
    cancelBtn.MouseButton1Click:Connect(function() finish(false) end)
    bg.MouseButton1Click:Connect(function() finish(false) end)
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then finish(true) end
    end)
end

--==============================================================
--  ВЫБОР ТОЧКИ МЫШКОЙ (клик по миру)
--==============================================================
local pickingMode = false

local function stopPicking()
    pickingMode = false
    pickPointBtn.Text = "🎯 Выбрать"
    pickPointBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
end

local function startPicking()
    pickingMode = true
    pickPointBtn.Text = "⏳ Кликни в мир"
    pickPointBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 40)
end

local function getMouseTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character }

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, params)
    if result then return result.Position end
    return nil
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not pickingMode then return end
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = getMouseTarget()
        if pos then
            stopPicking()
            promptAddPoint("Точка " .. (#CUSTOM_LOCATIONS + 1), pos)
        end
    elseif input.KeyCode == Enum.KeyCode.Escape then
        stopPicking()
    end
end)

--==============================================================
--  ДЕЙСТВИЯ ВКЛАДКИ 2
--==============================================================
addPointBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if not hrp then return end
    promptAddPoint("Точка " .. (#CUSTOM_LOCATIONS + 1), hrp.Position)
end)

pickPointBtn.MouseButton1Click:Connect(function()
    if pickingMode then stopPicking() else startPicking() end
end)

clearAllBtn.MouseButton1Click:Connect(function()
    CUSTOM_LOCATIONS = {}
    rebuildTab2()
end)

--==============================================================
--  ОТКРЫТИЕ / ЗАКРЫТИЕ МЕНЮ
--==============================================================
local isOpen = false
local isAnimating = false

local function openMenu()
    if isOpen or isAnimating then return end
    isAnimating = true
    isOpen = true

mainFrame.Visible = true
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)

local tween = TweenService:Create(mainFrame,
    TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {
        Size = CONFIG.menuSize,
        Position = UDim2.fromScale(0.5, 0.5),
    })
    tween:Play()
    tween.Completed:Wait()
    isAnimating = false

    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        Rotation = 90,
        BackgroundColor3 = CONFIG.accentColor2,
    }):Play()
end

local function closeMenu()
    if not isOpen or isAnimating then return end
    isAnimating = true
    isOpen = false

local tween = TweenService:Create(mainFrame,
    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
    })
    tween:Play()
    tween.Completed:Wait()
    mainFrame.Visible = false
    isAnimating = false

    TweenService:Create(toggleButton, TweenInfo.new(0.3), {
        Rotation = 0,
        BackgroundColor3 = CONFIG.accentColor,
    }):Play()
end

local function toggleMenu()
    if isOpen then closeMenu() else openMenu() end
end

local clickStart = nil

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        clickStart = input.Position
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if not clickStart then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        local moved = (input.Position - clickStart).Magnitude
        if moved < 6 then
            toggleMenu()
        end
        clickStart = nil
    end
end)
closeButton.MouseButton1Click:Connect(closeMenu)

toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
end)
toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

--==============================================================
--  ГОРЯЧАЯ КЛАВИША T
--==============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.openKey then
        toggleMenu()
    end
end)

print("[TeleportMenu] Загружено. T — открыть/закрыть меню.")

--==============================================================
--  ⚙️ ВКЛАДКА «ФАРМ» — Сила и Перерождения
--==============================================================

local RS = game:GetService("RunService")

---------------------------------------------------------------
-- СЕРВИСЫ ИГРЫ (можно менять, если в игре другие имена)
---------------------------------------------------------------
local farm = {
    ready = false,
    muscleEvent = nil,
    equipPetEvent = nil,
    rebirthRemote = nil,
    petsFolder = nil,
    strength = nil,
    rebirths = nil,
    durability = nil,
}

task.spawn(function()
    farm.muscleEvent = player:WaitForChild("muscleEvent", 20)
    farm.petsFolder  = player:WaitForChild("petsFolder", 20)
    farm.durability  = player:WaitForChild("Durability", 20)

    local ls = player:WaitForChild("leaderstats", 20)
    if ls then
        farm.strength = ls:WaitForChild("Strength", 20)
        farm.rebirths = ls:WaitForChild("Rebirths", 20)
    end

    local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents", 20)
    if rEvents then
        farm.equipPetEvent = rEvents:WaitForChild("equipPetEvent", 20)
        farm.rebirthRemote = rEvents:WaitForChild("rebirthRemote", 20)
    end

    if farm.muscleEvent and farm.strength and farm.rebirths then
        farm.ready = true
        print("[Farm] Сервисы загружены. Фарм готов.")
    else
        warn("[Farm] Не все сервисы найдены. Проверь имена в блоке farm.")
    end
end)

---------------------------------------------------------------
-- СЛОВАРЬ ПЕТОВ (из твоего примера — правь под свою игру)
---------------------------------------------------------------
local PETS = {
    ["Omega Overlord"]      = { repSpeed = 20, strength = 0,  durability = 0,  rebirth = 0 },
    ["Swift Samurai"]       = { repSpeed = 15, strength = 0,  durability = 0,  rebirth = 0 },
    ["Powercore Hound"]     = { repSpeed = 0,  strength = 25, durability = 15, rebirth = 0 },
    ["Titanium Hydra"]      = { repSpeed = 0,  strength = 0,  durability = 0,  rebirth = 2 },
    ["Tribal Overlord"]     = { repSpeed = 0,  strength = 0,  durability = 0,  rebirth = 2 },
    ["Inferno Unicorn"]     = { repSpeed = 0,  strength = 25, durability = 25, rebirth = 0 },
    ["Inferno Drake"]       = { repSpeed = 40, strength = 0,  durability = 0,  rebirth = 0 },
    ["Common Boss Pet"]     = { repSpeed = 5,  strength = 0,  durability = 0,  rebirth = 0 },
    ["Rare Boss Pet"]       = { repSpeed = 7, strength = 0,  durability = 0,  rebirth = 0 },
    ["Epic Boss Pet"]       = { repSpeed = 10,  strength = 0,  durability = 0,  rebirth = 0 },
    ["Rainbow Boss Pet"]    = { repSpeed = 10,  strength = 7,  durability = 0,  rebirth = 0 },
    ["Legendary Boss Pet"]  = { repSpeed = 10,  strength = 10, durability = 0,  rebirth = 0 },
    ["Mythic Boss Pet"]     = { repSpeed = 10,  strength = 25, durability = 0,  rebirth = 0 },
    -- ⬆️ Добавляй своих петов сюда
}

local MAX_PET_SLOTS = 12
local TARGET_REP_SPEED = 100

local function unequipAllPets()
    if not farm.petsFolder then return end
    for _, folder in ipairs(farm.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                farm.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function getOwnedPets()
    local list = {}
    if not farm.petsFolder then return list end
    for _, folder in ipairs(farm.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                local cfg = PETS[pet.Name]
                if cfg then
                    table.insert(list, {
                        instance = pet,
                        name = pet.Name,
                        repSpeed = cfg.repSpeed or 0,
                        strength = cfg.strength or 0,
                        durability = cfg.durability or 0,
                        rebirth = cfg.rebirth or 0,
                    })
                end
            end
        end
    end
    return list
end

local function equipBestFarmingPets()
    unequipAllPets()
    local pets = getOwnedPets()
    table.sort(pets, function(a, b) return a.repSpeed > b.repSpeed end)

    local equipped, count, repSpeed = {}, 0, 0
    for _, pet in ipairs(pets) do
        if count >= MAX_PET_SLOTS or repSpeed >= TARGET_REP_SPEED then break end
        if pet.repSpeed > 0 then
            farm.equipPetEvent:FireServer("equipPet", pet.instance)
            equipped[pet.instance] = true
            count = count + 1
            repSpeed = repSpeed + pet.repSpeed
        end
    end
    local rest = {}
    for _, pet in ipairs(pets) do if not equipped[pet.instance] then table.insert(rest, pet) end end
    table.sort(rest, function(a, b) return (a.strength + a.durability) > (b.strength + b.durability) end)
    for _, pet in ipairs(rest) do
        if count >= MAX_PET_SLOTS then break end
        if pet.strength > 0 or pet.durability > 0 then
            farm.equipPetEvent:FireServer("equipPet", pet.instance)
            count = count + 1
        end
    end
    return repSpeed, count
end

local function equipBestRebirthPets()
    unequipAllPets()
    local pets = getOwnedPets()
    table.sort(pets, function(a, b) return a.rebirth > b.rebirth end)
    local count, mult = 0, 0
    for _, pet in ipairs(pets) do
        if count >= MAX_PET_SLOTS then break end
        if pet.rebirth > 0 then
            farm.equipPetEvent:FireServer("equipPet", pet.instance)
            count = count + 1
            mult = mult + pet.rebirth
        end
    end
    return mult, count
end

---------------------------------------------------------------
--  UI-ЭЛЕМЕНТЫ ДЛЯ ВКЛАДКИ ФАРМА
---------------------------------------------------------------
local function makeSectionHeader(parent, text)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 28)
    h.BackgroundTransparency = 1
    h.Text = text
    h.TextColor3 = CONFIG.accentColor
    h.TextSize = 13
    h.Font = Enum.Font.GothamBold
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = parent
    return h
end

local function makeToggleRow(parent, labelText, initial, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(50, 26)
    track.Position = UDim2.new(1, -65, 0.5, -13)
    track.BackgroundColor3 = Color3.fromRGB(60, 65, 80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(20, 20)
    knob.Position = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = initial or false
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function apply(on, animate)
        local ti = animate and info or TweenInfo.new(0)
        if on then
            TweenService:Create(track, ti, { BackgroundColor3 = CONFIG.accentColor }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(1, -23, 0.5, -10) }):Play()
        else
            TweenService:Create(track, ti, { BackgroundColor3 = Color3.fromRGB(60, 65, 80) }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(0, 3, 0.5, -10) }):Play()
        end
    end

    apply(state, false)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseEnter:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = Color3.fromRGB(50, 58, 82) }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = Color3.fromRGB(38, 42, 58) }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.8 }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        apply(state, true)
        if callback then callback(state) end
    end)

    return {
        Set = function(on) state = on; apply(on, true); if callback then callback(on) end end,
        Get = function() return state end,
    }
end

local function makeActionRow(parent, labelText, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = color
    b.Text = labelText
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke")
    st.Color = Color3.new(1, 1, 1)
    st.Thickness = 1
    st.Transparency = 0.75
    st.Parent = b

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, info, { Size = UDim2.new(1, 4, 0, 42) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, info, { Size = UDim2.new(1, 0, 0, 42) }):Play()
    end)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

local function makeInfoLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or CONFIG.textColor
    l.TextSize = 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

---------------------------------------------------------------
--  НАПОЛНЕНИЕ ВКЛАДКИ
---------------------------------------------------------------
makeSectionHeader(scroll3, "📊 СТАТУС")

local statusLabel = makeInfoLabel(scroll3, "Status: Ожидание...", Color3.fromRGB(255, 180, 70))
local statsLabel = makeInfoLabel(scroll3, "Strength: -- | Rebirths: --", CONFIG.textColor)
local paceLabel = makeInfoLabel(scroll3, "Pace: --/s | --/min", Color3.fromRGB(150, 155, 180))

makeSectionHeader(scroll3, "🌾 СИЛА (Fast Rep)")

local repState = {
    running = false,
    maxRate = 659,
    sendRate = 200,
    tokens = 0,
    lastLoop = 0,
    lastControlAt = 0,
    lastStrength = 0,
    stalledIntervals = 0,
    sessionStart = 0,
    startStrength = 0,
}

_G.__repState = repState

local repWorker = nil
local function startRepWorker()
    if repWorker then return end
    repState.lastLoop = os.clock()
    repState.lastControlAt = tick()
    repState.lastStrength = farm.strength.Value
    repState.tokens = 0
    repState.sessionStart = tick()
    repState.startStrength = farm.strength.Value

    repWorker = task.spawn(function()
        while repState.running do
            local now = os.clock()
            local dt = math.min(0.1, now - repState.lastLoop)
            repState.lastLoop = now

            -- Автоконтроль скорости
            if tick() - repState.lastControlAt >= 0.5 then
                local progressed = farm.strength.Value > repState.lastStrength
                if progressed then
                    repState.stalledIntervals = 0
                    repState.sendRate = math.min(repState.maxRate, repState.sendRate * 1.12)
                    statusLabel.Text = ("Status: Фарм | %.0f reps/s"):format(repState.sendRate)
                    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
                else
                    repState.stalledIntervals = repState.stalledIntervals + 1
                end
                if repState.stalledIntervals >= 2 then
                    repState.sendRate = math.max(200, repState.sendRate * 0.65)
                    repState.tokens = 0
                    repState.stalledIntervals = 0
                    statusLabel.Text = ("Status: Замедляюсь | %.0f reps/s"):format(repState.sendRate)
                    statusLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
                end
                repState.lastControlAt = tick()
                repState.lastStrength = farm.strength.Value
            end

            -- Отправка reps
            repState.tokens = math.min(512, repState.tokens + repState.sendRate * dt)
            local burst = math.max(1, math.min(512, math.ceil(repState.sendRate * 0.06)))
            local count = math.min(math.floor(repState.tokens), burst)
            for _ = 1, count do
                farm.muscleEvent:FireServer("rep")
            end
            repState.tokens = repState.tokens - count

            RS.Heartbeat:Wait()
        end
        repWorker = nil
    end)
end

local function stopRep()
    repState.running = false
end

makeToggleRow(scroll3, "Fast Rep (Main)", false, function(on)
    if not farm.ready then
        statusLabel.Text = "Status: Игра не загружена"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    repState.running = on
    if on then
        startRepWorker()
        statusLabel.Text = "Status: Фарм запущен"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        stopRep()
        statusLabel.Text = "Status: Остановлено"
        statusLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
    end
end)

makeToggleRow(scroll3, "Fast Rep (для слабых ПК)", false, function(on)
    if not farm.ready then return end
    -- Упрощённая версия: простая отправка без токенов
    if on then
        repState.running = true
        task.spawn(function()
            while repState.running and repState.simpleMode do
                for _ = 1, 350 do
                    if not repState.simpleMode then break end
                    farm.muscleEvent:FireServer("rep")
                end
                task.wait(0.05)
            end
        end)
        repState.simpleMode = true
    else
        repState.simpleMode = false
        repState.running = false
    end
end)

makeSectionHeader(scroll3, "♻️ ПЕРЕРОЖДЕНИЯ (Fast Rebirth)")

local rebirthState = {
    running = false,
    startedAt = 0,
    startRebirths = 0,
    workerActive = false,
}

local function doOneRebirth()
    -- 1. Запускаем основной Fast Rep worker (если ещё не запущен)
    local wasRunning = repState.running
    if not wasRunning then
        repState.running = true
        startRepWorker()
    end

    -- 2. Ждём, пока сила дойдёт до целевого значения
    local target = 5000 + farm.rebirths.Value * 2550
    local t0 = tick()

    while rebirthState.running and farm.strength.Value < target do
        task.wait(0.1)
        -- защита от зависания: если за 60 сек сила не растёт — выходим
        if tick() - t0 > 60 and farm.strength.Value < target then
            -- продолжаем ждать, но не бесконечно
        end
    end

    if not rebirthState.running then
        -- если пользователь выключил rebirth — вернуть repState как было
        if not wasRunning then repState.running = false end
        return
    end

    -- 3. Rebirth
    local before = farm.rebirths.Value
    local t1 = tick()
    repeat
        farm.rebirthRemote:InvokeServer("rebirthRequest")
        task.wait(0.05)
    until farm.rebirths.Value > before or not rebirthState.running or tick() - t1 > 5

    -- 4. Если Fast Rep не был включён игроком — выключаем его
    if not wasRunning then
        repState.running = false
    end
end

local function startRebirthWorker()
    if rebirthState.workerActive then return end
    rebirthState.workerActive = true
    task.spawn(function()
        while rebirthState.running do
            -- 🔕 Петы теперь НЕ экипируются автоматически.
            -- Если хочешь — жми кнопку «⚡ Экипировать лучших на Rep» вручную.
            doOneRebirth()
            task.wait(0.5)
        end
        rebirthState.workerActive = false
    end)
end

makeToggleRow(scroll3, "Fast Rebirth (Auto)", false, function(on)
    if not farm.ready then
        statusLabel.Text = "Status: Игра не загружена"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    rebirthState.running = on
    if on then
        rebirthState.startedAt = tick()
        rebirthState.startRebirths = farm.rebirths.Value
        statusLabel.Text = "Status: Авто-перерождение"
        statusLabel.TextColor3 = Color3.fromRGB(180, 88, 255)
        startRebirthWorker()
    else
        statusLabel.Text = "Status: Остановлено"
        statusLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
    end
end)

makeSectionHeader(scroll3, "🐾 ПИТОМЦЫ")

makeActionRow(scroll3, "⚡ Экипировать лучших на Rep", Color3.fromRGB(50, 120, 80), function()
    if farm.ready then equipBestFarmingPets() end
end)

makeActionRow(scroll3, "♻️ Экипировать лучших на Rebirth", Color3.fromRGB(60, 90, 180), function()
    if farm.ready then equipBestRebirthPets() end
end)

makeActionRow(scroll3, "🚫 Снять всех петов", Color3.fromRGB(90, 45, 55), function()
    if farm.ready then unequipAllPets() end
end)

makeSectionHeader(scroll3, "ℹ️ ИНФО")
makeInfoLabel(scroll3, "Горячие клавиши: T — меню", Color3.fromRGB(150, 155, 180))
makeInfoLabel(scroll3, "Если не работает — проверь имена", Color3.fromRGB(150, 155, 180))
makeInfoLabel(scroll3, "сервисов в блоке farm в коде.", Color3.fromRGB(150, 155, 180))

---------------------------------------------------------------
--  АВТО-ОБНОВЛЕНИЕ СТАТИСТИКИ
---------------------------------------------------------------
task.spawn(function()
    while true do
        if farm.ready then
            statsLabel.Text = ("Strength: %s | Rebirths: %s"):format(
                tostring(math.floor(farm.strength.Value)),
                tostring(math.floor(farm.rebirths.Value))
            )

            if repState.running and repState.sessionStart > 0 then
                local elapsed = tick() - repState.sessionStart
                local gained = farm.strength.Value - repState.startStrength
                local pace = elapsed > 0 and (gained / elapsed) or 0
                paceLabel.Text = ("Pace: %.0f/s | %.0f/min | %.0f/h"):format(
                    pace, pace * 60, pace * 3600
                )
            end
        else
            statsLabel.Text = "Ожидание загрузки игры..."
        end
        task.wait(1)
    end
end)

print("[Farm Tab] Вкладка фарма загружена.")

--==============================================================
--  🖱️ ПЕРЕТАСКИВАНИЕ МЕНЮ И КНОПКИ-ОТКРЫВАШКИ
--  Вставь этот блок В КОНЕЦ существующего LocalScript
--==============================================================

local function makeDraggable(frame, dragHandle)
    -- dragHandle = за какую часть тащить (если nil — за саму frame)
    dragHandle = dragHandle or frame

    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
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
end

-- Делаем меню перетаскиваемым за заголовок
makeDraggable(mainFrame, title)

-- Делаем кнопку-открывашку перетаскиваемой
makeDraggable(toggleButton)

--==============================================================
--  🎨 ОБЩИЕ UI-ХЕЛПЕРЫ (для всех вкладок)
--==============================================================
local function makeSectionHeader(parent, text)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 28)
    h.BackgroundTransparency = 1
    h.Text = text
    h.TextColor3 = CONFIG.accentColor
    h.TextSize = 13
    h.Font = Enum.Font.GothamBold
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = parent
    return h
end

local function makeToggleRow(parent, labelText, initial, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(48, 24)
    track.Position = UDim2.new(1, -62, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(60, 65, 80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = initial or false
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function apply(on, animate)
        local ti = animate and info or TweenInfo.new(0)
        if on then
            TweenService:Create(track, ti, { BackgroundColor3 = CONFIG.accentColor }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(1, -21, 0.5, -9) }):Play()
        else
            TweenService:Create(track, ti, { BackgroundColor3 = Color3.fromRGB(60, 65, 80) }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(0, 3, 0.5, -9) }):Play()
        end
    end

    apply(state, false)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseEnter:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = Color3.fromRGB(50, 58, 82) }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = Color3.fromRGB(38, 42, 58) }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.8 }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        apply(state, true)
        if callback then callback(state) end
    end)

    return {
        Set = function(on) state = on; apply(on, true); if callback then callback(on) end end,
        Get = function() return state end,
    }
end

local function makeActionRow(parent, labelText, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = color
    b.Text = labelText
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke")
    st.Color = Color3.new(1, 1, 1)
    st.Thickness = 1
    st.Transparency = 0.75
    st.Parent = b

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, info, { Size = UDim2.new(1, 4, 0, 42) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, info, { Size = UDim2.new(1, 0, 0, 42) }):Play()
    end)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

local function makeInfoLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or CONFIG.textColor
    l.TextSize = 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

local function makeInputRow(parent, labelText, defaultText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -15, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5, -20, 0, 28)
    box.Position = UDim2.new(0.5, 5, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
    box.Text = tostring(defaultText or "")
    box.PlaceholderText = "Введи число"
    box.TextColor3 = CONFIG.textColor
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    -- 🔒 Фильтр: только цифры 0-9 (буквы, символы, эмодзи — блокируются)
    local updating = false
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if updating then return end
        updating = true
        local cleaned = box.Text:gsub("%D", "")   -- %D = всё, что не цифра
        if cleaned ~= box.Text then
            local cursor = box.CursorPosition
            box.Text = cleaned
            local newCursor = math.min(cursor - (#box.Text - #cleaned), #cleaned + 1)
            box.CursorPosition = math.max(1, newCursor)
        end
        updating = false
    end)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local v = tonumber(box.Text)
            if v and callback then callback(v) end
        end
    end)

    return box
end

--==============================================================
--  🎮 ВКЛАДКА «УТИЛИТЫ»
--==============================================================
local UIS = UserInputService
local Lighting = game:GetService("Lighting")
local Workspace = workspace

makeSectionHeader(scroll4, "👤 ПЕРСОНАЖ")

local charSettings = { Size = 2, Speed = 120, FOV = 70 }
local sizeEnabled, speedEnabled, fovEnabled = false, false, false

local changeSpeedSizeRemote = nil
task.spawn(function()
    local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents", 20)
    if rEvents then
        changeSpeedSizeRemote = rEvents:FindFirstChild("changeSpeedSizeRemote", 20)
    end
end)

makeInputRow(scroll4, "Размер (1-10)", "2", function(v)
    charSettings.Size = v
end)
makeToggleRow(scroll4, "Применить размер", false, function(on)
    sizeEnabled = on
end)

makeInputRow(scroll4, "Скорость", "120", function(v)
    charSettings.Speed = v
end)
makeToggleRow(scroll4, "Применить скорость", false, function(on)
    speedEnabled = on
end)

makeInputRow(scroll4, "FOV (1-120)", "70", function(v)
    charSettings.FOV = math.clamp(v, 1, 120)
end)
makeToggleRow(scroll4, "Применить FOV", false, function(on)
    fovEnabled = on
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = on and charSettings.FOV or 70 end
end)

task.spawn(function()
    while true do
        if changeSpeedSizeRemote then
            if sizeEnabled then
                pcall(function() changeSpeedSizeRemote:InvokeServer("changeSize", charSettings.Size) end)
            end
            if speedEnabled then
                pcall(function() changeSpeedSizeRemote:InvokeServer("changeSpeed", charSettings.Speed) end)
            end
        end
        if fovEnabled then
            local cam = Workspace.CurrentCamera
            if cam then cam.FieldOfView = charSettings.FOV end
        end
        task.wait(0.05)
    end
end)

makeSectionHeader(scroll4, "🛡️ ЗАЩИТА")

-- Anti-Fling
local antiFlingEnabled = false

local function ensureAntiFling()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not antiFlingEnabled then return end
    if hrp:FindFirstChild("AntiFlingBV") then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFlingBV"
    bv.MaxForce = Vector3.new(100000, 0, 100000)
    bv.Velocity = Vector3.zero
    bv.P = 1250
    bv.Parent = hrp
end

local function removeAntiFling()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("AntiFlingBV") then
        hrp.AntiFlingBV:Destroy()
    end
end

makeToggleRow(scroll4, "Anti-Fling", false, function(on)
    antiFlingEnabled = on
    if on then ensureAntiFling() else removeAntiFling() end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if antiFlingEnabled then ensureAntiFling() end
end)

task.spawn(function()
    while true do
        if antiFlingEnabled then ensureAntiFling() end
        task.wait(0.5)
    end
end)

-- Walk on Water
local waterParts = {}
task.spawn(function()
    local partSize = 2048
    local distance = 50000
    local startPos = Vector3.new(-2, -9.5, -2)
    for x = 0, math.ceil(distance / partSize) - 1 do
        for z = 0, math.ceil(distance / partSize) - 1 do
            for _, offset in ipairs({
                {x * partSize, z * partSize},
                {-x * partSize, z * partSize},
                {-x * partSize, -z * partSize},
                {x * partSize, -z * partSize}
            }) do
                local p = Instance.new("Part")
                p.Size = Vector3.new(partSize, 1, partSize)
                p.Position = startPos + Vector3.new(offset[1], 0, offset[2])
                p.Anchored = true
                p.Transparency = 1
                p.CanCollide = false
                p.Parent = Workspace
                table.insert(waterParts, p)
            end
        end
    end
end)

makeToggleRow(scroll4, "Walk on Water", true, function(on)
    for _, p in ipairs(waterParts) do
        if p and p.Parent then p.CanCollide = on end
    end
end):Set(true)

makeSectionHeader(scroll4, "👁️ ВИЗУАЛ")

local showPetsEvent = nil
local savePlayerSizeEvent = nil
task.spawn(function()
    local rEvents = game:GetService("ReplicatedStorage"):WaitForChild("rEvents", 20)
    if rEvents then
        showPetsEvent = rEvents:FindFirstChild("showPetsEvent", 20)
        savePlayerSizeEvent = rEvents:FindFirstChild("savePlayerSizeEvent", 20)
    end
end)

makeToggleRow(scroll4, "Hide Pets", true, function(on)
    if showPetsEvent then
        showPetsEvent:FireServer(on and "hidePets" or "showPets")
    end
end)

makeToggleRow(scroll4, "Hide Popups", true, function(on)
    if savePlayerSizeEvent then
        savePlayerSizeEvent:FireServer("showPopupsOption")
    end
end)

makeSectionHeader(scroll4, "⚡ РАЗНОЕ")

makeToggleRow(scroll4, "Infinite Jump", false, function(on)
    _G.InfiniteJump = on
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

makeActionRow(scroll4, "🌙 Ночь", Color3.fromRGB(40, 55, 100), function()
    Lighting.ClockTime = 0
end)
makeActionRow(scroll4, "☀️ День", Color3.fromRGB(120, 100, 40), function()
    Lighting.ClockTime = 12
end)

-- Fortune Wheel
local fortuneWheelRunning = false
task.spawn(function()
    while true do
        if fortuneWheelRunning then
            pcall(function()
                local rEvents = game:GetService("ReplicatedStorage"):FindFirstChild("rEvents")
                local remote = rEvents and rEvents:FindFirstChild("openFortuneWheelRemote")
                local chances = game:GetService("ReplicatedStorage").shared.catalogs.fortuneWheelChances["Fortune Wheel"]
                if remote and chances then
                    remote:InvokeServer("openFortuneWheel", chances)
                end
            end)
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

makeToggleRow(scroll4, "Spin Fortune Wheel", false, function(on)
    fortuneWheelRunning = on
end)

--==============================================================
--  ⚔️ ВКЛАДКА «PVP»
--==============================================================
--==============================================================
--  ⚔️ ВКЛАДКА «PVP» — переработанная
--==============================================================
local RunService = game:GetService("RunService")

-- Хелперы
local function isAlive(p)
    return p and p.Character
        and p.Character:FindFirstChild("HumanoidRootPart")
        and p.Character:FindFirstChildOfClass("Humanoid")
        and p.Character.Humanoid.Health > 0
end

local function isProtected(p)
    if not p or not p.Character then return false end
    if p.Character:FindFirstChildOfClass("ForceField") then return true end
    if p.Character:FindFirstChild("spawnProtectionHighlight") then return true end
    local t = p.Character:GetAttribute("SpawnProtectedUntil")
    return typeof(t) == "number" and Workspace:GetServerTimeNow() < t
end

-- Проверка Punch-тула в Backpack/StarterPack/Character
local function getPunchTool()
    local char = player.Character
    if char then
        local inChar = char:FindFirstChild("Punch")
        if inChar and inChar:IsA("Tool") then return inChar end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local inBp = bp:FindFirstChild("Punch")
        if inBp and inBp:IsA("Tool") then return inBp end
    end
    return nil
end

local function equipPunch()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    -- Уже в руках?
    local inHand = char:FindFirstChild("Punch")
    if inHand and inHand:IsA("Tool") then return inHand end

    -- Ищем в Backpack
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local tool = bp:FindFirstChild("Punch")
        if tool and tool:IsA("Tool") then
            hum:EquipTool(tool)
            return tool
        end
    end

    -- Ищем в StarterPack (для случаев, когда Backpack ещё не прогрузился)
    local sp = player:FindFirstChild("StarterPack")
    if sp then
        local tool = sp:FindFirstChild("Punch")
        if tool and tool:IsA("Tool") then
            hum:EquipTool(tool)
            return tool
        end
    end

    return nil
end

-- Удар по игроку (телепорт + firetouchinterest + FireServer)
local function hitPlayer(target)
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tgtHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not tgtHRP then return false end

    -- Проверяем Punch
    if not getPunchTool() and not myChar:FindFirstChild("Punch") then
        equipPunch()
    end

    -- Телепорт вплотную
    myHRP.CFrame = tgtHRP.CFrame * CFrame.new(0, 3, 0)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
    task.wait()

    -- Ищем руки
    local leftHand = myChar:FindFirstChild("LeftHand")
    local rightHand = myChar:FindFirstChild("RightHand")
    if not leftHand and not rightHand then return false end

    -- Touch + Fire
    pcall(function()
        if rightHand then
            firetouchinterest(tgtHRP, rightHand, 0)
            firetouchinterest(tgtHRP, rightHand, 1)
        end
        if leftHand then
            firetouchinterest(tgtHRP, leftHand, 0)
            firetouchinterest(tgtHRP, leftHand, 1)
        end
        player.muscleEvent:FireServer("punch", "leftHand")
        player.muscleEvent:FireServer("punch", "rightHand")
    end)

    return true
end

--==============================================================
--  🎯 ТОЧЕЧНАЯ АТАКА (TARGET KILL)
--==============================================================
makeSectionHeader(scroll5, "🎯 ТОЧЕЧНАЯ АТАКА")

local targetKillRunning = false
local targetKillPlayer = nil

-- Кнопка "Развернуть список"
local listExpanded = false
local expandBtn = makeActionRow(scroll5, "📜 Развернуть список игроков", Color3.fromRGB(60, 90, 180), function() end)

-- Контейнер списка игроков (создаём до самой кнопки, чтобы кнопка могла его прятать)
local playersListFrame = Instance.new("Frame")
playersListFrame.Size = UDim2.new(1, 0, 0, 0)
playersListFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
playersListFrame.BorderSizePixel = 0
playersListFrame.ClipsDescendants = true
playersListFrame.Visible = false
playersListFrame.Parent = scroll5
Instance.new("UICorner", playersListFrame).CornerRadius = UDim.new(0, 8)

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft = UDim.new(0, 6)
listPad.PaddingRight = UDim.new(0, 6)
listPad.PaddingTop = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 6)
listPad.Parent = playersListFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playersListFrame

-- Показывает выбранного
local selectedLabel = makeInfoLabel(scroll5, "🎯 Цель: не выбрана", Color3.fromRGB(255, 180, 70))

local function rebuildPlayerList()
    for _, c in ipairs(playersListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local count = 0
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            count = count + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
            b.Text = ("%s (@%s)"):format(other.DisplayName, other.Name)
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 13
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.LayoutOrder = count
            b.Parent = playersListFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(50, 58, 82)
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
            end)
            b.MouseButton1Click:Connect(function()
                targetKillPlayer = other
                selectedLabel.Text = ("🎯 Цель: %s (@%s)"):format(other.DisplayName, other.Name)
                -- Сворачиваем список после выбора
                listExpanded = false
                playersListFrame.Visible = false
                expandBtn.Text = "📜 Развернуть список игроков"
            end)
        end
    end

    if count == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 32)
        empty.BackgroundTransparency = 1
        empty.Text = "На сервере нет других игроков"
        empty.TextColor3 = Color3.fromRGB(150, 155, 180)
        empty.TextSize = 12
        empty.Font = Enum.Font.Gotham
        empty.Parent = playersListFrame
    end
end

-- Клик по кнопке «Развернуть» — сворачивает/разворачивает список
expandBtn.MouseButton1Click:Connect(function()
    listExpanded = not listExpanded
    if listExpanded then
        rebuildPlayerList()
        -- Считаем высоту: 32 (кнопка) + 4 (padding) за каждого + padding сверху/снизу
        local count = 0
        for _, c in ipairs(playersListFrame:GetChildren()) do
            if c:IsA("TextButton") or (c:IsA("TextLabel") and c.Text ~= "") then
                count = count + 1
            end
        end
        local h = math.max(36, count * 36 + 12)
        playersListFrame.Size = UDim2.new(1, 0, 0, h)
        playersListFrame.Visible = true
        expandBtn.Text = "📜 Свернуть список"
    else
        playersListFrame.Visible = false
        expandBtn.Text = "📜 Развернуть список игроков"
    end
end)

-- Обновляем список при изменении состава игроков
Players.PlayerAdded:Connect(function()
    if listExpanded then rebuildPlayerList() end
end)
Players.PlayerRemoving:Connect(function()
    if listExpanded then rebuildPlayerList() end
end)

-- Тумблер "Target Kill"
makeToggleRow(scroll5, "Target Kill (по всей карте)", false, function(on)
    targetKillRunning = on

    if on and not targetKillPlayer then
        selectedLabel.Text = "🎯 Цель: не выбрана (выбери в списке выше)"
        selectedLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    if on then
        selectedLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        task.spawn(function()
            while targetKillRunning do
                local target = targetKillPlayer
                -- Проверяем, что цель ещё в игре и жива
                if target and target.Parent and target.Character then
                    if isAlive(target) and not isProtected(target) then
                        hitPlayer(target)
                        task.wait(0.03)
                    else
                        -- Цель мертва или под защитой — ждём респавна
                        task.wait(0.2)
                    end
                else
                    -- Цель вышла из игры — вырубаем
                    if target and not target.Parent then
                        targetKillRunning = false
                        selectedLabel.Text = "🎯 Цель: вышла из игры"
                        selectedLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    end
                    task.wait(0.3)
                end
            end
            selectedLabel.Text = "🎯 Цель: не активна"
            selectedLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
        end)
    else
        selectedLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
    end
end)

makeActionRow(scroll5, "🚫 Сбросить цель", Color3.fromRGB(90, 45, 55), function()
    targetKillPlayer = nil
    targetKillRunning = false
    selectedLabel.Text = "🎯 Цель: не выбрана"
    selectedLabel.TextColor3 = Color3.fromRGB(255, 180, 70)
end)

--==============================================================
--  ⚔️ KILL AURA (радиус)
--==============================================================
makeSectionHeader(scroll5, "⚔️ KILL AURA")

local killAuraRunning = false
local killAuraRange = 30
local killAuraPlayerIndex = 1  -- индекс в списке (чтобы убивать по одному)

makeInputRow(scroll5, "Радиус", "30", function(v)
    killAuraRange = math.clamp(v, 5, 500)
end)

makeToggleRow(scroll5, "Kill Aura (в радиусе)", false, function(on)
    killAuraRunning = on
    if not on then return end

    task.spawn(function()
        while killAuraRunning do
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then task.wait(0.2); continue end

            -- Собираем игроков в радиусе
            local inRange = {}
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and isAlive(other) and not isProtected(other) then
                    local oHRP = other.Character.HumanoidRootPart
                    if (myHRP.Position - oHRP.Position).Magnitude <= killAuraRange then
                        table.insert(inRange, other)
                    end
                end
            end

            if #inRange == 0 then
                task.wait(0.3)
                continue
            end

            -- Убиваем по одному по кругу
            local target = inRange[((killAuraPlayerIndex - 1) % #inRange) + 1]
            killAuraPlayerIndex = killAuraPlayerIndex + 1

            if target and isAlive(target) then
                hitPlayer(target)
            end

            task.wait(0.03)
        end
    end)
end)

--==============================================================
--  💀 KILL EVERYONE (по всей карте)
--==============================================================
makeSectionHeader(scroll5, "💀 УБИЙСТВО ВСЕХ")

makeToggleRow(scroll5, "Kill Everyone (вся карта)", false, function(on)
    _G.KillEveryone = on
    if not on then return end

    task.spawn(function()
        local idx = 1
        while _G.KillEveryone do
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then task.wait(0.2); continue end

            local targets = {}
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and isAlive(other) and not isProtected(other) then
                    table.insert(targets, other)
                end
            end

            if #targets == 0 then
                task.wait(0.3)
                continue
            end

            -- Идём по кругу, чтобы всем досталось
            local target = targets[((idx - 1) % #targets) + 1]
            idx = idx + 1

            if target and isAlive(target) then
                hitPlayer(target)
            end

            task.wait(0.03)
        end
    end)
end)

--==============================================================
--  🤖 ВКЛАДКА «АВТО»
--==============================================================
local VIM = game:GetService("VirtualInputManager")

makeSectionHeader(scroll6, "👑 АВТО-BOSS")

-- Auto Boss (упрощённая версия — телепорт к цели и удары)
local autoBossRunning = false
makeToggleRow(scroll6, "Auto Boss (ближайший)", false, function(on)
    autoBossRunning = on
    if on then
        task.spawn(function()
            while autoBossRunning do
                pcall(function()
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local closest, closestDist = nil, math.huge
                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("Model") and string.find(d.Name:lower(), "boss", 1, true) then
                            local head = d:FindFirstChild("HumanoidRootPart") or d:FindFirstChild("Head")
                            if head then
                                local dist = (head.Position - hrp.Position).Magnitude
                                if dist < closestDist then
                                    closest, closestDist = head, dist
                                end
                            end
                        end
                    end

                    if closest then
                        hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 3, 3), closest.Position)
                        for _ = 1, 10 do
                            if not autoBossRunning then break end
                            player.muscleEvent:FireServer("punch", "leftHand")
                            player.muscleEvent:FireServer("punch", "rightHand")
                            task.wait(0.05)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

makeSectionHeader(scroll6, "🪨 АВТО-КАМНИ")

local rockData = {
    ["Tiny Rock"] = 0,
    ["Punching Rock"] = 10,
    ["Large Rock"] = 100,
    ["Golden Rock"] = 5000,
    ["Frost Rock"] = 150000,
    ["Mythical Rock"] = 400000,
    ["Eternal Rock"] = 750000,
    ["Legend Rock"] = 1000000,
    ["Muscle King Rock"] = 5000000,
    ["Jungle Rock"] = 10000000,
    ["Industrial Rock"] = 25000000,
}

local selectedRock = nil
local autoRockRunning = false

for name in pairs(rockData) do
    makeActionRow(scroll6, "🪨 " .. name, Color3.fromRGB(45, 55, 80), function()
        selectedRock = name
    end)
end

makeToggleRow(scroll6, "Auto Rock (выбранный выше)", false, function(on)
    autoRockRunning = on
    if on then
        task.spawn(function()
            while autoRockRunning do
                task.wait(0.12)
                if selectedRock and player.Character then
                    local dura = player:FindFirstChild("Durability")
                    if dura and dura.Value >= rockData[selectedRock] then
                        for _, v in pairs(Workspace.machinesFolder:GetDescendants()) do
                            if v.Name == "neededDurability" and v.Value == rockData[selectedRock] then
                                local char = player.Character
                                local rh = char:FindFirstChild("RightHand")
                                local lh = char:FindFirstChild("LeftHand")
                                local rock = v.Parent:FindFirstChild("Rock")
                                if rock and rh and lh then
                                    firetouchinterest(rock, rh, 0)
                                    firetouchinterest(rock, rh, 1)
                                    firetouchinterest(rock, lh, 0)
                                    firetouchinterest(rock, lh, 1)
                                    player.muscleEvent:FireServer("punch", "leftHand")
                                    player.muscleEvent:FireServer("punch", "rightHand")
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

makeSectionHeader(scroll6, "🏋️ АВТО-ТРЕНАЖЁРЫ")

-- Auto Squat / Lift
local machinesFolder = Workspace:WaitForChild("machinesFolder", 10)
local machineData = {
    Squat = { selected = nil, running = false, active = nil },
    Lift = { selected = nil, running = false, active = nil },
}

local squatNames, liftNames = {}, {}
if machinesFolder then
    for _, m in ipairs(machinesFolder:GetChildren()) do
        local lname = m.Name:lower()
        if string.find(lname, "squat") and lname ~= "squat rack" then
            table.insert(squatNames, m.Name)
        elseif string.find(lname, "lift") and lname ~= "deadlift" then
            table.insert(liftNames, m.Name)
        end
    end
end

local function getInteractSeat(machine)
    for _, d in ipairs(machine:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower() == "interactseat" then
            return d
        end
    end
end

local function enterMachine(machine)
    if not machine or not machine.Parent then return false end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local seat = getInteractSeat(machine)
    if not hrp or not seat then return false end

    hrp.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.4)
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    task.wait(0.4)
    return true
end

local function runMachine(data)
    data.running = true
    task.spawn(function()
        while data.running do
            if data.selected and not data.active then
                if enterMachine(data.selected) then
                    data.active = data.selected
                end
            end
            if data.active then
                pcall(function() player.muscleEvent:FireServer("rep") end)
            end
            task.wait()
        end
        data.active = nil
    end)
end

-- Squat
for _, name in ipairs(squatNames) do
    makeActionRow(scroll6, "🦵 " .. name, Color3.fromRGB(45, 55, 80), function()
        if machinesFolder then
            machineData.Squat.selected = machinesFolder:FindFirstChild(name)
        end
    end)
end
makeToggleRow(scroll6, "Auto Squat", false, function(on)
    machineData.Squat.running = on
    if on then
        machineData.Squat.active = nil
        runMachine(machineData.Squat)
    end
end)

-- Lift
for _, name in ipairs(liftNames) do
    makeActionRow(scroll6, "🏋️ " .. name, Color3.fromRGB(45, 55, 80), function()
        if machinesFolder then
            machineData.Lift.selected = machinesFolder:FindFirstChild(name)
        end
    end)
end
makeToggleRow(scroll6, "Auto Lift", false, function(on)
    machineData.Lift.running = on
    if on then
        machineData.Lift.active = nil
        runMachine(machineData.Lift)
    end
end)

--==============================================================
--  📦 ВКЛАДКА «ИНВЕНТАРЬ»
--==============================================================

makeSectionHeader(scroll7, "🥤 БУСТЕРЫ")

local eggEaterRunning = false
makeToggleRow(scroll7, "Eat All Eggs", false, function(on)
    eggEaterRunning = on
    if on then
        task.spawn(function()
            while eggEaterRunning do
                local tool = (player.Character and player.Character:FindFirstChild("Protein Egg"))
                    or player.Backpack:FindFirstChild("Protein Egg")
                if tool then
                    pcall(function() player.muscleEvent:FireServer("proteinEgg", tool) end)
                end
                task.wait(0.25)
            end
        end)
    end
end)

local boostList = {"Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar",
                   "Protein Shake", "ULTRA Shake", "Energy Bar"}
local boostRunning = false
makeToggleRow(scroll7, "Eat All Boosts (лаг)", false, function(on)
    boostRunning = on
    if on then
        task.spawn(function()
            while boostRunning do
                for _, name in ipairs(boostList) do
                    local tool = (player.Character and player.Character:FindFirstChild(name))
                        or player.Backpack:FindFirstChild(name)
                    if tool then
                        local parts = {}
                        for w in name:gmatch("%S+") do table.insert(parts, w:lower()) end
                        for i = 2, #parts do
                            parts[i] = parts[i]:sub(1,1):upper() .. parts[i]:sub(2)
                        end
                        for _ = 1, 10 do
                            pcall(function()
                                player.muscleEvent:FireServer(table.concat(parts), tool)
                            end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

makeSectionHeader(scroll7, "🐾 ПИТОМЦЫ")

local petShopRuntime = game:GetService("ReplicatedStorage"):WaitForChild("shared", 10)
if petShopRuntime then petShopRuntime = petShopRuntime:WaitForChild("runtime", 10) end
local petShopFolder = petShopRuntime and petShopRuntime:WaitForChild("cPetShopFolder", 10)
local petShopRemote = nil
task.spawn(function()
    local re = game:GetService("ReplicatedStorage"):WaitForChild("rEvents", 20)
    if re then petShopRemote = re:FindFirstChild("cPetShopRemote", 20) end
end)

local petList = {}
if petShopFolder then
    for _, item in ipairs(petShopFolder:GetChildren()) do
        if item:GetAttribute("IsPowerUp") ~= true then
            table.insert(petList, item.Name)
        end
    end
end
table.sort(petList)

local selectedPet = nil
for _, name in ipairs(petList) do
    makeActionRow(scroll7, "🐾 " .. name, Color3.fromRGB(45, 55, 80), function()
        selectedPet = name
    end)
end

local buyPetRunning = false
makeToggleRow(scroll7, "Buy Pet (выбранный)", false, function(on)
    buyPetRunning = on
    if on then
        task.spawn(function()
            while buyPetRunning do
                if selectedPet and petShopFolder and petShopRemote then
                    local pet = petShopFolder:FindFirstChild(selectedPet)
                    if pet then
                        pcall(function() petShopRemote:InvokeServer(pet) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local evolveRunning = false
makeToggleRow(scroll7, "Auto Evolve (выбранный)", false, function(on)
    evolveRunning = on
    if on then
        task.spawn(function()
            while evolveRunning do
                if selectedPet then
                    pcall(function()
                        game.ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", selectedPet)
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
end)

makeSectionHeader(scroll7, "🎁 ПОДАРКИ")

local selectedGiftPlayer = nil
local playerListHolder = Instance.new("Frame")
playerListHolder.Size = UDim2.new(1, 0, 0, 0)
playerListHolder.AutomaticSize = Enum.AutomaticSize.Y
playerListHolder.BackgroundTransparency = 1
playerListHolder.Parent = scroll7

local giftListLayout = Instance.new("UIListLayout")
giftListLayout.Padding = UDim.new(0, 4)
giftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
giftListLayout.Parent = playerListHolder

local function rebuildGiftList()
    for _, c in ipairs(playerListHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
            b.Text = other.DisplayName .. " (@" .. other.Name .. ")"
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.Parent = playerListHolder
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(function()
                selectedGiftPlayer = other
            end)
        end
    end
end
rebuildGiftList()
Players.PlayerAdded:Connect(rebuildGiftList)
Players.PlayerRemoving:Connect(rebuildGiftList)

local giftAmount = 0
makeInputRow(scroll7, "Кол-во", "0", function(v)
    giftAmount = math.max(0, math.floor(v))
end)

makeActionRow(scroll7, "🎁 Подарить Eggs", Color3.fromRGB(50, 120, 80), function()
    if not selectedGiftPlayer or giftAmount == 0 then return end
    task.spawn(function()
        for _ = 1, giftAmount do
            local egg = player:FindFirstChild("consumablesFolder")
                and player.consumablesFolder:FindFirstChild("Protein Egg")
            if not egg then break end
            pcall(function()
                game.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", selectedGiftPlayer, egg)
            end)
            task.wait(0.1)
        end
    end)
end)

makeActionRow(scroll7, "🥤 Подарить Shakes", Color3.fromRGB(50, 100, 140), function()
    if not selectedGiftPlayer or giftAmount == 0 then return end
    task.spawn(function()
        for _ = 1, giftAmount do
            local shake = player:FindFirstChild("consumablesFolder")
                and player.consumablesFolder:FindFirstChild("Tropical Shake")
            if not shake then break end
            pcall(function()
                game.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", selectedGiftPlayer, shake)
            end)
            task.wait(0.1)
        end
    end)
end)

--==============================================================
--  📊 ВКЛАДКА «СТАТЫ»
--==============================================================

local StatsTracker = {
    startTime = tick(),
    startValues = {},
    labels = {},
    leaderstats = nil,
    statDefs = {},
}

task.spawn(function()
    StatsTracker.leaderstats = player:WaitForChild("leaderstats", 20)

    local ls = StatsTracker.leaderstats
    StatsTracker.statDefs = {
        { name = "💪 Strength",   value = ls and ls:WaitForChild("Strength", 10) or nil },
        { name = "♻️ Rebirths",   value = ls and ls:WaitForChild("Rebirths", 10) or nil },
        { name = "🛡️ Durability", value = player:WaitForChild("Durability", 10) },
        { name = "☠️ Kills",      value = ls and ls:WaitForChild("Kills", 10) or nil },
        { name = "⚡ Agility",    value = player:WaitForChild("Agility", 10) },
        { name = "😈 Evil Karma", value = player:WaitForChild("evilKarma", 10) },
        { name = "😇 Good Karma", value = player:WaitForChild("goodKarma", 10) },
        { name = "🥊 Brawls",     value = ls and ls:WaitForChild("Brawls", 10) or nil },
    }

    for _, def in ipairs(StatsTracker.statDefs) do
        if def.value then
            StatsTracker.startValues[def.name] = def.value.Value
        else
            StatsTracker.startValues[def.name] = 0
        end
    end
end)

makeSectionHeader(scroll8, "⏱️ ВРЕМЯ СЕССИИ")
local timeLabel = makeInfoLabel(scroll8, "0d 0h 0m 0s", CONFIG.textColor)

task.spawn(function()
    while true do
        local e = tick() - StatsTracker.startTime
        timeLabel.Text = string.format("%dd %dh %dm %ds",
            math.floor(e / 86400),
            math.floor((e % 86400) / 3600),
            math.floor((e % 3600) / 60),
            math.floor(e % 60))
        task.wait(1)
    end
end)

makeSectionHeader(scroll8, "📊 ТВОИ СТАТЫ")

local function fmtNum(n)
    if n >= 1e18 then return string.format("%.1fQi", n / 1e18) end
    if n >= 1e15 then return string.format("%.1fQa", n / 1e15) end
    if n >= 1e12 then return string.format("%.1fT", n / 1e12) end
    if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

local function fmtCommas(n)
    local s = tostring(math.floor(n))
    while true do
        s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return s
end

task.spawn(function()
    task.wait(2)
    for _, def in ipairs(StatsTracker.statDefs) do
        StatsTracker.labels[def.name] = makeInfoLabel(scroll8, def.name .. ": --", CONFIG.textColor)
    end

    while true do
        for _, def in ipairs(StatsTracker.statDefs) do
            if def.value and StatsTracker.labels[def.name] then
                local cur = def.value.Value
                local start = StatsTracker.startValues[def.name] or cur
                local gained = cur - start
                StatsTracker.labels[def.name].Text = ("%s: %s | +%s"):format(
                    def.name, fmtNum(cur), fmtNum(gained))
            end
        end
        task.wait(1)
    end
end)

makeSectionHeader(scroll8, "🔍 ПРОСМОТР ИГРОКА")

local viewedPlayer = nil
local viewNameLabel = makeInfoLabel(scroll8, "👤 Игрок: не выбран", CONFIG.textColor)
local viewStatsLabels = {}
for _, def in ipairs(StatsTracker.statDefs) do
    viewStatsLabels[def.name] = makeInfoLabel(scroll8, def.name .. ": --", Color3.fromRGB(150, 155, 180))
end

local viewerHolder = Instance.new("Frame")
viewerHolder.Size = UDim2.new(1, 0, 0, 0)
viewerHolder.AutomaticSize = Enum.AutomaticSize.Y
viewerHolder.BackgroundTransparency = 1
viewerHolder.Parent = scroll8

local vListLayout = Instance.new("UIListLayout")
vListLayout.Padding = UDim.new(0, 4)
vListLayout.Parent = viewerHolder

local function rebuildViewerList()
    for _, c in ipairs(viewerHolder:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 28)
            b.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
            b.Text = other.DisplayName .. " (@" .. other.Name .. ")"
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.Parent = viewerHolder
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function()
                viewedPlayer = other
            end)
        end
    end
end
rebuildViewerList()
Players.PlayerAdded:Connect(rebuildViewerList)
Players.PlayerRemoving:Connect(rebuildViewerList)

task.spawn(function()
    while true do
        if viewedPlayer and viewedPlayer.Parent then
            viewNameLabel.Text = ("👤 %s (@%s)"):format(viewedPlayer.DisplayName, viewedPlayer.Name)

            local ls = viewedPlayer:FindFirstChild("leaderstats")
            local function get(parent, name)
                local v = parent and parent:FindFirstChild(name)
                return v and v.Value or 0
            end

            local map = {
                ["💪 Strength"] = get(ls, "Strength"),
                ["♻️ Rebirths"] = get(ls, "Rebirths"),
                ["🛡️ Durability"] = get(viewedPlayer, "Durability"),
                ["☠️ Kills"] = get(ls, "Kills"),
                ["⚡ Agility"] = get(viewedPlayer, "Agility"),
                ["😈 Evil Karma"] = get(viewedPlayer, "evilKarma"),
                ["😇 Good Karma"] = get(viewedPlayer, "goodKarma"),
                ["🥊 Brawls"] = get(ls, "Brawls"),
            }

            for name, value in pairs(map) do
                if viewStatsLabels[name] then
                    viewStatsLabels[name].Text = ("%s: %s (%s)"):format(name, fmtNum(value), fmtCommas(value))
                end
            end
        else
            viewNameLabel.Text = "👤 Игрок: не выбран"
        end
        task.wait(0.5)
    end
end)

print("[TeleportMenu] Готово. 8 вкладок, T — открыть меню.")

print("[TeleportMenu] Drag & Drop включён: меню — за заголовок, кнопка — за саму себя.")

--==============================================================
--  🌾 ПОЛЕ СКОРОСТИ Fast Rep (в самом конце — все хелперы готовы)
--==============================================================
task.defer(function()
    task.wait(0.2)

    local parent = scroll3

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -15, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Fast Rep: reps/s"
    lbl.TextColor3 = CONFIG.textColor
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5, -20, 0, 28)
    box.Position = UDim2.new(0.5, 5, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
    box.Text = "659"
    box.PlaceholderText = "Введи число"
    box.TextColor3 = CONFIG.textColor
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    -- 🔒 Фильтр: только цифры 0-9
    local updating = false
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if updating then return end
        updating = true
        local cleaned = box.Text:gsub("%D", "")
        if cleaned ~= box.Text then box.Text = cleaned end
        updating = false
    end)

    box.FocusLost:Connect(function(enter)
        if enter then
            local v = tonumber(box.Text)
            if v and v > 0 and _G.__repState then
                _G.__repState.maxRate = math.floor(v)
                _G.__repState.sendRate = math.min(_G.__repState.sendRate, _G.__repState.maxRate)
            end
        end
    end)
end)

print("[TeleportMenu] без ошибок.")
