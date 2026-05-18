-- UILib.lua
-- A clean, light gray Roblox UI Library
-- Usage: local UILib = loadstring(...)()

local UILib = {}
UILib.__index = UILib

-- // Services
local Players         = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- // Themes
local Themes = {
    Light = {
        Background    = Color3.fromRGB(204, 204, 204),
        TabBar        = Color3.fromRGB(192, 192, 192),
        TabText       = Color3.fromRGB(100, 100, 100),
        TabTextActive = Color3.fromRGB(30,  30,  30),
        Underline     = Color3.fromRGB(50,  50,  50),
        TitleText     = Color3.fromRGB(30,  30,  30),
        ContentBg     = Color3.fromRGB(210, 210, 210),
        ToggleBg      = Color3.fromRGB(180, 180, 180),
        ToggleOn      = Color3.fromRGB(80,  80,  80),
        ToggleKnob    = Color3.fromRGB(255, 255, 255),
        ItemLabel     = Color3.fromRGB(40,  40,  40),
    },
    Dark = {
        Background    = Color3.fromRGB(30,  30,  30),
        TabBar        = Color3.fromRGB(24,  24,  24),
        TabText       = Color3.fromRGB(130, 130, 130),
        TabTextActive = Color3.fromRGB(220, 220, 220),
        Underline     = Color3.fromRGB(200, 200, 200),
        TitleText     = Color3.fromRGB(220, 220, 220),
        ContentBg     = Color3.fromRGB(36,  36,  36),
        ToggleBg      = Color3.fromRGB(60,  60,  60),
        ToggleOn      = Color3.fromRGB(180, 180, 180),
        ToggleKnob    = Color3.fromRGB(220, 220, 220),
        ItemLabel     = Color3.fromRGB(210, 210, 210),
    },
}

local Theme = Themes.Light -- active theme (starts light)
local IsDark = false

-- // Utility: make a draggable frame
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- // Theme registry: all themed elements across all windows
local ThemedElements = {}

local function RegisterThemed(element, property, themeKey)
    table.insert(ThemedElements, { element = element, property = property, themeKey = themeKey })
end

local function ApplyTheme(newTheme)
    Theme = newTheme
    for _, entry in ipairs(ThemedElements) do
        if entry.element and entry.element.Parent then
            entry.element[entry.property] = Theme[entry.themeKey]
        end
    end
end

function UILib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "UILib"
    local size  = config.Size  or UDim2.new(0, 480, 0, 380)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name             = "UILib_" .. title
    screenGui.ResetOnSpawn     = false
    screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    screenGui.Parent           = PlayerGui

    -- Main window frame
    local window = Instance.new("Frame")
    window.Name            = "Window"
    window.Size            = size
    window.Position        = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    window.BackgroundColor3 = Theme.Background
    window.BorderSizePixel  = 0
    window.Parent           = screenGui

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 6)
    windowCorner.Parent = window

    -- Title bar (also the drag handle)
    local titleBar = Instance.new("Frame")
    titleBar.Name              = "TitleBar"
    titleBar.Size              = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3  = Theme.TabBar
    titleBar.BorderSizePixel   = 0
    titleBar.Parent            = window

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 6)
    titleBarCorner.Parent = titleBar

    -- Patch bottom corners of title bar (so only top is rounded)
    local titleBarPatch = Instance.new("Frame")
    titleBarPatch.Size             = UDim2.new(1, 0, 0, 6)
    titleBarPatch.Position         = UDim2.new(0, 0, 1, -6)
    titleBarPatch.BackgroundColor3 = Theme.TabBar
    titleBarPatch.BorderSizePixel  = 0
    titleBarPatch.Parent           = titleBar

    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text              = title
    titleLabel.Size              = UDim2.new(1, -16, 1, 0)
    titleLabel.Position          = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3        = Theme.TitleText
    titleLabel.TextSize          = 14
    titleLabel.Font               = Enum.Font.GothamBold
    titleLabel.TextXAlignment     = Enum.TextXAlignment.Left
    titleLabel.Parent             = titleBar

    -- Register elements for live theme switching
    RegisterThemed(window,       "BackgroundColor3", "Background")
    RegisterThemed(titleBar,     "BackgroundColor3", "TabBar")
    RegisterThemed(titleBarPatch,"BackgroundColor3", "TabBar")
    RegisterThemed(titleLabel,   "TextColor3",       "TitleText")
    RegisterThemed(tabBar,       "BackgroundColor3", "TabBar")
    RegisterThemed(contentArea,  "BackgroundColor3", "ContentBg")

    -- Make draggable via the title bar
    MakeDraggable(window, titleBar)

    -- Tab bar (sits below title bar)
    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(1, 0, 0, 32)
    tabBar.Position         = UDim2.new(0, 0, 0, 36)
    tabBar.BackgroundColor3 = Theme.TabBar
    tabBar.BorderSizePixel  = 0
    tabBar.Parent           = window

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection  = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder      = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding        = UDim.new(0, 0)
    tabBarLayout.Parent         = tabBar

    -- Content area (below tab bar)
    local contentArea = Instance.new("Frame")
    contentArea.Name             = "ContentArea"
    contentArea.Size             = UDim2.new(1, 0, 1, -68) -- full height minus titleBar+tabBar
    contentArea.Position         = UDim2.new(0, 0, 0, 68)
    contentArea.BackgroundColor3 = Theme.ContentBg
    contentArea.BorderSizePixel  = 0
    contentArea.Parent           = window

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentArea

    -- Window object returned to the user
    local windowObj = {
        _screenGui   = screenGui,
        _window      = window,
        _tabBar      = tabBar,
        _contentArea = contentArea,
        _tabs        = {},       -- list of tab objects
        _activeTab   = nil,
    }

    -- // AddTab
    function windowObj:AddTab(tabName)
        local tabs        = self._tabs
        local tabBarRef   = self._tabBar
        local contentRef  = self._contentArea
        local isFirstTab  = #tabs == 0

        -- Tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Text              = tabName
        tabBtn.Size              = UDim2.new(0, 80, 1, 0)
        tabBtn.BackgroundTransparency = 1
        tabBtn.TextColor3        = Theme.TabText
        tabBtn.TextSize          = 13
        tabBtn.Font              = Enum.Font.Gotham
        tabBtn.BorderSizePixel   = 0
        tabBtn.LayoutOrder        = #tabs + 1
        tabBtn.Parent            = tabBarRef

        -- Underline indicator
        local underline = Instance.new("Frame")
        underline.Name             = "Underline"
        underline.Size             = UDim2.new(1, 0, 0, 2)
        underline.Position         = UDim2.new(0, 0, 1, -2)
        underline.BackgroundColor3 = Theme.Underline
        underline.BorderSizePixel  = 0
        underline.Visible          = false
        underline.Parent           = tabBtn

        -- Content page for this tab
        local page = Instance.new("ScrollingFrame")
        page.Name                = tabName .. "_Page"
        page.Size                = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel     = 0
        page.ScrollBarThickness  = 4
        page.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
        page.Visible             = false
        page.Parent              = contentRef

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        pageLayout.Padding    = UDim.new(0, 6)
        pageLayout.Parent     = page

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingTop    = UDim.new(0, 8)
        pagePadding.PaddingLeft   = UDim.new(0, 10)
        pagePadding.PaddingRight  = UDim.new(0, 10)
        pagePadding.PaddingBottom = UDim.new(0, 8)
        pagePadding.Parent = page

        -- Auto-resize scrolling frame
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 16)
        end)

        local tabObj = {
            _btn       = tabBtn,
            _underline = underline,
            _page      = page,
            _name      = tabName,
            _itemCount = 0,
        }

        -- Register for theming
        RegisterThemed(tabBtn,    "TextColor3", "TabText")
        RegisterThemed(underline, "BackgroundColor3", "Underline")

        -- Tab click: switch active tab
        tabBtn.MouseButton1Click:Connect(function()
            windowObj:_SetActiveTab(tabObj)
        end)

        table.insert(tabs, tabObj)

        -- Auto-select the first tab
        if isFirstTab then
            windowObj:_SetActiveTab(tabObj)
        end

        return tabObj
    end

    -- Internal: switch active tab
    function windowObj:_SetActiveTab(tabObj)
        -- Deactivate all tabs
        for _, t in ipairs(self._tabs) do
            t._page.Visible      = false
            t._underline.Visible = false
            t._btn.TextColor3    = Theme.TabText
            t._btn.Font          = Enum.Font.Gotham
        end
        -- Activate selected tab
        tabObj._page.Visible      = true
        tabObj._underline.Visible = true
        tabObj._btn.TextColor3    = Theme.TabTextActive
        tabObj._btn.Font          = Enum.Font.GothamBold
        self._activeTab           = tabObj
    end

    -- // Built-in Settings tab (always last)
    local settingsTab = windowObj:AddTab("Settings")

    -- Dark mode toggle row
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.BorderSizePixel  = 0
    row.LayoutOrder      = 1
    row.Parent           = settingsTab._page

    local rowLabel = Instance.new("TextLabel")
    rowLabel.Text      = "Dark Mode"
    rowLabel.Size      = UDim2.new(1, -60, 1, 0)
    rowLabel.Position  = UDim2.new(0, 0, 0, 0)
    rowLabel.BackgroundTransparency = 1
    rowLabel.TextColor3 = Theme.ItemLabel
    rowLabel.TextSize   = 13
    rowLabel.Font       = Enum.Font.Gotham
    rowLabel.TextXAlignment = Enum.TextXAlignment.Left
    rowLabel.Parent    = row
    RegisterThemed(rowLabel, "TextColor3", "ItemLabel")

    -- Toggle pill
    local toggleBg = Instance.new("Frame")
    toggleBg.Size             = UDim2.new(0, 40, 0, 20)
    toggleBg.Position         = UDim2.new(1, -44, 0.5, -10)
    toggleBg.BackgroundColor3 = Theme.ToggleBg
    toggleBg.BorderSizePixel  = 0
    toggleBg.Parent           = row
    RegisterThemed(toggleBg, "BackgroundColor3", "ToggleBg")

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.ToggleKnob
    knob.BorderSizePixel  = 0
    knob.Parent           = toggleBg
    RegisterThemed(knob, "BackgroundColor3", "ToggleKnob")

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Clickable overlay on toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size             = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text             = ""
    toggleBtn.Parent           = toggleBg

    toggleBtn.MouseButton1Click:Connect(function()
        IsDark = not IsDark
        local newTheme = IsDark and Themes.Dark or Themes.Light
        ApplyTheme(newTheme)

        -- Animate knob
        local targetPos = IsDark
            and UDim2.new(1, -17, 0.5, -7)
            or  UDim2.new(0, 3,   0.5, -7)
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = targetPos }):Play()

        -- Active tab text color needs manual refresh since it overrides theme
        for _, t in ipairs(windowObj._tabs) do
            if t == windowObj._activeTab then
                t._btn.TextColor3 = Theme.TabTextActive
                t._btn.Font       = Enum.Font.GothamBold
            else
                t._btn.TextColor3 = Theme.TabText
                t._btn.Font       = Enum.Font.Gotham
            end
        end
    end)

    -- // RShift to toggle window visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            window.Visible = not window.Visible
        end
    end)

    return windowObj
end

return UILib
