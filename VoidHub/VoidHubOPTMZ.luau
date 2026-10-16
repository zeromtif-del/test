_G.__VH_GEN = (_G.__VH_GEN or 0) + 1
local MY_GEN = _G.__VH_GEN

print("[DEBUG] VoidHub стартовал, генерация", _G.__VH_GEN)

do

--==============================================================
--  📁 РЕЕСТР КОНФИГОВ
--==============================================================
_G.__VH_CONFIG_REGISTRY = {
    toggles = {},
    inputs = {},
    custom = {},
}

--==============================================================
--  📝 РЕГИСТРАЦИЯ КАСТОМНОГО СОСТОЯНИЯ
--  Использование:
--    registerCustomState("Lighting.ClockTime",
--        function() return Lighting.ClockTime end,
--        function(v) Lighting.ClockTime = v end)
--==============================================================
function _G.__VH_RegisterCustom(name, getFn, setFn)
    table.insert(_G.__VH_CONFIG_REGISTRY.custom, {
        name = name,
        get = getFn,
        set = setFn,
    })
end

--==============================================================
--  🔧 УСТАНОВКА INPUT ПО ИМЕНИ
--  Пример: setInputByName("Время (0-24)", "18")
--==============================================================
function _G.__VH_SetInput(name, value)
    for _, i in ipairs(_G.__VH_CONFIG_REGISTRY.inputs) do
        if i.name == name then
            i.set(value)
            return true
        end
    end
    return false
end

--==============================================================
--  🔧 УСТАНОВКА TOGGLE ПО ИМЕНИ
--==============================================================
function _G.__VH_SetToggle(name, value)
    for _, t in ipairs(_G.__VH_CONFIG_REGISTRY.toggles) do
        if t.name == name then
            t.set(value)
            return true
        end
    end
    return false
end

--==============================================================
--  📂 ХЕЛПЕР ДЛЯ ПАПОК (nested через "/")
--==============================================================
_G.__VH_Folder = {}

function _G.__VH_Folder.ensure(path)
    if not makefolder or not isfolder then return false end

    -- Разбиваем по "/"
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end

    -- Создаём поочерёдно
    local current = ""
    for i, part in ipairs(parts) do
        current = (i == 1) and part or (current .. "/" .. part)
        if not isfolder(current) then
            pcall(function() makefolder(current) end)
        end
    end
    return true
end

function _G.__VH_Folder.exists(path)
    if not isfolder then return false end
    local ok, res = pcall(isfolder, path)
    return ok and res
end

function _G.__VH_Folder.list(path)
    if not listfiles then return {} end
    local ok, files = pcall(listfiles, path)
    if ok and type(files) == "table" then return files end
    return {}
end
    
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer

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

    if _G.__VH_CONNS then
        for _, c in ipairs(_G.__VH_CONNS) do
            pcall(function() c:Disconnect() end)
        end
    end
    _G.__VH_CONNS = {}

    if _G.__VH_DRAG_CONNS then
        for _, c in ipairs(_G.__VH_DRAG_CONNS) do
            pcall(function() c:Disconnect() end)
        end
    end
    _G.__VH_DRAG_CONNS = {}

    _G.KillEveryone      = false
    _G.InfiniteJump      = false
    _G.AutoHatchPet      = false
    _G.AutoHatchAura     = false
    _G.RockFarmRunning   = false
    _G.WhitelistFriends  = false

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

    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("AntiFlingBV") then
        pcall(function() hrp.AntiFlingBV:Destroy() end)
    end

    for _, p in ipairs(workspace:GetChildren()) do
        if p:IsA("Part") and p.Anchored and p.Transparency == 1 then
            if p.Size == Vector3.new(2048, 1, 2048) then
                pcall(function() p:Destroy() end)
            end
        end
    end

    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = 70
    end

    print(("[Void Hub] Старый процесс убит. Запуск генерации #%d"):format(MY_GEN))
end

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

local ACTIVE_THEME = _G.__VH_THEME or "dark"
local T = THEMES[ACTIVE_THEME] or THEMES.dark

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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

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

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, CONFIG.headerH)
header.BackgroundColor3 = CONFIG.bgColor
header.BorderSizePixel = 0
header.Parent = mainFrame

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

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -CONFIG.sidebarW - CONFIG.rightW, 1, -CONFIG.headerH)
contentArea.Position = UDim2.new(0, CONFIG.sidebarW, 0, CONFIG.headerH)
contentArea.BackgroundColor3 = CONFIG.bgColor
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

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
--  🎚️ SLIDER (ползунок)
--==============================================================
local function makeSliderRow(parent, labelText, minVal, maxVal, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 56)
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
    label.Size = UDim2.new(0.7, -15, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.textColor
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, -15, 0, 20)
    valLabel.Position = UDim2.new(0.7, 0, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(defaultVal or minVal)
    valLabel.TextColor3 = CONFIG.accentColor2
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 8)
    track.Position = UDim2.new(0, 14, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.accentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local value = defaultVal or minVal
    local range = maxVal - minVal
    local dragging = false

    local function apply(v, fireCallback)
        v = math.clamp(math.floor(v + 0.5), minVal, maxVal)
        value = v
        local r = (v - minVal) / range
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        valLabel.Text = tostring(v)
        if fireCallback and callback then callback(v) end
    end

    local function setFromX(x)
        local trackX = track.AbsolutePosition.X
        local trackW = track.AbsoluteSize.X
        if trackW <= 0 then return end
        local ratio = math.clamp((x - trackX) / trackW, 0, 1)
        apply(minVal + ratio * range, true)
    end

    apply(value, false)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 0, 34)
    hit.Position = UDim2.new(0, 0, 0, 22)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = row

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Get = function() return value end,
        Set = function(v) apply(v, true) end,
    }
end

--==============================================================
--  📁 ОБЁРТКИ ДЛЯ АВТО-РЕГИСТРАЦИИ В КОНФИГАХ
--==============================================================
do
    local _origToggle = makeToggleRow
    makeToggleRow = function(parent, labelText, initial, callback)
        local obj = _origToggle(parent, labelText, initial, callback)
        table.insert(_G.__VH_CONFIG_REGISTRY.toggles, {
            name = labelText,
            get = function() return obj.Get() end,
            set = function(on) obj.Set(on) end,
        })
        return obj
    end
end

do
    local _origInput = makeInputRow
    makeInputRow = function(parent, labelText, defaultText, callback)
        local box = _origInput(parent, labelText, defaultText, callback)
        table.insert(_G.__VH_CONFIG_REGISTRY.inputs, {
            name = labelText,
            get = function() return box.Text end,
            set = function(v)
                box.Text = tostring(v)
                local num = tonumber(v)
                if num and callback then callback(num) end
            end,
        })
        return box
    end
end

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
    { icon = "🎨", name = "Визуалы" },
    { icon = "📁", name = "Конфиги" },
}

local tabButtons = {}
local tabFrames = {}
local scrolls = {}
local currentTab = 1

local switchTab

for i, info in ipairs(TABS) do
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

    local f = Instance.new("Frame")
    f.Size = UDim2.fromScale(1, 1)
    f.BackgroundTransparency = 1
    f.Visible = (i == 1)
    f.Parent = contentArea
    tabFrames[i] = f
    scrolls[i] = makeScrollingList(f)
end

local scroll1, scroll2, scroll3 = scrolls[1], scrolls[2], scrolls[3]
local scroll4, scroll5, scroll6 = scrolls[4], scrolls[5], scrolls[6]
local scroll7, scroll8, scroll9, scroll10, scroll11 = scrolls[7], scrolls[8], scrolls[9], scrolls[10], scrolls[11]

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
_G.__VH_REP_STATE = repState

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

            task.wait(0.015)
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
            while repState.running and repState.simpleMode and _G.__VH_GEN == MY_GEN do
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
        if farm.ready and farm.strength and farm.rebirths then
            statsLabel.Text = ("Strength: %s | Rebirths: %s"):format(
                tostring(math.floor(farm.strength.Value)),
                tostring(math.floor(farm.rebirths.Value))
            )
        else
            statsLabel.Text = "Ожидание загрузки игры..."
        end
        task.wait(2)
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

-- 🔥 Оптимизировано: спит когда всё выключено
task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
        if not (sizeEnabled or speedEnabled or fovEnabled) then
            task.wait(0.5)
            continue
        end

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
        task.wait(0.1)
    end
end)

makeSectionHeader(scroll4, "🛡️ Защита")

local antiFlingEnabled = false
local antiFlingLoop = nil

local function ensureAntiFling()
    if not antiFlingEnabled then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
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

local function startAntiFlingLoop()
    if antiFlingLoop then return end
    antiFlingLoop = task.spawn(function()
        while antiFlingEnabled and _G.__VH_GEN == MY_GEN do
            ensureAntiFling()
            task.wait(0.5)
        end
        antiFlingLoop = nil
    end)
end

makeToggleRow(scroll4, "Anti-Fling", false, function(on)
    antiFlingEnabled = on
    if on then
        ensureAntiFling()
        startAntiFlingLoop()
    else
        removeAntiFling()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if antiFlingEnabled then ensureAntiFling() end
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

--==============================================================
--  🛸 ДВИЖЕНИЕ
--==============================================================
makeSectionHeader(scroll4, "🛸 Движение")

---------------------------------------------------------------
-- ПОЛЁТ
---------------------------------------------------------------
local flightEnabled = false
local flightSpeed = 60
local flightBV, flightBG, flightConn = nil, nil, nil

local function startFlight()
    if flightConn then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if hrp:FindFirstChild("VHFlightBV") then hrp.VHFlightBV:Destroy() end
    if hrp:FindFirstChild("VHFlightBG") then hrp.VHFlightBG:Destroy() end

    flightBV = Instance.new("BodyVelocity")
    flightBV.Name = "VHFlightBV"
    flightBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flightBV.Velocity = Vector3.zero
    flightBV.P = 1250
    flightBV.Parent = hrp

    flightBG = Instance.new("BodyGyro")
    flightBG.Name = "VHFlightBG"
    flightBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flightBG.P = 1000
    flightBG.D = 100
    flightBG.CFrame = hrp.CFrame
    flightBG.Parent = hrp

    flightConn = RunService.RenderStepped:Connect(function()
        if not flightEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local moveDir = Vector3.zero
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flightSpeed
        end

        flightBV.Velocity = moveDir
        flightBG.CFrame = cam.CFrame
    end)
end

local function stopFlight()
    if flightConn then
        flightConn:Disconnect()
        flightConn = nil
    end
    if flightBV and flightBV.Parent then flightBV:Destroy() end
    if flightBG and flightBG.Parent then flightBG:Destroy() end
    flightBV, flightBG = nil, nil
end

makeInputRow(scroll4, "Скорость полёта", "60", function(v)
    if v and v > 0 then
        flightSpeed = v
    end
end)

makeToggleRow(scroll4, "Полёт (WASD + Space/Ctrl)", false, function(on)
    flightEnabled = on
    if on then startFlight() else stopFlight() end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if flightEnabled then startFlight() end
end)

---------------------------------------------------------------
-- NOCLIP
---------------------------------------------------------------
local noclipEnabled = false

makeToggleRow(scroll4, "Проход сквозь стены", false, function(on)
    noclipEnabled = on
end)

task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
        if noclipEnabled then
            local char = player.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

--==============================================================
--  🎥 КАМЕРА
--==============================================================
makeSectionHeader(scroll4, "🎥 Камера")

--==============================================================
--  🎥 КАМЕРА (Freecam)
--==============================================================
local freecamEnabled = false
local freecamSpeed = 120
local freecamSensitivity = 0.05
local freecamCF = nil
local freecamRenderConn = nil
local freecamInputBegConn = nil
local freecamInputEndConn = nil
local freecamInputChangeConn = nil
local freecamAnchoredParts = nil
local freecamRmbDown = false
local freecamToggleRow = nil

local function startFreecam()
    if freecamRenderConn then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    freecamCF = cam.CFrame
    freecamRmbDown = false

    -- Якорим части персонажа
    freecamAnchoredParts = {}
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                freecamAnchoredParts[part] = part.Anchored
                part.Anchored = true
            end
        end
    end

    cam.CameraType = Enum.CameraType.Scriptable

    -- ПКМ зажат → блокируем курсор
    freecamInputBegConn = UserInputService.InputBegan:Connect(function(input)
        if not freecamEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamRmbDown = true
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            end)
        end
    end)

    -- ПКМ отпущен → возвращаем курсор
    freecamInputEndConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamRmbDown = false
            if freecamEnabled then
                pcall(function()
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end)
            end
        end
    end)

    -- Вращение мышью
    freecamInputChangeConn = UserInputService.InputChanged:Connect(function(input)
        if not freecamEnabled then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if not freecamRmbDown then return end
        if not input.Delta then return end

        local sens = freecamSensitivity
        local yaw = math.rad(-input.Delta.X * sens)
        local pitch = math.rad(-input.Delta.Y * sens)
        freecamCF = freecamCF * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
    end)

    -- WASD движение
    freecamRenderConn = RunService.RenderStepped:Connect(function(dt)
        if not freecamEnabled then return end
        local c = workspace.CurrentCamera
        if not c then return end

        local moveDir = Vector3.new(0, 0, 0)
        local forward = freecamCF.LookVector
        local right = freecamCF.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            freecamCF = freecamCF + moveDir.Unit * freecamSpeed * dt
        end

        c.CFrame = freecamCF
    end)
end

local function stopFreecam()
    if freecamRenderConn then
        freecamRenderConn:Disconnect()
        freecamRenderConn = nil
    end
    if freecamInputBegConn then
        freecamInputBegConn:Disconnect()
        freecamInputBegConn = nil
    end
    if freecamInputEndConn then
        freecamInputEndConn:Disconnect()
        freecamInputEndConn = nil
    end
    if freecamInputChangeConn then
        freecamInputChangeConn:Disconnect()
        freecamInputChangeConn = nil
    end

    freecamRmbDown = false

    if freecamAnchoredParts then
        for part, wasAnchored in pairs(freecamAnchoredParts) do
            if part and part.Parent then
                part.Anchored = wasAnchored
            end
        end
        freecamAnchoredParts = nil
    end

    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)

    task.spawn(function()
        wait()
        local cam = workspace.CurrentCamera
        if not cam then return end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            cam.CameraSubject = hum
        end
        cam.CameraType = Enum.CameraType.Custom

        wait()
        if hum and cam.CameraSubject ~= hum then
            cam.CameraSubject = hum
            cam.CameraType = Enum.CameraType.Custom
        end
    end)

    freecamCF = nil
end

freecamToggleRow = makeToggleRow(scroll4, "Свободная камера (C)", false, function(on)
    freecamEnabled = on
    if on then startFreecam() else stopFreecam() end
end)

makeSliderRow(scroll4, "Скорость движения", 70, 250, 120, function(v)
    freecamSpeed = v
end)

makeSliderRow(scroll4, "Чувствительность мыши", 1, 20, 5, function(v)
    freecamSensitivity = v / 100
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.C then
        freecamEnabled = not freecamEnabled
        if freecamEnabled then
            startFreecam()
        else
            stopFreecam()
        end
        if freecamToggleRow then
            pcall(function() freecamToggleRow:Set(freecamEnabled) end)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.spawn(function()
        wait(1.5)
        if freecamEnabled then
            freecamEnabled = false
            if freecamToggleRow then
                pcall(function() freecamToggleRow:Set(false) end)
            end
            wait(0.1)
            freecamEnabled = true
            if freecamToggleRow then
                pcall(function() freecamToggleRow:Set(true) end)
            end
            startFreecam()
        end
    end)
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
            task.wait(1.5)
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
makeSectionHeader(scroll6, "👑 Auto Boss")

local bossData = {
    running = false,
    lockedBoss = nil,
}
_G.__VH_BOSS_STATE = bossData

local function getBossArena()
    local ev = workspace:FindFirstChild("Events")
    if not ev then return nil end
    return ev:FindFirstChild("BossArena")
end

local function getBossPart(m)
    return m:FindFirstChild("HumanoidRootPart")
        or m:FindFirstChildWhichIsA("BasePart", true)
end

local BOSS_WHITELIST = {
    ["Boss1"]       = true,
    ["Boss2"]       = true,
    ["Boss3"]       = true,
    ["Boss4"]       = true,
    ["Boss5"]       = true,
    ["BossRainbow"] = true,
}

local function isAliveBoss(d)
    if not d or not d.Parent or not d:IsA("Model") then return false end
    if not BOSS_WHITELIST[d.Name] then return false end

    local part = getBossPart(d)
    if not part then return false end

    local hum = d:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end

    local hp = d:GetAttribute("Health")
    if type(hp) == "number" then return hp > 0 end

    return true
end

local function findBoss()
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local arena = getBossArena()
    if not arena then return nil end

    local best, bestDist = nil, math.huge

    for _, d in ipairs(arena:GetChildren()) do
        if isAliveBoss(d) then
            local part = getBossPart(d)
            if part then
                local dist = (part.Position - myHRP.Position).Magnitude
                if dist < bestDist then
                    best, bestDist = d, dist
                end
            end
        end
    end

    return best
end

local function attackBoss(boss)
    if not boss or not boss.Parent then return end

    local part = getBossPart(boss)
    if not part then return end

    local hum = boss:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    if not myChar:FindFirstChild("Punch") then
        local bp = player:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChild("Punch")
        if tool then
            local mh = myChar:FindFirstChildOfClass("Humanoid")
            if mh then pcall(function() mh:EquipTool(tool) end) end
        end
    end

    myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0), part.Position)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero

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

local function getBossChest()
    return workspace:FindFirstChild("BossChest")
end

local function pressE()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.08)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function gatherPromptsAndAttachments(root)
    local prompts = {}
    local attachments = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            table.insert(prompts, d)
        elseif d:IsA("Attachment") then
            table.insert(attachments, d)
            for _, ch in ipairs(d:GetChildren()) do
                if ch:IsA("ProximityPrompt") then
                    table.insert(prompts, ch)
                end
            end
        end
    end
    return prompts, attachments
end

local function tryOpenChest(chest)
    if not chest or not chest.Parent then return false end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end

    local prompts, attachments = gatherPromptsAndAttachments(chest)

    local targetPos = nil
    if #attachments > 0 and attachments[1].WorldPosition then
        targetPos = attachments[1].WorldPosition
    else
        local part = chest:FindFirstChildWhichIsA("BasePart", true)
        if part then targetPos = part.Position end
    end
    if not targetPos then return false end

    myHRP.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.5, 0))
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.25)

    myHRP.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.5, 0))
    task.wait(0.1)

    for _, prompt in ipairs(prompts) do
        pcall(function()
            prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance or 0, 50)
            if prompt.Enabled == false then prompt.Enabled = true end
        end)

        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, 0)
            end
        end)

        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end)

        task.wait(0.1)
    end

    pcall(function()
        local lh = myChar:FindFirstChild("LeftHand")
        local rh = myChar:FindFirstChild("RightHand")
        for _, d in ipairs(chest:GetDescendants()) do
            if d:IsA("BasePart") then
                firetouchinterest(d, myHRP, 0)
                firetouchinterest(d, myHRP, 1)
                if lh then
                    firetouchinterest(d, lh, 0)
                    firetouchinterest(d, lh, 1)
                end
                if rh then
                    firetouchinterest(d, rh, 0)
                    firetouchinterest(d, rh, 1)
                end
            end
        end
    end)

    pcall(function()
        for _, d in ipairs(chest:GetDescendants()) do
            if d:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(d)
            end
        end
    end)

    pressE()
    task.wait(0.12)
    pressE()
    task.wait(0.12)
    pressE()

    return true
end

local function collectBossChest()
    local chest = getBossChest()
    if not chest then return false end

    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end

    for _ = 1, 5 do
        if not chest or not chest.Parent then break end
        tryOpenChest(chest)
        task.wait(0.2)
    end

    return true
end

local bossStatus = makeInfoLabel(scroll6, "Босс: —", CONFIG.textDim)

makeToggleRow(scroll6, "Auto Boss", false, function(on)
    bossData.running = on

    if on then
        bossData.lockedBoss = nil

        task.spawn(function()
            while bossData.running and _G.__VH_GEN == MY_GEN do
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then task.wait(0.2); continue end

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
                        task.wait(0.03)
                    end
                else
                    task.wait(0.5)
                end

                if boss and not isAliveBoss(boss) then
                    local waitStart = tick()
                    while tick() - waitStart < 5 do
                        if getBossChest() then break end
                        if not bossData.running then break end
                        task.wait(0.1)
                    end

                    for _ = 1, 6 do
                        if not getBossChest() then break end
                        if not bossData.running then break end
                        collectBossChest()
                        task.wait(0.4)
                    end

                    bossData.lockedBoss = nil
                end

                task.wait(0.05)
            end
        end)

        task.spawn(function()
            while bossData.running and _G.__VH_GEN == MY_GEN do
                if bossData.lockedBoss and bossData.lockedBoss.Parent then
                    local hum = bossData.lockedBoss:FindFirstChildOfClass("Humanoid")
                    local hp = hum and hum.Health or 0
                    bossStatus.Text = ("🎯 %s (HP %d)"):format(
                        bossData.lockedBoss.Name, math.floor(hp))
                    bossStatus.TextColor3 = CONFIG.green
                elseif getBossChest() then
                    bossStatus.Text = "🎁 Собираю BossChest..."
                    bossStatus.TextColor3 = CONFIG.orange
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
                task.wait(1.5)
            end
        end)
    else
        bossData.lockedBoss = nil
    end
end)

--==============================================================
--  🎁 AUTO CHEST COLLECTOR
--==============================================================
makeSectionHeader(scroll6, "🎁 Auto Chest Collector")

local chestCollectorRunning = false

local function findCircleInner(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and string.find(d.Name:lower(), "circleinner", 1, true) then
            return d
        end
    end
    return nil
end

-- 🔥 Кэш 0.5 сек
local _chestCache = { list = {}, lastScan = 0 }

local function gatherTargets()
    local now = tick()
    if now - _chestCache.lastScan < 0.5 then
        return _chestCache.list
    end
    _chestCache.lastScan = now
    _chestCache.list = {}

    for _, d in ipairs(workspace:GetChildren()) do
        if d:IsA("Model") and string.find(d.Name:lower(), "chest", 1, true) then
            local circle = findCircleInner(d)
            if circle then
                table.insert(_chestCache.list, {
                    model = d,
                    part = circle,
                })
            end
        end
    end
    return _chestCache.list
end

local function openChestByTouch(entry)
    if not entry or not entry.part or not entry.part.Parent then return false end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end

    local target = entry.part

    myHRP.CFrame = CFrame.new(target.Position + Vector3.new(0, 1, 0), target.Position)
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.15)

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

    return true
end

local function runCollector()
    local list = gatherTargets()
    for _, entry in ipairs(list) do
        if not chestCollectorRunning then break end
        if not entry.part or not entry.part.Parent then continue end

        openChestByTouch(entry)
        task.wait(0.2)

        if entry.part and entry.part.Parent then
            openChestByTouch(entry)
            task.wait(0.15)
        end
    end
end

local chestCollectorStatus = makeInfoLabel(scroll6, "🎁 Статус: ожидание", CONFIG.textDim)

makeToggleRow(scroll6, "Auto Chest Collector", false, function(on)
    chestCollectorRunning = on

    if on then
        chestCollectorStatus.Text = "🎁 Статус: ищу сундуки..."
        chestCollectorStatus.TextColor3 = CONFIG.green

        task.spawn(function()
            while chestCollectorRunning and _G.__VH_GEN == MY_GEN do
                local list = gatherTargets()

                if #list > 0 then
                    chestCollectorStatus.Text = ("🎁 Найдено: %d"):format(#list)
                    chestCollectorStatus.TextColor3 = CONFIG.green
                    pcall(runCollector)
                else
                    chestCollectorStatus.Text = "🎁 Сундуков нет"
                    chestCollectorStatus.TextColor3 = CONFIG.textDim
                end

                task.wait(1.5)
            end

            chestCollectorStatus.Text = "🎁 Статус: остановлено"
            chestCollectorStatus.TextColor3 = CONFIG.orange
        end)
    else
        chestCollectorStatus.Text = "🎁 Статус: остановлено"
        chestCollectorStatus.TextColor3 = CONFIG.orange
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

-- Регистрируем выбранный камень как custom state
task.defer(function()
    task.wait(0.5)
    _G.__VH_RegisterCustom("Auto Rock selected",
        function() return selectedRock end,
        function(v)
            if type(v) == "string" and rockData[v] then
                selectedRock = v
            end
        end
    )
end)

-- 🔥 Кэш на 5 сек
local _rockCache = { part = nil, lastScan = 0, lastRock = nil }

local function findNeededRockValue()
    if _rockCache.lastRock == selectedRock and (tick() - _rockCache.lastScan) < 5 then
        return _rockCache.part
    end
    _rockCache.lastScan = tick()
    _rockCache.lastRock = selectedRock
    _rockCache.part = nil

    local mf = Workspace:FindFirstChild("machinesFolder")
    if not mf then return nil end

    for _, v in pairs(mf:GetDescendants()) do
        if v.Name == "neededDurability" and v.Value == rockData[selectedRock] then
            _rockCache.part = v.Parent
            return v.Parent
        end
    end
    return nil
end

for name in pairs(rockData) do
    makeActionRow(scroll6, "🪨 " .. name, CONFIG.cardColor, function() selectedRock = name end)
end

makeToggleRow(scroll6, "Auto Rock", false, function(on)
    autoRockRunning = on
    if on then
        task.spawn(function()
            while autoRockRunning and _G.__VH_GEN == MY_GEN do
                task.wait(0.2)
                if selectedRock and player.Character then
                    local dura = player:FindFirstChild("Durability")
                    if dura and dura.Value >= rockData[selectedRock] then
                        local rockParent = findNeededRockValue()
                        if rockParent then
                            local char = player.Character
                            local rh = char:FindFirstChild("RightHand")
                            local lh = char:FindFirstChild("LeftHand")
                            local rock = rockParent:FindFirstChild("Rock")
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
        end)
    end
end)

makeSectionHeader(scroll6, "🏋️ Auto Тренажёры")

local machinesFolder = Workspace:WaitForChild("machinesFolder", 10)
local machineData = {
    Squat = { selected = nil, running = false, active = nil },
    Lift = { selected = nil, running = false, active = nil },
}

-- Регистрируем выбранные тренажёры
task.defer(function()
    task.wait(0.6)
    _G.__VH_RegisterCustom("Squat machine selected",
        function() return machineData.Squat.selected and machineData.Squat.selected.Name or nil end,
        function(v)
            if type(v) == "string" and machinesFolder then
                machineData.Squat.selected = machinesFolder:FindFirstChild(v)
            end
        end
    )
    _G.__VH_RegisterCustom("Lift machine selected",
        function() return machineData.Lift.selected and machineData.Lift.selected.Name or nil end,
        function(v)
            if type(v) == "string" and machinesFolder then
                machineData.Lift.selected = machinesFolder:FindFirstChild(v)
            end
        end
    )
end)

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
                -- 🔥 Бёрст 10 + пауза 0.03
                for _ = 1, 10 do
                    if not data.running then break end
                    pcall(function() player.muscleEvent:FireServer("rep") end)
                end
                task.wait(0.03)
            else
                task.wait(0.2)
            end
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

print("test")

--==============================================================
--  🔮 AUTO CRYSTAL — загрузчик из GitHub
--==============================================================
makeSectionHeader(scroll6, "🔮 Auto Crystal")

makeActionRow(scroll6, "🚀 Загрузить Auto Crystal", Color3.fromRGB(140, 80, 255), function()
    local url = "https://raw.githubusercontent.com/zeromtif-del/test/refs/heads/main/VoidHub/AutoCrystal.luau"

    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn("[AutoCrystal] Ошибка загрузки: " .. tostring(err))
    else
        print("[AutoCrystal] Загружен успешно")
    end
end)

makeInfoLabel(scroll6, "Загрузит меню Auto Crystal с 4 режимами", CONFIG.textDim)

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
    while _G.__VH_GEN == MY_GEN do
        local e = tick() - StatsTracker.startTime
        timeLabel.Text = string.format("%dd %dh %dm %ds",
            math.floor(e / 86400), math.floor((e % 86400) / 3600),
            math.floor((e % 3600) / 60), math.floor(e % 60))
        task.wait(2)
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
    while _G.__VH_GEN == MY_GEN do
        for _, def in ipairs(StatsTracker.statDefs) do
            if def.value and StatsTracker.labels[def.name] then
                local cur = def.value.Value
                local start = StatsTracker.startValues[def.name] or cur
                local gained = cur - start
                StatsTracker.labels[def.name].Text = ("%s: %s | +%s"):format(def.name, fmtNum(cur), fmtNum(gained))
            end
        end
        task.wait(3)
    end
end)

--==============================================================
--  RIGHT PANEL
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

-- 🔥 Оптимизировано: без pcall, wait(2)
task.spawn(function()
    while _G.__VH_GEN == MY_GEN do
        if player and player.Parent then
            local ls = player:FindFirstChild("leaderstats")
            local str = ls and ls:FindFirstChild("Strength")
            local reb = ls and ls:FindFirstChild("Rebirths")
            local kills = ls and ls:FindFirstChild("Kills")
            local dura = player:FindFirstChild("Durability")

            if statStrength   then statStrength.Text   = str   and fmtNum(str.Value)   or "—" end
            if statRebirths   then statRebirths.Text   = reb   and fmtNum(reb.Value)   or "—" end
            if statDurability then statDurability.Text = dura  and fmtNum(dura.Value)  or "—" end
            if statKills      then statKills.Text      = kills and fmtNum(kills.Value) or "—" end
        end
        task.wait(2)
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

    local conn1 = UserInputService.InputChanged:Connect(function(input)
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

    local conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(_G.__VH_DRAG_CONNS, conn1)
    table.insert(_G.__VH_DRAG_CONNS, conn2)
end

makeDraggable(mainFrame, header)
makeDraggable(toggleButton)

print("[Void Hub] Загружено. Клавиша меню: F1")

--==============================================================
--  🎃 ВКЛАДКА «HALLOWEEN BOSS»
--==============================================================
task.defer(function()
    task.wait(0.3)

    local HALLOWEEN_BOSSES = {
        "Pumpkin Titan",
        "Grim Reaper",
        "Scarecrow Colossus",
        "Frankenbrute",
    }

    local halloween = {
        running = false,
        lockedBoss = nil,
        selectedName = nil,
        listExpanded = false,
    }
    -- Регистрируем выбранного босса Halloween
    _G.__VH_RegisterCustom("Halloween target",
        function() return halloween.selectedName end,
        function(v)
            if type(v) == "string" then
                halloween.selectedName = v
            end
        end
    )
    
    _G.__VH_HALLOWEEN_STATE = halloween

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

    local function isHalloweenBoss(m)
        if not isAliveModel(m) then return false end
        local name = m.Name

        for _, bossName in ipairs(HALLOWEEN_BOSSES) do
            if name == bossName then return true end
        end

        if #HALLOWEEN_BOSSES == 0 then
            local lower = name:lower()
            if string.find(lower, "halloween", 1, true) then return true end
            if string.find(lower, "pumpkin", 1, true) then return true end
            if string.find(lower, "witch", 1, true) then return true end
            if string.find(lower, "candy", 1, true) then return true end

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

    -- 🔥 Кэш скана 5 сек
    local _halCache = { list = {}, lastScan = 0 }

    local function scanHalloweenBosses()
        local now = tick()
        if now - _halCache.lastScan < 5 then
            return _halCache.list
        end
        _halCache.lastScan = now
        _halCache.list = {}

        for _, d in ipairs(workspace:GetDescendants()) do
            if isHalloweenBoss(d) then
                table.insert(_halCache.list, d)
            end
        end
        return _halCache.list
    end

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

    local function findByName(name)
        if not name then return nil end
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Model") and d.Name == name and isAliveModel(d) then
                return d
            end
        end
        return nil
    end

    local function attackBoss(boss)
        if not boss or not boss.Parent then return end
        local part = getBossPart(boss)
        if not part then return end

        local hum = boss:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return end

        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        if not myChar:FindFirstChild("Punch") then
            local bp = player:FindFirstChild("Backpack")
            local tool = bp and bp:FindFirstChild("Punch")
            if tool then
                local mh = myChar:FindFirstChildOfClass("Humanoid")
                if mh then pcall(function() mh:EquipTool(tool) end) end
            end
        end

        myHRP.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0), part.Position)
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero

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

    makeSectionHeader(scroll9, "🎃 Halloween Boss")

    local halloweenStatus = makeInfoLabel(scroll9, "Статус: ожидание", CONFIG.textDim)
    local selectedBossLabel = makeInfoLabel(scroll9, "🎯 Цель: не выбрана", CONFIG.orange)
    local countLabel = makeInfoLabel(scroll9, "Найдено боссов: 0", CONFIG.textDim)

    local expandBtn = makeActionRow(scroll9, "📜 Развернуть список боссов", Color3.fromRGB(60, 90, 180), function() end)

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

    -- 🔥 Авто-обновление: только если раскрыто или режим включён, раз в 3 сек
    task.spawn(function()
        while _G.__VH_GEN == MY_GEN do
            task.wait(3)
            if halloween.listExpanded or halloween.running or halloween.nearestMode then
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
                    local bosses = scanHalloweenBosses()
                    countLabel.Text = ("Найдено боссов: %d"):format(#bosses)
                end
            end
        end
    end)

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

    task.spawn(function()
        while _G.__VH_GEN == MY_GEN do
            if halloween.lockedBoss and halloween.lockedBoss.Parent then
                local hum = halloween.lockedBoss:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                halloweenStatus.Text = ("🎯 %s (HP %d)"):format(halloween.lockedBoss.Name, hp)
                halloweenStatus.TextColor3 = CONFIG.green
            end
            task.wait(1.5)
        end
    end)

    print("[Halloween] Вкладка загружена.")
end)

--==============================================================
--  🛡️ WHITELIST UI
--==============================================================
task.defer(function()
    task.wait(0.4)

    makeSectionHeader(scroll5, "🛡️ Whitelist")

    local wlStatus = makeInfoLabel(scroll5, "Whitelist: пусто", CONFIG.textDim)

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

    makeActionRow(scroll5, "🗑 Очистить whitelist", Color3.fromRGB(120, 50, 60), function()
        whitelisted = {}
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)

    _G.__RebuildWlUI = function()
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

    _G.__RebuildWlUI()

    Players.PlayerAdded:Connect(function()
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)
    Players.PlayerRemoving:Connect(function(p)
        removeFromWhitelist(p.Name)
        if _G.__RebuildWlUI then _G.__RebuildWlUI() end
    end)

    print("[Whitelist] Загружено.")
end)

--==============================================================
--  🎨 ВКЛАДКА «ВИЗУАЛЫ»
--==============================================================
task.defer(function()
    task.wait(0.5)

    -- Регистрируем Lighting-настройки как custom states
    _G.__VH_RegisterCustom("Lighting.ClockTime",
        function() return Lighting.ClockTime end,
        function(v) if tonumber(v) then Lighting.ClockTime = tonumber(v) end end
    )
    _G.__VH_RegisterCustom("Lighting.Brightness",
        function() return Lighting.Brightness end,
        function(v) if tonumber(v) then Lighting.Brightness = tonumber(v) end end
    )
    _G.__VH_RegisterCustom("Lighting.FogStart",
        function() return Lighting.FogStart end,
        function(v) if tonumber(v) then Lighting.FogStart = tonumber(v) end end
    )
    _G.__VH_RegisterCustom("Lighting.FogEnd",
        function() return Lighting.FogEnd end,
        function(v) if tonumber(v) then Lighting.FogEnd = tonumber(v) end end
    )
    _G.__VH_RegisterCustom("Lighting.FogColor",
        function() return Lighting.FogColor end,
        function(v) if typeof(v) == "Color3" then Lighting.FogColor = v end end
    )

    local visual = {
        skyRunning = false,
        fogRunning = false,
        fogStart = 0,
        fogEnd = 500,
        fogColor = Color3.fromRGB(200, 200, 220),
        particlesRunning = false,
        espRunning = false,
        espColor = Color3.fromRGB(255, 60, 60),
        espShowName = true,
        espShowDistance = true,
        jumpRingRunning = false,
        jumpRingColor = Color3.fromRGB(120, 180, 255),
        jumpRingSize = 6,
    }

    local function resetLighting()
        pcall(function()
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            Lighting.FogColor = Color3.fromRGB(192, 192, 192)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(70, 70, 70)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
    end

    makeSectionHeader(scroll10, "☀️ Небо и солнце")

    makeInputRow(scroll10, "Время (0-24)", "14", function(v)
        if v then
            Lighting.ClockTime = math.clamp(v, 0, 24)
        end
    end)

    makeInputRow(scroll10, "Яркость", "2", function(v)
        if v then
            Lighting.Brightness = math.clamp(v, 0, 10)
        end
    end)

    makeActionRow(scroll10, "🌅 Рассвет (6:00)", Color3.fromRGB(255, 160, 80), function()
        Lighting.ClockTime = 6
        _G.__VH_SetInput("Время (0-24)", "6")
    end)
    makeActionRow(scroll10, "☀️ День (12:00)", Color3.fromRGB(255, 220, 100), function()
        Lighting.ClockTime = 12
        _G.__VH_SetInput("Время (0-24)", "12")
    end)
    makeActionRow(scroll10, "🌇 Закат (18:00)", Color3.fromRGB(255, 120, 60), function()
        Lighting.ClockTime = 18
        _G.__VH_SetInput("Время (0-24)", "18")
    end)
    makeActionRow(scroll10, "🌙 Ночь (0:00)", Color3.fromRGB(80, 90, 160), function()
        Lighting.ClockTime = 0
        _G.__VH_SetInput("Время (0-24)", "0")
    end)

    makeActionRow(scroll10, "🔄 Сбросить освещение", Color3.fromRGB(90, 45, 55), function()
        resetLighting()
    end)

    makeSectionHeader(scroll10, "🌫️ Туман")

    makeInputRow(scroll10, "Начало тумана", "0", function(v)
        if v then
            visual.fogStart = math.clamp(v, 0, 10000)
            if visual.fogRunning then
                Lighting.FogStart = visual.fogStart
            end
        end
    end)

    makeInputRow(scroll10, "Конец тумана", "500", function(v)
        if v then
            visual.fogEnd = math.clamp(v, 10, 100000)
            if visual.fogRunning then
                Lighting.FogEnd = visual.fogEnd
            end
        end
    end)

    -- Регистрируем выбор цвета тумана
    _G.__VH_RegisterCustom("Fog preset color",
        function() return visual.fogColor end,
        function(v)
            if typeof(v) == "Color3" then
                visual.fogColor = v
                if visual.fogRunning then Lighting.FogColor = v end
            end
        end
    )

    makeActionRow(scroll10, "🌫️ Серый туман", Color3.fromRGB(150, 150, 160), function()
        visual.fogColor = Color3.fromRGB(180, 180, 190)
        if visual.fogRunning then Lighting.FogColor = visual.fogColor end
    end)
    makeActionRow(scroll10, "🌃 Ночной туман", Color3.fromRGB(30, 30, 60), function()
        visual.fogColor = Color3.fromRGB(20, 20, 50)
        if visual.fogRunning then Lighting.FogColor = visual.fogColor end
    end)
    makeActionRow(scroll10, "🩸 Кровавый туман", Color3.fromRGB(120, 20, 20), function()
        visual.fogColor = Color3.fromRGB(120, 20, 20)
        if visual.fogRunning then Lighting.FogColor = visual.fogColor end
    end)
    makeActionRow(scroll10, "🟣 Фиолетовый туман", Color3.fromRGB(100, 60, 150), function()
        visual.fogColor = Color3.fromRGB(100, 60, 150)
        if visual.fogRunning then Lighting.FogColor = visual.fogColor end
    end)
    makeActionRow(scroll10, "💚 Зелёный туман", Color3.fromRGB(60, 130, 60), function()
        visual.fogColor = Color3.fromRGB(60, 130, 60)
        if visual.fogRunning then Lighting.FogColor = visual.fogColor end
    end)

    makeToggleRow(scroll10, "Применить туман", false, function(on)
        visual.fogRunning = on
        if on then
            Lighting.FogStart = visual.fogStart
            Lighting.FogEnd = visual.fogEnd
            Lighting.FogColor = visual.fogColor
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            Lighting.FogColor = Color3.fromRGB(192, 192, 192)
        end
    end)

    makeSectionHeader(scroll10, "✨ Частицы в воздухе")

    local airParticle = nil

    makeToggleRow(scroll10, "Плавающие частицы", false, function(on)
        visual.particlesRunning = on

        if on then
            local cam = workspace.CurrentCamera
            if not cam then return end

            if airParticle and airParticle.Parent then
                airParticle:Destroy()
            end

            airParticle = Instance.new("ParticleEmitter")
            airParticle.Name = "VoidHubAirParticles"
            airParticle.Texture = "rbxassetid://243660364"
            airParticle.LightEmission = 0.5
            airParticle.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 200, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 180)),
            })
            airParticle.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.5, 0.3),
                NumberSequenceKeypoint.new(1, 0),
            })
            airParticle.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            })
            airParticle.Lifetime = NumberRange.new(4, 8)
            airParticle.Rate = 15
            airParticle.Speed = NumberRange.new(1, 3)
            airParticle.SpreadAngle = Vector2.new(180, 180)
            airParticle.Rotation = NumberRange.new(0, 360)
            airParticle.RotSpeed = NumberRange.new(-30, 30)
            airParticle.VelocityInheritance = 0
            airParticle.Parent = cam
        else
            if airParticle and airParticle.Parent then
                airParticle:Destroy()
                airParticle = nil
            end
        end
    end)

    makeSectionHeader(scroll10, "👁️ ESP игроков")

    local espHighlights = {}

    local function clearESP()
        for plr, highlight in pairs(espHighlights) do
            pcall(function()
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end)
        end
        espHighlights = {}
    end

    local function createESP(targetPlayer)
        if targetPlayer == player then return end
        if not targetPlayer.Character then return end

        if espHighlights[targetPlayer] and espHighlights[targetPlayer].Parent then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "VoidHubESP"
        highlight.FillColor = visual.espColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = targetPlayer.Character
        highlight.Parent = targetPlayer.Character

        espHighlights[targetPlayer] = highlight

        if visual.espShowName then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("VoidHubNameTag") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "VoidHubNameTag"
                billboard.Size = UDim2.fromOffset(200, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = head
                billboard.Parent = head

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, 0, 0, 20)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = targetPlayer.Name
                nameLbl.TextColor3 = visual.espColor
                nameLbl.TextSize = 14
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextStrokeTransparency = 0.3
                nameLbl.Parent = billboard

                local distLbl = Instance.new("TextLabel")
                distLbl.Name = "Distance"
                distLbl.Size = UDim2.new(1, 0, 0, 16)
                distLbl.Position = UDim2.new(0, 0, 0, 20)
                distLbl.BackgroundTransparency = 1
                distLbl.Text = "0 studs"
                distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                distLbl.TextSize = 11
                distLbl.Font = Enum.Font.Gotham
                distLbl.TextStrokeTransparency = 0.5
                distLbl.Parent = billboard
            end
        end
    end

    task.spawn(function()
        while _G.__VH_GEN == MY_GEN do
            if visual.espRunning then
                local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player and other.Character then
                        createESP(other)
                        if myHRP then
                            local oHRP = other.Character:FindFirstChild("HumanoidRootPart")
                            local head = other.Character:FindFirstChild("Head")
                            if oHRP and head then
                                local tag = head:FindFirstChild("VoidHubNameTag")
                                if tag then
                                    local dist = tag:FindFirstChild("Distance")
                                    if dist then
                                        dist.Text = ("%d studs"):format(
                                            math.floor((myHRP.Position - oHRP.Position).Magnitude))
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            if visual.espRunning then
                task.wait(0.5)
                createESP(p)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(p)
        if espHighlights[p] then
            pcall(function() espHighlights[p]:Destroy() end)
            espHighlights[p] = nil
        end
    end)

    makeActionRow(scroll10, "🔴 Красный ESP", Color3.fromRGB(255, 60, 60), function()
        visual.espColor = Color3.fromRGB(255, 60, 60)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h.FillColor = visual.espColor end
        end
    end)
    makeActionRow(scroll10, "🟢 Зелёный ESP", Color3.fromRGB(60, 255, 60), function()
        visual.espColor = Color3.fromRGB(60, 255, 60)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h.FillColor = visual.espColor end
        end
    end)
    makeActionRow(scroll10, "🔵 Синий ESP", Color3.fromRGB(60, 120, 255), function()
        visual.espColor = Color3.fromRGB(60, 120, 255)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h.FillColor = visual.espColor end
        end
    end)
    makeActionRow(scroll10, "🟣 Фиолетовый ESP", Color3.fromRGB(180, 80, 255), function()
        visual.espColor = Color3.fromRGB(180, 80, 255)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h.FillColor = visual.espColor end
        end
    end)
    makeActionRow(scroll10, "🟡 Жёлтый ESP", Color3.fromRGB(255, 220, 60), function()
        visual.espColor = Color3.fromRGB(255, 220, 60)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h.FillColor = visual.espColor end
        end
    end)

    makeToggleRow(scroll10, "Показывать имя", true, function(on)
        visual.espShowName = on
        if visual.espRunning then
            clearESP()
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player then createESP(other) end
            end
        end
    end):Set(true)

    makeToggleRow(scroll10, "Показывать дистанцию", true, function(on)
        visual.espShowDistance = on
    end):Set(true)

    makeToggleRow(scroll10, "ESP игроков", false, function(on)
        visual.espRunning = on
        if on then
            for _, other in ipairs(Players:GetPlayers()) do
                createESP(other)
            end
        else
            clearESP()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        local tag = head:FindFirstChild("VoidHubNameTag")
                        if tag then tag:Destroy() end
                    end
                end
            end
        end
    end)

    makeSectionHeader(scroll10, "💫 Круг при прыжке")

    makeInputRow(scroll10, "Размер круга", "6", function(v)
        if v then
            visual.jumpRingSize = math.clamp(v, 2, 30)
        end
    end)

    makeActionRow(scroll10, "🔵 Голубой круг", Color3.fromRGB(120, 180, 255), function()
        visual.jumpRingColor = Color3.fromRGB(120, 180, 255)
    end)
    makeActionRow(scroll10, "🟣 Фиолетовый круг", Color3.fromRGB(180, 100, 255), function()
        visual.jumpRingColor = Color3.fromRGB(180, 100, 255)
    end)
    makeActionRow(scroll10, "🔴 Красный круг", Color3.fromRGB(255, 80, 80), function()
        visual.jumpRingColor = Color3.fromRGB(255, 80, 80)
    end)
    makeActionRow(scroll10, "🟢 Зелёный круг", Color3.fromRGB(80, 255, 120), function()
        visual.jumpRingColor = Color3.fromRGB(80, 255, 120)
    end)
    makeActionRow(scroll10, "🟡 Золотой круг", Color3.fromRGB(255, 220, 80), function()
        visual.jumpRingColor = Color3.fromRGB(255, 220, 80)
    end)

    local function createJumpRing(position, color, size)
        local ring = Instance.new("Part")
        ring.Name = "VoidHubJumpRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(0.2, size, size)
        ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
        ring.Anchored = true
        ring.CanCollide = false
        ring.CanTouch = false
        ring.CanQuery = false
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Transparency = 0.2
        ring.Parent = workspace

        task.spawn(function()
            for i = 1, 20 do
                if not ring.Parent then break end
                local progress = i / 20
                ring.Size = Vector3.new(0.2, size * (1 + progress * 0.8), size * (1 + progress * 0.8))
                ring.Transparency = 0.2 + progress * 0.8
                task.wait(0.03)
            end
            if ring.Parent then ring:Destroy() end
        end)
    end

    local jumpConnection = nil

    local function startJumpRing()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
        end

        jumpConnection = hum.StateChanged:Connect(function(old, new)
            if new == Enum.HumanoidStateType.Jumping then
                local curHRP = char:FindFirstChild("HumanoidRootPart")
                if curHRP then
                    createJumpRing(curHRP.Position, visual.jumpRingColor, visual.jumpRingSize)
                end
            end
        end)
    end

    local function stopJumpRing()
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
            jumpConnection = nil
        end
    end

    makeToggleRow(scroll10, "Круг при прыжке", false, function(on)
        visual.jumpRingRunning = on
        if on then
            startJumpRing()
        else
            stopJumpRing()
        end
    end)

    player.CharacterAdded:Connect(function()
        task.wait(1)
        if visual.jumpRingRunning then
            startJumpRing()
        end
    end)

    makeSectionHeader(scroll10, "🔄 Сброс")

    makeActionRow(scroll10, "🧹 Сбросить всё", Color3.fromRGB(120, 50, 60), function()
        resetLighting()
        visual.fogRunning = false

        if airParticle and airParticle.Parent then
            airParticle:Destroy()
            airParticle = nil
        end
        visual.particlesRunning = false

        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("VoidHubFindChild")
                    if not tag then
                        tag = head:FindFirstChild("VoidHubNameTag")
                    end
                    if tag then tag:Destroy() end
                end
            end
        end
        visual.espRunning = false

        stopJumpRing()
        visual.jumpRingRunning = false

        print("[Visuals] Всё сброшено.")
    end)

    print("[Visuals] Вкладка загружена.")
end)

--==============================================================
--  📁 ВКЛАДКА «КОНФИГИ» (с папками)
--==============================================================
task.defer(function()
    task.wait(0.7)

    local HttpService = game:GetService("HttpService")

    -------------------------------------------------------------
    -- Папка для конфигов
    -------------------------------------------------------------
    local ROOT_FOLDER = "VoidHub"
    local CONFIGS_FOLDER = ROOT_FOLDER .. "/Configs"

    -- Создаём структуру
    _G.__VH_Folder.ensure(CONFIGS_FOLDER)

    -------------------------------------------------------------
    -- Загрузка всех конфигов из папки
    -------------------------------------------------------------
    local configs = {}

    local function loadAllFromDisk()
        local result = {}

        if not listfiles then
            return result
        end

        local files = _G.__VH_Folder.list(CONFIGS_FOLDER)
        for _, filePath in ipairs(files) do
            -- Только .json
            local ok, ext = pcall(function()
                return string.match(filePath, "%.(%w+)$")
            end)
            if ok and ext and ext:lower() == "json" then
                -- Имя файла без пути и расширения
                local name = filePath:match("([^/\\]+)%.json$")
                if name then
                    local ok2, data = pcall(function()
                        return HttpService:JSONDecode(readfile(filePath))
                    end)
                    if ok2 and type(data) == "table" then
                        result[name] = data
                    end
                end
            end
        end

        return result
    end

    -------------------------------------------------------------
    -- Сохранить один конфиг
    -------------------------------------------------------------
    local function saveOneToDisk(name, state)
        if not writefile then return false end

        local path = CONFIGS_FOLDER .. "/" .. name .. ".json"
        local ok = pcall(function()
            writefile(path, HttpService:JSONEncode(state))
        end)
        return ok
    end

    -------------------------------------------------------------
    -- Удалить файл конфига
    -------------------------------------------------------------
    local function deleteFromDisk(name)
        if not delfile then return false end

        local path = CONFIGS_FOLDER .. "/" .. name .. ".json"
        local ok = pcall(function()
            delfile(path)
        end)
        return ok
    end

    -------------------------------------------------------------
    -- Загружаем при старте
    -------------------------------------------------------------
    configs = loadAllFromDisk()

    -------------------------------------------------------------
    -- Popup: ввод имени
    -------------------------------------------------------------
    local function showPrompt(title, placeholder, onConfirm)
        local promptGui = Instance.new("ScreenGui")
        promptGui.Name = "VoidHubPrompt"
        promptGui.ResetOnSpawn = false
        promptGui.DisplayOrder = 100
        promptGui.Parent = playerGui

        local bg = Instance.new("TextButton")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = 0.5
        bg.Text = ""
        bg.AutoButtonColor = false
        bg.Parent = promptGui

        local box = Instance.new("Frame")
        box.Size = UDim2.fromOffset(380, 180)
        box.Position = UDim2.new(0.5, -190, 0.5, -90)
        box.BackgroundColor3 = CONFIG.bgColor
        box.BorderSizePixel = 0
        box.Parent = promptGui
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

        local st = Instance.new("UIStroke")
        st.Color = CONFIG.accentColor
        st.Thickness = 2
        st.Parent = box

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -30, 0, 30)
        lbl.Position = UDim2.new(0, 15, 0, 15)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = CONFIG.textColor
        lbl.TextSize = 15
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = box

        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -30, 0, 40)
        tb.Position = UDim2.new(0, 15, 0, 58)
        tb.BackgroundColor3 = CONFIG.panelColor
        tb.Text = ""
        tb.PlaceholderText = placeholder or ""
        tb.TextColor3 = CONFIG.textColor
        tb.PlaceholderColor3 = CONFIG.textDim
        tb.TextSize = 14
        tb.Font = Enum.Font.Gotham
        tb.ClearTextOnFocus = false
        tb.Parent = box
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

        local ok = Instance.new("TextButton")
        ok.Size = UDim2.fromOffset(120, 36)
        ok.Position = UDim2.new(1, -270, 1, -52)
        ok.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
        ok.Text = "✓ Создать"
        ok.TextColor3 = Color3.new(1,1,1)
        ok.TextSize = 13
        ok.Font = Enum.Font.GothamBold
        ok.Parent = box
        Instance.new("UICorner", ok).CornerRadius = UDim.new(0, 8)

        local cancel = Instance.new("TextButton")
        cancel.Size = UDim2.fromOffset(120, 36)
        cancel.Position = UDim2.new(1, -145, 1, -52)
        cancel.BackgroundColor3 = Color3.fromRGB(90, 45, 55)
        cancel.Text = "✕ Отмена"
        cancel.TextColor3 = Color3.new(1,1,1)
        cancel.TextSize = 13
        cancel.Font = Enum.Font.GothamBold
        cancel.Parent = box
        Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 8)

        task.defer(function() tb:CaptureFocus() end)

        local done = false
        local function finish(save)
            if done then return end
            done = true
            if save and tb.Text ~= "" then
                onConfirm(tb.Text)
            end
            promptGui:Destroy()
        end

        ok.MouseButton1Click:Connect(function() finish(true) end)
        cancel.MouseButton1Click:Connect(function() finish(false) end)
        bg.MouseButton1Click:Connect(function() finish(false) end)
        tb.FocusLost:Connect(function(enter)
            if enter then finish(true) end
        end)
    end

    -------------------------------------------------------------
    -- Popup: список
    -------------------------------------------------------------
    local function showListPopup(title, list, onSelect)
        local promptGui = Instance.new("ScreenGui")
        promptGui.Name = "VoidHubListPrompt"
        promptGui.ResetOnSpawn = false
        promptGui.DisplayOrder = 100
        promptGui.Parent = playerGui

        local bg = Instance.new("TextButton")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = 0.5
        bg.Text = ""
        bg.AutoButtonColor = false
        bg.Parent = promptGui

        local box = Instance.new("Frame")
        box.Size = UDim2.fromOffset(400, 400)
        box.Position = UDim2.new(0.5, -200, 0.5, -200)
        box.BackgroundColor3 = CONFIG.bgColor
        box.BorderSizePixel = 0
        box.Parent = promptGui
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

        local st = Instance.new("UIStroke")
        st.Color = CONFIG.accentColor
        st.Thickness = 2
        st.Parent = box

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -30, 0, 34)
        lbl.Position = UDim2.new(0, 15, 0, 12)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = CONFIG.textColor
        lbl.TextSize = 15
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = box

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -30, 1, -120)
        scroll.Position = UDim2.new(0, 15, 0, 55)
        scroll.BackgroundColor3 = CONFIG.panelColor
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = CONFIG.accentColor
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = box
        Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.Parent = scroll

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.Parent = scroll

        local done = false
        local function close()
            if done then return end
            done = true
            promptGui:Destroy()
        end

        local count = 0
        for name in pairs(list) do
            count = count + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -8, 0, 34)
            b.BackgroundColor3 = CONFIG.cardColor
            b.Text = "  " .. name
            b.TextColor3 = CONFIG.textColor
            b.TextSize = 13
            b.Font = Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = scroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseEnter:Connect(function() b.BackgroundColor3 = CONFIG.cardHover end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = CONFIG.cardColor end)
            b.MouseButton1Click:Connect(function()
                onSelect(name)
                close()
            end)
        end

        if count == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, -8, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "Нет конфигов"
            empty.TextColor3 = CONFIG.textDim
            empty.TextSize = 13
            empty.Font = Enum.Font.Gotham
            empty.Parent = scroll
        end

        local cancel = Instance.new("TextButton")
        cancel.Size = UDim2.fromOffset(120, 34)
        cancel.Position = UDim2.new(0.5, -60, 1, -46)
        cancel.BackgroundColor3 = Color3.fromRGB(90, 45, 55)
        cancel.Text = "✕ Закрыть"
        cancel.TextColor3 = Color3.new(1,1,1)
        cancel.TextSize = 13
        cancel.Font = Enum.Font.GothamBold
        cancel.Parent = box
        Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 8)

        cancel.MouseButton1Click:Connect(close)
        bg.MouseButton1Click:Connect(close)
    end

    -------------------------------------------------------------
    -- Захват / применение
    -------------------------------------------------------------
    local function captureState()
        local state = { toggles = {}, inputs = {}, custom = {} }

        for _, t in ipairs(_G.__VH_CONFIG_REGISTRY.toggles) do
            local ok, val = pcall(t.get)
            if ok then state.toggles[t.name] = val end
        end
        for _, i in ipairs(_G.__VH_CONFIG_REGISTRY.inputs) do
            local ok, val = pcall(i.get)
            if ok then state.inputs[i.name] = val end
        end

        -- 🔥 Кастомные состояния
        for _, c in ipairs(_G.__VH_CONFIG_REGISTRY.custom) do
            local ok, val = pcall(c.get)
            if ok then
                -- Color3 нельзя в JSON — конвертируем
                if typeof(val) == "Color3" then
                    state.custom[c.name] = {
                        __type = "Color3",
                        r = val.R, g = val.G, b = val.B,
                    }
                else
                    state.custom[c.name] = val
                end
            end
        end

        return state
    end

    local function applyState(state)
        if not state then return end

        if state.toggles then
            for _, t in ipairs(_G.__VH_CONFIG_REGISTRY.toggles) do
                if state.toggles[t.name] ~= nil then
                    pcall(function() t.set(state.toggles[t.name]) end)
                end
            end
        end

        if state.inputs then
            for _, i in ipairs(_G.__VH_CONFIG_REGISTRY.inputs) do
                if state.inputs[i.name] ~= nil then
                    pcall(function() i.set(state.inputs[i.name]) end)
                end
            end
        end

        -- 🔥 Кастомные состояния
        if state.custom then
            for _, c in ipairs(_G.__VH_CONFIG_REGISTRY.custom) do
                local val = state.custom[c.name]
                if val ~= nil then
                    -- Color3 разворачиваем
                    if type(val) == "table" and val.__type == "Color3" then
                        val = Color3.new(val.r or 0, val.g or 0, val.b or 0)
                    end
                    pcall(function() c.set(val) end)
                end
            end
        end
    end

    -------------------------------------------------------------
    -- UI
    -------------------------------------------------------------
    makeSectionHeader(scroll11, "📁 Конфиги")

    local statusLabel = makeInfoLabel(scroll11, "Конфигов: 0", CONFIG.textDim)
    local currentLabel = makeInfoLabel(scroll11, "Загружен: —", CONFIG.textDim)
    local folderLabel = makeInfoLabel(scroll11, "Папка: " .. CONFIGS_FOLDER, CONFIG.textDim)

    local function updateStatus()
        local count = 0
        for _ in pairs(configs) do count = count + 1 end
        statusLabel.Text = ("Конфигов: %d"):format(count)
    end
    updateStatus()

    -------------------------------------------------------------
    -- Создать конфиг
    -------------------------------------------------------------
    makeActionRow(scroll11, "💾 Создать конфиг", Color3.fromRGB(50, 130, 80), function()
        showPrompt("Название конфига", "My Config", function(name)
            -- Создаём папку если ещё нет
            _G.__VH_Folder.ensure(CONFIGS_FOLDER)

            local state = captureState()
            configs[name] = state

            local saved = saveOneToDisk(name, state)
            if saved then
                currentLabel.Text = "Создан: " .. name
                currentLabel.TextColor3 = CONFIG.green
                print("[Configs] Создан:", name, "->", CONFIGS_FOLDER .. "/" .. name .. ".json")
            else
                currentLabel.Text = "Создан (в памяти): " .. name
                currentLabel.TextColor3 = CONFIG.orange
                print("[Configs] Создан (без записи):", name)
            end
            updateStatus()
        end)
    end)

    -------------------------------------------------------------
    -- Загрузить
    -------------------------------------------------------------
    makeActionRow(scroll11, "📂 Загрузить конфиг", Color3.fromRGB(60, 90, 180), function()
        configs = loadAllFromDisk()
        updateStatus()

        if next(configs) == nil then
            currentLabel.Text = "Нет конфигов в папке"
            currentLabel.TextColor3 = CONFIG.red
            return
        end

        showListPopup("Выбери конфиг для загрузки", configs, function(name)
            local state = configs[name]
            if not state then return end
            applyState(state)
            currentLabel.Text = "Загружен: " .. name
            currentLabel.TextColor3 = CONFIG.green
            print("[Configs] Загружен:", name)
        end)
    end)

    -------------------------------------------------------------
    -- Удалить
    -------------------------------------------------------------
    makeActionRow(scroll11, "🗑 Удалить конфиг", Color3.fromRGB(120, 50, 60), function()
        configs = loadAllFromDisk()
        updateStatus()

        if next(configs) == nil then
            currentLabel.Text = "Нет конфигов для удаления"
            currentLabel.TextColor3 = CONFIG.red
            return
        end

        showListPopup("Выбери конфиг для удаления", configs, function(name)
            configs[name] = nil
            deleteFromDisk(name)
            updateStatus()
            if currentLabel.Text == "Загружен: " .. name then
                currentLabel.Text = "Загружен: —"
                currentLabel.TextColor3 = CONFIG.textDim
            end
            print("[Configs] Удалён:", name)
        end)
    end)

    -------------------------------------------------------------
    -- Обновить / открыть папку
    -------------------------------------------------------------
    makeActionRow(scroll11, "🔄 Обновить список", CONFIG.cardColor, function()
        configs = loadAllFromDisk()
        updateStatus()
        currentLabel.Text = "Список обновлён"
        currentLabel.TextColor3 = CONFIG.green
    end)

    makeActionRow(scroll11, "📂 Создать папку снова", CONFIG.cardColor, function()
        _G.__VH_Folder.ensure(CONFIGS_FOLDER)
        currentLabel.Text = "Папка проверена: " .. CONFIGS_FOLDER
        currentLabel.TextColor3 = CONFIG.green
    end)

    -------------------------------------------------------------
    -- Очистить всё
    -------------------------------------------------------------
    makeActionRow(scroll11, "❌ Очистить все конфиги", Color3.fromRGB(90, 45, 55), function()
        for name in pairs(configs) do
            deleteFromDisk(name)
        end
        configs = {}
        updateStatus()
        currentLabel.Text = "Загружен: —"
        currentLabel.TextColor3 = CONFIG.textDim
    end)

    makeInfoLabel(scroll11, "Файлы: VoidHub/Configs/имя.json", CONFIG.textDim)
    makeInfoLabel(scroll11, "Работает через makefolder + writefile", CONFIG.textDim)

    print("[Configs] Загружено. Папка: " .. CONFIGS_FOLDER)
end)

print("[DEBUG] VoidHub загрузился ДО КОНЦА")
