--==============================================================
--  VOID HUB — MUSCLE
--  Дизайн в стиле MUSCLE HUB, все вкладки слева, статы справа
--==============================================================

--==============================================================
--  🧹 АВТО-ОЧИСТКА СТАРОГО ПРОЦЕССА
--  Каждый запуск убивает предыдущую версию скрипта
--==============================================================
_G.__VH_GEN = (_G.__VH_GEN or 0) + 1
local MY_GEN = _G.__VH_GEN

do
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer

    -- 1) Уничтожаем старые ScreenGui
    local pg = plr:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui.Name == "VoidHub"
                or gui.Name == "TeleportMenuGui"
                or gui.Name == "TP_InputPrompt" then
                pcall(function() gui:Destroy() end)
            end
        end
    end

    -- 2) Отключаем старые коннекты, если они сохранены
    if _G.__VH_CONNS then
        for _, c in ipairs(_G.__VH_CONNS) do
            pcall(function() c:Disconnect() end)
        end
    end
    _G.__VH_CONNS = {}

    -- 3) Отключаем старые InputChanged / InputEnded от drag
    if _G.__VH_DRAG_CONNS then
        for _, c in ipairs(_G.__VH_DRAG_CONNS) do
            pcall(function() c:Disconnect() end)
        end
    end
    _G.__VH_DRAG_CONNS = {}

    -- 4) Сбрасываем флаги всех режимов старых скриптов
    _G.KillEveryone      = false
    _G.InfiniteJump      = false
    _G.AutoHatchPet      = false
    _G.AutoHatchAura     = false
    _G.RockFarmRunning   = false
    _G.WhitelistFriends  = false

    -- 5) Останавливаем старые машины/воркеры
    if _G.__VH_REP_STATE then
        _G.__VH_REP_STATE.running = false
        _G.__VH_REP_STATE.simpleMode = false
    end
    if _G.__VH_REBIRTH_STATE then
        _G.__VH_REBIRTH_STATE.running = false
    end
    if _G.__VH_BOSS_STATE then
        _G.__VH_BOSS_STATE.running = false
    end
    if _G.__VH_HALLOWEEN_STATE then
        _G.__VH_HALLOWEEN_STATE.running = false
        _G.__VH_HALLOWEEN_STATE.nearestMode = false
    end
    if _G.__VH_HOP_STATE then
        _G.__VH_HOP_STATE.running = false
    end
    if _G.__VH_MACHINE_DATA then
        for _, data in pairs(_G.__VH_MACHINE_DATA) do
            data.running = false
        end
    end

    -- 6) Убираем AntiFling
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("AntiFlingBV") then
        pcall(function() hrp.AntiFlingBV:Destroy() end)
    end

    -- 7) Убираем Walk on Water parts
    for _, p in ipairs(workspace:GetChildren()) do
        if p:IsA("Part") and p.Anchored and p.Transparency == 1 then
            if p.Size == Vector3.new(2048, 1, 2048) then
                pcall(function() p:Destroy() end)
            end
        end
    end

    -- 8) Возвращаем FOV
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = 70
    end

    print(("[Void Hub] Старый процесс убит. Запуск генерации #%d"):format(MY_GEN))
end
--==============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Workspace        = workspace
local VIM              = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
--  НАСТРОЙКИ
--==============================================================
--==============================================================
--  ТЕМЫ — читаем из лоадера или берём "dark" по умолчанию
--==============================================================
local THEMES = {
    crimson = {
        accent     = Color3.fromRGB(220, 40, 60),
        accent2    = Color3.fromRGB(255, 100, 120),
        bg         = Color3.fromRGB(18, 8, 12),
        panel      = Color3.fromRGB(30, 12, 18),
        card       = Color3.fromRGB(42, 18, 24),
        cardHover  = Color3.fromRGB(58, 26, 34),
        text       = Color3.fromRGB(245, 235, 240),
        textDim    = Color3.fromRGB(170, 130, 140),
        green      = Color3.fromRGB(80, 220, 120),
        orange     = Color3.fromRGB(255, 180, 70),
        red        = Color3.fromRGB(255, 80, 90),
    },
    dark = {
        accent     = Color3.fromRGB(100, 110, 150),
        accent2    = Color3.fromRGB(150, 160, 200),
        bg         = Color3.fromRGB(12, 12, 16),
        panel      = Color3.fromRGB(22, 22, 28),
        card       = Color3.fromRGB(32, 32, 40),
        cardHover  = Color3.fromRGB(44, 44, 56),
        text       = Color3.fromRGB(235, 235, 240),
        textDim    = Color3.fromRGB(140, 140, 155),
        green      = Color3.fromRGB(80, 220, 120),
        orange     = Color3.fromRGB(255, 180, 70),
        red        = Color3.fromRGB(255, 80, 90),
    },
    light = {
        accent     = Color3.fromRGB(70, 100, 220),
        accent2    = Color3.fromRGB(120, 150, 255),
        bg         = Color3.fromRGB(240, 240, 248),
        panel      = Color3.fromRGB(225, 225, 238),
        card       = Color3.fromRGB(208, 208, 228),
        cardHover  = Color3.fromRGB(190, 190, 218),
        text       = Color3.fromRGB(25, 25, 45),
        textDim    = Color3.fromRGB(90, 90, 120),
        green      = Color3.fromRGB(30, 170, 80),
        orange     = Color3.fromRGB(220, 130, 30),
        red        = Color3.fromRGB(210, 40, 60),
    },
}

-- Какая тема активна? (лоадер ставит _G.__VH_THEME, если нет — "dark")
local ACTIVE_THEME = _G.__VH_THEME or "dark"
local T = THEMES[ACTIVE_THEME] or THEMES.dark

--==============================================================
--  CONFIG — использует активную тему
--==============================================================
local CONFIG = {
    accentColor   = T.accent,
    accentColor2  = T.accent2,
    bgColor       = T.bg,
    panelColor    = T.panel,
    cardColor     = T.card,
    cardHover     = T.cardHover,
    textColor     = T.text,
    textDim       = T.textDim,
    green         = T.green,
    orange        = T.orange,
    red           = T.red,

    openKey       = Enum.KeyCode.F1,
    winSize       = Vector2.new(980, 640),

    headerH       = 64,
    sidebarW      = 200,
    rightW        = 220,
}

--==============================================================
--  🔧 ОБЩИЕ ФУНКЦИИ ДЛЯ ТРЕНАЖЁРОВ
--==============================================================
local MachineHelper = {}
do
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

    function MachineHelper.findIndustrialLift()
        local mf = workspace:FindFirstChild("machinesFolder")
        if not mf then return nil end
        local exact = mf:FindFirstChild("Industrial Bar Lift")
        if exact then return exact end
        for _, m in ipairs(mf:GetChildren()) do
            local ln = m.Name:lower()
            if string.find(ln, "industrial", 1, true)
                and string.find(ln, "bar", 1, true)
                and string.find(ln, "lift", 1, true) then
                return m
            end
        end
        for _, m in ipairs(mf:GetChildren()) do
            local ln = m.Name:lower()
            if string.find(ln, "industrial", 1, true)
                and string.find(ln, "lift", 1, true) then
                return m
            end
        end
        return nil
    end

    function MachineHelper.getInteractSeat(machine)
        for _, d in ipairs(machine:GetDescendants()) do
            if d:IsA("BasePart") and d.Name:lower() == "interactseat" then
                return d
            end
        end
    end

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
--  ЛОКАЦИИ
--==============================================================
local FIXED_LOCATIONS = {
    { name = "spawn",              position = Vector3.new(-96, 7, 234) },
    { name = "tiny island",        position = Vector3.new(-38, 4, 1884) },
    { name = "frost gym",          position = Vector3.new(-2623, 3, -409) },
    { name = "mythical gym",       position = Vector3.new(2251, 3, 1073) },
    { name = "eternal gym",        position = Vector3.new(-6763, 3, -1285) },
    { name = "legends gym",        position = Vector3.new(4597, 988, -3897) },
    { name = "muscle king gym",    position = Vector3.new(-8626, 17, -5730) },
    { name = "jungle gym",         position = Vector3.new(-8686, 7, 2392) },
    { name = "industrial gym",     position = Vector3.new(-5563, 60, 4942) },
    { name = "overcharged gym",    position = Vector3.new(-3087, 154, 4995) },
    { name = "hallowed gym",       position = Vector3.new(5538, 85, 5872) },
    { name = "2.5k strength",      position = Vector3.new(-2, 7, -246) },
    { name = "boss arena",         position = Vector3.new(-7, 16, -1267) },
    { name = "pet enchant",        position = Vector3.new(71, 15, 407) },
    { name = "secret area",        position = Vector3.new(1953, 2, 6182) },
    { name = "RIP pet glitch's",   position = Vector3.new(-493, 7, -205) },
    { name = "stand head",         position = Vector3.new(0, 90, 237) },
}

local CUSTOM_LOCATIONS = {}

--==============================================================
--  ScreenGui
--==============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Кнопка MENU
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(90, 34)
toggleButton.Position = UDim2.new(0.5, -45, 0, 14)
toggleButton.BackgroundColor3 = CONFIG.panelColor
toggleButton.Text = "MENU"
toggleButton.TextColor3 = CONFIG.textColor
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.GothamBold
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = CONFIG.accentColor
toggleStroke.Thickness = 1
toggleStroke.Transparency = 0.4
toggleStroke.Parent = toggleButton

--==============================================================
--  ГЛАВНОЕ ОКНО
--==============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(CONFIG.winSize.X, CONFIG.winSize.Y)
mainFrame.BackgroundColor3 = CONFIG.bgColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.accentColor
mainStroke.Thickness = 1
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

-- Авто-масштаб
local menuScale = Instance.new("UIScale")
menuScale.Scale = 1
menuScale.Parent = mainFrame

local function updateMenuScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local sx = (vp.X * 0.94) / CONFIG.winSize.X
    local sy = (vp.Y * 0.94) / CONFIG.winSize.Y
    local scale = math.min(sx, sy, 1)
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        scale = scale * 0.95
    end
    menuScale.Scale = scale
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMenuScale)
end
updateMenuScale()

--==============================================================
--  HEADER
--==============================================================
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, CONFIG.headerH)
header.BackgroundColor3 = CONFIG.bgColor
header.BorderSizePixel = 0
header.Parent = mainFrame

-- Лого (чёрная дыра)
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(46, 46)
logo.Position = UDim2.new(0, 18, 0.5, -23)
logo.BackgroundColor3 = CONFIG.accentColor
logo.Text = "🌌"
logo.TextSize = 24
logo.Font = Enum.Font.GothamBold
logo.Parent = header
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.accentColor),
    ColorSequenceKeypoint.new(1, CONFIG.accentColor2),
})
logoGrad.Rotation = 45
logoGrad.Parent = logo

-- Название
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 400, 0, 24)
titleLbl.Position = UDim2.new(0, 76, 0, 12)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Void Hub"
titleLbl.TextColor3 = CONFIG.textColor
titleLbl.TextSize = 20
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = header

-- Подзаголовок
local subtitleLbl = Instance.new("TextLabel")
subtitleLbl.Size = UDim2.new(0, 400, 0, 16)
subtitleLbl.Position = UDim2.new(0, 76, 0, 36)
subtitleLbl.BackgroundTransparency = 1
subtitleLbl.Text = "Muscle"
subtitleLbl.TextColor3 = CONFIG.textDim
subtitleLbl.TextSize = 12
subtitleLbl.Font = Enum.Font.Gotham
subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
subtitleLbl.Parent = header

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(34, 34)
closeBtn.Position = UDim2.new(1, -46, 0.5, -17)
closeBtn.BackgroundColor3 = CONFIG.panelColor
closeBtn.Text = "✕"
closeBtn.TextColor3 = CONFIG.red
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

--==============================================================
--  SIDEBAR (вкладки слева)
--==============================================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, CONFIG.sidebarW, 1, -CONFIG.headerH)
sidebar.Position = UDim2.new(0, 0, 0, CONFIG.headerH)
sidebar.BackgroundColor3 = CONFIG.bgColor
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarList = Instance.new("UIListLayout")
sidebarList.Padding = UDim.new(0, 4)
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.Parent = sidebar

local sidebarPad = Instance.new("UIPadding")
sidebarPad.PaddingTop = UDim.new(0, 10)
sidebarPad.PaddingLeft = UDim.new(0, 10)
sidebarPad.PaddingRight = UDim.new(0, 10)
sidebarPad.Parent = sidebar

--==============================================================
--  RIGHT PANEL (статы + быстрые действия)
--==============================================================
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0, CONFIG.rightW, 1, -CONFIG.headerH)
rightPanel.Position = UDim2.new(1, -CONFIG.rightW, 0, CONFIG.headerH)
rightPanel.BackgroundColor3 = CONFIG.bgColor
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 10)
rightList.SortOrder = Enum.SortOrder.LayoutOrder
rightList.Parent = rightPanel

local rightPad = Instance.new("UIPadding")
rightPad.PaddingTop = UDim.new(0, 10)
rightPad.PaddingLeft = UDim.new(0, 6)
rightPad.PaddingRight = UDim.new(0, 10)
rightPad.Parent = rightPanel

--==============================================================
--  CONTENT AREA
--==============================================================
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -CONFIG.sidebarW - CONFIG.rightW, 1, -CONFIG.headerH)
contentArea.Position = UDim2.new(0, CONFIG.sidebarW, 0, CONFIG.headerH)
contentArea.BackgroundColor3 = CONFIG.bgColor
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

--==============================================================
--  UI HELPERS
--==============================================================
local function makeScrollingList(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = CONFIG.accentColor
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = scroll

    return scroll, layout
end

-- Секция (заголовок с чертой)
local function makeSectionHeader(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = CONFIG.accentColor
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = CONFIG.accentColor
    line.BackgroundTransparency = 0.85
    line.BorderSizePixel = 0
    line.Parent = holder

    return holder
end

-- Toggle (переключатель)
local function makeToggleRow(parent, labelText, initial, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = CONFIG.cardColor
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(46, 24)
    track.Position = UDim2.new(1, -58, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(55, 60, 80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = initial or false
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

    local function apply(on, animate)
        local ti = animate and info or TweenInfo.new(0)
        if on then
            TweenService:Create(track, ti, { BackgroundColor3 = CONFIG.accentColor }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = Color3.new(1,1,1) }):Play()
        else
            TweenService:Create(track, ti, { BackgroundColor3 = Color3.fromRGB(55, 60, 80) }):Play()
            TweenService:Create(knob, ti, { Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(200, 200, 220) }):Play()
        end
    end
    apply(state, false)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseEnter:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = CONFIG.cardHover }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, info, { BackgroundColor3 = CONFIG.cardColor }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.85 }):Play()
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

-- Action button
local function makeActionRow(parent, labelText, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = color or CONFIG.accentColor
    b.Text = labelText
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke")
    st.Color = Color3.new(1, 1, 1)
    st.Thickness = 1
    st.Transparency = 0.8
    st.Parent = b

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, info, { BackgroundTransparency = 0.15 }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, info, { BackgroundTransparency = 0 }):Play()
    end)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

-- Info
local function makeInfoLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or CONFIG.textColor
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

-- Input
local function makeInputRow(parent, labelText, defaultText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = CONFIG.cardColor
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -15, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.5, -20, 0, 28)
    box.Position = UDim2.new(0.5, 5, 0.5, -14)
    box.BackgroundColor3 = CONFIG.bgColor
    box.Text = tostring(defaultText or "")
    box.PlaceholderText = "число"
    box.TextColor3 = CONFIG.textColor
    box.PlaceholderColor3 = CONFIG.textDim
    box.TextSize = 13
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

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
            if v and callback then callback(v) end
        end
    end)
    return box
end

--==============================================================
--  СОЗДАНИЕ 8 ВКЛАДОК
--==============================================================
local TABS = {
    { icon = "📍", name = "Локации" },
    { icon = "⭐", name = "Мои точки" },
    { icon = "⚙️", name = "Фарм" },
    { icon = "🎮", name = "Утилиты" },
    { icon = "⚔️", name = "PvP" },
    { icon = "🤖", name = "Авто" },
    { icon = "📦", name = "Инвентарь" },
    { icon = "📊", name = "Статы" },
    { icon = "🎃", name = "Halloween" },
}

local tabButtons = {}
local tabFrames = {}
local scrolls = {}
local currentTab = 1

-- Функция переключения (объявлена заранее)
local switchTab

for i, info in ipairs(TABS) do
    -- Кнопка
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = (i == 1) and CONFIG.accentColor or CONFIG.bgColor
    btn.Text = "  " .. info.icon .. "   " .. info.name
    btn.TextColor3 = (i == 1) and Color3.new(1,1,1) or CONFIG.textDim
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseEnter:Connect(function()
        if currentTab ~= i then
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.panelColor }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= i then
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.bgColor }):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if switchTab then switchTab(i) end
    end)

    tabButtons[i] = btn

    -- Фрейм контента
    local f = Instance.new("Frame")
    f.Size = UDim2.fromScale(1, 1)
    f.BackgroundTransparency = 1
    f.Visible = (i == 1)
    f.Parent = contentArea
    tabFrames[i] = f
    scrolls[i] = makeScrollingList(f)
end

-- Псевдонимы
local scroll1, scroll2, scroll3 = scrolls[1], scrolls[2], scrolls[3]
local scroll4, scroll5, scroll6 = scrolls[4], scrolls[5], scrolls[6]
local scroll7, scroll8, scroll9 = scrolls[7], scrolls[8], scrolls[9]

-- Switch function
switchTab = function(idx)
    if idx == currentTab then return end
    currentTab = idx

    for i, b in ipairs(tabButtons) do
        local isActive = (i == idx)
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = isActive and CONFIG.accentColor or CONFIG.bgColor,
            TextColor3 = isActive and Color3.new(1,1,1) or CONFIG.textDim,
        }):Play()
    end

    for i, f in ipairs(tabFrames) do
        f.Visible = (i == idx)
    end
end
_G.__switchTab = switchTab

--==============================================================
--  📍 ВКЛАДКА 1 — ЛОКАЦИИ
--==============================================================
makeSectionHeader(scroll1, "📍 Предустановленные локации")

local function createTeleportButton(data, parentScroll, order, allowDelete, indexRef)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = CONFIG.cardColor
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = parentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.Parent = btn

    local marker = Instance.new("Frame")
    marker.Size = UDim2.fromOffset(6, 6)
    marker.Position = UDim2.new(0, 14, 0.5, -3)
    marker.BackgroundColor3 = CONFIG.accentColor
    marker.BorderSizePixel = 0
    marker.Parent = btn
    Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 28, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.name
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn

    if allowDelete then
        local del = Instance.new("TextButton")
        del.Size = UDim2.fromOffset(26, 26)
        del.Position = UDim2.new(1, -32, 0.5, -13)
        del.BackgroundColor3 = Color3.fromRGB(80, 35, 45)
        del.Text = "✕"
        del.TextColor3 = CONFIG.red
        del.TextSize = 13
        del.Font = Enum.Font.GothamBold
        del.ZIndex = 5
        del.Parent = btn
        Instance.new("UICorner", del).CornerRadius = UDim.new(1, 0)

        del.MouseButton1Click:Connect(function()
            table.remove(CUSTOM_LOCATIONS, indexRef)
            if _G.__RebuildTab2 then _G.__RebuildTab2() end
        end)
    end

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, info, { BackgroundColor3 = CONFIG.cardHover }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, info, { BackgroundColor3 = CONFIG.cardColor }):Play()
        TweenService:Create(stroke, info, { Transparency = 0.85 }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char then
            char:PivotTo(CFrame.new(data.position))
        end
    end)

    return btn
end

local function clearList(scroll)
    for _, ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
end

local function rebuildTab1()
    clearList(scroll1)
    for i, data in ipairs(FIXED_LOCATIONS) do
        createTeleportButton(data, scroll1, i + 10, false)
    end
end

local function rebuildTab2()
    clearList(scroll2)
    for i, data in ipairs(CUSTOM_LOCATIONS) do
        createTeleportButton(data, scroll2, i + 10, true, i)
    end
end

_G.__RebuildTab2 = rebuildTab2

rebuildTab1()
rebuildTab2()

--==============================================================
--  ⭐ ВКЛАДКА 2 — МОИ ТОЧКИ
--==============================================================
makeSectionHeader(scroll2, "⭐ Мои точки")

local addBtn = makeActionRow(scroll2, "➕ Добавить текущую позицию", Color3.fromRGB(50, 120, 80), function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    table.insert(CUSTOM_LOCATIONS, {
        name = "Точка " .. (#CUSTOM_LOCATIONS + 1),
        position = hrp.Position,
    })
    rebuildTab2()
end)

local clearBtn = makeActionRow(scroll2, "🗑 Очистить все точки", Color3.fromRGB(120, 50, 60), function()
    CUSTOM_LOCATIONS = {}
    rebuildTab2()
end)

--==============================================================
--  ⚙️ ВКЛАДКА 3 — ФАРМ
--==============================================================
local RS = game:GetService("RunService")

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

    local rEvents = ReplicatedStorage:WaitForChild("rEvents", 20)
    if rEvents then
        farm.equipPetEvent = rEvents:WaitForChild("equipPetEvent", 20)
        farm.rebirthRemote = rEvents:WaitForChild("rebirthRemote", 20)
    end

    if farm.muscleEvent and farm.strength and farm.rebirths then
        farm.ready = true
        print("[Farm] Сервисы загружены.")
    end
end)

local PETS = {
    ["Omega Overlord"]      = { repSpeed = 20, strength = 0,  durability = 0,  rebirth = 0 },
    ["Swift Samurai"]       = { repSpeed = 15, strength = 0,  durability = 0,  rebirth = 0 },
    ["Powercore Hound"]     = { repSpeed = 0,  strength = 25, durability = 15, rebirth = 0 },
    ["Titanium Hydra"]      = { repSpeed = 0,  strength = 0,  durability = 0,  rebirth = 2 },
    ["Tribal Overlord"]     = { repSpeed = 0,  strength = 0,  durability = 0,  rebirth = 2 },
    ["Inferno Unicorn"]     = { repSpeed = 0,  strength = 25, durability = 25, rebirth = 0 },
    ["Inferno Drake"]       = { repSpeed = 40, strength = 0,  durability = 0,  rebirth = 0 },
    ["Common Boss Pet"]     = { repSpeed = 5,  strength = 0,  durability = 0,  rebirth = 0 },
    ["Rare Boss Pet"]       = { repSpeed = 7,  strength = 0,  durability = 0,  rebirth = 0 },
    ["Epic Boss Pet"]       = { repSpeed = 10, strength = 0,  durability = 0,  rebirth = 0 },
    ["Rainbow Boss Pet"]    = { repSpeed = 10, strength = 7,  durability = 0,  rebirth = 0 },
    ["Legendary Boss Pet"]  = { repSpeed = 10, strength = 10, durability = 0,  rebirth = 0 },
    ["Mythic Boss Pet"]     = { repSpeed = 10, strength = 25, durability = 0,  rebirth = 0 },
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
                        instance = pet, name = pet.Name,
                        repSpeed = cfg.repSpeed or 0, strength = cfg.strength or 0,
                        durability = cfg.durability or 0, rebirth = cfg.rebirth or 0,
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
            equipped[pet.instance] = true; count = count + 1; repSpeed = repSpeed + pet.repSpeed
        end
    end
    local rest = {}
    for _, pet in ipairs(pets) do if not equipped[pet.instance] then table.insert(rest, pet) end end
    table.sort(rest, function(a, b) return (a.strength + a.durability) > (b.strength + b.durability) end)
    for _, pet in ipairs(rest) do
        if count >= MAX_PET_SLOTS then break end
        if pet.strength > 0 or pet.durability > 0 then
            farm.equipPetEvent:FireServer("equipPet", pet.instance); count = count + 1
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
            count = count + 1; mult = mult + pet.rebirth
        end
    end
    return mult, count
end

-- Farm UI
makeSectionHeader(scroll3, "📊 Статус")

local statusLabel = makeInfoLabel(scroll3, "Status: Ожидание...", CONFIG.orange)
local statsLabel = makeInfoLabel(scroll3, "Strength: -- | Rebirths: --", CONFIG.textColor)

makeSectionHeader(scroll3, "🌾 Fast Rep")

local repState = {
    running = false, maxRate = 659, sendRate = 200,
    tokens = 0, lastLoop = 0, lastControlAt = 0, lastStrength = 0,
    stalledIntervals = 0, sessionStart = 0, startStrength = 0,
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
        while repState.running and _G.__VH_GEN == MY_GEN do
            local now = os.clock()
            local dt = math.min(0.1, now - repState.lastLoop)
            repState.lastLoop = now

            if tick() - repState.lastControlAt >= 0.5 then
                local progressed = farm.strength.Value > repState.lastStrength
                if progressed then
                    repState.stalledIntervals = 0
                    repState.sendRate = math.min(repState.maxRate, repState.sendRate * 1.12)
                    statusLabel.Text = ("Status: Фарм | %.0f reps/s"):format(repState.sendRate)
                    statusLabel.TextColor3 = CONFIG.green
                else
                    repState.stalledIntervals = repState.stalledIntervals + 1
                end
                if repState.stalledIntervals >= 2 then
                    repState.sendRate = math.max(200, repState.sendRate * 0.65)
                    repState.tokens = 0
                    repState.stalledIntervals = 0
                    statusLabel.Text = ("Status: Замедляюсь | %.0f reps/s"):format(repState.sendRate)
                    statusLabel.TextColor3 = CONFIG.orange
                end
                repState.lastControlAt = tick()
                repState.lastStrength = farm.strength.Value
            end

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

makeInputRow(scroll3, "Fast Rep: reps/s", "659", function(v)
    if v and v > 0 then
        repState.maxRate = math.floor(v)
        repState.sendRate = math.min(repState.sendRate, repState.maxRate)
    end
end)

makeToggleRow(scroll3, "Fast Rep (Main)", false, function(on)
    if not farm.ready then
        statusLabel.Text = "Status: Игра не загружена"
        statusLabel.TextColor3 = CONFIG.red
        return
    end
    repState.running = on
    if on then
        startRepWorker()
        statusLabel.Text = "Status: Фарм запущен"
        statusLabel.TextColor3 = CONFIG.green
    else
        repState.running = false
        statusLabel.Text = "Status: Остановлено"
        statusLabel.TextColor3 = CONFIG.orange
    end
end)

makeToggleRow(scroll3, "Fast Rep (для слабых ПК)", false, function(on)
    if not farm.ready then return end
    if on then
        repState.simpleMode = true
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
    else
        repState.simpleMode = false
        repState.running = false
    end
end)

makeSectionHeader(scroll3, "♻️ Fast Rebirth")

local rebirthState = { running = false, workerActive = false }

_G.__VH_REBIRTH_STATE = rebirthState

local function doOneRebirth()
    local wasRunning = repState.running
    if not wasRunning then
        repState.running = true
        startRepWorker()
    end

    local target = 5000 + farm.rebirths.Value * 2550
    while rebirthState.running and farm.strength.Value < target do
        task.wait(0.1)
    end

    if not rebirthState.running then
        if not wasRunning then repState.running = false end
        return
    end

    local before = farm.rebirths.Value
    local t1 = tick()
    repeat
        farm.rebirthRemote:InvokeServer("rebirthRequest")
        task.wait(0.05)
    until farm.rebirths.Value > before or not rebirthState.running or tick() - t1 > 5

    if not wasRunning then repState.running = false end
end

local function startRebirthWorker()
    if rebirthState.workerActive then return end
    rebirthState.workerActive = true
    task.spawn(function()
        while rebirthState.running and _G.__VH_GEN == MY_GEN do
            doOneRebirth()
            task.wait(0.5)
        end
        rebirthState.workerActive = false
    end)
end

makeToggleRow(scroll3, "Fast Rebirth (Auto)", false, function(on)
    if not farm.ready then
        statusLabel.Text = "Status: Игра не загружена"
        statusLabel.TextColor3 = CONFIG.red
        return
    end
    rebirthState.running = on
    if on then
        statusLabel.Text = "Status: Авто-перерождение"
        statusLabel.TextColor3 = CONFIG.accentColor2
        startRebirthWorker()
    else
        statusLabel.Text = "Status: Остановлено"
        statusLabel.TextColor3 = CONFIG.orange
    end
end)

makeSectionHeader(scroll3, "🐾 Питомцы")

makeActionRow(scroll3, "⚡ Экипировать лучших на Rep", Color3.fromRGB(50, 120, 80), function()
    if farm.ready then equipBestFarmingPets() end
end)
makeActionRow(scroll3, "♻️ Экипировать лучших на Rebirth", Color3.fromRGB(60, 90, 180), function()
    if farm.ready then equipBestRebirthPets() end
end)
makeActionRow(scroll3, "🚫 Снять всех петов", Color3.fromRGB(90, 45, 55), function()
    if farm.ready then unequipAllPets() end
end)

-- Farm stats update
task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
        if farm.ready then
            statsLabel.Text = ("Strength: %s | Rebirths: %s"):format(
                tostring(math.floor(farm.strength.Value)),
                tostring(math.floor(farm.rebirths.Value))
            )
        else
            statsLabel.Text = "Ожидание загрузки игры..."
        end
        task.wait(1)
    end
end)

--==============================================================
--  🎮 ВКЛАДКА 4 — УТИЛИТЫ
--==============================================================
makeSectionHeader(scroll4, "👤 Персонаж")

local charSettings = { Size = 2, Speed = 120, FOV = 70 }
local sizeEnabled, speedEnabled, fovEnabled = false, false, false

local changeSpeedSizeRemote = nil
task.spawn(function()
    local rEvents = ReplicatedStorage:WaitForChild("rEvents", 20)
    if rEvents then changeSpeedSizeRemote = rEvents:FindFirstChild("changeSpeedSizeRemote", 20) end
end)

makeInputRow(scroll4, "Размер (1-10)", "2", function(v) charSettings.Size = v end)
makeToggleRow(scroll4, "Применить размер", false, function(on) sizeEnabled = on end)

makeInputRow(scroll4, "Скорость", "120", function(v) charSettings.Speed = v end)
makeToggleRow(scroll4, "Применить скорость", false, function(on) speedEnabled = on end)

makeInputRow(scroll4, "FOV (1-120)", "70", function(v) charSettings.FOV = math.clamp(v, 1, 120) end)
makeToggleRow(scroll4, "Применить FOV", false, function(on)
    fovEnabled = on
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = on and charSettings.FOV or 70 end
end)

task.spawn(function()
    while true do
        if changeSpeedSizeRemote then
            if sizeEnabled then pcall(function() changeSpeedSizeRemote:InvokeServer("changeSize", charSettings.Size) end) end
            if speedEnabled then pcall(function() changeSpeedSizeRemote:InvokeServer("changeSpeed", charSettings.Speed) end) end
        end
        if fovEnabled then
            local cam = Workspace.CurrentCamera
            if cam then cam.FieldOfView = charSettings.FOV end
        end
        task.wait(0.05)
    end
end)

makeSectionHeader(scroll4, "🛡️ Защита")

local antiFlingEnabled = false
local function ensureAntiFling()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not antiFlingEnabled then return end
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
    if hrp and hrp:FindFirstChild("AntiFlingBV") then hrp.AntiFlingBV:Destroy() end
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

makeSectionHeader(scroll4, "👁️ Визуал")

local showPetsEvent, savePlayerSizeEvent = nil, nil
task.spawn(function()
    local rEvents = ReplicatedStorage:WaitForChild("rEvents", 20)
    if rEvents then
        showPetsEvent = rEvents:FindFirstChild("showPetsEvent", 20)
        savePlayerSizeEvent = rEvents:FindFirstChild("savePlayerSizeEvent", 20)
    end
end)

makeToggleRow(scroll4, "Hide Pets", true, function(on)
    if showPetsEvent then showPetsEvent:FireServer(on and "hidePets" or "showPets") end
end)
makeToggleRow(scroll4, "Hide Popups", true, function(on)
    if savePlayerSizeEvent then savePlayerSizeEvent:FireServer("showPopupsOption") end
end)

makeSectionHeader(scroll4, "⚡ Разное")

makeToggleRow(scroll4, "Infinite Jump", false, function(on) _G.InfiniteJump = on end)
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

makeActionRow(scroll4, "🌙 Ночь", Color3.fromRGB(40, 55, 100), function() Lighting.ClockTime = 0 end)
makeActionRow(scroll4, "☀️ День", Color3.fromRGB(120, 100, 40), function() Lighting.ClockTime = 12 end)

local fortuneWheelRunning = false
task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
    if fortuneWheelRunning then
            pcall(function()
                local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
                local remote = rEvents and rEvents:FindFirstChild("openFortuneWheelRemote")
                local chances = ReplicatedStorage.shared.catalogs.fortuneWheelChances["Fortune Wheel"]
                if remote and chances then remote:InvokeServer("openFortuneWheel", chances) end
            end)
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)
makeToggleRow(scroll4, "Spin Fortune Wheel", false, function(on) fortuneWheelRunning = on end)

--==============================================================
--  ⚔️ ВКЛАДКА 5 — PVP
--==============================================================
local function isAlive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0
end

local function isProtected(p)
    if not p or not p.Character then return false end
    if p.Character:FindFirstChildOfClass("ForceField") then return true end
    if p.Character:FindFirstChild("spawnProtectionHighlight") then return true end
    local t = p.Character:GetAttribute("SpawnProtectedUntil")
    return typeof(t) == "number" and Workspace:GetServerTimeNow() < t
end

---------------------------------------------------------------
-- Whitelist
---------------------------------------------------------------
local whitelisted = {}

local function isWhitelisted(p)
    if not p then return false end
    for _, name in ipairs(whitelisted) do
        if name:lower() == p.Name:lower() then return true end
    end
    return false
end

local function addToWhitelist(p)
    if not p then return end
    if isWhitelisted(p) then return end
    table.insert(whitelisted, p.Name)
end

local function removeFromWhitelist(name)
    for i = #whitelisted, 1, -1 do
        if whitelisted[i]:lower() == name:lower() then
            table.remove(whitelisted, i)
        end
    end
end

local function getPunchTool()
    local char = player.Character
    if char then
        local t = char:FindFirstChild("Punch")
        if t and t:IsA("Tool") then return t end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local t = bp:FindFirstChild("Punch")
        if t and t:IsA("Tool") then return t end
    end
end

local function equipPunch()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local inHand = char:FindFirstChild("Punch")
    if inHand then return inHand end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local tool = bp:FindFirstChild("Punch")
        if tool then hum:EquipTool(tool) return tool end
    end
    local sp = player:FindFirstChild("StarterPack")
    if sp then
        local tool = sp:FindFirstChild("Punch")
        if tool then hum:EquipTool(tool) return tool end
    end
end

local function hitPlayer(target)
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tgtHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not tgtHRP then return end

    if not getPunchTool() and not myChar:FindFirstChild("Punch") then
        equipPunch()
    end

    myHRP.CFrame = tgtHRP.CFrame * CFrame.new(0, 3, 0)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
    task.wait()

    local lh = myChar:FindFirstChild("LeftHand")
    local rh = myChar:FindFirstChild("RightHand")
    if not lh and not rh then return end

    pcall(function()
        if rh then firetouchinterest(tgtHRP, rh, 0); firetouchinterest(tgtHRP, rh, 1) end
        if lh then firetouchinterest(tgtHRP, lh, 0); firetouchinterest(tgtHRP, lh, 1) end
        player.muscleEvent:FireServer("punch", "leftHand")
        player.muscleEvent:FireServer("punch", "rightHand")
    end)
end

makeSectionHeader(scroll5, "🎯 Точечная атака")

local targetKillRunning = false
local targetKillPlayer = nil
local listExpanded = false

local expandBtn = makeActionRow(scroll5, "📜 Развернуть список игроков", Color3.fromRGB(60, 90, 180), function() end)

local playersListFrame = Instance.new("Frame")
playersListFrame.Size = UDim2.new(1, 0, 0, 0)
playersListFrame.BackgroundColor3 = CONFIG.panelColor
playersListFrame.BorderSizePixel = 0
playersListFrame.ClipsDescendants = true
playersListFrame.Visible = false
playersListFrame.Parent = scroll5
Instance.new("UICorner", playersListFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = playersListFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft = UDim.new(0, 6); listPad.PaddingRight = UDim.new(0, 6)
listPad.PaddingTop = UDim.new(0, 6); listPad.PaddingBottom = UDim.new(0, 6)
listPad.Parent = playersListFrame

local selectedLabel = makeInfoLabel(scroll5, "🎯 Цель: не выбрана", CONFIG.orange)

local function rebuildPlayerList()
    for _, c in ipairs(playersListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            count = count + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = CONFIG.cardColor
            b.Text = ("%s (@%s)"):format(other.DisplayName, other.Name)
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.Parent = playersListFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseEnter:Connect(function() b.BackgroundColor3 = CONFIG.cardHover end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = CONFIG.cardColor end)
            b.MouseButton1Click:Connect(function()
                targetKillPlayer = other
                selectedLabel.Text = ("🎯 Цель: %s (@%s)"):format(other.DisplayName, other.Name)
                listExpanded = false
                playersListFrame.Visible = false
                expandBtn.Text = "📜 Развернуть список игроков"
            end)
        end
    end
end

expandBtn.MouseButton1Click:Connect(function()
    listExpanded = not listExpanded
    if listExpanded then
        rebuildPlayerList()
        local count = 0
        for _, c in ipairs(playersListFrame:GetChildren()) do
            if c:IsA("TextButton") then count = count + 1 end
        end
        playersListFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 34 + 12))
        playersListFrame.Visible = true
        expandBtn.Text = "📜 Свернуть список"
    else
        playersListFrame.Visible = false
        expandBtn.Text = "📜 Развернуть список игроков"
    end
end)

Players.PlayerAdded:Connect(function() if listExpanded then rebuildPlayerList() end end)
Players.PlayerRemoving:Connect(function() if listExpanded then rebuildPlayerList() end end)

makeToggleRow(scroll5, "Target Kill (по всей карте)", false, function(on)
    targetKillRunning = on
    if on and not targetKillPlayer then
        selectedLabel.Text = "🎯 Цель: не выбрана"
        selectedLabel.TextColor3 = CONFIG.red
        return
    end
    if on then
        selectedLabel.TextColor3 = CONFIG.green
        task.spawn(function()
            while targetKillRunning and _G.__VH_GEN == MY_GEN do
                local t = targetKillPlayer
                if t and t.Parent and t.Character then
                    if isAlive(t) and not isProtected(t) and not isWhitelisted(t) then
                        hitPlayer(t)
                        task.wait(0.03)
                    else
                        task.wait(0.2)
                    end
                else
                    if t and not t.Parent then
                        targetKillRunning = false
                        selectedLabel.Text = "🎯 Цель: вышла из игры"
                        selectedLabel.TextColor3 = CONFIG.red
                    end
                    task.wait(0.3)
                end
            end
        end)
    end
end)

makeActionRow(scroll5, "🚫 Сбросить цель", Color3.fromRGB(90, 45, 55), function()
    targetKillPlayer = nil
    targetKillRunning = false
    selectedLabel.Text = "🎯 Цель: не выбрана"
    selectedLabel.TextColor3 = CONFIG.orange
end)

makeSectionHeader(scroll5, "⚔️ Kill Aura")

local killAuraRunning = false
local killAuraRange = 30
local killAuraPlayerIndex = 1

makeInputRow(scroll5, "Радиус", "30", function(v) killAuraRange = math.clamp(v, 5, 500) end)

makeToggleRow(scroll5, "Kill Aura (в радиусе)", false, function(on)
    killAuraRunning = on
    if not on then return end
    task.spawn(function()
        while killAuraRunning and _G.__VH_GEN == MY_GEN do
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then task.wait(0.2); continue end
            local inRange = {}
for _, other in ipairs(Players:GetPlayers()) do
    if other ~= player and isAlive(other) and not isProtected(other) and not isWhitelisted(other) then
        local oHRP = other.Character.HumanoidRootPart
        if (myHRP.Position - oHRP.Position).Magnitude <= killAuraRange then
            table.insert(inRange, other)
        end
    end
end
            if #inRange == 0 then task.wait(0.3); continue end
            local target = inRange[((killAuraPlayerIndex - 1) % #inRange) + 1]
            killAuraPlayerIndex = killAuraPlayerIndex + 1
            if target and isAlive(target) then hitPlayer(target) end
            task.wait(0.03)
        end
    end)
end)

makeSectionHeader(scroll5, "💀 Убийство всех")

makeToggleRow(scroll5, "Kill Everyone", false, function(on)
    _G.KillEveryone = on
    if not on then return end
    task.spawn(function()
        local idx = 1
        while _G.KillEveryone and _G.__VH_GEN == MY_GEN do
            local targets = {}
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and isAlive(other) and not isProtected(other) then
                    table.insert(targets, other)
                end
            end
            if #targets == 0 then task.wait(0.3); continue end
            local target = targets[((idx - 1) % #targets) + 1]
            idx = idx + 1
            if target and isAlive(target) then hitPlayer(target) end
            task.wait(0.03)
        end
    end)
end)

--==============================================================
--  🤖 ВКЛАДКА 6 — АВТО
--==============================================================
--==============================================================
--  👑 AUTO BOSS — полная версия
--==============================================================
makeSectionHeader(scroll6, "👑 Auto Boss")

local bossData = {
    running = false,
    autoChest = false,
    lockedBoss = nil,
}

_G.__VH_BOSS_STATE = bossData

---------------------------------------------------------------
-- Папка BossArena
---------------------------------------------------------------
local function getBossArena()
    local ev = workspace:FindFirstChild("Events")
    if not ev then return nil end
    return ev:FindFirstChild("BossArena")
end

---------------------------------------------------------------
-- Проверка: это живой босс с "Boss" в имени?
---------------------------------------------------------------
local function isAliveBoss(d)
    if not d or not d.Parent or not d:IsA("Model") then return false end
    if not string.find(d.Name:lower(), "boss", 1, true) then return false end

    local part = d:FindFirstChild("HumanoidRootPart")
        or d:FindFirstChildWhichIsA("BasePart", true)
    if not part then return false end

    local hum = d:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end

    local hp = d:GetAttribute("Health")
    if type(hp) == "number" then return hp > 0 end

    return true
end

---------------------------------------------------------------
-- Поиск ближайшего босса
---------------------------------------------------------------
local function findBoss()
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local best, bestDist = nil, math.huge

    local function scan(root)
        for _, d in ipairs(root:GetChildren()) do
            if isAliveBoss(d) then
                local part = d:FindFirstChild("HumanoidRootPart")
                    or d:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local dist = (part.Position - myHRP.Position).Magnitude
                    if dist < bestDist then
                        best, bestDist = d, dist
                    end
                end
            end
        end
    end

    local arena = getBossArena()
    if arena then scan(arena) end
    if not best then scan(workspace) end

    return best
end

---------------------------------------------------------------
-- Удар по боссу
---------------------------------------------------------------
local function attackBoss(boss)
    if not boss or not boss.Parent then return end

    local part = boss:FindFirstChild("HumanoidRootPart")
        or boss:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end

    local hum = boss:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    -- Авто-экип Punch
    if not myChar:FindFirstChild("Punch") then
        local bp = player:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChild("Punch")
        if tool then
            local mh = myChar:FindFirstChildOfClass("Humanoid")
            if mh then pcall(function() mh:EquipTool(tool) end) end
        end
    end

    -- Телепорт вплотную
    myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0), part.Position)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero

    -- Удары
    pcall(function()
        local lh = myChar:FindFirstChild("LeftHand")
        local rh = myChar:FindFirstChild("RightHand")
        if lh then
            firetouchinterest(part, lh, 0)
            firetouchinterest(part, lh, 1)
        end
        if rh then
            firetouchinterest(part, rh, 0)
            firetouchinterest(part, rh, 1)
        end
        player.muscleEvent:FireServer("punch", "leftHand")
        player.muscleEvent:FireServer("punch", "rightHand")
    end)
end

---------------------------------------------------------------
-- Сбор сундуков
---------------------------------------------------------------
local function collectChest()
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Model") then
            local name = d.Name:lower()
            if string.find(name, "chest", 1, true)
                or string.find(name, "reward", 1, true)
                or string.find(name, "loot", 1, true) then
                local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                if part then
                    myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.05)
                    pcall(function()
                        firetouchinterest(part, myHRP, 0)
                        firetouchinterest(part, myHRP, 1)
                    end)
                end
            end
        end
    end
end

---------------------------------------------------------------
-- UI + воркер
---------------------------------------------------------------
local bossStatus = makeInfoLabel(scroll6, "Босс: —", CONFIG.textDim)

makeToggleRow(scroll6, "Auto Boss", false, function(on)
    bossData.running = on

    if on then
        bossData.lockedBoss = nil

        -- Воркер
        task.spawn(function()
            while bossData.running do
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if not myHRP then
                    task.wait(0.2)
                    continue
                end

                local boss = bossData.lockedBoss

                if not isAliveBoss(boss) then
                    bossData.lockedBoss = nil
                    boss = findBoss()
                    if boss then
                        bossData.lockedBoss = boss
                        print("[AutoBoss] Новый босс:", boss:GetFullName())
                    end
                end

                if boss and isAliveBoss(boss) then
                    for _ = 1, 20 do
                        if not bossData.running then break end
                        if not isAliveBoss(boss) then break end
                        attackBoss(boss)
                        task.wait(0.02)
                    end
                else
                    task.wait(0.3)
                end

                task.wait(0.02)
            end
        end)

        -- Обновление статуса
        task.spawn(function()
            while bossData.running and _G.__VH_GEN == MY_GEN do
                if bossData.lockedBoss and bossData.lockedBoss.Parent then
                    local hum = bossData.lockedBoss:FindFirstChildOfClass("Humanoid")
                    local hp = hum and hum.Health or 0
                    bossStatus.Text = ("🎯 %s (HP %d)"):format(
                        bossData.lockedBoss.Name, math.floor(hp))
                    bossStatus.TextColor3 = CONFIG.green
                else
                    local arena = getBossArena()
                    local count = 0
                    if arena then
                        for _, d in ipairs(arena:GetChildren()) do
                            if isAliveBoss(d) then count = count + 1 end
                        end
                    end
                    bossStatus.Text = ("Босс: — (в BossArena: %d)"):format(count)
                    bossStatus.TextColor3 = CONFIG.textDim
                end
                task.wait(0.5)
            end
            bossStatus.Text = "Босс: —"
            bossStatus.TextColor3 = CONFIG.textDim
        end)
    else
        bossData.lockedBoss = nil
    end
end)

makeToggleRow(scroll6, "Auto Collect Chest", false, function(on)
    bossData.autoChest = on
    if on then
        task.spawn(function()
            while bossData.autoChest do
                pcall(collectChest)
                task.wait(0.5)
            end
        end)
    end
end)

makeSectionHeader(scroll6, "🪨 Auto Rock")

local rockData = {
    ["Tiny Rock"] = 0, ["Punching Rock"] = 10, ["Large Rock"] = 100,
    ["Golden Rock"] = 5000, ["Frost Rock"] = 150000, ["Mythical Rock"] = 400000,
    ["Eternal Rock"] = 750000, ["Legend Rock"] = 1000000, ["Muscle King Rock"] = 5000000,
    ["Jungle Rock"] = 10000000, ["Industrial Rock"] = 25000000,
}

local selectedRock = nil
local autoRockRunning = false

for name in pairs(rockData) do
    makeActionRow(scroll6, "🪨 " .. name, CONFIG.cardColor, function() selectedRock = name end)
end

makeToggleRow(scroll6, "Auto Rock", false, function(on)
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
                                    firetouchinterest(rock, rh, 0); firetouchinterest(rock, rh, 1)
                                    firetouchinterest(rock, lh, 0); firetouchinterest(rock, lh, 1)
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

makeSectionHeader(scroll6, "🏋️ Auto Тренажёры")

local machinesFolder = Workspace:WaitForChild("machinesFolder", 10)
local machineData = {
    Squat = { selected = nil, running = false, active = nil },
    Lift = { selected = nil, running = false, active = nil },
}

_G.__VH_MACHINE_DATA = machineData

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

local function runMachine(data)
    data.running = true
    task.spawn(function()
        while data.running and _G.__VH_GEN == MY_GEN do
            if data.selected and not data.active then
                if MachineHelper.enter(data.selected) then
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

for _, name in ipairs(squatNames) do
    makeActionRow(scroll6, "🦵 " .. name, CONFIG.cardColor, function()
        if machinesFolder then machineData.Squat.selected = machinesFolder:FindFirstChild(name) end
    end)
end
makeToggleRow(scroll6, "Auto Squat", false, function(on)
    machineData.Squat.running = on
    if on then machineData.Squat.active = nil; runMachine(machineData.Squat) end
end)

for _, name in ipairs(liftNames) do
    makeActionRow(scroll6, "🏋️ " .. name, CONFIG.cardColor, function()
        if machinesFolder then machineData.Lift.selected = machinesFolder:FindFirstChild(name) end
    end)
end
makeToggleRow(scroll6, "Auto Lift", false, function(on)
    machineData.Lift.running = on
    if on then machineData.Lift.active = nil; runMachine(machineData.Lift) end
end)

--==============================================================
--  📦 ВКЛАДКА 7 — ИНВЕНТАРЬ
--==============================================================
makeSectionHeader(scroll7, "🥤 Бустеры")

local eggEaterRunning = false
makeToggleRow(scroll7, "Eat All Eggs", false, function(on)
    eggEaterRunning = on
    if on then
        task.spawn(function()
            while eggEaterRunning and _G.__VH_GEN == MY_GEN do
                local tool = (player.Character and player.Character:FindFirstChild("Protein Egg"))
                    or player.Backpack:FindFirstChild("Protein Egg")
                if tool then pcall(function() player.muscleEvent:FireServer("proteinEgg", tool) end) end
                task.wait(0.25)
            end
        end)
    end
end)

local boostList = {"Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar"}
local boostRunning = false
makeToggleRow(scroll7, "Eat All Boosts (лаг)", false, function(on)
    boostRunning = on
    if on then
        task.spawn(function()
            while boostRunning and _G.__VH_GEN == MY_GEN do
                for _, name in ipairs(boostList) do
                    local tool = (player.Character and player.Character:FindFirstChild(name))
                        or player.Backpack:FindFirstChild(name)
                    if tool then
                        local parts = {}
                        for w in name:gmatch("%S+") do table.insert(parts, w:lower()) end
                        for i = 2, #parts do parts[i] = parts[i]:sub(1,1):upper() .. parts[i]:sub(2) end
                        for _ = 1, 10 do
                            pcall(function() player.muscleEvent:FireServer(table.concat(parts), tool) end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

makeSectionHeader(scroll7, "🐾 Питомцы (магазин)")

local petShopRuntime = ReplicatedStorage:WaitForChild("shared", 10)
if petShopRuntime then petShopRuntime = petShopRuntime:WaitForChild("runtime", 10) end
local petShopFolder = petShopRuntime and petShopRuntime:WaitForChild("cPetShopFolder", 10)
local petShopRemote = nil
task.spawn(function()
    local re = ReplicatedStorage:WaitForChild("rEvents", 20)
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
    makeActionRow(scroll7, "🐾 " .. name, CONFIG.cardColor, function() selectedPet = name end)
end

local buyPetRunning = false
makeToggleRow(scroll7, "Buy Pet", false, function(on)
    buyPetRunning = on
    if on then
        task.spawn(function()
            while buyPetRunning and _G.__VH_GEN == MY_GEN do
                if selectedPet and petShopFolder and petShopRemote then
                    local pet = petShopFolder:FindFirstChild(selectedPet)
                    if pet then pcall(function() petShopRemote:InvokeServer(pet) end) end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local evolveRunning = false
makeToggleRow(scroll7, "Auto Evolve", false, function(on)
    evolveRunning = on
    if on then
        task.spawn(function()
            while evolveRunning and _G.__VH_GEN == MY_GEN do
                if selectedPet then
                    pcall(function()
                        ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", selectedPet)
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
end)

--==============================================================
--  📊 ВКЛАДКА 8 — СТАТЫ
--==============================================================
local StatsTracker = {
    startTime = tick(), startValues = {}, labels = {}, statDefs = {},
}

task.spawn(function()
    local ls = player:WaitForChild("leaderstats", 20)
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
        StatsTracker.startValues[def.name] = def.value and def.value.Value or 0
    end
end)

makeSectionHeader(scroll8, "⏱️ Время сессии")
local timeLabel = makeInfoLabel(scroll8, "0d 0h 0m 0s", CONFIG.textColor)

task.spawn(function()
    while true do
        local e = tick() - StatsTracker.startTime
        timeLabel.Text = string.format("%dd %dh %dm %ds",
            math.floor(e / 86400), math.floor((e % 86400) / 3600),
            math.floor((e % 3600) / 60), math.floor(e % 60))
        task.wait(1)
    end
end)

makeSectionHeader(scroll8, "📊 Твои статы")

local function fmtNum(n)
    if n >= 1e18 then return string.format("%.1fQi", n / 1e18) end
    if n >= 1e15 then return string.format("%.1fQa", n / 1e15) end
    if n >= 1e12 then return string.format("%.1fT", n / 1e12) end
    if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
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
                StatsTracker.labels[def.name].Text = ("%s: %s | +%s"):format(def.name, fmtNum(cur), fmtNum(gained))
            end
        end
        task.wait(1)
    end
end)

--==============================================================
--  RIGHT PANEL — статистика + быстрые действия
--==============================================================
local statsCard = Instance.new("Frame")
statsCard.Size = UDim2.new(1, 0, 0, 150)
statsCard.BackgroundColor3 = CONFIG.panelColor
statsCard.BorderSizePixel = 0
statsCard.Parent = rightPanel
Instance.new("UICorner", statsCard).CornerRadius = UDim.new(0, 12)

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 26)
statsTitle.Position = UDim2.new(0, 12, 0, 6)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "📊 Статистика"
statsTitle.TextColor3 = CONFIG.textColor
statsTitle.TextSize = 13
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsCard

local statsHolder = Instance.new("Frame")
statsHolder.Size = UDim2.new(1, -12, 1, -40)
statsHolder.Position = UDim2.new(0, 6, 0, 34)
statsHolder.BackgroundTransparency = 1
statsHolder.Parent = statsCard

local sl = Instance.new("UIListLayout")
sl.Padding = UDim.new(0, 4)
sl.Parent = statsHolder

local function makeStatRow(icon, label, color)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.Parent = statsHolder

    local i = Instance.new("TextLabel")
    i.Size = UDim2.fromOffset(22, 22)
    i.Position = UDim2.new(0, 4, 0, 0)
    i.BackgroundTransparency = 1
    i.Text = icon
    i.TextColor3 = CONFIG.accentColor
    i.TextSize = 13
    i.Font = Enum.Font.GothamBold
    i.Parent = row

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, -28, 1, 0)
    l.Position = UDim2.new(0, 30, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = CONFIG.textDim
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = row

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0.5, -8, 1, 0)
    v.Position = UDim2.new(0.5, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "—"
    v.TextColor3 = color or CONFIG.accentColor2
    v.TextSize = 13
    v.Font = Enum.Font.GothamBold
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Parent = row

    return v
end

local statStrength = makeStatRow("💪", "Сила", CONFIG.accentColor2)
local statRebirths = makeStatRow("♻️", "Rebirths", CONFIG.accentColor2)
local statDurability = makeStatRow("🛡️", "Durability", CONFIG.accentColor2)
local statKills = makeStatRow("☠️", "Убийства", CONFIG.red)

-- Quick actions
local quickCard = Instance.new("Frame")
quickCard.Size = UDim2.new(1, 0, 0, 80)
quickCard.BackgroundColor3 = CONFIG.panelColor
quickCard.BorderSizePixel = 0
quickCard.Parent = rightPanel
Instance.new("UICorner", quickCard).CornerRadius = UDim.new(0, 12)

local quickTitle = Instance.new("TextLabel")
quickTitle.Size = UDim2.new(1, -20, 0, 26)
quickTitle.Position = UDim2.new(0, 12, 0, 6)
quickTitle.BackgroundTransparency = 1
quickTitle.Text = "⚡ Быстрые действия"
quickTitle.TextColor3 = CONFIG.textColor
quickTitle.TextSize = 13
quickTitle.Font = Enum.Font.GothamBold
quickTitle.TextXAlignment = Enum.TextXAlignment.Left
quickTitle.Parent = quickCard

local teleportQuickBtn = Instance.new("TextButton")
teleportQuickBtn.Size = UDim2.new(1, -20, 0, 34)
teleportQuickBtn.Position = UDim2.new(0, 10, 0, 38)
teleportQuickBtn.BackgroundColor3 = CONFIG.cardColor
teleportQuickBtn.Text = "📍  Телепорт"
teleportQuickBtn.TextColor3 = CONFIG.textColor
teleportQuickBtn.TextSize = 13
teleportQuickBtn.Font = Enum.Font.GothamBold
teleportQuickBtn.AutoButtonColor = false
teleportQuickBtn.Parent = quickCard
Instance.new("UICorner", teleportQuickBtn).CornerRadius = UDim.new(0, 8)

local tqStroke = Instance.new("UIStroke")
tqStroke.Color = CONFIG.accentColor
tqStroke.Thickness = 1
tqStroke.Transparency = 0.7
tqStroke.Parent = teleportQuickBtn

teleportQuickBtn.MouseEnter:Connect(function()
    TweenService:Create(teleportQuickBtn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.cardHover }):Play()
end)
teleportQuickBtn.MouseLeave:Connect(function()
    TweenService:Create(teleportQuickBtn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.cardColor }):Play()
end)
teleportQuickBtn.MouseButton1Click:Connect(function()
    switchTab(1)
end)

-- Обновление статов
task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
        pcall(function()
            local ls = player:FindFirstChild("leaderstats")
            local str = ls and ls:FindFirstChild("Strength")
            local reb = ls and ls:FindFirstChild("Rebirths")
            local kills = ls and ls:FindFirstChild("Kills")
            local dura = player:FindFirstChild("Durability")

            statStrength.Text = str and fmtNum(str.Value) or "—"
            statRebirths.Text = reb and fmtNum(reb.Value) or "—"
            statDurability.Text = dura and fmtNum(dura.Value) or "—"
            statKills.Text = kills and fmtNum(kills.Value) or "—"
        end)
        task.wait(1)
    end
end)

--==============================================================
--  ОТКРЫТИЕ / ЗАКРЫТИЕ
--==============================================================
local isOpen = false
local isAnimating = false

local function openMenu()
    if isOpen or isAnimating then return end
    isAnimating = true
    isOpen = true

    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0)

    local tween = TweenService:Create(mainFrame,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(CONFIG.winSize.X, CONFIG.winSize.Y) })
    tween:Play()
    tween.Completed:Wait()
    isAnimating = false

    TweenService:Create(toggleButton, TweenInfo.new(0.2), { BackgroundColor3 = CONFIG.accentColor }):Play()
end

local function closeMenu()
    if not isOpen or isAnimating then return end
    isAnimating = true
    isOpen = false

    local tween = TweenService:Create(mainFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 0, 0) })
    tween:Play()
    tween.Completed:Wait()
    mainFrame.Visible = false
    isAnimating = false

    TweenService:Create(toggleButton, TweenInfo.new(0.2), { BackgroundColor3 = CONFIG.panelColor }):Play()
end

local function toggleMenu()
    if isOpen then closeMenu() else openMenu() end
end

-- Умный клик по MENU (без срабатывания при перетаскивании)
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
        if moved < 6 then toggleMenu() end
        clickStart = nil
    end
end)

closeBtn.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.openKey then toggleMenu() end
end)

--==============================================================
--  ПЕРЕТАСКИВАНИЕ
--==============================================================
local function makeDraggable(frame, dragHandle)
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

makeDraggable(mainFrame, header)
makeDraggable(toggleButton)

print("[Void Hub] Загружено. Клавиша меню: F1")

--==============================================================
--  🎃 ВКЛАДКА «HALLOWEEN BOSS»
--==============================================================
task.defer(function()
    task.wait(0.3)

    -------------------------------------------------------------
    -- ✏️ СЮДА ВПИШИ НУЖНЫЕ ИМЕНА БОССОВ
    -- Если оставить пустым — скрипт сам найдёт всех,
    -- у кого в имени есть "halloween" или кто сидит в папке "Halloween"
    -------------------------------------------------------------
    local HALLOWEEN_BOSSES = {
        "Pumpkin Titan",
        "Grim Reaper",
        "Scarecrow Colossus",
        "Frankenbrute",
        -- и так далее...
    }

    -------------------------------------------------------------
    -- Состояние
    -------------------------------------------------------------
    local halloween = {
        running = false,
        lockedBoss = nil,
        selectedName = nil,
        listExpanded = false,
    }

_G.__VH_HALLOWEEN_STATE = halloween

    -------------------------------------------------------------
    -- Проверки
    -------------------------------------------------------------
    local function getBossPart(model)
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChildWhichIsA("BasePart", true)
    end

    local function isAliveModel(m)
        if not m or not m.Parent or not m:IsA("Model") then return false end
        if m == player.Character then return false end
        if Players:GetPlayerFromCharacter(m) then return false end

        local part = getBossPart(m)
        if not part then return false end

        local hum = m:FindFirstChildOfClass("Humanoid")
        if hum then return hum.Health > 0 end

        local hp = m:GetAttribute("Health")
        if type(hp) == "number" then return hp > 0 end

        return true
    end

    -------------------------------------------------------------
    -- Проверка "это Halloween-босс?"
    -------------------------------------------------------------
    local function isHalloweenBoss(m)
        if not isAliveModel(m) then return false end
        local name = m.Name

        -- 1) Точное совпадение из списка
        for _, bossName in ipairs(HALLOWEEN_BOSSES) do
            if name == bossName then return true end
        end

        -- 2) Если список не задан — ищем по ключевым словам
        if #HALLOWEEN_BOSSES == 0 then
            local lower = name:lower()
            if string.find(lower, "halloween", 1, true) then return true end
            if string.find(lower, "pumpkin", 1, true) then return true end
            if string.find(lower, "witch", 1, true) then return true end
            if string.find(lower, "candy", 1, true) then return true end

            -- 3) Или сидит в папке с "halloween" / "event" в имени
            local cur = m.Parent
            local depth = 0
            while cur and cur ~= workspace and depth < 5 do
                local pn = cur.Name:lower()
                if string.find(pn, "halloween", 1, true) then return true end
                cur = cur.Parent
                depth = depth + 1
            end
        end

        return false
    end

    -------------------------------------------------------------
    -- Собрать список живых Halloween-боссов
    -------------------------------------------------------------
    local function scanHalloweenBosses()
        local list = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if isHalloweenBoss(d) then
                table.insert(list, d)
            end
        end
        return list
    end

    -------------------------------------------------------------
    -- Найти ближайшего из списка
    -------------------------------------------------------------
    local function findNearest(list)
        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end

        local best, bestDist = nil, math.huge
        for _, m in ipairs(list) do
            local part = getBossPart(m)
            if part then
                local d = (part.Position - myHRP.Position).Magnitude
                if d < bestDist then
                    best, bestDist = m, d
                end
            end
        end
        return best
    end

    -------------------------------------------------------------
    -- Найти конкретного босса по имени
    -------------------------------------------------------------
    local function findByName(name)
        if not name then return nil end
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Model") and d.Name == name and isAliveModel(d) then
                return d
            end
        end
        return nil
    end

    -------------------------------------------------------------
    -- Атака
    -------------------------------------------------------------
    local function attackBoss(boss)
        if not boss or not boss.Parent then return end
        local part = getBossPart(boss)
        if not part then return end

        local hum = boss:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return end

        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        -- Auto-экип Punch
        if not myChar:FindFirstChild("Punch") then
            local bp = player:FindFirstChild("Backpack")
            local tool = bp and bp:FindFirstChild("Punch")
            if tool then
                local mh = myChar:FindFirstChildOfClass("Humanoid")
                if mh then pcall(function() mh:EquipTool(tool) end) end
            end
        end

        -- Телепорт вплотную
        myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0), part.Position)
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero

        -- Удары
        pcall(function()
            local lh = myChar:FindFirstChild("LeftHand")
            local rh = myChar:FindFirstChild("RightHand")
            if lh then
                firetouchinterest(part, lh, 0)
                firetouchinterest(part, lh, 1)
            end
            if rh then
                firetouchinterest(part, rh, 0)
                firetouchinterest(part, rh, 1)
            end
            player.muscleEvent:FireServer("punch", "leftHand")
            player.muscleEvent:FireServer("punch", "rightHand")
        end)
    end

    -------------------------------------------------------------
    -- UI
    -------------------------------------------------------------
    makeSectionHeader(scroll9, "🎃 Halloween Boss")

    local halloweenStatus = makeInfoLabel(scroll9, "Статус: ожидание", CONFIG.textDim)
    local selectedBossLabel = makeInfoLabel(scroll9, "🎯 Цель: не выбрана", CONFIG.orange)
    local countLabel = makeInfoLabel(scroll9, "Найдено боссов: 0", CONFIG.textDim)

    -------------------------------------------------------------
    -- Разворачиваемый список боссов
    -------------------------------------------------------------
    local expandBtn = makeActionRow(scroll9, "📜 Развернуть список боссов", Color3.fromRGB(60, 90, 180), function() end)

    -- Контейнер списка
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.BackgroundColor3 = CONFIG.panelColor
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible = false
    listFrame.Parent = scroll9
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listFrame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingLeft = UDim.new(0, 6)
    listPad.PaddingRight = UDim.new(0, 6)
    listPad.PaddingTop = UDim.new(0, 6)
    listPad.PaddingBottom = UDim.new(0, 6)
    listPad.Parent = listFrame

    local function rebuildList()
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then
                c:Destroy()
            end
        end

        local bosses = scanHalloweenBosses()
        countLabel.Text = ("Найдено боссов: %d"):format(#bosses)

        if #bosses == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "Боссов пока нет на карте"
            empty.TextColor3 = CONFIG.textDim
            empty.TextSize = 12
            empty.Font = Enum.Font.Gotham
            empty.Parent = listFrame
            return
        end

        for _, boss in ipairs(bosses) do
            local hum = boss:FindFirstChildOfClass("Humanoid")
            local hp = hum and math.floor(hum.Health) or 0

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = CONFIG.cardColor
            b.Text = ("%s   (HP %d)"):format(boss.Name, hp)
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.Parent = listFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = CONFIG.cardHover
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = CONFIG.cardColor
            end)
            b.MouseButton1Click:Connect(function()
                halloween.selectedName = boss.Name
                selectedBossLabel.Text = ("🎯 Цель: %s"):format(boss.Name)
                selectedBossLabel.TextColor3 = CONFIG.green

                -- Сворачиваем список
                halloween.listExpanded = false
                listFrame.Visible = false
                expandBtn.Text = "📜 Развернуть список боссов"
            end)
        end
    end

    expandBtn.MouseButton1Click:Connect(function()
        halloween.listExpanded = not halloween.listExpanded
        if halloween.listExpanded then
            rebuildList()
            -- Высота: 36 за каждого + padding
            local count = 0
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then
                    count = count + 1
                end
            end
            listFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 36 + 12))
            listFrame.Visible = true
            expandBtn.Text = "📜 Свернуть список"
        else
            listFrame.Visible = false
            expandBtn.Text = "📜 Развернуть список боссов"
        end
    end)

    -- Авто-обновление списка (если развёрнут)
    task.spawn(function()
        while true do
            task.wait(2)
            if halloween.listExpanded then
                rebuildList()
                local count = 0
                for _, c in ipairs(listFrame:GetChildren()) do
                    if c:IsA("TextButton") or c:IsA("TextLabel") then
                        count = count + 1
                    end
                end
                listFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 36 + 12))
            else
                -- Обновляем счётчик
                local bosses = scanHalloweenBosses()
                countLabel.Text = ("Найдено боссов: %d"):format(#bosses)
            end
        end
    end)

    -------------------------------------------------------------
    -- Тумблеры
    -------------------------------------------------------------
    makeToggleRow(scroll9, "Атаковать выбранного", false, function(on)
        if on and not halloween.selectedName then
            selectedBossLabel.Text = "🎯 Цель: не выбрана"
            selectedBossLabel.TextColor3 = CONFIG.red
            halloweenStatus.Text = "Статус: выбери босса в списке"
            halloweenStatus.TextColor3 = CONFIG.red
            return
        end

        halloween.running = on
        if not on then
            halloweenStatus.Text = "Статус: остановлено"
            halloweenStatus.TextColor3 = CONFIG.orange
            return
        end

        halloweenStatus.Text = "Статус: атака..."
        halloweenStatus.TextColor3 = CONFIG.green

        task.spawn(function()
            while halloween.running and _G.__VH_GEN == MY_GEN do
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then task.wait(0.2); continue end

                local boss = halloween.lockedBoss

                -- Перепроверяем босса
                if not isAliveModel(boss) or (boss and boss.Name ~= halloween.selectedName) then
                    halloween.lockedBoss = nil
                    boss = findByName(halloween.selectedName)
                    if boss then
                        halloween.lockedBoss = boss
                    end
                end

                if boss and isAliveModel(boss) then
                    for _ = 1, 20 do
                        if not halloween.running then break end
                        if not isAliveModel(boss) then break end
                        attackBoss(boss)
                        task.wait(0.02)
                    end
                else
                    task.wait(0.3)
                end

                task.wait(0.02)
            end
        end)
    end)

    makeToggleRow(scroll9, "Атаковать ближайшего (Halloween)", false, function(on)
        halloween.nearestMode = on
        if not on then return end

        halloweenStatus.Text = "Статус: ищу ближайшего..."
        halloweenStatus.TextColor3 = CONFIG.green

        task.spawn(function()
            while halloween.nearestMode and _G.__VH_GEN == MY_GEN do
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then task.wait(0.2); continue end

                local bosses = scanHalloweenBosses()
                local boss = findNearest(bosses)

                if boss then
                    selectedBossLabel.Text = ("🎯 Ближайший: %s"):format(boss.Name)
                    selectedBossLabel.TextColor3 = CONFIG.green

                    for _ = 1, 20 do
                        if not halloween.nearestMode then break end
                        if not isAliveModel(boss) then break end
                        attackBoss(boss)
                        task.wait(0.02)
                    end
                else
                    halloweenStatus.Text = "Статус: боссов нет"
                    halloweenStatus.TextColor3 = CONFIG.textDim
                    task.wait(0.5)
                end

                task.wait(0.05)
            end
        end)
    end)

    makeActionRow(scroll9, "🚫 Сбросить цель", Color3.fromRGB(90, 45, 55), function()
        halloween.selectedName = nil
        halloween.lockedBoss = nil
        halloween.running = false
        halloween.nearestMode = false
        selectedBossLabel.Text = "🎯 Цель: не выбрана"
        selectedBossLabel.TextColor3 = CONFIG.orange
        halloweenStatus.Text = "Статус: ожидание"
        halloweenStatus.TextColor3 = CONFIG.textDim
    end)

    -------------------------------------------------------------
    -- Обновление статуса в реальном времени
    -------------------------------------------------------------
    task.spawn(function()
        while true do
            if halloween.lockedBoss and halloween.lockedBoss.Parent then
                local hum = halloween.lockedBoss:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                halloweenStatus.Text = ("🎯 %s (HP %d)"):format(halloween.lockedBoss.Name, hp)
                halloweenStatus.TextColor3 = CONFIG.green
            end
            task.wait(0.5)
        end
    end)

    print("[Halloween] Вкладка загружена. Впиши имена боссов в HALLOWEEN_BOSSES.")
end)

--==============================================================
--  🛡️ WHITELIST UI — добавляем в PvP вкладку
--==============================================================
task.defer(function()
    task.wait(0.4)

    -------------------------------------------------------------
    -- Проверка: мы уже создали whitelist в PvP?
    -- Если нет — создаём
    -------------------------------------------------------------
    if not whitelisted then
        warn("[Whitelist] whitelisted не найдена в PvP — создай её патчем 1")
        return
    end

    makeSectionHeader(scroll5, "🛡️ Whitelist")

    local wlStatus = makeInfoLabel(scroll5, "Whitelist: пусто", CONFIG.textDim)

    -------------------------------------------------------------
    -- Кнопка разворота списка игроков (добавление)
    -------------------------------------------------------------
    local addExpandBtn = makeActionRow(scroll5, "➕ Добавить в whitelist", Color3.fromRGB(50, 120, 80), function() end)

    local addListFrame = Instance.new("Frame")
    addListFrame.Size = UDim2.new(1, 0, 0, 0)
    addListFrame.BackgroundColor3 = CONFIG.panelColor
    addListFrame.BorderSizePixel = 0
    addListFrame.ClipsDescendants = true
    addListFrame.Visible = false
    addListFrame.Parent = scroll5
    Instance.new("UICorner", addListFrame).CornerRadius = UDim.new(0, 8)

    local addLayout = Instance.new("UIListLayout")
    addLayout.Padding = UDim.new(0, 4)
    addLayout.Parent = addListFrame

    local addPad = Instance.new("UIPadding")
    addPad.PaddingLeft = UDim.new(0, 6)
    addPad.PaddingRight = UDim.new(0, 6)
    addPad.PaddingTop = UDim.new(0, 6)
    addPad.PaddingBottom = UDim.new(0, 6)
    addPad.Parent = addListFrame

    local addExpanded = false

    local function rebuildAddList()
        for _, c in ipairs(addListFrame:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then
                c:Destroy()
            end
        end

        local count = 0
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                count = count + 1
                local isIn = isWhitelisted(other)

                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 30)
                b.BackgroundColor3 = isIn and Color3.fromRGB(50, 120, 80) or CONFIG.cardColor
                b.Text = (isIn and "✓ " or "  ") .. ("%s (@%s)"):format(other.DisplayName, other.Name)
                b.TextColor3 = CONFIG.textColor
                b.TextSize = 12
                b.Font = Enum.Font.GothamMedium
                b.AutoButtonColor = false
                b.Parent = addListFrame
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

                b.MouseEnter:Connect(function()
                    if not isWhitelisted(other) then
                        b.BackgroundColor3 = CONFIG.cardHover
                    end
                end)
                b.MouseLeave:Connect(function()
                    b.BackgroundColor3 = isWhitelisted(other)
                        and Color3.fromRGB(50, 120, 80) or CONFIG.cardColor
                end)
                b.MouseButton1Click:Connect(function()
                    if isWhitelisted(other) then
                        removeFromWhitelist(other.Name)
                    else
                        addToWhitelist(other)
                    end
                    -- Пересобираем и добавленный, и удаляемый списки
                    if _G.__RebuildWlUI then _G.__RebuildWlUI() end
                end)
            end
        end

        if count == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "На сервере нет других игроков"
            empty.TextColor3 = CONFIG.textDim
            empty.TextSize = 12
            empty.Font = Enum.Font.Gotham
            empty.Parent = addListFrame
        end
    end

    addExpandBtn.MouseButton1Click:Connect(function()
        addExpanded = not addExpanded
        if addExpanded then
            rebuildAddList()
            local count = 0
            for _, c in ipairs(addListFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then
                    count = count + 1
                end
            end
            addListFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 34 + 12))
            addListFrame.Visible = true
            addExpandBtn.Text = "➕ Свернуть список"
        else
            addListFrame.Visible = false
            addExpandBtn.Text = "➕ Добавить в whitelist"
        end
    end)

    -------------------------------------------------------------
    -- Кнопка разворота списка whitelist (удаление)
    -------------------------------------------------------------
    local removeExpandBtn = makeActionRow(scroll5, "📜 Показать whitelist", Color3.fromRGB(90, 45, 55), function() end)

    local wlListFrame = Instance.new("Frame")
    wlListFrame.Size = UDim2.new(1, 0, 0, 0)
    wlListFrame.BackgroundColor3 = CONFIG.panelColor
    wlListFrame.BorderSizePixel = 0
    wlListFrame.ClipsDescendants = true
    wlListFrame.Visible = false
    wlListFrame.Parent = scroll5
    Instance.new("UICorner", wlListFrame).CornerRadius = UDim.new(0, 8)

    local wlLayout = Instance.new("UIListLayout")
    wlLayout.Padding = UDim.new(0, 4)
    wlLayout.Parent = wlListFrame

    local wlPad = Instance.new("UIPadding")
    wlPad.PaddingLeft = UDim.new(0, 6)
    wlPad.PaddingRight = UDim.new(0, 6)
    wlPad.PaddingTop = UDim.new(0, 6)
    wlPad.PaddingBottom = UDim.new(0, 6)
    wlPad.Parent = wlListFrame

    local wlExpanded = false

    local function rebuildWlList()
        for _, c in ipairs(wlListFrame:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then
                c:Destroy()
            end
        end

        if #whitelisted == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "Whitelist пуст"
            empty.TextColor3 = CONFIG.textDim
            empty.TextSize = 12
            empty.Font = Enum.Font.Gotham
            empty.Parent = wlListFrame
            return
        end

        for _, name in ipairs(whitelisted) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = CONFIG.cardColor
            b.Text = "  " .. name .. "   (нажми чтобы удалить)"
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.Parent = wlListFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseEnter:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(90, 45, 55)
            end)
            b.MouseLeave:Connect(function()
                b.BackgroundColor3 = CONFIG.cardColor
            end)
            b.MouseButton1Click:Connect(function()
                removeFromWhitelist(name)
                if _G.__RebuildWlUI then _G.__RebuildWlUI() end
            end)
        end
    end

    removeExpandBtn.MouseButton1Click:Connect(function()
        wlExpanded = not wlExpanded
        if wlExpanded then
            rebuildWlList()
            local count = 0
            for _, c in ipairs(wlListFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then
                    count = count + 1
                end
            end
            wlListFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 34 + 12))
            wlListFrame.Visible = true
            removeExpandBtn.Text = "📜 Скрыть whitelist"
        else
            wlListFrame.Visible = false
            removeExpandBtn.Text = "📜 Показать whitelist"
        end
    end)

    -------------------------------------------------------------
    -- Очистить всё
    -------------------------------------------------------------
    makeActionRow(scroll5, "🗑 Очистить whitelist", Color3.fromRGB(120, 50, 60), function()
        whitelisted = {}
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)

    -------------------------------------------------------------
    -- Общая функция пересборки обоих списков
    -------------------------------------------------------------
    _G.__RebuildWlUI = function()
        -- Обновляем статус
        if #whitelisted == 0 then
            wlStatus.Text = "Whitelist: пусто"
            wlStatus.TextColor3 = CONFIG.textDim
        else
            wlStatus.Text = ("Whitelist (%d): %s"):format(#whitelisted, table.concat(whitelisted, ", "))
            wlStatus.TextColor3 = CONFIG.green
        end

        if addExpanded then
            rebuildAddList()
            local count = 0
            for _, c in ipairs(addListFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then count = count + 1 end
            end
            addListFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 34 + 12))
        end

        if wlExpanded then
            rebuildWlList()
            local count = 0
            for _, c in ipairs(wlListFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then count = count + 1 end
            end
            wlListFrame.Size = UDim2.new(1, 0, 0, math.max(36, count * 34 + 12))
        end
    end

    -- Первый рендер
    _G.__RebuildWlUI()

    -- Обновление при заходе/выходе игроков
    Players.PlayerAdded:Connect(function()
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)
    Players.PlayerRemoving:Connect(function(p)
        removeFromWhitelist(p.Name)
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)

    print("[Whitelist] Загружено. Добавление — через ➕ в PvP.")
end)
