-- ██████╗ ██████╗ ██╗  ██╗██╗   ██╗██╗
-- ██╔══██╗██╔══██╗╚██╗██╔╝██║   ██║██║
-- ██████╔╝██████╔╝ ╚███╔╝ ██║   ██║██║
-- ██╔══██╗██╔══██╗ ██╔██╗ ██║   ██║██║
-- ██║  ██║██████╔╝██╔╝ ██╗╚██████╔╝██║
-- ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝
-- RbxUI — Clean Roblox UI Library
-- Version 1.0.0

local RbxUI = {}
RbxUI.__index = RbxUI

-- ─────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────
-- Theme
-- ─────────────────────────────────────────────
local Theme = {
    -- Backgrounds
    BG          = Color3.fromRGB(12, 12, 14),
    BG_Surface  = Color3.fromRGB(18, 18, 22),
    BG_Card     = Color3.fromRGB(24, 24, 30),
    BG_Hover    = Color3.fromRGB(32, 32, 40),
    BG_Input    = Color3.fromRGB(20, 20, 26),

    -- Borders
    Border      = Color3.fromRGB(45, 45, 58),
    BorderLight = Color3.fromRGB(60, 60, 75),

    -- Text
    TextPrimary   = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(140, 140, 160),
    TextMuted     = Color3.fromRGB(80, 80, 100),

    -- Accents
    AccentBlue  = Color3.fromRGB(100, 149, 237),
    AccentGreen = Color3.fromRGB(80, 200, 120),
    AccentRed   = Color3.fromRGB(255, 95, 87),
    AccentYellow = Color3.fromRGB(255, 189, 68),
    AccentPurple = Color3.fromRGB(155, 120, 255),

    -- macOS Buttons
    CloseRed     = Color3.fromRGB(255, 95, 87),
    MinimizeYellow = Color3.fromRGB(255, 189, 68),
    MaximizeGreen  = Color3.fromRGB(39, 201, 63),

    -- Sidebar
    SidebarBG   = Color3.fromRGB(15, 15, 18),
    SidebarW    = 160,

    -- Fonts
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    FontLight   = Enum.Font.Gotham,
}

-- ─────────────────────────────────────────────
-- Utility
-- ─────────────────────────────────────────────
local function Tween(obj, props, duration, style, dir)
    style    = style or Enum.EasingStyle.Quart
    dir      = dir or Enum.EasingDirection.Out
    duration = duration or 0.2
    local info = TweenInfo.new(duration, style, dir)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(topBar, frame)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position
        end
    end)
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Stroke(color, thickness, parent)
    local s = Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    s.Parent = parent
    return s
end

local function Corner(radius, parent)
    local c = Create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
    c.Parent = parent
    return c
end

local function Padding(t, b, l, r, parent)
    local p = Create("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    })
    p.Parent = parent
    return p
end

-- ─────────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────────
function RbxUI:CreateWindow(config)
    config = config or {}
    local title    = config.Title or "My Script"
    local subtitle = config.Subtitle or "rbxui"
    local size     = config.Size or UDim2.new(0, 640, 0, 480)
    local pos      = config.Position or UDim2.new(0.5, -320, 0.5, -240)
    local game_id  = config.Game or "Roblox"

    local ScreenGui = Create("ScreenGui", {
        Name             = "RbxUI_" .. title,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn     = false,
        IgnoreGuiInset   = true,
        Parent           = PlayerGui,
    })

    -- ── Main Frame ──────────────────────────────
    local Main = Create("Frame", {
        Name            = "Main",
        Size            = size,
        Position        = pos,
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = ScreenGui,
    })
    Corner(12, Main)
    Stroke(Theme.Border, 1, Main)

    -- Entry animation
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)
    task.spawn(function()
        task.wait(0.05)
        Tween(Main, { BackgroundTransparency = 0, Size = size }, 0.35, Enum.EasingStyle.Back)
    end)

    -- ── Top Bar ─────────────────────────────────
    local TopBar = Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.BG_Surface,
        BorderSizePixel  = 0,
        Parent           = Main,
    })
    -- Only round top corners
    Create("UICorner", { CornerRadius = UDim.new(0, 12) }).Parent = TopBar
    -- Hack: cover bottom corners
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.BG_Surface,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })

    -- Bottom separator
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        Parent           = TopBar,
    })

    -- Traffic lights (macOS style)
    local btnHolder = Create("Frame", {
        Size             = UDim2.new(0, 70, 0, 44),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Parent           = TopBar,
    })

    local function TrafficBtn(color, x, action)
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = UDim2.new(0, x, 0.5, -6),
            BackgroundColor3 = color,
            Text             = "",
            BorderSizePixel  = 0,
            Parent           = btnHolder,
        })
        Corner(99, btn)
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.25) }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = color }, 0.1)
        end)
        btn.MouseButton1Click:Connect(action)
        return btn
    end

    local minimized = false
    local savedSize = size
    TrafficBtn(Theme.CloseRed, 0, function()
        Tween(Main, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        ScreenGui:Destroy()
    end)
    TrafficBtn(Theme.MinimizeYellow, 20, function()
        minimized = not minimized
        if minimized then
            savedSize = Main.Size
            Tween(Main, { Size = UDim2.new(0, savedSize.X.Offset, 0, 44) }, 0.3, Enum.EasingStyle.Back)
        else
            Tween(Main, { Size = savedSize }, 0.3, Enum.EasingStyle.Back)
        end
    end)
    TrafficBtn(Theme.MaximizeGreen, 40, function()
        -- Fullscreen toggle
        local full = UDim2.new(1, 0, 1, 0)
        if Main.Size == full then
            Tween(Main, { Size = savedSize, Position = pos }, 0.3, Enum.EasingStyle.Back)
        else
            savedSize = Main.Size
            Tween(Main, { Size = full, Position = UDim2.new(0,0,0,0) }, 0.3, Enum.EasingStyle.Back)
        end
    end)

    -- Title
    Create("TextLabel", {
        Size             = UDim2.new(1, -160, 1, 0),
        Position         = UDim2.new(0, 80, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        Font             = Theme.FontBold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Center,
        Parent           = TopBar,
    })

    MakeDraggable(TopBar, Main)

    -- ── Sidebar ─────────────────────────────────
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, Theme.SidebarW, 1, -44),
        Position         = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.SidebarBG,
        BorderSizePixel  = 0,
        Parent           = Main,
    })

    -- Right border
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        Parent           = Sidebar,
    })

    -- Avatar area
    local AvatarArea = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 72),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BG_Card,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        Parent           = AvatarArea,
    })

    -- Avatar image (uses thumbnail API)
    local userId = LocalPlayer.UserId
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=48&height=48&format=png"
    local AvatarImg = Create("ImageLabel", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 12, 0.5, -16),
        BackgroundColor3 = Theme.Border,
        Image            = "rbxthumb:type=AvatarHeadShot&id=" .. userId .. "&w=48&h=48",
        Parent           = AvatarArea,
    })
    Corner(99, AvatarImg)

    Create("TextLabel", {
        Size             = UDim2.new(1, -56, 0, 16),
        Position         = UDim2.new(0, 52, 0.5, -15),
        BackgroundTransparency = 1,
        Text             = LocalPlayer.DisplayName,
        TextColor3       = Theme.TextPrimary,
        Font             = Theme.FontBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
        Parent           = AvatarArea,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -56, 0, 13),
        Position         = UDim2.new(0, 52, 0.5, 3),
        BackgroundTransparency = 1,
        Text             = "@" .. LocalPlayer.Name,
        TextColor3       = Theme.TextMuted,
        Font             = Theme.FontLight,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
        Parent           = AvatarArea,
    })

    -- Tab list
    local TabList = Create("ScrollingFrame", {
        Name             = "TabList",
        Size             = UDim2.new(1, 0, 1, -110),
        Position         = UDim2.new(0, 0, 0, 72),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent           = Sidebar,
    })
    Padding(6, 6, 0, 0, TabList)
    Create("UIListLayout", {
        Padding          = UDim.new(0, 2),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = TabList,
    })

    -- Bottom branding
    local Branding = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        Position         = UDim2.new(0, 0, 1, -38),
        BackgroundColor3 = Theme.SidebarBG,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Border,
        Parent           = Branding,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "ROBLOX",
        TextColor3       = Theme.TextMuted,
        Font             = Theme.FontBold,
        TextSize         = 11,
        LetterSpacing    = 4,
        Parent           = Branding,
    })

    -- ── Content Area ────────────────────────────
    local ContentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -Theme.SidebarW, 1, -44),
        Position         = UDim2.new(0, Theme.SidebarW, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Main,
    })

    -- ── Window Object ────────────────────────────
    local WindowObj = {
        _gui        = ScreenGui,
        _main       = Main,
        _tabList    = TabList,
        _content    = ContentArea,
        _tabs       = {},
        _activeTab  = nil,
    }

    function WindowObj:SelectTab(tab)
        for _, t in ipairs(self._tabs) do
            local isActive = t == tab
            -- Sidebar button
            Tween(t._btn, {
                BackgroundColor3 = isActive and Theme.BG_Hover or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isActive and 0 or 1,
            }, 0.15)
            Tween(t._btnLabel, {
                TextColor3 = isActive and Theme.TextPrimary or Theme.TextSecondary,
            }, 0.15)
            -- Page
            t._page.Visible = isActive
        end
        self._activeTab = tab
    end

    function WindowObj:AddTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or "rbxassetid://0"

        -- Sidebar button
        local Btn = Create("TextButton", {
            Size             = UDim2.new(1, -12, 0, 32),
            BackgroundColor3 = Theme.BG_Hover,
            BackgroundTransparency = 1,
            Text             = "",
            BorderSizePixel  = 0,
            Parent           = self._tabList,
        })
        Corner(7, Btn)
        Padding(0, 0, 10, 10, Btn)

        local BtnLabel = Create("TextLabel", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = tabName,
            TextColor3       = Theme.TextSecondary,
            Font             = Theme.Font,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = Btn,
        })

        -- Page
        local Page = Create("ScrollingFrame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible          = false,
            Parent           = self._content,
        })
        Padding(12, 12, 14, 14, Page)
        Create("UIListLayout", {
            Padding  = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent   = Page,
        })

        local tabObj = {
            _btn      = Btn,
            _btnLabel = BtnLabel,
            _page     = Page,
            _sections = {},
        }

        -- Hover effects
        Btn.MouseEnter:Connect(function()
            if self._activeTab ~= tabObj then
                Tween(Btn, { BackgroundTransparency = 0.7 }, 0.1)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if self._activeTab ~= tabObj then
                Tween(Btn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)
        Btn.MouseButton1Click:Connect(function()
            self:SelectTab(tabObj)
        end)

        table.insert(self._tabs, tabObj)
        if #self._tabs == 1 then
            self:SelectTab(tabObj)
        end

        -- ── Section ───────────────────────────────
        function tabObj:AddSection(config)
            config = config or {}
            local secTitle = config.Title or "Section"

            local Section = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.BG_Card,
                AutomaticSize    = Enum.AutomaticSize.Y,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Corner(10, Section)
            Stroke(Theme.Border, 1, Section)
            Padding(10, 10, 14, 14, Section)

            local Layout = Create("UIListLayout", {
                Padding  = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent   = Section,
            })

            -- Section title
            Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text             = secTitle:upper(),
                TextColor3       = Theme.TextMuted,
                Font             = Theme.FontBold,
                TextSize         = 10,
                LetterSpacing    = 3,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LayoutOrder      = -999,
                Parent           = Section,
            })

            -- Separator
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                LayoutOrder      = -998,
                Parent           = Section,
            })

            local SecObj = { _frame = Section }

            -- ── Row helper ──────────────────────────
            local function MakeRow(label, desc)
                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent           = Section,
                })
                Create("TextLabel", {
                    Size             = UDim2.new(0.5, 0, 0, 18),
                    Position         = UDim2.new(0, 0, 0.5, -9),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = Row,
                })
                if desc then
                    Row.Size = UDim2.new(1, 0, 0, 48)
                    Create("TextLabel", {
                        Size             = UDim2.new(0.6, 0, 0, 14),
                        Position         = UDim2.new(0, 0, 0, 22),
                        BackgroundTransparency = 1,
                        Text             = desc,
                        TextColor3       = Theme.TextMuted,
                        Font             = Theme.FontLight,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        Parent           = Row,
                    })
                end
                return Row
            end

            -- ════════════════════════════════════════
            -- Toggle
            -- ════════════════════════════════════════
            function SecObj:AddToggle(config)
                config = config or {}
                local label    = config.Label or "Toggle"
                local desc     = config.Description
                local default  = config.Default or false
                local callback = config.Callback or function() end

                local Row = MakeRow(label, desc)
                local state = default

                local Track = Create("TextButton", {
                    Size             = UDim2.new(0, 40, 0, 22),
                    Position         = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = state and Theme.AccentBlue or Theme.BG_Input,
                    Text             = "",
                    BorderSizePixel  = 0,
                    Parent           = Row,
                })
                Corner(99, Track)
                Stroke(state and Theme.AccentBlue or Theme.Border, 1, Track)

                local Thumb = Create("Frame", {
                    Size             = UDim2.new(0, 16, 0, 16),
                    Position         = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = state and Color3.new(1,1,1) or Theme.TextMuted,
                    BorderSizePixel  = 0,
                    Parent           = Track,
                })
                Corner(99, Thumb)

                local function SetState(newState)
                    state = newState
                    Tween(Track, {
                        BackgroundColor3 = state and Theme.AccentBlue or Theme.BG_Input,
                    }, 0.2)
                    Tween(Thumb, {
                        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                        BackgroundColor3 = state and Color3.new(1,1,1) or Theme.TextMuted,
                    }, 0.2)
                    pcall(callback, state)
                end

                Track.MouseButton1Click:Connect(function()
                    SetState(not state)
                end)

                return {
                    Set = SetState,
                    Get = function() return state end,
                }
            end

            -- ════════════════════════════════════════
            -- Slider
            -- ════════════════════════════════════════
            function SecObj:AddSlider(config)
                config = config or {}
                local label    = config.Label or "Slider"
                local desc     = config.Description
                local min      = config.Min or 0
                local max      = config.Max or 100
                local default  = config.Default or min
                local suffix   = config.Suffix or ""
                local callback = config.Callback or function() end

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    Parent           = Section,
                })

                -- Label row
                Create("TextLabel", {
                    Size             = UDim2.new(0.6, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = Row,
                })

                local ValueLabel = Create("TextLabel", {
                    Size             = UDim2.new(0.4, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = tostring(default) .. suffix,
                    TextColor3       = Theme.AccentBlue,
                    Font             = Theme.FontBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    Parent           = Row,
                })

                -- Track
                local TrackBG = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 4),
                    Position         = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = Theme.BG_Input,
                    BorderSizePixel  = 0,
                    Parent           = Row,
                })
                Corner(99, TrackBG)

                local TrackFill = Create("Frame", {
                    Size             = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.AccentBlue,
                    BorderSizePixel  = 0,
                    Parent           = TrackBG,
                })
                Corner(99, TrackFill)

                local Handle = Create("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                    Parent           = TrackBG,
                })
                Corner(99, Handle)

                -- Hover area
                local HitBox = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 20),
                    Position         = UDim2.new(0, 0, 0.5, -10),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 10,
                    Parent           = TrackBG,
                })

                local value = default
                local dragging = false

                local function UpdateSlider(input)
                    local abs = TrackBG.AbsolutePosition
                    local size = TrackBG.AbsoluteSize
                    local rel = math.clamp((input.Position.X - abs.X) / size.X, 0, 1)
                    value = math.floor(min + (max - min) * rel + 0.5)
                    local pct = (value - min) / (max - min)
                    TrackFill.Size = UDim2.new(pct, 0, 1, 0)
                    Handle.Position = UDim2.new(pct, -7, 0.5, -7)
                    ValueLabel.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end

                HitBox.MouseButton1Down:Connect(function()
                    dragging = true
                    Tween(Handle, { Size = UDim2.new(0, 18, 0, 18) }, 0.1)
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if dragging then
                            dragging = false
                            Tween(Handle, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
                        end
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                HitBox.MouseButton1Click:Connect(function()
                    local input = UserInputService:GetMouseLocation()
                    UpdateSlider({ Position = Vector3.new(input.X, input.Y, 0) })
                end)

                return {
                    Set = function(v)
                        value = math.clamp(v, min, max)
                        local pct = (value - min) / (max - min)
                        TrackFill.Size = UDim2.new(pct, 0, 1, 0)
                        Handle.Position = UDim2.new(pct, -7, 0.5, -7)
                        ValueLabel.Text = tostring(value) .. suffix
                    end,
                    Get = function() return value end,
                }
            end

            -- ════════════════════════════════════════
            -- Dropdown
            -- ════════════════════════════════════════
            function SecObj:AddDropdown(config)
                config = config or {}
                local label    = config.Label or "Dropdown"
                local options  = config.Options or {}
                local default  = config.Default or options[1] or "Select..."
                local callback = config.Callback or function() end

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex           = 50,
                    Parent           = Section,
                })

                Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = Row,
                })

                local DropBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    Position         = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Theme.BG_Input,
                    Text             = "",
                    BorderSizePixel  = 0,
                    ZIndex           = 51,
                    Parent           = Row,
                })
                Corner(8, DropBtn)
                Stroke(Theme.Border, 1, DropBtn)

                local DropLabel = Create("TextLabel", {
                    Size             = UDim2.new(1, -30, 1, 0),
                    Position         = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = default,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 52,
                    Parent           = DropBtn,
                })

                -- Arrow
                Create("TextLabel", {
                    Size             = UDim2.new(0, 20, 1, 0),
                    Position         = UDim2.new(1, -26, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = "⌄",
                    TextColor3       = Theme.TextMuted,
                    Font             = Theme.FontBold,
                    TextSize         = 14,
                    ZIndex           = 52,
                    Parent           = DropBtn,
                })

                -- Dropdown list
                local ListFrame = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    Position         = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Theme.BG_Card,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    ZIndex           = 100,
                    Visible          = false,
                    Parent           = DropBtn,
                })
                Corner(8, ListFrame)
                Stroke(Theme.Border, 1, ListFrame)
                Padding(4, 4, 0, 0, ListFrame)
                Create("UIListLayout", {
                    Padding  = UDim.new(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent   = ListFrame,
                })

                local isOpen = false
                local selected = default

                local function CloseDropdown()
                    isOpen = false
                    Tween(ListFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    task.wait(0.15)
                    ListFrame.Visible = false
                end

                -- Populate items
                for i, opt in ipairs(options) do
                    local Item = Create("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.BG_Card,
                        BackgroundTransparency = 1,
                        Text             = opt,
                        TextColor3       = opt == selected and Theme.TextPrimary or Theme.TextSecondary,
                        Font             = opt == selected and Theme.FontBold or Theme.Font,
                        TextSize         = 13,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        ZIndex           = 101,
                        Parent           = ListFrame,
                    })
                    Padding(0, 0, 10, 10, Item)
                    Corner(6, Item)
                    Item.MouseEnter:Connect(function()
                        Tween(Item, { BackgroundTransparency = 0.85 }, 0.1)
                    end)
                    Item.MouseLeave:Connect(function()
                        Tween(Item, { BackgroundTransparency = 1 }, 0.1)
                    end)
                    Item.MouseButton1Click:Connect(function()
                        selected = opt
                        DropLabel.Text = opt
                        CloseDropdown()
                        pcall(callback, opt)
                    end)
                end

                local fullHeight = #options * 31 + 8

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        ListFrame.Visible = true
                        Tween(ListFrame, { Size = UDim2.new(1, 0, 0, fullHeight) }, 0.2, Enum.EasingStyle.Back)
                    else
                        CloseDropdown()
                    end
                end)

                return {
                    Set = function(v) selected = v; DropLabel.Text = v end,
                    Get = function() return selected end,
                }
            end

            -- ════════════════════════════════════════
            -- Button
            -- ════════════════════════════════════════
            function SecObj:AddButton(config)
                config = config or {}
                local label    = config.Label or "Button"
                local desc     = config.Description
                local callback = config.Callback or function() end
                local style    = config.Style or "default" -- "default" | "primary" | "danger"

                local accentColor = (style == "primary" and Theme.AccentBlue)
                    or (style == "danger" and Theme.AccentRed)
                    or Theme.BG_Hover

                local Btn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = accentColor,
                    Text             = "",
                    BorderSizePixel  = 0,
                    Parent           = Section,
                })
                Corner(8, Btn)
                if style == "default" then
                    Stroke(Theme.Border, 1, Btn)
                end

                Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = style == "default" and Theme.TextSecondary or Color3.new(1,1,1),
                    Font             = Theme.Font,
                    TextSize         = 13,
                    Parent           = Btn,
                })

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundColor3 = accentColor:Lerp(Color3.new(1,1,1), 0.08) }, 0.1)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundColor3 = accentColor }, 0.1)
                end)
                Btn.MouseButton1Down:Connect(function()
                    Tween(Btn, { Size = UDim2.new(1, -4, 0, 32) }, 0.08)
                end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(Btn, { Size = UDim2.new(1, 0, 0, 34) }, 0.12, Enum.EasingStyle.Back)
                end)
                Btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)

                return Btn
            end

            -- ════════════════════════════════════════
            -- TextInput
            -- ════════════════════════════════════════
            function SecObj:AddTextInput(config)
                config = config or {}
                local label       = config.Label or "Input"
                local placeholder = config.Placeholder or "Type here..."
                local default     = config.Default or ""
                local callback    = config.Callback or function() end

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    Parent           = Section,
                })

                Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = Row,
                })

                local InputBox = Create("TextBox", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    Position         = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Theme.BG_Input,
                    Text             = default,
                    PlaceholderText  = placeholder,
                    TextColor3       = Theme.TextPrimary,
                    PlaceholderColor3 = Theme.TextMuted,
                    Font             = Theme.Font,
                    TextSize         = 13,
                    BorderSizePixel  = 0,
                    ClearTextOnFocus = false,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = Row,
                })
                Corner(8, InputBox)
                Padding(0, 0, 10, 10, InputBox)
                local stroke = Stroke(Theme.Border, 1, InputBox)

                InputBox.Focused:Connect(function()
                    Tween(stroke, { Color = Theme.AccentBlue }, 0.15)
                end)
                InputBox.FocusLost:Connect(function(enter)
                    Tween(stroke, { Color = Theme.Border }, 0.15)
                    pcall(callback, InputBox.Text, enter)
                end)

                return {
                    Set = function(v) InputBox.Text = v end,
                    Get = function() return InputBox.Text end,
                }
            end

            -- ════════════════════════════════════════
            -- Label / Paragraph
            -- ════════════════════════════════════════
            function SecObj:AddLabel(config)
                config = config or {}
                local text  = config.Text or ""
                local color = config.Color or Theme.TextSecondary
                local size  = config.TextSize or 13

                local Lbl = Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text             = text,
                    TextColor3       = color,
                    Font             = Theme.FontLight,
                    TextSize         = size,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Parent           = Section,
                })
                return {
                    Set = function(v) Lbl.Text = v end,
                    Get = function() return Lbl.Text end,
                }
            end

            -- ════════════════════════════════════════
            -- Keybind
            -- ════════════════════════════════════════
            function SecObj:AddKeybind(config)
                config = config or {}
                local label    = config.Label or "Keybind"
                local default  = config.Default or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end

                local Row = MakeRow(label)
                local bound = default
                local listening = false

                local BindBtn = Create("TextButton", {
                    Size             = UDim2.new(0, 80, 0, 24),
                    Position         = UDim2.new(1, -80, 0.5, -12),
                    BackgroundColor3 = Theme.BG_Input,
                    Text             = default.Name,
                    TextColor3       = Theme.AccentBlue,
                    Font             = Theme.Font,
                    TextSize         = 12,
                    BorderSizePixel  = 0,
                    Parent           = Row,
                })
                Corner(6, BindBtn)
                Stroke(Theme.Border, 1, BindBtn)

                BindBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = Theme.AccentYellow
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gpe)
                        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                            bound = input.KeyCode
                            BindBtn.Text = input.KeyCode.Name
                            BindBtn.TextColor3 = Theme.AccentBlue
                            listening = false
                            conn:Disconnect()
                        end
                    end)
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and not listening and input.KeyCode == bound then
                        pcall(callback, bound)
                    end
                end)

                return {
                    Get = function() return bound end,
                }
            end

            table.insert(self._sections, SecObj)
            return SecObj
        end

        return tabObj
    end

    return WindowObj
end

return RbxUI
