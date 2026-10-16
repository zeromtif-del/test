--==============================================================
--  🌌 VOID HUB — LOADER v2
--  Шаг 1: выбор скрипта → Шаг 2: выбор темы → Запуск
--==============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
--  📜 СПИСОК СКРИПТОВ — ВПИШИ СВОИ
--  name — название для отображения
--  desc — короткое описание
--  icon — эмодзи
--  url  — ссылка на raw-скрипт
--==============================================================
local SCRIPTS = {
    {
        name = "Void Hub",
        desc = "Основной хаб Muscle Legends",
        icon = "🌌",
        url  = "https://raw.githubusercontent.com/zeromtif-del/test/refs/heads/main/VoidHub/VoidHub.luau",
    },
    {
        name = "Void Hub OPTMZ",
        desc = "Здесь будет описание второго скрипта",
        icon = "⚡",
        url  = "https://raw.githubusercontent.com/zeromtif-del/test/refs/heads/main/VoidHub/VoidHubOPTMZ.luau",
    },
    {
        name = "Скрипт 3",
        desc = "Здесь будет описание третьего скрипта",
        icon = "🔥",
        url  = "https://raw.githubusercontent.com/zeromtif-del/test/refs/heads/main/VoidHub/test.lua",
    },
    -- ⬆️ ДОБАВЛЯЙ СЮДА СВОИ СКРИПТЫ
    -- { name = "...", desc = "...", icon = "💫", url = "https://..." },
}

--==============================================================
--  🎨 ТЕМЫ
--==============================================================
local THEMES = {
    crimson = {
        name = "Багровая",
        desc = "Тёмный + красный",
        bg         = Color3.fromRGB(18, 8, 12),
        panel      = Color3.fromRGB(30, 12, 18),
        card       = Color3.fromRGB(42, 18, 24),
        cardHover  = Color3.fromRGB(58, 26, 34),
        accent     = Color3.fromRGB(220, 40, 60),
        accent2    = Color3.fromRGB(255, 100, 120),
        text       = Color3.fromRGB(245, 235, 240),
        textDim    = Color3.fromRGB(170, 130, 140),
        green      = Color3.fromRGB(80, 220, 120),
        orange     = Color3.fromRGB(255, 180, 70),
        red        = Color3.fromRGB(255, 80, 90),
    },
    dark = {
        name = "Тёмная",
        desc = "Чёрный + серо-синий",
        bg         = Color3.fromRGB(12, 12, 16),
        panel      = Color3.fromRGB(22, 22, 28),
        card       = Color3.fromRGB(32, 32, 40),
        cardHover  = Color3.fromRGB(44, 44, 56),
        accent     = Color3.fromRGB(100, 110, 150),
        accent2    = Color3.fromRGB(150, 160, 200),
        text       = Color3.fromRGB(235, 235, 240),
        textDim    = Color3.fromRGB(140, 140, 155),
        green      = Color3.fromRGB(80, 220, 120),
        orange     = Color3.fromRGB(255, 180, 70),
        red        = Color3.fromRGB(255, 80, 90),
    },
    light = {
        name = "Светлая",
        desc = "Светлый + синий",
        bg         = Color3.fromRGB(240, 240, 248),
        panel      = Color3.fromRGB(225, 225, 238),
        card       = Color3.fromRGB(208, 208, 228),
        cardHover  = Color3.fromRGB(190, 190, 218),
        accent     = Color3.fromRGB(70, 100, 220),
        accent2    = Color3.fromRGB(120, 150, 255),
        text       = Color3.fromRGB(25, 25, 45),
        textDim    = Color3.fromRGB(90, 90, 120),
        green      = Color3.fromRGB(30, 170, 80),
        orange     = Color3.fromRGB(220, 130, 30),
        red        = Color3.fromRGB(210, 40, 60),
    },
    galaxy = {
        name = "Galaxy",
        desc = "Космос + фиолетовый",
        bg         = Color3.fromRGB(10, 6, 24),
        panel      = Color3.fromRGB(20, 12, 42),
        card       = Color3.fromRGB(30, 18, 58),
        cardHover  = Color3.fromRGB(45, 28, 80),
        accent     = Color3.fromRGB(140, 80, 255),
        accent2    = Color3.fromRGB(200, 130, 255),
        text       = Color3.fromRGB(240, 230, 255),
        textDim    = Color3.fromRGB(160, 140, 200),
        green      = Color3.fromRGB(120, 255, 180),
        orange     = Color3.fromRGB(255, 180, 220),
        red        = Color3.fromRGB(255, 100, 180),
    },
}

-- Настройки
local selectedScript = nil
local selectedTheme  = _G.__VH_THEME or "dark"

--==============================================================
--  УДАЛЯЕМ СТАРЫЙ ЛОАДЕР
--==============================================================
do
    local old = playerGui:FindFirstChild("VoidHubLoader")
    if old then old:Destroy() end
    local oldMain = playerGui:FindFirstChild("VoidHub")
    if oldMain then oldMain:Destroy() end
end

--==============================================================
--  SCREEN GUI
--==============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "VoidHubLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

TweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 0.35 }):Play()

--==============================================================
--  ОСНОВНОЕ ОКНО
--==============================================================
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(620, 560)
main.BackgroundColor3 = THEMES[selectedTheme].bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEMES[selectedTheme].accent
mainStroke.Thickness = 2
mainStroke.Transparency = 0.5
mainStroke.Parent = main

-- Масштаб под экран
local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = main

local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local sx = (vp.X * 0.92) / 620
    local sy = (vp.Y * 0.92) / 560
    scale.Scale = math.min(sx, sy, 1)
end
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateScale()

-- Появление
main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(620, 560),
}):Play()

--==============================================================
--  HEADER
--==============================================================
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(72, 72)
logo.Position = UDim2.new(0.5, -36, 0, 28)
logo.BackgroundColor3 = THEMES[selectedTheme].accent
logo.Text = "🌌"
logo.TextSize = 38
logo.Font = Enum.Font.GothamBold
logo.Parent = main
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 18)

local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEMES[selectedTheme].accent),
    ColorSequenceKeypoint.new(1, THEMES[selectedTheme].accent2),
})
logoGrad.Rotation = 45
logoGrad.Parent = logo

-- Пульсация
task.spawn(function()
    while logo.Parent do
        TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
            Size = UDim2.fromOffset(78, 78),
            Position = UDim2.new(0.5, -39, 0, 25),
        }):Play()
        task.wait(0.9)
        TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
            Size = UDim2.fromOffset(72, 72),
            Position = UDim2.new(0.5, -36, 0, 28),
        }):Play()
        task.wait(0.9)
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 108)
title.BackgroundTransparency = 1
title.Text = "VOID HUB"
title.TextColor3 = THEMES[selectedTheme].text
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 138)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Шаг 1 из 2 — Выбери скрипт"
subtitle.TextColor3 = THEMES[selectedTheme].textDim
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = main

--==============================================================
--  КОНТЕЙНЕР СТРАНИЦ
--==============================================================
local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, 0, 1, -290)
pagesContainer.Position = UDim2.new(0, 0, 0, 170)
pagesContainer.BackgroundTransparency = 1
pagesContainer.ClipsDescendants = true
pagesContainer.Parent = main

--==============================================================
--  СТРАНИЦА 1 — ВЫБОР СКРИПТА
--==============================================================
local page1 = Instance.new("Frame")
page1.Name = "Page1"
page1.Size = UDim2.fromScale(1, 1)
page1.BackgroundTransparency = 1
page1.Position = UDim2.new(0, 0, 0, 0)
page1.Parent = pagesContainer

local scriptsScroll = Instance.new("ScrollingFrame")
scriptsScroll.Size = UDim2.new(1, -40, 1, -20)
scriptsScroll.Position = UDim2.new(0, 20, 0, 10)
scriptsScroll.BackgroundTransparency = 1
scriptsScroll.BorderSizePixel = 0
scriptsScroll.ScrollBarThickness = 4
scriptsScroll.ScrollBarImageColor3 = THEMES[selectedTheme].accent
scriptsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scriptsScroll.Parent = page1

local scriptsLayout = Instance.new("UIListLayout")
scriptsLayout.Padding = UDim.new(0, 8)
scriptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptsLayout.Parent = scriptsScroll

local scriptCards = {}

for i, scriptData in ipairs(SCRIPTS) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, -8, 0, 70)
    card.BackgroundColor3 = THEMES[selectedTheme].card
    card.Text = ""
    card.AutoButtonColor = false
    card.LayoutOrder = i
    card.Parent = scriptsScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEMES[selectedTheme].accent
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.Parent = card

    -- Иконка
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(50, 50)
    icon.Position = UDim2.new(0, 10, 0.5, -25)
    icon.BackgroundColor3 = THEMES[selectedTheme].panel
    icon.Text = scriptData.icon or "📜"
    icon.TextSize = 26
    icon.Font = Enum.Font.GothamBold
    icon.Parent = card
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 10)

    -- Название
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -130, 0, 24)
    nameLbl.Position = UDim2.new(0, 72, 0, 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = scriptData.name or "Script"
    nameLbl.TextColor3 = THEMES[selectedTheme].text
    nameLbl.TextSize = 16
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = card

    -- Описание
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -130, 0, 18)
    descLbl.Position = UDim2.new(0, 72, 0, 36)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = scriptData.desc or ""
    descLbl.TextColor3 = THEMES[selectedTheme].textDim
    descLbl.TextSize = 12
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    descLbl.Parent = card

    -- Индикатор выбора
    local check = Instance.new("TextLabel")
    check.Size = UDim2.fromOffset(28, 28)
    check.Position = UDim2.new(1, -40, 0.5, -14)
    check.BackgroundColor3 = THEMES[selectedTheme].panel
    check.Text = ""
    check.TextSize = 18
    check.TextColor3 = Color3.new(1, 1, 1)
    check.Font = Enum.Font.GothamBold
    check.Parent = card
    Instance.new("UICorner", check).CornerRadius = UDim.new(1, 0)

    scriptCards[i] = { card = card, stroke = stroke, check = check, data = scriptData }

    card.MouseEnter:Connect(function()
        if selectedScript ~= i then
            TweenService:Create(card, TweenInfo.new(0.15), {
                BackgroundColor3 = THEMES[selectedTheme].cardHover,
            }):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if selectedScript ~= i then
            TweenService:Create(card, TweenInfo.new(0.15), {
                BackgroundColor3 = THEMES[selectedTheme].card,
            }):Play()
        end
    end)
    card.MouseButton1Click:Connect(function()
        selectedScript = i
        for idx, c in pairs(scriptCards) do
            local isSelected = (idx == i)
            TweenService:Create(c.card, TweenInfo.new(0.2), {
                BackgroundColor3 = isSelected and THEMES[selectedTheme].cardHover or THEMES[selectedTheme].card,
            }):Play()
            TweenService:Create(c.stroke, TweenInfo.new(0.2), {
                Transparency = isSelected and 0 or 0.8,
                Thickness = isSelected and 2 or 1,
            }):Play()
            TweenService:Create(c.check, TweenInfo.new(0.2), {
                BackgroundColor3 = isSelected and THEMES[selectedTheme].accent or THEMES[selectedTheme].panel,
            }):Play()
            c.check.Text = isSelected and "✓" or ""
        end

        -- Разблокируем "Далее"
        nextBtn.BackgroundColor3 = THEMES[selectedTheme].accent
        nextBtn.TextColor3 = Color3.new(1, 1, 1)
        nextBtn.AutoButtonColor = true
    end)
end

--==============================================================
--  СТРАНИЦА 2 — ВЫБОР ТЕМЫ
--==============================================================
local page2 = Instance.new("Frame")
page2.Name = "Page2"
page2.Size = UDim2.fromScale(1, 1)
page2.BackgroundTransparency = 1
page2.Position = UDim2.new(1, 0, 0, 0)   -- справа за экраном
page2.Parent = pagesContainer

local themesHolder = Instance.new("Frame")
themesHolder.Size = UDim2.new(1, -40, 0, 240)
themesHolder.Position = UDim2.new(0, 20, 0, 10)
themesHolder.BackgroundTransparency = 1
themesHolder.Parent = page2

local themesLayout = Instance.new("UIGridLayout")
themesLayout.CellSize = UDim2.new(0.5, -8, 0, 110)
themesLayout.CellPadding = UDim2.new(0, 8, 0, 8)
themesLayout.SortOrder = Enum.SortOrder.LayoutOrder
themesLayout.Parent = themesHolder

local themeCards = {}

local function refreshThemeCards()
    for key, card in pairs(themeCards) do
        local theme = THEMES[key]
        local isSelected = (key == selectedTheme)

        TweenService:Create(card.frame, TweenInfo.new(0.2), {
            BackgroundColor3 = isSelected and theme.cardHover or THEMES[selectedTheme].card,
        }):Play()
        TweenService:Create(card.stroke, TweenInfo.new(0.2), {
            Transparency = isSelected and 0 or 0.7,
            Thickness = isSelected and 2 or 1,
        }):Play()
    end
end

local themeOrder = {"dark", "crimson", "light", "galaxy"}

for idx, key in ipairs(themeOrder) do
    local theme = THEMES[key]
    if not theme then continue end

    local card = Instance.new("TextButton")
    card.BackgroundColor3 = THEMES[selectedTheme].card
    card.Text = ""
    card.AutoButtonColor = false
    card.LayoutOrder = idx
    card.Parent = themesHolder
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = card

    -- Превью
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(1, -20, 0, 40)
    preview.Position = UDim2.new(0, 10, 0, 10)
    preview.BackgroundColor3 = theme.bg
    preview.BorderSizePixel = 0
    preview.Parent = card
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

    -- 3 полоски
    for i = 1, 3 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1, -16, 0, 8)
        p.Position = UDim2.new(0, 8, 0, 4 + (i-1) * 11)
        p.BackgroundColor3 = i == 1 and theme.accent or (i == 2 and theme.accent2 or theme.textDim)
        p.BorderSizePixel = 0
        p.Parent = preview
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    end

    -- Название
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -20, 0, 18)
    nameLbl.Position = UDim2.new(0, 10, 0, 58)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = theme.name
    nameLbl.TextColor3 = THEMES[selectedTheme].text
    nameLbl.TextSize = 14
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = card

    -- Описание
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -20, 0, 14)
    descLbl.Position = UDim2.new(0, 10, 0, 76)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = theme.desc
    descLbl.TextColor3 = THEMES[selectedTheme].textDim
    descLbl.TextSize = 10
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    themeCards[key] = { frame = card, stroke = stroke, name = nameLbl, desc = descLbl }

    card.MouseEnter:Connect(function()
        if key ~= selectedTheme then
            TweenService:Create(card, TweenInfo.new(0.15), {
                BackgroundColor3 = THEMES[selectedTheme].cardHover,
            }):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if key ~= selectedTheme then
            TweenService:Create(card, TweenInfo.new(0.15), {
                BackgroundColor3 = THEMES[selectedTheme].card,
            }):Play()
        end
    end)
    card.MouseButton1Click:Connect(function()
        selectedTheme = key
        _G.__VH_THEME = key

        local t = THEMES[selectedTheme]

        -- Меняем цвета всего лоадера
        TweenService:Create(main, TweenInfo.new(0.3), { BackgroundColor3 = t.bg }):Play()
        TweenService:Create(mainStroke, TweenInfo.new(0.3), { Color = t.accent }):Play()
        TweenService:Create(logo, TweenInfo.new(0.3), { BackgroundColor3 = t.accent }):Play()
        TweenService:Create(title, TweenInfo.new(0.3), { TextColor3 = t.text }):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.3), { TextColor3 = t.textDim }):Play()
        TweenService:Create(progressBg, TweenInfo.new(0.3), { BackgroundColor3 = t.panel }):Play()
        TweenService:Create(progressFill, TweenInfo.new(0.3), { BackgroundColor3 = t.accent }):Play()
        TweenService:Create(progressText, TweenInfo.new(0.3), { TextColor3 = t.textDim }):Play()

        logoGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.accent),
            ColorSequenceKeypoint.new(1, t.accent2),
        })
        progressGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.accent),
            ColorSequenceKeypoint.new(1, t.accent2),
        })

        -- Обновляем страницы
        for _, c in pairs(scriptCards) do
            TweenService:Create(c.card, TweenInfo.new(0.2), {
                BackgroundColor3 = t.card,
            }):Play()
            TweenService:Create(c.stroke, TweenInfo.new(0.2), { Color = t.accent }):Play()
        end
        refreshThemeCards()

        -- Кнопка "Запуск"
        launchBtn.BackgroundColor3 = t.accent
        launchGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.accent),
            ColorSequenceKeypoint.new(1, t.accent2),
        })
        launchBtn.AutoButtonColor = true
        launchBtn.TextColor3 = Color3.new(1, 1, 1)
    end)
end

refreshThemeCards()

--==============================================================
--  КНОПКИ: ДАЛЕЕ + ЗАПУСК + НАЗАД
--==============================================================
-- "Далее" (внизу лоадера)
local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0.5, -25, 0, 46)
nextBtn.Position = UDim2.new(0, 20, 1, -64)
nextBtn.BackgroundColor3 = THEMES[selectedTheme].panel   -- неактивна
nextBtn.Text = "Далее ➡"
nextBtn.TextColor3 = THEMES[selectedTheme].textDim
nextBtn.TextSize = 15
nextBtn.Font = Enum.Font.GothamBold
nextBtn.AutoButtonColor = false
nextBtn.Parent = main
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 12)

-- "Запуск" (появляется на шаге 2)
local launchBtn = Instance.new("TextButton")
launchBtn.Size = UDim2.new(0.5, -25, 0, 46)
launchBtn.Position = UDim2.new(0.5, 5, 1, -64)
launchBtn.BackgroundColor3 = THEMES[selectedTheme].panel
launchBtn.Text = "🚀 Запуск"
launchBtn.TextColor3 = THEMES[selectedTheme].textDim
launchBtn.TextSize = 15
launchBtn.Font = Enum.Font.GothamBold
launchBtn.AutoButtonColor = false
launchBtn.Visible = false
launchBtn.Parent = main
Instance.new("UICorner", launchBtn).CornerRadius = UDim.new(0, 12)

local launchGrad = Instance.new("UIGradient")
launchGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEMES[selectedTheme].accent),
    ColorSequenceKeypoint.new(1, THEMES[selectedTheme].accent2),
})
launchGrad.Rotation = 45
launchGrad.Parent = launchBtn

-- "Назад" (на шаге 2)
local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0.5, -25, 0, 46)
backBtn.Position = UDim2.new(0, 20, 1, -64)
backBtn.BackgroundColor3 = THEMES[selectedTheme].panel
backBtn.Text = "⬅ Назад"
backBtn.TextColor3 = THEMES[selectedTheme].text
backBtn.TextSize = 14
backBtn.Font = Enum.Font.GothamBold
backBtn.AutoButtonColor = false
backBtn.Visible = false
backBtn.Parent = main
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 12)

--==============================================================
--  ПРОГРЕСС-БАР (появляется при запуске)
--==============================================================
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -40, 0, 8)
progressBg.Position = UDim2.new(0, 20, 1, -80)
progressBg.BackgroundColor3 = THEMES[selectedTheme].panel
progressBg.BorderSizePixel = 0
progressBg.Visible = false
progressBg.Parent = main
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = THEMES[selectedTheme].accent
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local progressGrad = Instance.new("UIGradient")
progressGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEMES[selectedTheme].accent),
    ColorSequenceKeypoint.new(1, THEMES[selectedTheme].accent2),
})
progressGrad.Parent = progressFill

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 18)
progressText.Position = UDim2.new(0, 0, 1, -100)
progressText.BackgroundTransparency = 1
progressText.Text = ""
progressText.TextColor3 = THEMES[selectedTheme].textDim
progressText.TextSize = 12
progressText.Font = Enum.Font.Gotham
progressText.Visible = false
progressText.Parent = main

--==============================================================
--  ПЕРЕХОДЫ МЕЖДУ СТРАНИЦАМИ
--==============================================================
local currentPage = 1
local transitioning = false

local function goToPage(n)
    if transitioning then return end
    if n == currentPage then return end
    transitioning = true

    if n == 2 then
        -- Скрываем page1, показываем page2
        TweenService:Create(page1, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-1, 0, 0, 0),
        }):Play()
        TweenService:Create(page2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
        }):Play()

        subtitle.Text = "Шаг 2 из 2 — Выбери тему"

        -- Скрываем "Далее", показываем "Назад" + "Запуск"
        nextBtn.Visible = false
        backBtn.Visible = true
        launchBtn.Visible = true

        currentPage = 2
    else
        -- Обратно на page1
        TweenService:Create(page1, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
        }):Play()
        TweenService:Create(page2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, 0, 0, 0),
        }):Play()

        subtitle.Text = "Шаг 1 из 2 — Выбери скрипт"

        nextBtn.Visible = true
        backBtn.Visible = false
        launchBtn.Visible = false

        currentPage = 1
    end

    task.wait(0.4)
    transitioning = false
end

--==============================================================
--  КЛИКИ
--==============================================================
nextBtn.MouseButton1Click:Connect(function()
    if not selectedScript then return end

    -- Анимация нажатия
    TweenService:Create(nextBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(0.5, -30, 0, 44),
    }):Play()
    task.wait(0.1)
    TweenService:Create(nextBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(0.5, -25, 0, 46),
    }):Play()

    goToPage(2)
end)

backBtn.MouseButton1Click:Connect(function()
    goToPage(1)
end)

nextBtn.MouseEnter:Connect(function()
    if selectedScript then
        TweenService:Create(nextBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
    end
end)
nextBtn.MouseLeave:Connect(function()
    TweenService:Create(nextBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
end)

launchBtn.MouseEnter:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
end)
launchBtn.MouseLeave:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
end)

backBtn.MouseEnter:Connect(function()
    TweenService:Create(backBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.3 }):Play()
end)
backBtn.MouseLeave:Connect(function()
    TweenService:Create(backBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
end)

--==============================================================
--  ЗАПУСК
--==============================================================
local launched = false

launchBtn.MouseButton1Click:Connect(function()
    if launched then return end
    if not selectedScript then return end

    launched = true
    launchBtn.AutoButtonColor = false

    local scriptData = SCRIPTS[selectedScript]
    local theme = THEMES[selectedTheme]

    -- Скрываем кнопки
    TweenService:Create(backBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
    TweenService:Create(launchBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
    task.wait(0.3)
    backBtn.Visible = false
    launchBtn.Visible = false

    -- Показываем прогресс
    progressBg.Visible = true
    progressText.Visible = true
    progressText.Text = ("Запускаю %s..."):format(scriptData.name)

    TweenService:Create(progressText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()

    -- Прогресс до 100
    task.spawn(function()
        for i = 1, 100 do
            TweenService:Create(progressFill, TweenInfo.new(0.03), {
                Size = UDim2.new(i / 100, 0, 1, 0),
            }):Play()
            progressText.Text = ("Загрузка... %d%%"):format(i)
            task.wait(0.015)
        end
        progressText.Text = "✅ Готово! Запускаю..."
        progressText.TextColor3 = theme.green
    end)

    task.wait(2)

    -- Исчезновение лоадера
    TweenService:Create(main, TweenInfo.new(0.4), {
        Size = UDim2.fromOffset(0, 0),
    }):Play()
    TweenService:Create(backdrop, TweenInfo.new(0.4), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.5)

    gui:Destroy()

    --==============================================================
    -- ЗАПУСК ВЫБРАННОГО СКРИПТА
    --==============================================================
    local ok, err = pcall(function()
        loadstring(game:HttpGet(scriptData.url))()
    end)

    if not ok then
        warn(("[VoidHub Loader] Ошибка загрузки '%s': %s"):format(scriptData.name, tostring(err)))
    else
        print(("[VoidHub Loader] Запущен '%s' с темой '%s'"):format(scriptData.name, theme.name))
    end
end)

--==============================================================
--  ENTER = ДАЛЕЕ (если на 1 шаге) / ЗАПУСК (если на 2)
--==============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Return then
        if currentPage == 1 and selectedScript and not transitioning then
            goToPage(2)
        elseif currentPage == 2 and not launched and not transitioning then
            launchBtn.MouseButton1Click:Fire()
        end
    end
end)

print("[VoidHub Loader] Загружено. Выбери скрипт → Далее → Тема → Запуск")
