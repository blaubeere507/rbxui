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

-- // Theme
local Theme = {
    Background    = Color3.fromRGB(204, 204, 204), -- #cccccc
    TabBar        = Color3.fromRGB(192, 192, 192), -- slightly darker bar
    TabText       = Color3.fromRGB(100, 100, 100), -- inactive tab text
    TabTextActive = Color3.fromRGB(30,  30,  30),  -- active tab text
    Underline     = Color3.fromRGB(50,  50,  50),  -- active tab underline
    TitleText     = Color3.fromRGB(30,  30,  30),
    ContentBg     = Color3.fromRGB(210, 210, 210),
}

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

-- // Window
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

    return windowObj
end

return UILib
