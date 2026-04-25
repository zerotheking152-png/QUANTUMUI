-- // =====================================================
-- //  QUANTUM UI v2.0 - Rewritten & Enhanced
-- //  Modular | Feature-Rich | Smooth Animations
-- // =====================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Cleanup existing
local existing = LocalPlayer.PlayerGui:FindFirstChild("QuantumUI_v2")
if existing then existing:Destroy() end

-- =====================================================
--  CONFIGURATION
-- =====================================================
local Config = {
    Name = "Quantum UI",
    Size = UDim2.new(0, 500, 0, 350),
    Position = UDim2.new(0.5, -250, 0.5, -175),
    CornerRadius = UDim.new(0, 14),
    AnimationSpeed = 0.35,
    FastAnimation = 0.2,
}

-- =====================================================
--  THEME SYSTEM
-- =====================================================
local Themes = {
    CyberGreen = {
        Primary = Color3.fromRGB(0, 255, 136),
        PrimarySoft = Color3.fromRGB(0, 220, 120),
        PrimaryDark = Color3.fromRGB(0, 180, 90),
        Background = Color3.fromRGB(12, 14, 18),
        Surface = Color3.fromRGB(18, 22, 28),
        SurfaceHover = Color3.fromRGB(28, 34, 42),
        Element = Color3.fromRGB(24, 28, 36),
        ElementHover = Color3.fromRGB(32, 38, 48),
        TextPrimary = Color3.fromRGB(245, 250, 255),
        TextSecondary = Color3.fromRGB(160, 170, 180),
        TextDark = Color3.fromRGB(100, 110, 120),
        Danger = Color3.fromRGB(255, 70, 70),
        DangerSoft = Color3.fromRGB(255, 100, 100),
        Success = Color3.fromRGB(0, 255, 136),
        GlowTransparency = 0.85,
        StrokeTransparency = 0.75,
    },
    Crimson = {
        Primary = Color3.fromRGB(255, 60, 80),
        PrimarySoft = Color3.fromRGB(255, 90, 110),
        PrimaryDark = Color3.fromRGB(200, 40, 60),
        Background = Color3.fromRGB(14, 10, 12),
        Surface = Color3.fromRGB(22, 16, 18),
        SurfaceHover = Color3.fromRGB(34, 24, 28),
        Element = Color3.fromRGB(28, 20, 24),
        ElementHover = Color3.fromRGB(40, 28, 32),
        TextPrimary = Color3.fromRGB(255, 245, 247),
        TextSecondary = Color3.fromRGB(180, 160, 170),
        TextDark = Color3.fromRGB(120, 100, 110),
        Danger = Color3.fromRGB(255, 50, 50),
        DangerSoft = Color3.fromRGB(255, 80, 80),
        Success = Color3.fromRGB(0, 255, 136),
        GlowTransparency = 0.85,
        StrokeTransparency = 0.75,
    },
    Midnight = {
        Primary = Color3.fromRGB(88, 160, 255),
        PrimarySoft = Color3.fromRGB(120, 180, 255),
        PrimaryDark = Color3.fromRGB(60, 130, 220),
        Background = Color3.fromRGB(10, 12, 16),
        Surface = Color3.fromRGB(16, 20, 26),
        SurfaceHover = Color3.fromRGB(26, 32, 42),
        Element = Color3.fromRGB(22, 26, 34),
        ElementHover = Color3.fromRGB(30, 36, 48),
        TextPrimary = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(150, 165, 185),
        TextDark = Color3.fromRGB(100, 115, 135),
        Danger = Color3.fromRGB(255, 70, 90),
        DangerSoft = Color3.fromRGB(255, 100, 120),
        Success = Color3.fromRGB(0, 255, 136),
        GlowTransparency = 0.85,
        StrokeTransparency = 0.75,
    }
}

local Theme = Themes.CyberGreen

-- =====================================================
--  UTILITY FUNCTIONS
-- =====================================================
local Utility = {}

function Utility:Tween(obj, props, duration, easingStyle, easingDir, callback)
    duration = duration or Config.AnimationSpeed
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDir = easingDir or Enum.EasingDirection.Out

    local tween = TweenService:Create(obj, TweenInfo.new(duration, easingStyle, easingDir), props)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Utility:TweenFast(obj, props, callback)
    return self:Tween(obj, props, Config.FastAnimation, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, callback)
end

function Utility:Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

function Utility:RoundCorner(obj, radius)
    radius = radius or Config.CornerRadius
    return Utility:Create("UICorner", {CornerRadius = radius}, obj)
end

function Utility:Stroke(obj, color, thickness, transparency)
    return Utility:Create("UIStroke", {
        Color = color or Theme.Primary,
        Thickness = thickness or 1,
        Transparency = transparency or Theme.StrokeTransparency,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

function Utility:Shadow(obj, color)
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 50, 1, 50),
        ZIndex = obj.ZIndex - 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = color or Theme.Primary,
        ImageTransparency = Theme.GlowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, obj)
    return shadow
end

-- =====================================================
--  NOTIFICATION SYSTEM
-- =====================================================
local NotificationSystem = {}
NotificationSystem.Queue = {}
NotificationSystem.Active = false

function NotificationSystem:Init(parent)
    self.Container = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -320, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = parent
    }, parent)

    self.Layout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder
    }, self.Container)
end

function NotificationSystem:Notify(text, duration, ntype)
    duration = duration or 3
    ntype = ntype or "info"

    local colors = {
        info = Theme.Primary,
        success = Theme.Success,
        error = Theme.Danger,
        warning = Color3.fromRGB(255, 180, 0)
    }
    local color = colors[ntype] or Theme.Primary

    local notif = Utility:Create("Frame", {
        Size = UDim2.new(0, 280, 0, 60),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0, 0),
        ZIndex = 101
    }, self.Container)

    Utility:RoundCorner(notif, UDim.new(0, 10))
    Utility:Stroke(notif, color, 1.5, 0.6)

    local accent = Utility:Create("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 102
    }, notif)
    Utility:RoundCorner(accent, UDim.new(0, 2))

    local title = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = "Quantum",
        TextColor3 = color,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102
    }, notif)

    local msg = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 102
    }, notif)

    Utility:Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        Utility:Tween(notif, {Position = UDim2.new(1, 20, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            notif:Destroy()
        end)
    end)
end

-- =====================================================
--  MAIN GUI CONSTRUCTION
-- =====================================================
local ScreenGui = Utility:Create("ScreenGui", {
    Name = "QuantumUI_v2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LocalPlayer:WaitForChild("PlayerGui")
})

NotificationSystem:Init(ScreenGui)

local MainFrame = Utility:Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
    ZIndex = 10,
    Parent = ScreenGui
})

Utility:RoundCorner(MainFrame)
Utility:Shadow(MainFrame)

-- Background subtle pattern
local BgPattern = Utility:Create("ImageLabel", {
    Name = "Pattern",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6887086486",
    ImageColor3 = Theme.Primary,
    ImageTransparency = 0.97,
    ScaleType = Enum.ScaleType.Tile,
    TileSize = UDim2.new(0, 30, 0, 30),
    ZIndex = 1
}, MainFrame)

-- Gradient overlay
local GradientOverlay = Utility:Create("Frame", {
    Name = "GradientOverlay",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 2
}, MainFrame)

local gradient = Utility:Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 30, 15)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 20, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 20))
    }),
    Rotation = 135,
    Transparency = NumberSequence.new(0.3)
}, GradientOverlay)

-- Top Bar
local TopBar = Utility:Create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = MainFrame
})

Utility:RoundCorner(TopBar, UDim.new(0, 14))

local TopBarFix = Utility:Create("Frame", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -20),
    BackgroundColor3 = TopBar.BackgroundColor3,
    BackgroundTransparency = TopBar.BackgroundTransparency,
    BorderSizePixel = 0,
    ZIndex = 11
}, TopBar)

-- Title with glow effect
local TitleContainer = Utility:Create("Frame", {
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 12
}, TopBar)

local TitleGlow = Utility:Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 1, 0, 1),
    BackgroundTransparency = 1,
    Text = Config.Name,
    TextColor3 = Theme.Primary,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.88,
    ZIndex = 11
}, TitleContainer)

local Title = Utility:Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = Config.Name,
    TextColor3 = Theme.TextPrimary,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12
}, TitleContainer)

-- Version tag
local VersionTag = Utility:Create("TextLabel", {
    Size = UDim2.new(0, 40, 0, 16),
    Position = UDim2.new(0, Title.TextBounds.X + 8, 0.5, -8),
    BackgroundColor3 = Theme.Primary,
    BackgroundTransparency = 0.85,
    Text = "v2.0",
    TextColor3 = Theme.Primary,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    ZIndex = 12
}, TitleContainer)
Utility:RoundCorner(VersionTag, UDim.new(0, 4))

-- Window Controls
local ControlsFrame = Utility:Create("Frame", {
    Size = UDim2.new(0, 80, 0, 28),
    Position = UDim2.new(1, -90, 0.5, -14),
    BackgroundTransparency = 1,
    ZIndex = 12
}, TopBar)

local MinimizeBtn = Utility:Create("TextButton", {
    Name = "Minimize",
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.4,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 13
}, ControlsFrame)
Utility:RoundCorner(MinimizeBtn, UDim.new(0, 8))

local MinIcon = Utility:Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "−",
    TextColor3 = Theme.TextSecondary,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    ZIndex = 14
}, MinimizeBtn)

local CloseBtn = Utility:Create("TextButton", {
    Name = "Close",
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 36, 0, 0),
    BackgroundColor3 = Theme.Danger,
    BackgroundTransparency = 0.3,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 13
}, ControlsFrame)
Utility:RoundCorner(CloseBtn, UDim.new(0, 8))

local CloseIcon = Utility:Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Theme.TextPrimary,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    ZIndex = 14
}, CloseBtn)

-- Sidebar
local Sidebar = Utility:Create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 130, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = MainFrame
})

local SidebarLayout = Utility:Create("UIListLayout", {
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder
}, Sidebar)

local SidebarPadding = Utility:Create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10)
}, Sidebar)

-- Content Area
local ContentArea = Utility:Create("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -138, 1, -50),
    Position = UDim2.new(0, 134, 0, 46),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 11,
    ClipsDescendants = true,
    Parent = MainFrame
})

-- Minimized Button
local MinimizedBtn = Utility:Create("TextButton", {
    Name = "Minimized",
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.1,
    Text = "Q",
    TextColor3 = Theme.Primary,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    Visible = false,
    ZIndex = 100,
    Parent = ScreenGui
})
Utility:RoundCorner(MinimizedBtn, UDim.new(0, 14))
Utility:Stroke(MinimizedBtn, Theme.Primary, 2, 0.4)
Utility:Shadow(MinimizedBtn)

-- =====================================================
--  DRAG SYSTEM
-- =====================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:TweenFast(frame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

MakeDraggable(MainFrame, TopBar)
MakeDraggable(MinimizedBtn)

-- =====================================================
--  WINDOW STATE MANAGEMENT
-- =====================================================
local WindowState = {Minimized = false, Animating = false}

local function Minimize()
    if WindowState.Minimized or WindowState.Animating then return end
    WindowState.Animating = true

    local currentPos = MainFrame.Position
    local targetPos = UDim2.new(
        currentPos.X.Scale, currentPos.X.Offset + Config.Size.X.Offset / 2,
        currentPos.Y.Scale, currentPos.Y.Offset + Config.Size.Y.Offset / 2
    )

    Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = targetPos}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        MainFrame.Visible = false
        WindowState.Minimized = true
        WindowState.Animating = false

        MinimizedBtn.Visible = true
        MinimizedBtn.Size = UDim2.new(0, 0, 0, 0)
        Utility:Tween(MinimizedBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

local function Restore()
    if not WindowState.Minimized or WindowState.Animating then return end
    WindowState.Animating = true

    Utility:Tween(MinimizedBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
        MinimizedBtn.Visible = false

        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        Utility:Tween(MainFrame, {
            Size = Config.Size,
            Position = Config.Position
        }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, function()
            WindowState.Minimized = false
            WindowState.Animating = false
        end)
    end)
end

MinimizeBtn.MouseButton1Click:Connect(Minimize)
MinimizedBtn.MouseButton1Click:Connect(Restore)

CloseBtn.MouseButton1Click:Connect(function()
    Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        ScreenGui:Destroy()
    end)
end)

-- Button hover effects
MinimizeBtn.MouseEnter:Connect(function()
    Utility:TweenFast(MinimizeBtn, {BackgroundTransparency = 0.2})
    Utility:TweenFast(MinIcon, {TextColor3 = Theme.TextPrimary})
end)
MinimizeBtn.MouseLeave:Connect(function()
    Utility:TweenFast(MinimizeBtn, {BackgroundTransparency = 0.4})
    Utility:TweenFast(MinIcon, {TextColor3 = Theme.TextSecondary})
end)

CloseBtn.MouseEnter:Connect(function()
    Utility:TweenFast(CloseBtn, {BackgroundTransparency = 0.1})
end)
CloseBtn.MouseLeave:Connect(function()
    Utility:TweenFast(CloseBtn, {BackgroundTransparency = 0.3})
end)

-- =====================================================
--  INTRO ANIMATION
-- =====================================================
Utility:Tween(MainFrame, {Size = Config.Size, Position = Config.Position}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- =====================================================
--  UI LIBRARY CORE
-- =====================================================
local Quantum = {}
Quantum.Tabs = {}
Quantum.CurrentTab = nil
Quantum.Theme = Theme
Quantum.Config = Config
Quantum.Notify = function(text, dur, ntype) NotificationSystem:Notify(text, dur, ntype) end

function Quantum:SetTheme(themeName)
    if Themes[themeName] then
        Theme = Themes[themeName]
        Quantum.Theme = Theme
        Quantum.Notify("Theme changed to " .. themeName, 2, "success")
    end
end

function Quantum:CreateTab(name, icon)
    local TabBtn = Utility:Create("TextButton", {
        Name = name .. "_Tab",
        Size = UDim2.new(0, 118, 0, 34),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.4,
        Text = icon and (icon .. "  " .. name) or name,
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = Sidebar
    })
    Utility:RoundCorner(TabBtn, UDim.new(0, 10))

    local Indicator = Utility:Create("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 13,
        Visible = false
    }, TabBtn)
    Utility:RoundCorner(Indicator, UDim.new(0, 2))

    local TabPage = Utility:Create("ScrollingFrame", {
        Name = name .. "_Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Primary,
        ScrollBarImageTransparency = 0.6,
        Visible = false,
        ZIndex = 11,
        Parent = ContentArea,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local PageList = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    }, TabPage)

    Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    }, TabPage)

    local TabObj = {
        Name = name,
        Button = TabBtn,
        Page = TabPage,
        Indicator = Indicator,
        Elements = {}
    }

    local function Activate()
        if Quantum.CurrentTab == TabObj then return end

        if Quantum.CurrentTab then
            Utility:TweenFast(Quantum.CurrentTab.Button, {
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4
            })
            Utility:TweenFast(Quantum.CurrentTab.Button, {TextColor3 = Theme.TextSecondary})
            Quantum.CurrentTab.Indicator.Visible = false
            Quantum.CurrentTab.Page.Visible = false
        end

        Quantum.CurrentTab = TabObj

        Utility:TweenFast(TabBtn, {
            BackgroundColor3 = Theme.ElementHover,
            BackgroundTransparency = 0.2
        })
        Utility:TweenFast(TabBtn, {TextColor3 = Theme.Primary})
        Indicator.Visible = true
        Utility:Tween(Indicator, {Size = UDim2.new(0, 3, 0.5, 0)}, 0.2)

        TabPage.Visible = true
        TabPage.CanvasPosition = Vector2.new(0, 0)
    end

    TabBtn.MouseButton1Click:Connect(Activate)

    TabBtn.MouseEnter:Connect(function()
        if Quantum.CurrentTab ~= TabObj then
            Utility:TweenFast(TabBtn, {BackgroundTransparency = 0.25})
        end
    end)

    TabBtn.MouseLeave:Connect(function()
        if Quantum.CurrentTab ~= TabObj then
            Utility:TweenFast(TabBtn, {BackgroundTransparency = 0.4})
        end
    end)

    if not Quantum.CurrentTab then
        Activate()
    end

    -- =====================================================
    --  COMPONENTS
    -- =====================================================

    function TabObj:AddSection(text)
        local Sec = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 28),
            BackgroundTransparency = 1,
            ZIndex = 12,
            Parent = TabPage
        })

        local LeftLine = Utility:Create("Frame", {
            Size = UDim2.new(0.22, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            ZIndex = 13
        }, Sec)

        local RightLine = Utility:Create("Frame", {
            Size = UDim2.new(0.22, 0, 0, 1),
            Position = UDim2.new(0.78, 0, 0.5, 0),
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            ZIndex = 13
        }, Sec)

        Utility:Create("TextLabel", {
            Size = UDim2.new(0.56, 0, 1, 0),
            Position = UDim2.new(0.22, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Primary,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 13
        }, Sec)

        return Sec
    end

    function TabObj:AddLabel(config)
        config = config or {}
        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 320, 0, 24),
            BackgroundTransparency = 1,
            Text = config.Text or "Label",
            TextColor3 = config.Color or Theme.TextSecondary,
            TextSize = config.Size or 12,
            Font = config.Font or Enum.Font.Gotham,
            TextXAlignment = config.Alignment or Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 12,
            Parent = TabPage
        })
        return Label
    end

    function TabObj:AddButton(config)
        config = config or {}
        local text = config.Text or "Button"
        local callback = config.Callback or function() end

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        local Stroke = Utility:Stroke(Frame, Theme.Primary, 1, 0.8)

        local Btn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            ZIndex = 13,
            Parent = Frame
        })

        Btn.MouseEnter:Connect(function()
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.ElementHover})
            Utility:TweenFast(Stroke, {Transparency = 0.4})
        end)

        Btn.MouseLeave:Connect(function()
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.Element})
            Utility:TweenFast(Stroke, {Transparency = 0.8})
        end)

        Btn.MouseButton1Down:Connect(function()
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.PrimaryDark})
            Utility:TweenFast(Stroke, {Transparency = 0})
        end)

        Btn.MouseButton1Up:Connect(function()
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.ElementHover})
            Utility:TweenFast(Stroke, {Transparency = 0.4})
        end)

        Btn.MouseButton1Click:Connect(callback)

        return Frame
    end

    function TabObj:AddToggle(config)
        config = config or {}
        local text = config.Text or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        Utility:Stroke(Frame, Theme.Primary, 1, 0.85)

        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        }, Frame)

        local ToggleBtn = Utility:Create("TextButton", {
            Size = UDim2.new(0, 48, 0, 26),
            Position = UDim2.new(1, -60, 0.5, -13),
            BackgroundColor3 = default and Theme.Primary or Color3.fromRGB(55, 55, 60),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 13
        }, Frame)
        Utility:RoundCorner(ToggleBtn, UDim.new(1, 0))

        local Circle = Utility:Create("Frame", {
            Size = UDim2.new(0, 22, 0, 22),
            Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 14
        }, ToggleBtn)
        Utility:RoundCorner(Circle, UDim.new(1, 0))

        local Glow = Utility:Stroke(ToggleBtn, Theme.Primary, 1.5, default and 0.3 or 1)

        local enabled = default
        callback(enabled)

        local function Update(state)
            enabled = state
            Utility:Tween(ToggleBtn, {BackgroundColor3 = enabled and Theme.Primary or Color3.fromRGB(55, 55, 60)}, 0.2)
            Utility:Tween(Circle, {Position = enabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)}, 0.2)
            Utility:Tween(Glow, {Transparency = enabled and 0.3 or 1}, 0.2)
            callback(enabled)
        end

        ToggleBtn.MouseButton1Click:Connect(function() Update(not enabled) end)

        return {
            Set = Update,
            Get = function() return enabled end,
            Frame = Frame
        }
    end

    function TabObj:AddSlider(config)
        config = config or {}
        local text = config.Text or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = math.clamp(config.Default or min, min, max)
        local callback = config.Callback or function() end
        local suffix = config.Suffix or ""

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 54),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        Utility:Stroke(Frame, Theme.Primary, 1, 0.85)

        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0.5, 0, 0, 22),
            Position = UDim2.new(0, 14, 0, 6),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        }, Frame)

        local ValueLabel = Utility:Create("TextLabel", {
            Size = UDim2.new(0.3, 0, 0, 22),
            Position = UDim2.new(0.65, 0, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(default) .. suffix,
            TextColor3 = Theme.Primary,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 13
        }, Frame)

        local Track = Utility:Create("Frame", {
            Size = UDim2.new(1, -28, 0, 6),
            Position = UDim2.new(0, 14, 0, 36),
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            BorderSizePixel = 0,
            ZIndex = 13
        }, Frame)
        Utility:RoundCorner(Track, UDim.new(0, 3))

        local Fill = Utility:Create("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Theme.Primary,
            BorderSizePixel = 0,
            ZIndex = 14
        }, Track)
        Utility:RoundCorner(Fill, UDim.new(0, 3))

        local Knob = Utility:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 15
        }, Track)
        Utility:RoundCorner(Knob, UDim.new(1, 0))
        Utility:Stroke(Knob, Theme.Primary, 2, 0.3)

        local dragging = false
        local currentVal = default

        local function Update(input)
            local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            currentVal = math.floor(min + (max - min) * pos)
            ValueLabel.Text = tostring(currentVal) .. suffix
            Utility:TweenFast(Fill, {Size = UDim2.new(pos, 0, 1, 0)})
            Utility:TweenFast(Knob, {Position = UDim2.new(pos, -8, 0.5, -8)})
            callback(currentVal)
        end

        Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                Update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        callback(default)

        return {
            Set = function(val)
                currentVal = math.clamp(val, min, max)
                local pos = (currentVal - min) / (max - min)
                ValueLabel.Text = tostring(currentVal) .. suffix
                Utility:TweenFast(Fill, {Size = UDim2.new(pos, 0, 1, 0)})
                Utility:TweenFast(Knob, {Position = UDim2.new(pos, -8, 0.5, -8)})
                callback(currentVal)
            end,
            Get = function() return currentVal end,
            Frame = Frame
        }
    end

    function TabObj:AddDropdown(config)
        config = config or {}
        local text = config.Text or "Dropdown"
        local options = config.Options or {}
        local default = config.Default
        local callback = config.Callback or function() end

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            ClipsDescendants = true,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        local Stroke = Utility:Stroke(Frame, Theme.Primary, 1, 0.8)

        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0.4, 0, 0, 36),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        }, Frame)

        local Selected = Utility:Create("TextLabel", {
            Size = UDim2.new(0.35, 0, 0, 36),
            Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = default or "Select...",
            TextColor3 = Theme.Primary,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 13
        }, Frame)

        local Arrow = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 26, 0, 36),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Theme.Primary,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            ZIndex = 13
        }, Frame)

        local OptionsFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, #options * 30),
            Position = UDim2.new(0, 0, 0, 36),
            BackgroundTransparency = 1,
            ZIndex = 14,
            Parent = Frame
        })

        local OptList = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }, OptionsFrame)

        local isOpen = false
        local selectedVal = default

        for _, opt in ipairs(options) do
            local OptBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.2,
                Text = opt,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                ZIndex = 15,
                Parent = OptionsFrame
            })
            Utility:RoundCorner(OptBtn, UDim.new(0, 6))

            OptBtn.MouseEnter:Connect(function()
                Utility:TweenFast(OptBtn, {BackgroundColor3 = Theme.ElementHover})
            end)
            OptBtn.MouseLeave:Connect(function()
                Utility:TweenFast(OptBtn, {BackgroundColor3 = Theme.Element})
            end)

            OptBtn.MouseButton1Click:Connect(function()
                selectedVal = opt
                Selected.Text = opt
                callback(opt)
                isOpen = false
                Utility:Tween(Frame, {Size = UDim2.new(0, 320, 0, 36)}, 0.2)
                Arrow.Text = "▼"
                Utility:TweenFast(Stroke, {Transparency = 0.8})
            end)
        end

        local ClickArea = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 20,
            Parent = Frame
        })

        ClickArea.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                Utility:Tween(Frame, {Size = UDim2.new(0, 320, 0, 36 + #options * 30 + 8)}, 0.25)
                Arrow.Text = "▲"
                Utility:TweenFast(Stroke, {Transparency = 0.3})
            else
                Utility:Tween(Frame, {Size = UDim2.new(0, 320, 0, 36)}, 0.25)
                Arrow.Text = "▼"
                Utility:TweenFast(Stroke, {Transparency = 0.8})
            end
        end)

        if default then callback(default) end

        return {
            Set = function(val)
                selectedVal = val
                Selected.Text = val
                callback(val)
            end,
            Get = function() return selectedVal end,
            Frame = Frame
        }
    end

    function TabObj:AddTextBox(config)
        config = config or {}
        local text = config.Text or "TextBox"
        local placeholder = config.Placeholder or "Type here..."
        local callback = config.Callback or function() end

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        Utility:Stroke(Frame, Theme.Primary, 1, 0.85)

        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0.35, 0, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        }, Frame)

        local Box = Utility:Create("TextBox", {
            Size = UDim2.new(0.55, 0, 0, 26),
            Position = UDim2.new(0.4, 0, 0.5, -13),
            BackgroundColor3 = Color3.fromRGB(20, 24, 32),
            Text = "",
            PlaceholderText = placeholder,
            TextColor3 = Theme.Primary,
            PlaceholderColor3 = Theme.TextDark,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            ZIndex = 13
        }, Frame)
        Utility:RoundCorner(Box, UDim.new(0, 6))

        Box.Focused:Connect(function()
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.ElementHover})
        end)

        Box.FocusLost:Connect(function(enterPressed)
            Utility:TweenFast(Frame, {BackgroundColor3 = Theme.Element})
            callback(Box.Text, enterPressed)
        end)

        return Box
    end

    function TabObj:AddKeybind(config)
        config = config or {}
        local text = config.Text or "Keybind"
        local default = config.Default or Enum.KeyCode.Unknown
        local callback = config.Callback or function() end

        local Frame = Utility:Create("Frame", {
            Size = UDim2.new(0, 320, 0, 36),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.3,
            ZIndex = 12,
            Parent = TabPage
        })
        Utility:RoundCorner(Frame)
        Utility:Stroke(Frame, Theme.Primary, 1, 0.85)

        local Label = Utility:Create("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13
        }, Frame)

        local KeyBtn = Utility:Create("TextButton", {
            Size = UDim2.new(0, 70, 0, 26),
            Position = UDim2.new(1, -82, 0.5, -13),
            BackgroundColor3 = Color3.fromRGB(20, 24, 32),
            Text = default ~= Enum.KeyCode.Unknown and default.Name or "None",
            TextColor3 = Theme.Primary,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 13
        }, Frame)
        Utility:RoundCorner(KeyBtn, UDim.new(0, 6))

        local listening = false
        local currentKey = default

        KeyBtn.MouseButton1Click:Connect(function()
            listening = true
            KeyBtn.Text = "..."
            Utility:TweenFast(KeyBtn, {BackgroundColor3 = Theme.PrimaryDark})
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and not gameProcessed then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyBtn.Text = currentKey.Name
                    listening = false
                    Utility:TweenFast(KeyBtn, {BackgroundColor3 = Color3.fromRGB(20, 24, 32)})
                end
            elseif input.KeyCode == currentKey and not gameProcessed then
                callback()
            end
        end)

        return {
            Set = function(key)
                currentKey = key
                KeyBtn.Text = key.Name
            end,
            Get = function() return currentKey end,
            Frame = Frame
        }
    end

    table.insert(Quantum.Tabs, TabObj)
    return TabObj
end

-- =====================================================
--  FEATURE MODULES
-- =====================================================
local Features = {}

-- Fly System
Features.Fly = {
    Enabled = false,
    Speed = 50,
    BodyGyro = nil,
    BodyVelocity = nil,
    Connection = nil
}

function Features.Fly:Toggle(state)
    self.Enabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    if state then
        self.BodyGyro = Instance.new("BodyGyro")
        self.BodyGyro.P = 9e4
        self.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        self.BodyGyro.CFrame = hrp.CFrame
        self.BodyGyro.Parent = hrp

        self.BodyVelocity = Instance.new("BodyVelocity")
        self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        self.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.BodyVelocity.Parent = hrp

        humanoid.PlatformStand = true

        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            local camCF = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * self.Speed
            end

            if self.BodyVelocity then self.BodyVelocity.Velocity = moveDir end
            if self.BodyGyro then self.BodyGyro.CFrame = camCF end
        end)

        Quantum.Notify("Fly enabled", 2, "success")
    else
        if self.Connection then self.Connection:Disconnect() end
        if self.BodyGyro then self.BodyGyro:Destroy() end
        if self.BodyVelocity then self.BodyVelocity:Destroy() end
        humanoid.PlatformStand = false
        self.Connection = nil
        self.BodyGyro = nil
        self.BodyVelocity = nil
        Quantum.Notify("Fly disabled", 2, "info")
    end
end

-- Infinite Jump
Features.InfiniteJump = {
    Enabled = false,
    Connection = nil
}

function Features.InfiniteJump:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                    end
                end
            end
        end)
        Quantum.Notify("Infinite Jump enabled", 2, "success")
    else
        if self.Connection then self.Connection:Disconnect() end
        self.Connection = nil
        Quantum.Notify("Infinite Jump disabled", 2, "info")
    end
end

-- NoClip
Features.NoClip = {
    Enabled = false,
    Connection = nil
}

function Features.NoClip:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = RunService.Stepped:Connect(function()
            if not self.Enabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Quantum.Notify("NoClip enabled", 2, "success")
    else
        if self.Connection then self.Connection:Disconnect() end
        self.Connection = nil
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Quantum.Notify("NoClip disabled", 2, "info")
    end
end

-- Speed/Walk
Features.Speed = {
    Enabled = false,
    Value = 16,
    Connection = nil
}

function Features.Speed:Set(value)
    self.Value = value
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

function Features.Speed:Toggle(state)
    self.Enabled = state
    if state then
        self:Set(self.Value)
        self.Connection = LocalPlayer.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.WalkSpeed = self.Value
            end
        end)
        Quantum.Notify("Speed modifier enabled: " .. self.Value, 2, "success")
    else
        if self.Connection then self.Connection:Disconnect() end
        self.Connection = nil
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
        Quantum.Notify("Speed modifier disabled", 2, "info")
    end
end

-- =====================================================
--  BUILT-IN TABS SETUP
-- =====================================================
local function SetupDefaultTabs()
    -- Main Tab
    local MainTab = Quantum:CreateTab("Main", "⚡")
    MainTab:AddSection("Welcome")
    MainTab:AddLabel({Text = "Quantum UI v2.0 loaded successfully!", Color = Theme.Primary, Size = 13})
    MainTab:AddLabel({Text = "Use the sidebar to navigate features.", Color = Theme.TextDark, Size = 11})
    MainTab:AddSection("Information")
    MainTab:AddLabel({Text = "User: " .. LocalPlayer.Name, Color = Theme.TextSecondary})

    local success, gameInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    MainTab:AddLabel({Text = "Game: " .. (success and gameInfo or "Unknown"), Color = Theme.TextSecondary})

    -- Movement Tab
    local MoveTab = Quantum:CreateTab("Movement", "🏃")
    MoveTab:AddSection("Flight")

    local FlyToggle = MoveTab:AddToggle({
        Text = "Fly",
        Default = false,
        Callback = function(v) Features.Fly:Toggle(v) end
    })

    local FlySpeed = MoveTab:AddSlider({
        Text = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = "",
        Callback = function(v)
            Features.Fly.Speed = v
        end
    })

    MoveTab:AddSection("Movement Mods")

    local SpeedToggle = MoveTab:AddToggle({
        Text = "Speed Modifier",
        Default = false,
        Callback = function(v) Features.Speed:Toggle(v) end
    })

    local SpeedSlider = MoveTab:AddSlider({
        Text = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Suffix = "",
        Callback = function(v)
            Features.Speed.Value = v
            if Features.Speed.Enabled then
                Features.Speed:Set(v)
            end
        end
    })

    local InfJumpToggle = MoveTab:AddToggle({
        Text = "Infinite Jump",
        Default = false,
        Callback = function(v) Features.InfiniteJump:Toggle(v) end
    })

    local NoClipToggle = MoveTab:AddToggle({
        Text = "NoClip",
        Default = false,
        Callback = function(v) Features.NoClip:Toggle(v) end
    })

    -- Settings Tab
    local SettingsTab = Quantum:CreateTab("Settings", "⚙️")
    SettingsTab:AddSection("UI Settings")

    SettingsTab:AddDropdown({
        Text = "Theme",
        Options = {"CyberGreen", "Crimson", "Midnight"},
        Default = "CyberGreen",
        Callback = function(v)
            Quantum:SetTheme(v)
        end
    })

    SettingsTab:AddButton({
        Text = "Rejoin Server",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })

    SettingsTab:AddButton({
        Text = "Destroy UI",
        Callback = function()
            ScreenGui:Destroy()
        end
    })

    return Quantum
end

-- Initialize
SetupDefaultTabs()
Quantum.Notify("Quantum UI v2.0 loaded", 3, "success")

return Quantum
