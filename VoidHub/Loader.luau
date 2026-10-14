--==============================================================
--  🌌 VOID HUB — LOADER
--  Красивый лоадер с выбором темы перед загрузкой
--==============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
--  ТЕМЫ
--==============================================================
local THEMES = {
    crimson = {
        name = "Багровая",
        desc = "Тёмный фон + красный акцент",
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
        desc = "Почти чёрный фон + серо-синий",
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
        desc = "Светлый фон + синий акцент",
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
}

-- Тема по умолчанию (подсвечена в лоадере)
_G.__VH_THEME = _G.__VH_THEME or "dark"
local selectedTheme = _G.__VH_THEME

--==============================================================
--  LOADER GUI
--==============================================================
-- Удаляем старый лоадер, если был
do
    local old = playerGui:FindFirstChild("VoidHubLoader")
    if old then old:Destroy() end
    local oldMain = playerGui:FindFirstChild("VoidHub")
    if oldMain then oldMain:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "VoidHubLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Затемняющий фон
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

TweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 0.35 }):Play()

-- Основное окно
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(560, 460)
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
    local sx = (vp.X * 0.92) / 560
    local sy = (vp.Y * 0.92) / 460
    scale.Scale = math.min(sx, sy, 1)
end
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateScale()

-- Появление
main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(560, 460),
}):Play()

--==============================================================
--  HEADER
--==============================================================
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(72, 72)
logo.Position = UDim2.new(0.5, -36, 0, 32)
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

-- Пульсация лого
task.spawn(function()
    while logo.Parent do
        TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
            Size = UDim2.fromOffset(78, 78),
            Position = UDim2.new(0.5, -39, 0, 29),
        }):Play()
        task.wait(0.9)
        TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
            Size = UDim2.fromOffset(72, 72),
            Position = UDim2.new(0.5, -36, 0, 32),
        }):Play()
        task.wait(0.9)
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 115)
title.BackgroundTransparency = 1
title.Text = "VOID HUB"
title.TextColor3 = THEMES[selectedTheme].text
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 145)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Загрузка... Выбери тему"
subtitle.TextColor3 = THEMES[selectedTheme].textDim
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = main

--==============================================================
--  ВЫБОР ТЕМЫ
--==============================================================
local themesHolder = Instance.new("Frame")
themesHolder.Size = UDim2.new(1, -40, 0, 130)
themesHolder.Position = UDim2.new(0, 20, 0, 185)
themesHolder.BackgroundTransparency = 1
themesHolder.Parent = main

local themesLayout = Instance.new("UIListLayout")
themesLayout.FillDirection = Enum.FillDirection.Horizontal
themesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
themesLayout.SortOrder = Enum.SortOrder.LayoutOrder
themesLayout.Padding = UDim.new(0, 10)
themesLayout.Parent = themesHolder

local themeCards = {}

local function refreshThemeCards()
    for key, card in pairs(themeCards) do
        local theme = THEMES[key]
        local isSelected = (key == selectedTheme)

        TweenService:Create(card.frame, TweenInfo.new(0.2), {
            BackgroundColor3 = isSelected and theme.cardHover or theme.card,
        }):Play()
        TweenService:Create(card.stroke, TweenInfo.new(0.2), {
            Transparency = isSelected and 0 or 0.7,
            Thickness = isSelected and 2 or 1,
        }):Play()
    end
end

for key, theme in pairs(THEMES) do
    local card = Instance.new("TextButton")
    card.Size = UDim2.fromOffset(150, 130)
    card.BackgroundColor3 = theme.card
    card.Text = ""
    card.AutoButtonColor = false
    card.Parent = themesHolder
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = card

    -- Превью цвета
    local preview = Instance.new("Frame")
    preview.Size = UDim2.fromOffset(120, 46)
    preview.Position = UDim2.new(0, 15, 0, 12)
    preview.BackgroundColor3 = theme.bg
    preview.BorderSizePixel = 0
    preview.Parent = card
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

    -- 3 полоски-превью
    for i = 1, 3 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1, -16, 0, 8)
        p.Position = UDim2.new(0, 8, 0, 6 + (i-1) * 12)
        p.BackgroundColor3 = i == 1 and theme.accent or (i == 2 and theme.accent2 or theme.textDim)
        p.BorderSizePixel = 0
        p.Parent = preview
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    end

    -- Название темы
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 18)
    nameLbl.Position = UDim2.new(0, 0, 0, 68)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = theme.name
    nameLbl.TextColor3 = theme.text
    nameLbl.TextSize = 15
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.Parent = card

    -- Описание
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -14, 0, 32)
    descLbl.Position = UDim2.new(0, 7, 0, 88)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = theme.desc
    descLbl.TextColor3 = theme.textDim
    descLbl.TextSize = 10
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextWrapped = true
    descLbl.Parent = card

    themeCards[key] = { frame = card, stroke = stroke }

    card.MouseEnter:Connect(function()
        if key ~= selectedTheme then
            TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = theme.cardHover }):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if key ~= selectedTheme then
            TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = theme.card }):Play()
        end
    end)
    card.MouseButton1Click:Connect(function()
        selectedTheme = key
        _G.__VH_THEME = key

        -- Меняем цвета самого лоадера
        TweenService:Create(main, TweenInfo.new(0.3), { BackgroundColor3 = theme.bg }):Play()
        TweenService:Create(mainStroke, TweenInfo.new(0.3), { Color = theme.accent }):Play()
        TweenService:Create(logo, TweenInfo.new(0.3), { BackgroundColor3 = theme.accent }):Play()
        TweenService:Create(title, TweenInfo.new(0.3), { TextColor3 = theme.text }):Play()
        TweenService:Create(subtitle, TweenInfo.new(0.3), { TextColor3 = theme.textDim }):Play()

        logoGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.accent),
            ColorSequenceKeypoint.new(1, theme.accent2),
        })

        refreshThemeCards()
    end)
end

refreshThemeCards()

--==============================================================
--  ПРОГРЕСС-БАР
--==============================================================
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -40, 0, 8)
progressBg.Position = UDim2.new(0, 20, 0, 330)
progressBg.BackgroundColor3 = THEMES[selectedTheme].panel
progressBg.BorderSizePixel = 0
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
progressText.Size = UDim2.new(1, 0, 0, 20)
progressText.Position = UDim2.new(0, 0, 0, 348)
progressText.BackgroundTransparency = 1
progressText.Text = "Готов к запуску"
progressText.TextColor3 = THEMES[selectedTheme].textDim
progressText.TextSize = 12
progressText.Font = Enum.Font.Gotham
progressText.Parent = main

--==============================================================
--  КНОПКИ
--==============================================================
local launchBtn = Instance.new("TextButton")
launchBtn.Size = UDim2.new(1, -40, 0, 46)
launchBtn.Position = UDim2.new(0, 20, 1, -64)
launchBtn.BackgroundColor3 = THEMES[selectedTheme].accent
launchBtn.Text = "🚀  ЗАПУСТИТЬ VOID HUB"
launchBtn.TextColor3 = Color3.new(1, 1, 1)
launchBtn.TextSize = 15
launchBtn.Font = Enum.Font.GothamBold
launchBtn.AutoButtonColor = false
launchBtn.Parent = main
Instance.new("UICorner", launchBtn).CornerRadius = UDim.new(0, 12)

local launchGrad = Instance.new("UIGradient")
launchGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEMES[selectedTheme].accent),
    ColorSequenceKeypoint.new(1, THEMES[selectedTheme].accent2),
})
launchGrad.Rotation = 45
launchGrad.Parent = launchBtn

launchBtn.MouseEnter:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.15), {
        Size = UDim2.new(1, -34, 0, 48),
        Position = UDim2.new(0, 17, 1, -65),
    }):Play()
end)
launchBtn.MouseLeave:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.15), {
        Size = UDim2.new(1, -40, 0, 46),
        Position = UDim2.new(0, 20, 1, -64),
    }):Play()
end)

--==============================================================
--  ЗАПУСК
--==============================================================
local launched = false

launchBtn.MouseButton1Click:Connect(function()
    if launched then return end
    launched = true

    -- Анимация прогресса
    launchBtn.Text = "⏳  Загрузка..."
    launchBtn.AutoButtonColor = false

    local theme = THEMES[selectedTheme]
    TweenService:Create(progressFill, TweenInfo.new(0.3), {
        BackgroundColor3 = theme.accent,
    }):Play()

    -- Прогресс до 100%
    task.spawn(function()
        for i = 1, 100 do
            TweenService:Create(progressFill, TweenInfo.new(0.03), {
                Size = UDim2.new(i / 100, 0, 1, 0),
            }):Play()
            progressText.Text = ("Загрузка... %d%%"):format(i)
            task.wait(0.02)
        end
        progressText.Text = "✅ Готово! Запускаю Void Hub..."
        progressText.TextColor3 = theme.green
    end)

    -- Ждём завершения анимации и запускаем основной скрипт
    task.wait(2.2)

    -- Плавное исчезновение лоадера
    TweenService:Create(main, TweenInfo.new(0.4), {
        Size = UDim2.fromOffset(0, 0),
    }):Play()
    TweenService:Create(backdrop, TweenInfo.new(0.4), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.5)

    gui:Destroy()

    --==============================================================
    -- ЗАПУСК ОСНОВНОГО СКРИПТА
    --==============================================================
    -- ВАРИАНТ 1: Загрузка по URL (если скрипт лежит на GitHub/Pastebin)
    -- Раскомментируй и вставь свою ссылку:
    --
    local url = "https://raw.githubusercontent.com/zeromtif-del/test/refs/heads/main/VoidHub/VoidHub.luau"
    loadstring(game:HttpGet(url))()

    -- ВАРИАНТ 2: Если ты вставил этот лоадер в САМОЕ НАЧАЛО Void Hub —
    -- ничего не делай, код ниже сам продолжит работать.

    print(("[VoidHub Loader] Тема '%s' выбрана. Запускаю Void Hub..."):format(theme.name))
end)

-- Авто-запуск через Enter
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Return and not launched then
        launchBtn.MouseButton1Click:Fire()
    end
end)

print("[VoidHub Loader] Загружено. Выбери тему и нажми Запустить.")
