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
    menuSize      = UDim2.fromOffset(460, 580),
    buttonHeight  = 46,
    buttonSpacing = 8,
}

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
mainFrame.Size = CONFIG.menuSize
mainFrame.Position = UDim2.new(0.5, -CONFIG.menuSize.X.Offset / 2,
                               0.5, -CONFIG.menuSize.Y.Offset / 2)
mainFrame.BackgroundColor3 = CONFIG.bgColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

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
tabIndicator.Size = UDim2.new(1/3, -4, 1, -6)
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

local tab1Button = makeTabButton("locations", 0)
local tab2Button = makeTabButton("my", 0)
local tab3Button = makeTabButton("farm", 0)

tab1Button.Size = UDim2.new(1/3, 0, 1, 0); tab1Button.Position = UDim2.new(0, 0, 0, 0)
tab2Button.Size = UDim2.new(1/3, 0, 1, 0); tab2Button.Position = UDim2.new(1/3, 0, 0, 0)
tab3Button.Size = UDim2.new(1/3, 0, 1, 0); tab3Button.Position = UDim2.new(2/3, 0, 0, 0)

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

local tab1Frame = Instance.new("Frame")
tab1Frame.Size = UDim2.fromScale(1, 1)
tab1Frame.BackgroundTransparency = 1
tab1Frame.Visible = true
tab1Frame.Parent = contentHolder

local tab2Frame = Instance.new("Frame")
tab2Frame.Size = UDim2.fromScale(1, 1)
tab2Frame.BackgroundTransparency = 1
tab2Frame.Visible = false
tab2Frame.Parent = contentHolder

local tab3Frame = Instance.new("Frame")
tab3Frame.Size = UDim2.fromScale(1, 1)
tab3Frame.BackgroundTransparency = 1
tab3Frame.Visible = false
tab3Frame.Parent = contentHolder

local scroll1, _ = makeScrollingList(tab1Frame)
local scroll2, _ = makeScrollingList(tab2Frame)
local scroll3, _ = makeScrollingList(tab3Frame)

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

toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
end)

toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

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

    local targetX
    if tabNum == 1 then
        targetX = UDim2.new(0, 3, 0, 3)
    elseif tabNum == 2 then
        targetX = UDim2.new(1/3, 1, 0, 3)
    else
        targetX = UDim2.new(2/3, 1, 0, 3)
    end

    TweenService:Create(tabIndicator, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetX,
    }):Play()

    local activeColor = Color3.new(1, 1, 1)
    local inactiveColor = Color3.fromRGB(160, 165, 190)

    for _, pair in ipairs({
        {tab1Button, 1}, {tab2Button, 2}, {tab3Button, 3}
    }) do
        TweenService:Create(pair[1], TweenInfo.new(0.2), {
            TextColor3 = (tabNum == pair[2]) and activeColor or inactiveColor,
        }):Play()
    end

    tab1Frame.Visible = (tabNum == 1)
    tab2Frame.Visible = (tabNum == 2)
    tab3Frame.Visible = (tabNum == 3)
    actionBar.Visible = (tabNum == 2)

    local activeFrame = (tabNum == 1) and tab1Frame or (tabNum == 2) and tab2Frame or tab3Frame
    activeFrame.Position = UDim2.new(0, (tabNum == 1) and -10 or 10, 0, 0)
    TweenService:Create(activeFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
end

tab1Button.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Button.MouseButton1Click:Connect(function() switchTab(2) end)
tab3Button.MouseButton1Click:Connect(function() switchTab(3) end)

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
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

    local tween = TweenService:Create(mainFrame,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = CONFIG.menuSize,
            Position = UDim2.new(0.5, -CONFIG.menuSize.X.Offset / 2,
                                 0.5, -CONFIG.menuSize.Y.Offset / 2),
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
            Position = UDim2.new(0.5, 0, 0.5, 0),
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
    TweenService:Create(toggleButton, TweenInfo.new(0.15), {
        Size = UDim2.fromOffset(70, 70),
        Position = UDim2.new(0, 25, 0.5, -35),
    }):Play()
end)
toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.15), {
        Size = UDim2.fromOffset(60, 60),
        Position = UDim2.new(0, 30, 0.5, -30),
    }):Play()
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
    ["Common Boss Pet"]     = { repSpeed = 3,  strength = 0,  durability = 0,  rebirth = 0 },
    ["Rare Boss Pet"]       = { repSpeed = 7, strength = 0,  durability = 0,  rebirth = 0 },
    ["Epic Boss Pet"]       = { repSpeed = 10,  strength = 5,  durability = 0,  rebirth = 0 },
    ["Rainbow Boss Pet"]    = { repSpeed = 10,  strength = 7,  durability = 0,  rebirth = 0 },
    ["Legendary Boss Pet"]  = { repSpeed = 10,  strength = 10, durability = 0,  rebirth = 0 },
    ["Mythic Boss Pet"]     = { repSpeed = 10,  strength = 20, durability = 0,  rebirth = 0 },
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

            -- Отправка
            repState.tokens = math.min(24, repState.tokens + repState.sendRate * dt)
            local burst = math.max(1, math.min(24, math.ceil(repState.sendRate * 0.05)))
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
    -- 1. Качаем силу до целевого значения
    local target = 5000 + farm.rebirths.Value * 2550
    local isPremium = player.MembershipType == Enum.MembershipType.Premium
    local burst = isPremium and 6 or 12

    while rebirthState.running and farm.strength.Value < target do
        for _ = 1, burst do
            farm.muscleEvent:FireServer("rep")
        end
        task.wait(0.02)
    end

    if not rebirthState.running then return end

    -- 2. Меняем петов на rebirth
    equipBestRebirthPets()
    task.wait(0.25)

    -- 3. Жмём перерождение
    local before = farm.rebirths.Value
    local t0 = tick()
    repeat
        farm.rebirthRemote:InvokeServer("rebirthRequest")
        task.wait(0.05)
    until farm.rebirths.Value > before or not rebirthState.running or tick() - t0 > 5
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

print("[TeleportMenu] Drag & Drop включён: меню — за заголовок, кнопка — за саму себя.")
