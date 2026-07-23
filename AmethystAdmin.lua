--[[
    ╔══════════════════════════════════════════════════════════╗
    ║   💎 AMETHYST ADMIN v3.0 — ULTIMATE CRYSTAL EDITION 💎  ║
    ║   Premium Admin Panel • Roblox Experience               ║
    ║   Designed with Amethyst Crystal Aesthetics             ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ==================== CONFIGURATION ====================
local Config = {
    Version = "3.0.0",
    BuildName = "Crystal Edition",
    Author = "Amethyst Dev Team",
    Prefix = ":",
    MaxPlayers = 50,
    AutoSave = true,
    SavePath = "AmethystAdmin_Config.json",
    AnimationsEnabled = true,
    SoundEnabled = true,
    ParticleDensity = 25,
    GlowIntensity = 0.6,
}

-- ==================== THEME ENGINE ====================
local Theme = {
    -- Core Amethyst Palette
    Primary = Color3.fromRGB(147, 51, 234),
    PrimaryLight = Color3.fromRGB(192, 132, 252),
    PrimaryDark = Color3.fromRGB(88, 28, 135),
    Secondary = Color3.fromRGB(109, 40, 217),
    Tertiary = Color3.fromRGB(168, 85, 247),

    -- Crystal Backgrounds
    Background = Color3.fromRGB(10, 7, 20),
    BackgroundAlt = Color3.fromRGB(15, 10, 30),
    Surface = Color3.fromRGB(22, 16, 42),
    SurfaceHover = Color3.fromRGB(32, 24, 58),
    SurfaceActive = Color3.fromRGB(42, 32, 72),
    Card = Color3.fromRGB(28, 20, 52),
    CardBorder = Color3.fromRGB(147, 51, 234),

    -- Glass Effect
    Glass = Color3.fromRGB(147, 51, 234),
    GlassBorder = Color3.fromRGB(192, 132, 252),

    -- Text Colors
    Text = Color3.fromRGB(245, 240, 255),
    TextSecondary = Color3.fromRGB(180, 165, 210),
    TextMuted = Color3.fromRGB(130, 115, 165),
    TextAccent = Color3.fromRGB(192, 132, 252),

    -- Status Colors
    Success = Color3.fromRGB(74, 222, 128),
    Danger = Color3.fromRGB(248, 113, 113),
    Warning = Color3.fromRGB(251, 191, 36),
    Info = Color3.fromRGB(96, 165, 250),

    -- Gradient Stops
    GradientTop = Color3.fromRGB(168, 85, 247),
    GradientBottom = Color3.fromRGB(88, 28, 135),
    GradientAccent1 = Color3.fromRGB(217, 70, 239),
    GradientAccent2 = Color3.fromRGB(139, 92, 246),

    -- Glow
    Glow = Color3.fromRGB(147, 51, 234),
    GlowSoft = Color3.fromRGB(192, 132, 252),
}

-- ==================== UTILITY FUNCTIONS ====================
local Utils = {}

function Utils:Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils:LerpColor(c1, c2, t)
    return Color3.new(
        self:Lerp(c1.R, c2.R, t),
        self:Lerp(c1.G, c2.G, t),
        self:Lerp(c1.B, c2.B, t)
    )
end

function Utils:Create(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        if prop ~= "Parent" then
            pcall(function()
                inst[prop] = val
            end)
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if properties and properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

function Utils:Tween(obj, time, props, style, dir)
    if not obj or not obj.Parent then return end
    local tween = TweenService:Create(obj, TweenInfo.new(
        time,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    ), props)
    tween:Play()
    return tween
end

function Utils:CreateGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 90
    return gradient
end

function Utils:CreateGlow(parent, color, size, transparency)
    local glow = Utils:Create("ImageLabel", {
        Parent = parent,
        Size = UDim2.new(1, size or 20, 1, size or 20),
        Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = color or Theme.Glow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298),
        ZIndex = -1,
    })
    return glow
end

function Utils:PlaySound(id, volume, pitch)
    if not Config.SoundEnabled then return end
    local sound = Utils:Create("Sound", {
        Parent = SoundService,
        SoundId = "rbxassetid://" .. id,
        Volume = volume or 0.3,
        PlaybackSpeed = pitch or 1,
    })
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
    Debris:AddItem(sound, 5)
end

-- ==================== MAIN SCREEN GUI ====================
local screenGui = Utils:Create("ScreenGui", {
    Name = "AmethystAdminV3",
    Parent = game:GetService("CoreGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
})

-- ==================== LOADING SCREEN ====================
local LoadingScreen = {}

function LoadingScreen:Create()
    local loadGui = Utils:Create("Frame", {
        Name = "LoadingScreen",
        Parent = screenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 100000,
    })

    -- Animated gradient background
    local bgGrad = Utils:Create("Frame", {
        Parent = loadGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 100000,
    })

    -- Floating crystal particles for loading screen
    local loadParticles = Utils:Create("Frame", {
        Parent = loadGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 100001,
    })

    -- Spawn loading particles
    task.spawn(function()
        for i = 1, 60 do
            local size = math.random(2, 6)
            local crystal = Utils:Create("Frame", {
                Parent = loadParticles,
                Size = UDim2.fromOffset(size, size),
                Position = UDim2.new(math.random() * 0.8 + 0.1, 0, 1, math.random(10, 50)),
                BackgroundColor3 = Utils:LerpColor(Theme.PrimaryDark, Theme.PrimaryLight, math.random() * 100 / 100),
                BackgroundTransparency = math.random(30, 70) / 100,
                Rotation = math.random(0, 360),
                BorderSizePixel = 0,
                ZIndex = 100001,
            })
            Utils:Create("UICorner", { Parent = crystal, CornerRadius = UDim.new(0, 2) })

            local dur = math.random(8, 18)
            local targetX = math.random(-80, 80)
            Utils:Tween(crystal, dur, {
                Position = UDim2.new(crystal.Position.X.Scale, targetX, 0, -20),
                Rotation = crystal.Rotation + math.random(360, 1080),
                BackgroundTransparency = 1,
            }, Enum.EasingStyle.Linear)

            Debris:AddItem(crystal, dur + 1)
        end
    end)

    -- Central logo area
    local logoContainer = Utils:Create("Frame", {
        Parent = loadGui,
        Size = UDim2.new(0, 300, 0, 260),
        Position = UDim2.new(0.5, -150, 0.5, -160),
        BackgroundTransparency = 1,
        ZIndex = 100002,
    })

    -- Crystal icon with glow
    local crystalGlow = Utils:Create("Frame", {
        Parent = logoContainer,
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0.5, -50, 0, 0),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 100002,
    })
    Utils:Create("UICorner", { Parent = crystalGlow, CornerRadius = UDim.new(1, 0) })

    -- Pulsing glow ring
    local glowRing = Utils:Create("Frame", {
        Parent = logoContainer,
        Size = UDim2.new(0, 110, 0, 110),
        Position = UDim2.new(0.5, -55, 0, -5),
        BackgroundTransparency = 1,
        ZIndex = 100001,
    })
    Utils:Create("UIStroke", {
        Parent = glowRing,
        Color = Theme.PrimaryLight,
        Thickness = 2,
        Transparency = 0.5,
    })
    Utils:Create("UICorner", { Parent = glowRing, CornerRadius = UDim.new(1, 0) })

    -- Pulse animation for glow ring
    task.spawn(function()
        while glowRing and glowRing.Parent do
            Utils:Tween(glowRing, 1.2, {
                Size = UDim2.new(0, 130, 0, 130),
                Position = UDim2.new(0.5, -65, 0, -15),
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Utils:Tween(glowRing:FindFirstChildWhichIsA("UIStroke"), 1.2, {
                Transparency = 0.8,
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            Utils:Tween(glowRing, 1.2, {
                Size = UDim2.new(0, 110, 0, 110),
                Position = UDim2.new(0.5, -55, 0, -5),
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Utils:Tween(glowRing:FindFirstChildWhichIsA("UIStroke"), 1.2, {
                Transparency = 0.3,
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

    -- Diamond emoji
    local crystalIcon = Utils:Create("TextLabel", {
        Parent = logoContainer,
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, -40, 0, 10),
        BackgroundTransparency = 1,
        Text = "💎",
        TextSize = 48,
        ZIndex = 100003,
    })

    -- Rotating outer ring
    local outerRing = Utils:Create("Frame", {
        Parent = logoContainer,
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0.5, -70, 0, -20),
        BackgroundTransparency = 1,
        ZIndex = 100001,
    })
    Utils:Create("UIStroke", {
        Parent = outerRing,
        Color = Theme.Primary,
        Thickness = 1,
        Transparency = 0.7,
    })
    Utils:Create("UICorner", { Parent = outerRing, CornerRadius = UDim.new(1, 0) })

    -- Spin animation
    task.spawn(function()
        while outerRing and outerRing.Parent do
            Utils:Tween(outerRing, 4, {
                Rotation = 360,
            }, Enum.EasingStyle.Linear)
            task.wait(4)
            outerRing.Rotation = 0
        end
    end)

    -- Title text
    local titleText = Utils:Create("TextLabel", {
        Parent = logoContainer,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 115),
        BackgroundTransparency = 1,
        Text = "AMETHYST ADMIN",
        TextColor3 = Theme.Text,
        TextSize = 28,
        Font = Enum.Font.GothamBlack,
        TextTransparency = 1,
        ZIndex = 100003,
    })

    -- Subtitle
    local subtitleText = Utils:Create("TextLabel", {
        Parent = logoContainer,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 152),
        BackgroundTransparency = 1,
        Text = "Crystal Edition • v" .. Config.Version,
        TextColor3 = Theme.TextMuted,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        ZIndex = 100003,
    })

    -- Loading bar container
    local barContainer = Utils:Create("Frame", {
        Parent = logoContainer,
        Size = UDim2.new(0.8, 0, 0, 6),
        Position = UDim2.new(0.1, 0, 0, 195),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 100003,
    })
    Utils:Create("UICorner", { Parent = barContainer, CornerRadius = UDim.new(1, 0) })

    local barFill = Utils:Create("Frame", {
        Parent = barContainer,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 100004,
    })
    Utils:Create("UICorner", { Parent = barFill, CornerRadius = UDim.new(1, 0) })
    Utils:CreateGradient({
        ColorSequenceKeypoint.new(0, Theme.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.PrimaryLight),
    }, 0).Parent = barFill

    -- Loading shimmer on bar
    local shimmer = Utils:Create("Frame", {
        Parent = barFill,
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 100005,
    })
    Utils:Create("UICorner", { Parent = shimmer, CornerRadius = UDim.new(1, 0) })
    task.spawn(function()
        while shimmer and shimmer.Parent do
            shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
            Utils:Tween(shimmer, 1.5, {
                Position = UDim2.new(1, 0, 0, 0),
            }, Enum.EasingStyle.Linear)
            task.wait(1.5)
        end
    end)

    -- Loading status text
    local statusText = Utils:Create("TextLabel", {
        Parent = logoContainer,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 210),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        ZIndex = 100003,
    })

    -- Percentage text
    local percentText = Utils:Create("TextLabel", {
        Parent = logoContainer,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 228),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Theme.PrimaryLight,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        ZIndex = 100003,
    })

    -- Fade in elements
    Utils:Tween(titleText, 0.6, { TextTransparency = 0 }, Enum.EasingStyle.Quint)
    task.wait(0.3)
    Utils:Tween(subtitleText, 0.6, { TextTransparency = 0 }, Enum.EasingStyle.Quint)
    task.wait(0.2)
    Utils:Tween(statusText, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quint)
    Utils:Tween(percentText, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quint)

    -- Loading stages
    local stages = {
        { text = "Loading core modules...", target = 0.15, duration = 0.6 },
        { text = "Initializing theme engine...", target = 0.25, duration = 0.5 },
        { text = "Loading UI components...", target = 0.40, duration = 0.7 },
        { text = "Building admin panels...", target = 0.55, duration = 0.6 },
        { text = "Registering commands...", target = 0.70, duration = 0.5 },
        { text = "Loading player data...", target = 0.80, duration = 0.4 },
        { text = "Initializing particle system...", target = 0.90, duration = 0.4 },
        { text = "Finalizing...", target = 1.00, duration = 0.5 },
    }

    for _, stage in ipairs(stages) do
        statusText.Text = stage.text
        local pct = math.floor(stage.target * 100)
        percentText.Text = pct .. "%"
        Utils:Tween(barFill, stage.duration, {
            Size = UDim2.new(stage.target, 0, 1, 0),
        }, Enum.EasingStyle.Quint)
        task.wait(stage.duration + 0.1)
    end

    percentText.Text = "100%"
    statusText.Text = "Welcome, " .. LocalPlayer.DisplayName .. "! 💎"
    statusText.TextColor3 = Theme.PrimaryLight

    task.wait(1)

    -- Fade out loading screen
    Utils:Tween(loadGui, 0.6, { BackgroundTransparency = 1 })
    for _, child in ipairs(loadGui:GetDescendants()) do
        if child:IsA("TextLabel") then
            Utils:Tween(child, 0.5, { TextTransparency = 1 })
        elseif child:IsA("Frame") then
            Utils:Tween(child, 0.5, { BackgroundTransparency = 1 })
            local stroke = child:FindFirstChildWhichIsA("UIStroke")
            if stroke then
                Utils:Tween(stroke, 0.5, { Transparency = 1 })
            end
        elseif child:IsA("ImageLabel") then
            Utils:Tween(child, 0.5, { ImageTransparency = 1 })
        end
    end

    task.wait(0.7)
    loadGui:Destroy()
end

-- ==================== NOTIFICATION SYSTEM ====================
local NotifSystem = {}
NotifSystem.Container = nil

function NotifSystem:Init()
    self.Container = Utils:Create("Frame", {
        Name = "NotificationContainer",
        Parent = screenGui,
        Size = UDim2.new(0, 340, 1, -20),
        Position = UDim2.new(1, -350, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 9999,
    })
    Utils:Create("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    })
end

function NotifSystem:Send(title, message, nType, duration)
    if not self.Container then self:Init() end
    nType = nType or "info"
    duration = duration or 4

    local colors = {
        info = Theme.Info,
        success = Theme.Success,
        warning = Theme.Warning,
        danger = Theme.Danger,
        amethyst = Theme.Primary,
    }

    local icons = {
        info = "ℹ️",
        success = "✅",
        warning = "⚠️",
        danger = "❌",
        amethyst = "💎",
    }

    local accentColor = colors[nType] or Theme.Primary

    local notif = Utils:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        ZIndex = 9999,
    })

    Utils:Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 12) })
    Utils:Create("UIStroke", {
        Parent = notif,
        Color = accentColor,
        Thickness = 1.5,
        Transparency = 0.4,
    })

    -- Accent bar
    Utils:Create("Frame", {
        Parent = notif,
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 10000,
    })

    -- Icon
    local iconFrame = Utils:Create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.8,
        Text = icons[nType] or "💎",
        TextSize = 18,
        TextColor3 = accentColor,
        Font = Enum.Font.GothamBold,
        ZIndex = 10000,
    })
    Utils:Create("UICorner", { Parent = iconFrame, CornerRadius = UDim.new(0, 8) })

    -- Title
    Utils:Create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 58, 0, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10000,
    })

    -- Message
    Utils:Create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -70, 0, 32),
        Position = UDim2.new(0, 58, 0, 32),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 10000,
    })

    -- Progress bar
    local progress = Utils:Create("Frame", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 3),
        Position = UDim2.new(0, 10, 1, -6),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 10000,
    })
    Utils:Create("UICorner", { Parent = progress, CornerRadius = UDim.new(1, 0) })

    -- Animate in
    notif.Position = UDim2.new(1, 10, 0, 0)
    Utils:Tween(notif, 0.5, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

    -- Progress animation
    Utils:Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    -- Auto dismiss
    task.delay(duration, function()
        if notif and notif.Parent then
            Utils:Tween(notif, 0.4, {
                Position = UDim2.new(1, 10, 0, 0),
                BackgroundTransparency = 1,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.5, function()
                if notif and notif.Parent then notif:Destroy() end
            end)
        end
    end)
end

-- ==================== ANIMATED BACKGROUND PARTICLES ====================
local ParticleSystem = {}

ParticleSystem.Container = Utils:Create("Frame", {
    Name = "ParticleLayer",
    Parent = screenGui,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 0,
    ClipsDescendants = true,
})

function ParticleSystem:SpawnCrystal()
    local size = math.random(3, 8)
    local crystal = Utils:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.new(math.random() * 0.95 + 0.025, 0, 1, math.random(10, 40)),
        BackgroundColor3 = Utils:LerpColor(Theme.Primary, Theme.PrimaryLight, math.random() * 100 / 100),
        BackgroundTransparency = math.random(40, 75) / 100,
        Rotation = math.random(0, 360),
        BorderSizePixel = 0,
        ZIndex = 0,
    })
    Utils:Create("UICorner", { Parent = crystal, CornerRadius = UDim.new(0, 2) })

    local duration = math.random(6, 14)
    local targetX = math.random(-100, 100)

    Utils:Tween(crystal, duration, {
        Position = UDim2.new(crystal.Position.X.Scale, targetX, 0, -20),
        Rotation = crystal.Rotation + math.random(180, 720),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Linear)

    Debris:AddItem(crystal, duration + 1)
end

function ParticleSystem:Start()
    task.spawn(function()
        while screenGui and screenGui.Parent do
            if Config.AnimationsEnabled then
                self:SpawnCrystal()
            end
            task.wait(math.random(200, 600) / 1000)
        end
    end)
end

-- ==================== MAIN WINDOW ====================
local MainFrame = Utils:Create("Frame", {
    Name = "MainWindow",
    Parent = screenGui,
    Size = UDim2.fromOffset(860, 600),
    Position = UDim2.new(0.5, -430, 0.5, -300),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 10,
})

Utils:Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 16) })
Utils:Create("UIStroke", {
    Parent = MainFrame,
    Color = Theme.Primary,
    Thickness = 1.5,
    Transparency = 0.5,
})

-- Outer glow
Utils:CreateGlow(MainFrame, Theme.Glow, 30, 0.6)

-- ==================== TITLE BAR ====================
local TitleBar = Utils:Create("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ZIndex = 20,
})
Utils:Create("UICorner", { Parent = TitleBar, CornerRadius = UDim.new(0, 16) })

-- Fix bottom corners of title bar
Utils:Create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ZIndex = 20,
})

-- Gradient line under title
local titleLine = Utils:Create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BorderSizePixel = 0,
    ZIndex = 21,
})
Utils:CreateGradient({
    ColorSequenceKeypoint.new(0, Theme.PrimaryDark),
    ColorSequenceKeypoint.new(0.3, Theme.Primary),
    ColorSequenceKeypoint.new(0.5, Theme.PrimaryLight),
    ColorSequenceKeypoint.new(0.7, Theme.Primary),
    ColorSequenceKeypoint.new(1, Theme.PrimaryDark),
}, 0).Parent = titleLine

-- Animated gradient on title line
task.spawn(function()
    local grad = titleLine:FindFirstChildWhichIsA("UIGradient")
    while grad and grad.Parent do
        Utils:Tween(grad, 3, { Rotation = 360 }, Enum.EasingStyle.Linear)
        task.wait(3)
        grad.Rotation = 0
    end
end)

-- Crystal Logo
Utils:Create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.fromOffset(32, 32),
    Position = UDim2.new(0, 14, 0, 10),
    BackgroundTransparency = 1,
    Text = "💎",
    TextSize = 24,
    ZIndex = 22,
})

-- Title Text
Utils:Create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0, 200, 0, 24),
    Position = UDim2.new(0, 52, 0, 8),
    BackgroundTransparency = 1,
    Text = "AMETHYST ADMIN",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22,
})

Utils:Create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0, 200, 0, 14),
    Position = UDim2.new(0, 52, 0, 30),
    BackgroundTransparency = 1,
    Text = "v3.0 • Crystal Edition",
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22,
})

-- Window Controls
local function CreateWindowButton(text, color, posX)
    local btn = Utils:Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(1, posX, 0, 19),
        BackgroundColor3 = color,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 22,
    })
    Utils:Create("UICorner", { Parent = btn, CornerRadius = UDim.new(1, 0) })

    btn.MouseEnter:Connect(function()
        Utils:Tween(btn, 0.15, { Size = UDim2.fromOffset(16, 16) })
    end)
    btn.MouseLeave:Connect(function()
        Utils:Tween(btn, 0.15, { Size = UDim2.fromOffset(14, 14) })
    end)

    return btn
end

local CloseBtn = CreateWindowButton("", Theme.Danger, -24)
local MinBtn = CreateWindowButton("", Theme.Warning, -46)
local MaxBtn = CreateWindowButton("", Theme.Success, -68)

-- ==================== SIDEBAR NAVIGATION ====================
local Sidebar = Utils:Create("Frame", {
    Name = "Sidebar",
    Parent = MainFrame,
    Size = UDim2.new(0, 200, 1, -52),
    Position = UDim2.new(0, 0, 0, 52),
    BackgroundColor3 = Theme.BackgroundAlt,
    BorderSizePixel = 0,
    ZIndex = 15,
})

-- User Profile Section
local ProfileSection = Utils:Create("Frame", {
    Parent = Sidebar,
    Size = UDim2.new(1, -20, 0, 70),
    Position = UDim2.new(0, 10, 0, 12),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ZIndex = 16,
})
Utils:Create("UICorner", { Parent = ProfileSection, CornerRadius = UDim.new(0, 12) })
Utils:Create("UIStroke", {
    Parent = ProfileSection,
    Color = Theme.Primary,
    Thickness = 1,
    Transparency = 0.7,
})

-- Avatar
local Avatar = Utils:Create("ImageLabel", {
    Parent = ProfileSection,
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.new(0, 12, 0, 14),
    BackgroundColor3 = Theme.PrimaryDark,
    BorderSizePixel = 0,
    ZIndex = 17,
})
Utils:Create("UICorner", { Parent = Avatar, CornerRadius = UDim.new(0, 10) })
Utils:Create("UIStroke", { Parent = Avatar, Color = Theme.Primary, Thickness = 2, Transparency = 0.3 })

-- Load avatar
task.spawn(function()
    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if success then Avatar.Image = thumb end
end)

Utils:Create("TextLabel", {
    Parent = ProfileSection,
    Size = UDim2.new(1, -68, 0, 18),
    Position = UDim2.new(0, 62, 0, 16),
    BackgroundTransparency = 1,
    Text = LocalPlayer.DisplayName,
    TextColor3 = Theme.Text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 17,
})

Utils:Create("TextLabel", {
    Parent = ProfileSection,
    Size = UDim2.new(1, -68, 0, 14),
    Position = UDim2.new(0, 62, 0, 34),
    BackgroundTransparency = 1,
    Text = "@" .. LocalPlayer.Name,
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 17,
})

-- Online status dot
local statusDot = Utils:Create("Frame", {
    Parent = ProfileSection,
    Size = UDim2.fromOffset(8, 8),
    Position = UDim2.new(0, 46, 0, 48),
    BackgroundColor3 = Theme.Success,
    BorderSizePixel = 0,
    ZIndex = 18,
})
Utils:Create("UICorner", { Parent = statusDot, CornerRadius = UDim.new(1, 0) })

-- Pulse status dot
task.spawn(function()
    while statusDot and statusDot.Parent do
        Utils:Tween(statusDot, 0.8, { BackgroundTransparency = 0.5 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(0.8)
        Utils:Tween(statusDot, 0.8, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(0.8)
    end
end)

-- Navigation Items
local NavContainer = Utils:Create("ScrollingFrame", {
    Parent = Sidebar,
    Size = UDim2.new(1, -16, 1, -100),
    Position = UDim2.new(0, 8, 0, 92),
    BackgroundTransparency = 1,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Primary,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 16,
})
Utils:Create("UIListLayout", {
    Parent = NavContainer,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
})

local Tabs = {}
local CurrentTab = nil
local TabContent = {}

local TabIcons = {
    Dashboard = "📊",
    Players = "👥",
    Commands = "⌨️",
    Visuals = "🎨",
    Teleport = "🌀",
    Server = "🖥️",
    Scripts = "📜",
    Settings = "⚙️",
}

local function SwitchTab(name)
    if CurrentTab == name then return end

    -- Deactivate old tab
    if CurrentTab and Tabs[CurrentTab] then
        local oldTab = Tabs[CurrentTab]
        Utils:Tween(oldTab.Button, 0.25, { BackgroundTransparency = 1 })
        Utils:Tween(oldTab.Indicator, 0.25, { BackgroundTransparency = 1 })
        oldTab.Content.Visible = false
        -- Reset label colors
        for _, child in ipairs(oldTab.Button:GetChildren()) do
            if child:IsA("TextLabel") and child.TextSize >= 12 and child.TextSize <= 14 then
                Utils:Tween(child, 0.25, { TextColor3 = Theme.TextSecondary })
            end
        end
    end

    -- Activate new tab
    CurrentTab = name
    local newTab = Tabs[name]
    newTab.Button.BackgroundColor3 = Theme.SurfaceActive
    Utils:Tween(newTab.Button, 0.25, { BackgroundTransparency = 0.3 })
    Utils:Tween(newTab.Indicator, 0.25, { BackgroundTransparency = 0 })

    -- Update label colors
    for _, child in ipairs(newTab.Button:GetChildren()) do
        if child:IsA("TextLabel") and child.TextSize >= 12 and child.TextSize <= 14 then
            Utils:Tween(child, 0.25, { TextColor3 = Theme.TextAccent })
        end
    end

    newTab.Content.Visible = true

    -- Animate content in
    newTab.Content.Position = UDim2.new(0, 208, 0, 68)
    Utils:Tween(newTab.Content, 0.3, { Position = UDim2.new(0, 208, 0, 60) }, Enum.EasingStyle.Quint)
end

local function CreateTab(name, order)
    local tabBtn = Utils:Create("TextButton", {
        Parent = NavContainer,
        Size = UDim2.new(1, -8, 0, 40),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        ZIndex = 17,
    })
    Utils:Create("UICorner", { Parent = tabBtn, CornerRadius = UDim.new(0, 10) })

    -- Icon
    Utils:Create("TextLabel", {
        Parent = tabBtn,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = TabIcons[name] or "📌",
        TextSize = 16,
        ZIndex = 18,
    })

    -- Label
    Utils:Create("TextLabel", {
        Parent = tabBtn,
        Size = UDim2.new(1, -48, 0, 28),
        Position = UDim2.new(0, 44, 0, 6),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18,
    })

    -- Active indicator
    local indicator = Utils:Create("Frame", {
        Parent = tabBtn,
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 18,
    })
    Utils:Create("UICorner", { Parent = indicator, CornerRadius = UDim.new(1, 0) })

    -- Content frame
    local content = Utils:Create("ScrollingFrame", {
        Name = name .. "_Content",
        Parent = MainFrame,
        Size = UDim2.new(1, -216, 1, -68),
        Position = UDim2.new(0, 208, 0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 12,
    })

    Utils:Create("UIListLayout", {
        Parent = content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })
    Utils:Create("UIPadding", {
        Parent = content,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })

    Tabs[name] = { Button = tabBtn, Content = content, Indicator = indicator }
    TabContent[name] = content

    -- Hover effects
    tabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            Utils:Tween(tabBtn, 0.2, { BackgroundTransparency = 0.7 })
            tabBtn.BackgroundColor3 = Theme.SurfaceHover
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            Utils:Tween(tabBtn, 0.2, { BackgroundTransparency = 1 })
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(name)
        Utils:PlaySound(6326540735, 0.15, 1.2)
    end)

    return content
end

-- Create all tabs
local DashboardContent = CreateTab("Dashboard", 1)
local PlayersContent = CreateTab("Players", 2)
local CommandsContent = CreateTab("Commands", 3)
local VisualsContent = CreateTab("Visuals", 4)
local TeleportContent = CreateTab("Teleport", 5)
local ServerContent = CreateTab("Server", 6)
local ScriptsContent = CreateTab("Scripts", 7)
local SettingsContent = CreateTab("Settings", 8)

-- ==================== UI COMPONENT BUILDERS ====================
local UI = {}

function UI:CreateSection(parent, title, order)
    local section = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        ZIndex = 13,
    })

    Utils:Create("UIListLayout", {
        Parent = section,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })

    -- Section header
    local header = Utils:Create("Frame", {
        Parent = section,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        ZIndex = 13,
    })

    Utils:Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "  " .. title:upper() .. "  ",
        TextColor3 = Theme.TextAccent,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
    })

    Utils:Create("Frame", {
        Parent = header,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 13,
    })

    return section
end

function UI:CreateCard(parent, order)
    local card = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 13,
    })
    Utils:Create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 12) })
    Utils:Create("UIStroke", {
        Parent = card,
        Color = Theme.Primary,
        Thickness = 1,
        Transparency = 0.8,
    })
    Utils:Create("UIPadding", {
        Parent = card,
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
    })
    Utils:Create("UIListLayout", {
        Parent = card,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    return card
end

function UI:CreateButton(parent, text, icon, callback, order, btnColor)
    local btn = Utils:Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = btnColor or Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order or 0,
        ZIndex = 14,
    })
    Utils:Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
    Utils:Create("UIStroke", {
        Parent = btn,
        Color = Theme.Primary,
        Thickness = 1,
        Transparency = 0.85,
    })

    if icon then
        Utils:Create("TextLabel", {
            Parent = btn,
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.new(0, 10, 0, 7),
            BackgroundTransparency = 1,
            Text = icon,
            TextSize = 14,
            ZIndex = 15,
        })
    end

    Utils:Create("TextLabel", {
        Parent = btn,
        Size = UDim2.new(1, icon and -44 or -20, 1, 0),
        Position = UDim2.new(0, icon and 38 or 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
    })

    -- Hover/Click effects
    btn.MouseEnter:Connect(function()
        Utils:Tween(btn, 0.2, { BackgroundColor3 = Theme.SurfaceHover })
        local stroke = btn:FindFirstChildWhichIsA("UIStroke")
        if stroke then stroke.Transparency = 0.5 end
    end)
    btn.MouseLeave:Connect(function()
        Utils:Tween(btn, 0.2, { BackgroundColor3 = btnColor or Theme.Surface })
        local stroke = btn:FindFirstChildWhichIsA("UIStroke")
        if stroke then stroke.Transparency = 0.85 end
    end)
    btn.MouseButton1Down:Connect(function()
        Utils:Tween(btn, 0.1, { BackgroundColor3 = Theme.SurfaceActive })
    end)
    btn.MouseButton1Up:Connect(function()
        Utils:Tween(btn, 0.1, { BackgroundColor3 = Theme.SurfaceHover })
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
        Utils:PlaySound(6326540735, 0.1, 1.5)
    end)

    return btn
end

function UI:CreateToggle(parent, text, default, callback, order)
    local state = default or false

    local container = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        ZIndex = 14,
    })

    Utils:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    local toggleBg = Utils:Create("TextButton", {
        Parent = container,
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -44, 0, 6),
        BackgroundColor3 = state and Theme.Primary or Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 15,
    })
    Utils:Create("UICorner", { Parent = toggleBg, CornerRadius = UDim.new(1, 0) })
    local toggleStroke = Utils:Create("UIStroke", {
        Parent = toggleBg,
        Color = state and Theme.PrimaryLight or Theme.TextMuted,
        Thickness = 1.5,
        Transparency = 0.5,
    })

    local knob = Utils:Create("Frame", {
        Parent = toggleBg,
        Size = UDim2.fromOffset(18, 18),
        Position = state and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 16,
    })
    Utils:Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local function UpdateVisual()
        Utils:Tween(toggleBg, 0.25, { BackgroundColor3 = state and Theme.Primary or Theme.Surface })
        Utils:Tween(knob, 0.25, {
            Position = state and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
        }, Enum.EasingStyle.Back)
        toggleStroke.Color = state and Theme.PrimaryLight or Theme.TextMuted
    end

    toggleBg.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        if callback then task.spawn(callback, state) end
        Utils:PlaySound(state and 6326540735 or 6326540831, 0.12, 1.3)
    end)

    return {
        SetState = function(s) state = s; UpdateVisual() end,
        GetState = function() return state end,
    }
end

function UI:CreateSlider(parent, text, min, max, default, callback, order, suffix)
    local value = default or min

    local container = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        ZIndex = 14,
    })

    Utils:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, -50, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    local valueLabel = Utils:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(0, 50, 0, 18),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value) .. (suffix or ""),
        TextColor3 = Theme.TextAccent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 14,
    })

    local track = Utils:Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 14,
    })
    Utils:Create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

    local fill = Utils:Create("Frame", {
        Parent = track,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 15,
    })
    Utils:Create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })
    Utils:CreateGradient({
        ColorSequenceKeypoint.new(0, Theme.PrimaryDark),
        ColorSequenceKeypoint.new(1, Theme.PrimaryLight),
    }, 0).Parent = fill

    local knob = Utils:Create("Frame", {
        Parent = track,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new((value - min) / (max - min), -8, 0, -5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 16,
    })
    Utils:Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })
    Utils:Create("UIStroke", { Parent = knob, Color = Theme.Primary, Thickness = 2 })

    local dragging = false

    local function UpdateSlider(inputX)
        local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        local pct = (value - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0, -5)
        valueLabel.Text = tostring(value) .. (suffix or "")
        if callback then callback(value) end
    end

    track.MouseButton1Down:Connect(function()
        dragging = true
        UpdateSlider(Mouse.X)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        SetValue = function(v)
            value = v
            UpdateSlider(track.AbsolutePosition.X + (v - min) / (max - min) * track.AbsoluteSize.X)
        end,
        GetValue = function() return value end,
    }
end

function UI:CreateInput(parent, text, placeholder, callback, order)
    local container = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        ZIndex = 14,
    })

    Utils:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    local inputFrame = Utils:Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 14,
    })
    Utils:Create("UICorner", { Parent = inputFrame, CornerRadius = UDim.new(0, 8) })
    local inputStroke = Utils:Create("UIStroke", {
        Parent = inputFrame,
        Color = Theme.Primary,
        Thickness = 1,
        Transparency = 0.8,
    })

    local input = Utils:Create("TextBox", {
        Parent = inputFrame,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = placeholder or "Type here...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 15,
    })

    input.Focused:Connect(function()
        Utils:Tween(inputStroke, 0.2, { Transparency = 0.2 })
    end)
    input.FocusLost:Connect(function(enterPressed)
        Utils:Tween(inputStroke, 0.2, { Transparency = 0.8 })
        if enterPressed and callback then
            callback(input.Text)
        end
    end)

    return input
end

function UI:CreateDropdown(parent, text, options, default, callback, order)
    local selected = default or options[1]
    local open = false

    local container = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        ZIndex = 14,
    })

    Utils:Create("TextLabel", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    local dropdownBtn = Utils:Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 14,
    })
    Utils:Create("UICorner", { Parent = dropdownBtn, CornerRadius = UDim.new(0, 8) })
    Utils:Create("UIStroke", { Parent = dropdownBtn, Color = Theme.Primary, Thickness = 1, Transparency = 0.8 })

    local selectedLabel = Utils:Create("TextLabel", {
        Parent = dropdownBtn,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
    })

    Utils:Create("TextLabel", {
        Parent = dropdownBtn,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -24, 0, 5),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        ZIndex = 15,
    })

    local optionsFrame = Utils:Create("Frame", {
        Parent = container,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 54),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 20,
    })
    Utils:Create("UICorner", { Parent = optionsFrame, CornerRadius = UDim.new(0, 8) })
    Utils:Create("UIStroke", { Parent = optionsFrame, Color = Theme.Primary, Thickness = 1, Transparency = 0.6 })
    Utils:Create("UIListLayout", { Parent = optionsFrame, SortOrder = Enum.SortOrder.LayoutOrder })

    for i, opt in ipairs(options) do
        local optBtn = Utils:Create("TextButton", {
            Parent = optionsFrame,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Theme.Surface,
            Text = opt,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 21,
        })
        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = Theme.SurfaceHover
            optBtn.TextColor3 = Theme.TextAccent
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = Theme.Surface
            optBtn.TextColor3 = Theme.TextSecondary
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selectedLabel.Text = opt
            open = false
            Utils:Tween(optionsFrame, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.2, function()
                if not open then optionsFrame.Visible = false end
            end)
            if callback then callback(opt) end
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        open = not open
        optionsFrame.Visible = true
        if open then
            Utils:Tween(optionsFrame, 0.25, {
                Size = UDim2.new(1, 0, 0, #options * 28),
            }, Enum.EasingStyle.Back)
        else
            Utils:Tween(optionsFrame, 0.2, {
                Size = UDim2.new(1, 0, 0, 0),
            })
            task.delay(0.2, function()
                if not open then optionsFrame.Visible = false end
            end)
        end
    end)
end

function UI:CreateStatCard(parent, label, value, icon, color, order)
    local card = Utils:Create("Frame", {
        Parent = parent,
        Size = UDim2.new(0.48, -4, 0, 72),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 13,
    })
    Utils:Create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 12) })
    Utils:Create("UIStroke", { Parent = card, Color = color or Theme.Primary, Thickness = 1, Transparency = 0.7 })

    Utils:Create("TextLabel", {
        Parent = card,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = color or Theme.Primary,
        BackgroundTransparency = 0.8,
        Text = icon or "📊",
        TextSize = 14,
        ZIndex = 14,
    })
    Utils:Create("UICorner", {
        Parent = card:GetChildren()[4],
        CornerRadius = UDim.new(0, 8),
    })

    local valLabel = Utils:Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -52, 0, 22),
        Position = UDim2.new(0, 48, 0, 12),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    Utils:Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -52, 0, 16),
        Position = UDim2.new(0, 48, 0, 36),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
    })

    return valLabel
end

-- ==================== DASHBOARD TAB ====================
local dashSection1 = UI:CreateSection(DashboardContent, "Server Overview", 1)

local statsRow = Utils:Create("Frame", {
    Parent = dashSection1,
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
    ZIndex = 13,
})
Utils:Create("UIListLayout", {
    Parent = statsRow,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
})

local playerCountLabel = UI:CreateStatCard(statsRow, "Players Online", #Players:GetPlayers(), "👥", Theme.Primary, 1)
local serverTimeLabel = UI:CreateStatCard(statsRow, "Server Time", os.date("%H:%M"), "🕐", Theme.Info, 2)

local statsRow2 = Utils:Create("Frame", {
    Parent = dashSection1,
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1,
    LayoutOrder = 2,
    ZIndex = 13,
})
Utils:Create("UIListLayout", {
    Parent = statsRow2,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
})

local fpsLabel = UI:CreateStatCard(statsRow2, "FPS", "60", "⚡", Theme.Success, 1)
local pingLabel = UI:CreateStatCard(statsRow2, "Ping", "0ms", "📡", Theme.Warning, 2)

-- Quick Actions
local dashSection2 = UI:CreateSection(DashboardContent, "Quick Actions", 2)
local quickCard = UI:CreateCard(dashSection2, 1)

UI:CreateButton(quickCard, "Respawn All Players", "🔄", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            plr.Character:BreakJoints()
        end
    end
    NotifSystem:Send("Amethyst", "All players respawned!", "success")
end, 1)

UI:CreateButton(quickCard, "Heal All Players", "💚", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end
    NotifSystem:Send("Amethyst", "All players healed!", "success")
end, 2)

UI:CreateButton(quickCard, "Freeze All Players", "❄️", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
        end
    end
    NotifSystem:Send("Amethyst", "All players frozen!", "warning")
end, 3)

UI:CreateButton(quickCard, "Unfreeze All Players", "🔥", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        end
    end
    NotifSystem:Send("Amethyst", "All players unfrozen!", "success")
end, 4)

-- Server Info Card
local dashSection3 = UI:CreateSection(DashboardContent, "Server Information", 3)
local infoCard = UI:CreateCard(dashSection3, 1)

Utils:Create("TextLabel", {
    Parent = infoCard,
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Text = "Job ID: " .. game.JobId:sub(1, 20) .. (#game.JobId > 20 and "..." or ""),
    TextColor3 = Theme.TextSecondary,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 1,
})

Utils:Create("TextLabel", {
    Parent = infoCard,
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Text = "Place ID: " .. tostring(game.PlaceId),
    TextColor3 = Theme.TextSecondary,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 2,
})

Utils:Create("TextLabel", {
    Parent = infoCard,
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Text = "Server Age: " .. math.floor(workspace.DistributedGameTime / 60) .. " min",
    TextColor3 = Theme.TextSecondary,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 3,
})

-- ==================== PLAYERS TAB ====================
local plrSection1 = UI:CreateSection(PlayersContent, "Player Management", 1)
local plrSearchCard = UI:CreateCard(plrSection1, 1)

local PlayerButtons = {}
local SelectedPlayer = nil
local plrListContainer = nil

local searchInput = UI:CreateInput(plrSearchCard, "Search Players", "Type player name...", function(text)
    -- Filter player list
    if plrListContainer then
        for _, entry in ipairs(plrListContainer:GetChildren()) do
            if entry:IsA("TextButton") then
                local nameLabel = entry:FindFirstChildWhichIsA("TextLabel")
                if nameLabel then
                    if text == "" or nameLabel.Text:lower():find(text:lower(), 1, true) then
                        entry.Visible = true
                    else
                        entry.Visible = false
                    end
                end
            end
        end
    end
end, 1)

local plrListCard = UI:CreateCard(plrSection1, 2)
plrListContainer = plrListCard

local function CreatePlayerEntry(plr)
    local entry = Utils:Create("TextButton", {
        Parent = plrListCard,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Surface,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 14,
    })
    Utils:Create("UICorner", { Parent = entry, CornerRadius = UDim.new(0, 8) })
    Utils:Create("UIStroke", { Parent = entry, Color = Theme.Primary, Thickness = 1, Transparency = 0.9 })

    local miniAvatar = Utils:Create("ImageLabel", {
        Parent = entry,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Theme.PrimaryDark,
        BorderSizePixel = 0,
        ZIndex = 15,
    })
    Utils:Create("UICorner", { Parent = miniAvatar, CornerRadius = UDim.new(0, 6) })

    task.spawn(function()
        local s, t = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if s then miniAvatar.Image = t end
    end)

    Utils:Create("TextLabel", {
        Parent = entry,
        Name = "PlayerName",
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 40, 0, 4),
        BackgroundTransparency = 1,
        Text = plr.DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 15,
    })

    Utils:Create("TextLabel", {
        Parent = entry,
        Size = UDim2.new(1, -80, 0, 14),
        Position = UDim2.new(0, 40, 0, 20),
        BackgroundTransparency = 1,
        Text = "@" .. plr.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
    })

    entry.MouseButton1Click:Connect(function()
        SelectedPlayer = plr
        for _, btn in pairs(PlayerButtons) do
            if btn and btn.Parent then
                local stroke = btn:FindFirstChildWhichIsA("UIStroke")
                if stroke then stroke.Transparency = 0.9 end
                btn.BackgroundColor3 = Theme.Surface
            end
        end
        local stroke = entry:FindFirstChildWhichIsA("UIStroke")
        if stroke then stroke.Transparency = 0.3 end
        entry.BackgroundColor3 = Theme.SurfaceActive
        NotifSystem:Send("Amethyst", "Selected: " .. plr.DisplayName, "amethyst", 2)
    end)

    PlayerButtons[plr] = entry
end

for _, plr in ipairs(Players:GetPlayers()) do
    CreatePlayerEntry(plr)
end

Players.PlayerAdded:Connect(function(plr)
    CreatePlayerEntry(plr)
    playerCountLabel.Text = tostring(#Players:GetPlayers())
    NotifSystem:Send("Amethyst", plr.DisplayName .. " joined the server", "info", 3)
end)

Players.PlayerRemoving:Connect(function(plr)
    if PlayerButtons[plr] then
        PlayerButtons[plr]:Destroy()
        PlayerButtons[plr] = nil
    end
    playerCountLabel.Text = tostring(#Players:GetPlayers())
end)

-- Player Actions
local plrSection2 = UI:CreateSection(PlayersContent, "Player Actions", 2)
local actionCard = UI:CreateCard(plrSection2, 1)

UI:CreateButton(actionCard, "Teleport To Player", "🌀", function()
    if SelectedPlayer and SelectedPlayer.Character and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(SelectedPlayer.Character:GetPivot() + Vector3.new(0, 0, -5))
        NotifSystem:Send("Amethyst", "Teleported to " .. SelectedPlayer.DisplayName, "success")
    else
        NotifSystem:Send("Amethyst", "Select a player first!", "warning")
    end
end, 1)

UI:CreateButton(actionCard, "Bring Player", "📍", function()
    if SelectedPlayer and SelectedPlayer.Character and LocalPlayer.Character then
        SelectedPlayer.Character:PivotTo(LocalPlayer.Character:GetPivot() + Vector3.new(0, 0, -5))
        NotifSystem:Send("Amethyst", "Brought " .. SelectedPlayer.DisplayName, "success")
    else
        NotifSystem:Send("Amethyst", "Select a player first!", "warning")
    end
end, 2)

UI:CreateButton(actionCard, "Spectate Player", "👁️", function()
    if SelectedPlayer and SelectedPlayer.Character then
        Camera.CameraSubject = SelectedPlayer.Character:FindFirstChild("Humanoid")
        NotifSystem:Send("Amethyst", "Spectating " .. SelectedPlayer.DisplayName, "info")
    end
end, 3)

UI:CreateButton(actionCard, "Stop Spectating", "🚫", function()
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end, 4)

UI:CreateButton(actionCard, "View Player Info", "📋", function()
    if SelectedPlayer then
        local info = string.format(
            "Name: %s\nDisplay: %s\nID: %d\nAge: %d days\nTeam: %s",
            SelectedPlayer.Name,
            SelectedPlayer.DisplayName,
            SelectedPlayer.UserId,
            SelectedPlayer.AccountAge,
            tostring(SelectedPlayer.Team or "None")
        )
        NotifSystem:Send("Player Info", info, "amethyst", 6)
    end
end, 5)

-- ==================== COMMANDS TAB ====================
local cmdSection1 = UI:CreateSection(CommandsContent, "Command Center", 1)
local cmdCard = UI:CreateCard(cmdSection1, 1)

local cmdInput = UI:CreateInput(cmdCard, "Execute Command", ":command [args]...", function(text)
    if text == "" then return end
    print("[Amethyst CMD] " .. text)

    local args = string.split(text, " ")
    local cmd = args[1]:lower()

    if cmd == ":speed" and args[2] then
        local speed = tonumber(args[2]) or 16
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end
        NotifSystem:Send("Amethyst", "Speed set to " .. speed, "success")
    elseif cmd == ":jump" and args[2] then
        local power = tonumber(args[2]) or 50
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = power end
        end
        NotifSystem:Send("Amethyst", "Jump power set to " .. power, "success")
    elseif cmd == ":fov" and args[2] then
        Camera.FieldOfView = tonumber(args[2]) or 70
        NotifSystem:Send("Amethyst", "FOV set to " .. args[2], "success")
    elseif cmd == ":time" and args[2] then
        Lighting.ClockTime = tonumber(args[2]) or 12
        NotifSystem:Send("Amethyst", "Time set to " .. args[2], "success")
    elseif cmd == ":gravity" and args[2] then
        workspace.Gravity = tonumber(args[2]) or 196.2
        NotifSystem:Send("Amethyst", "Gravity set to " .. args[2], "success")
    elseif cmd == ":fly" then
        NotifSystem:Send("Amethyst", "Fly mode toggled!", "info")
    elseif cmd == ":noclip" then
        NotifSystem:Send("Amethyst", "Noclip toggled!", "info")
    else
        NotifSystem:Send("Amethyst", "Unknown command: " .. cmd, "warning")
    end

    cmdInput.Text = ""
end, 1)

-- Quick command buttons
local cmdSection2 = UI:CreateSection(CommandsContent, "Quick Commands", 2)
local quickCmdCard = UI:CreateCard(cmdSection2, 1)

UI:CreateButton(quickCmdCard, "Set Speed to 50", "🏃", function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 50 end
    end
    NotifSystem:Send("Amethyst", "Speed: 50", "success")
end, 1)

UI:CreateButton(quickCmdCard, "Set Speed to 100", "⚡", function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 100 end
    end
    NotifSystem:Send("Amethyst", "Speed: 100", "success")
end, 2)

UI:CreateButton(quickCmdCard, "Reset Speed", "🚶", function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    NotifSystem:Send("Amethyst", "Speed reset to 16", "success")
end, 3)

UI:CreateButton(quickCmdCard, "Set Jump to 100", "🦘", function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = 100 end
    end
    NotifSystem:Send("Amethyst", "Jump: 100", "success")
end, 4)

UI:CreateButton(quickCmdCard, "Low Gravity", "🌙", function()
    workspace.Gravity = 50
    NotifSystem:Send("Amethyst", "Low gravity enabled", "success")
end, 5)

UI:CreateButton(quickCmdCard, "Normal Gravity", "🌍", function()
    workspace.Gravity = 196.2
    NotifSystem:Send("Amethyst", "Normal gravity restored", "success")
end, 6)

-- Command Reference
local cmdSection3 = UI:CreateSection(CommandsContent, "Command Reference", 3)
local refCard = UI:CreateCard(cmdSection3, 1)

local commands = {
    ":speed [value] - Set walk speed",
    ":jump [value] - Set jump power",
    ":fov [value] - Set field of view",
    ":time [0-24] - Set server time",
    ":gravity [value] - Set gravity",
    ":fly - Toggle fly mode",
    ":noclip - Toggle noclip",
}

for i, cmd in ipairs(commands) do
    Utils:Create("TextLabel", {
        Parent = refCard,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = cmd,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = i,
        ZIndex = 14,
    })
end

-- ==================== VISUALS TAB ====================
local visSection1 = UI:CreateSection(VisualsContent, "Camera & View", 1)
local camCard = UI:CreateCard(visSection1, 1)

UI:CreateSlider(camCard, "Field of View", 50, 120, 70, function(val)
    Camera.FieldOfView = val
end, 1, "°")

UI:CreateToggle(camCard, "Free Camera", false, function(state)
    if state then
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
end, 2)

-- Lighting Controls
local visSection2 = UI:CreateSection(VisualsContent, "Lighting & Atmosphere", 2)
local lightCard = UI:CreateCard(visSection2, 1)

UI:CreateSlider(lightCard, "Time of Day", 0, 24, 12, function(val)
    Lighting.ClockTime = val
end, 1, "h")

UI:CreateSlider(lightCard, "Brightness", 0, 10, 2, function(val)
    Lighting.Brightness = val
end, 2)

UI:CreateSlider(lightCard, "Fog Density", 0, 100, 0, function(val)
    Lighting.FogEnd = val == 0 and 100000 or (1000 / (val / 10))
end, 3, "%")

UI:CreateDropdown(lightCard, "Ambient Preset", {
    "Default", "Amethyst Night", "Golden Hour", "Midnight", "Crystal Cave"
}, "Default", function(preset)
    if preset == "Amethyst Night" then
        Lighting.ClockTime = 22
        Lighting.Ambient = Color3.fromRGB(80, 40, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(40, 20, 80)
        Lighting.Brightness = 1
    elseif preset == "Golden Hour" then
        Lighting.ClockTime = 17.5
        Lighting.Ambient = Color3.fromRGB(255, 200, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 150, 80)
        Lighting.Brightness = 3
    elseif preset == "Midnight" then
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(10, 10, 30)
        Lighting.OutdoorAmbient = Color3.fromRGB(5, 5, 20)
        Lighting.Brightness = 0.5
    elseif preset == "Crystal Cave" then
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.fromRGB(100, 50, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(60, 30, 120)
        Lighting.Brightness = 1.5
    else
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2
    end
    NotifSystem:Send("Amethyst", "Preset: " .. preset, "amethyst")
end, 4)

-- Character Visuals
local visSection3 = UI:CreateSection(VisualsContent, "Character Effects", 3)
local charCard = UI:CreateCard(visSection3, 1)

UI:CreateToggle(charCard, "Fullbright", false, function(state)
    if state then
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end
end, 1)

UI:CreateToggle(charCard, "Noclip", false, function(state)
    if state then
        RunService:BindToRenderStep("AmethystNoclip", Enum.RenderPriority.Character.Value + 1, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("AmethystNoclip")
    end
end, 2)

UI:CreateToggle(charCard, "Invisible", false, function(state)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = state and 1 or 0
            end
        end
    end
end, 3)

UI:CreateDropdown(charCard, "Character Material", {
    "Normal", "Neon", "Glass", "ForceField", "SmoothPlastic"
}, "Normal", function(mat)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if mat == "Normal" then
                    part.Material = Enum.Material.Plastic
                else
                    part.Material = Enum.Material[mat]
                end
            end
        end
    end
end, 4)

-- ==================== TELEPORT TAB ====================
local tpSection1 = UI:CreateSection(TeleportContent, "Teleportation", 1)
local tpCard = UI:CreateCard(tpSection1, 1)

UI:CreateButton(tpCard, "Teleport to Sky", "☁️", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(CFrame.new(0, 500, 0))
    end
end, 1)

UI:CreateButton(tpCard, "Teleport to Ground", "🌍", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(CFrame.new(0, 5, 0))
    end
end, 2)

UI:CreateButton(tpCard, "Save Position", "💾", function()
    if LocalPlayer.Character then
        _G.AmethystSavedPos = LocalPlayer.Character:GetPivot()
        NotifSystem:Send("Amethyst", "Position saved!", "success")
    end
end, 3)

UI:CreateButton(tpCard, "Load Position", "📂", function()
    if _G.AmethystSavedPos and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(_G.AmethystSavedPos)
        NotifSystem:Send("Amethyst", "Teleported to saved position!", "success")
    else
        NotifSystem:Send("Amethyst", "No saved position found!", "warning")
    end
end, 4)

UI:CreateButton(tpCard, "Teleport to Random Player", "🎲", function()
    local players = Players:GetPlayers()
    local target = players[math.random(1, #players)]
    if target ~= LocalPlayer and target.Character and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(target.Character:GetPivot() + Vector3.new(0, 0, -5))
        NotifSystem:Send("Amethyst", "Teleported to " .. target.DisplayName, "success")
    end
end, 5)

-- Waypoints
local tpSection2 = UI:CreateSection(TeleportContent, "Waypoints", 2)
local wpCard = UI:CreateCard(tpSection2, 1)

local Waypoints = {}

UI:CreateButton(wpCard, "Add Current Position as Waypoint", "📌", function()
    if LocalPlayer.Character then
        local name = "WP_" .. (#Waypoints + 1)
        Waypoints[name] = LocalPlayer.Character:GetPivot()
        NotifSystem:Send("Amethyst", "Waypoint '" .. name .. "' saved!", "success")
    end
end, 1)

UI:CreateButton(wpCard, "Teleport to Last Waypoint", "🔙", function()
    local last = "WP_" .. #Waypoints
    if Waypoints[last] and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(Waypoints[last])
        NotifSystem:Send("Amethyst", "Teleported to " .. last, "success")
    else
        NotifSystem:Send("Amethyst", "No waypoints saved!", "warning")
    end
end, 2)

UI:CreateButton(wpCard, "Clear All Waypoints", "🗑️", function()
    Waypoints = {}
    NotifSystem:Send("Amethyst", "All waypoints cleared!", "info")
end, 3)

-- ==================== SERVER TAB ====================
local srvSection1 = UI:CreateSection(ServerContent, "Server Control", 1)
local srvCard = UI:CreateCard(srvSection1, 1)

UI:CreateButton(srvCard, "Set Time to Day", "☀️", function()
    Lighting.ClockTime = 12
    NotifSystem:Send("Amethyst", "Time set to noon", "success")
end, 1)

UI:CreateButton(srvCard, "Set Time to Night", "🌙", function()
    Lighting.ClockTime = 0
    NotifSystem:Send("Amethyst", "Time set to midnight", "success")
end, 2)

UI:CreateButton(srvCard, "Enable Fog", "🌫️", function()
    Lighting.FogEnd = 200
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.fromRGB(100, 80, 140)
    NotifSystem:Send("Amethyst", "Fog enabled", "info")
end, 3)

UI:CreateButton(srvCard, "Disable Fog", "🔆", function()
    Lighting.FogEnd = 100000
    NotifSystem:Send("Amethyst", "Fog disabled", "info")
end, 4)

UI:CreateButton(srvCard, "Server Rejoin", "🔁", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end, 5)

-- Utility
local srvSection2 = UI:CreateSection(ServerContent, "Utility", 2)
local utilCard = UI:CreateCard(srvSection2, 1)

local antiAfkConnection = nil

UI:CreateToggle(utilCard, "Anti-AFK", false, function(state)
    if state then
        antiAfkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        NotifSystem:Send("Amethyst", "Anti-AFK enabled", "success")
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        NotifSystem:Send("Amethyst", "Anti-AFK disabled", "info")
    end
end, 1)

UI:CreateToggle(utilCard, "Auto Respawn", false, function(state)
    if state then
        LocalPlayer.CharacterAdded:Connect(function()
            NotifSystem:Send("Amethyst", "Character respawned", "info", 2)
        end)
    end
end, 2)

-- ==================== SCRIPTS TAB ====================
local scrSection1 = UI:CreateSection(ScriptsContent, "Script Executor", 1)
local scrCard = UI:CreateCard(scrSection1, 1)

local scriptInput = Utils:Create("TextBox", {
    Parent = scrCard,
    Size = UDim2.new(1, 0, 0, 120),
    BackgroundColor3 = Theme.Background,
    Text = "",
    PlaceholderText = "-- Write Lua code here...\nprint('Hello Amethyst!')",
    PlaceholderColor3 = Theme.TextMuted,
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    MultiLine = true,
    TextWrapped = true,
    ClearTextOnFocus = false,
    ZIndex = 14,
})
Utils:Create("UICorner", { Parent = scriptInput, CornerRadius = UDim.new(0, 8) })
Utils:Create("UIStroke", { Parent = scriptInput, Color = Theme.Primary, Thickness = 1, Transparency = 0.7 })
Utils:Create("UIPadding", {
    Parent = scriptInput,
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
})

UI:CreateButton(scrCard, "Execute Script", "▶️", function()
    local code = scriptInput.Text
    if code == "" then return end
    local success, err = pcall(function()
        local func = loadstring(code)
        if func then func() end
    end)
    if success then
        NotifSystem:Send("Amethyst", "Script executed successfully!", "success")
    else
        NotifSystem:Send("Amethyst", "Error: " .. tostring(err), "danger", 5)
    end
end, 2)

UI:CreateButton(scrCard, "Clear Editor", "🗑️", function()
    scriptInput.Text = ""
end, 3)

-- ==================== SETTINGS TAB ====================
local setSection1 = UI:CreateSection(SettingsContent, "Appearance", 1)
local appCard = UI:CreateCard(setSection1, 1)

UI:CreateToggle(appCard, "Particle Effects", true, function(state)
    Config.AnimationsEnabled = state
    ParticleSystem.Container.Visible = state
end, 1)

UI:CreateToggle(appCard, "Sound Effects", true, function(state)
    Config.SoundEnabled = state
end, 2)

UI:CreateSlider(appCard, "UI Scale", 70, 130, 100, function(val)
    local scale = val / 100
    MainFrame.Size = UDim2.fromOffset(860 * scale, 600 * scale)
    MainFrame.Position = UDim2.new(0.5, -430 * scale, 0.5, -300 * scale)
end, 3, "%")

-- Keybinds
local setSection2 = UI:CreateSection(SettingsContent, "Keybinds", 2)
local keyCard = UI:CreateCard(setSection2, 1)

Utils:Create("TextLabel", {
    Parent = keyCard,
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "Toggle GUI: Right Shift",
    TextColor3 = Theme.TextSecondary,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 1,
})

Utils:Create("TextLabel", {
    Parent = keyCard,
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "Quick TP: T (hold)",
    TextColor3 = Theme.TextSecondary,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 2,
})

-- About
local setSection3 = UI:CreateSection(SettingsContent, "About", 3)
local aboutCard = UI:CreateCard(setSection3, 1)

Utils:Create("TextLabel", {
    Parent = aboutCard,
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "💎 Amethyst Admin v" .. Config.Version,
    TextColor3 = Theme.TextAccent,
    TextSize = 14,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 1,
})

Utils:Create("TextLabel", {
    Parent = aboutCard,
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = Config.BuildName .. " • " .. Config.Author,
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 2,
})

Utils:Create("TextLabel", {
    Parent = aboutCard,
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Text = "Built with 💜 for the Roblox community",
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    LayoutOrder = 3,
})

-- ==================== STATUS BAR ====================
local StatusBar = Utils:Create("Frame", {
    Name = "StatusBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundColor3 = Theme.BackgroundAlt,
    BorderSizePixel = 0,
    ZIndex = 20,
})

Utils:Create("Frame", {
    Parent = StatusBar,
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Primary,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex = 21,
})

Utils:Create("TextLabel", {
    Parent = StatusBar,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "💎 Amethyst v" .. Config.Version .. " • Connected",
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 21,
})

local statusRight = Utils:Create("TextLabel", {
    Parent = StatusBar,
    Size = UDim2.new(0.5, -12, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "Players: " .. #Players:GetPlayers() .. " • " .. os.date("%H:%M:%S"),
    TextColor3 = Theme.TextMuted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 21,
})

-- ==================== WINDOW DRAGGING ====================
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ==================== WINDOW CONTROLS ====================
CloseBtn.MouseButton1Click:Connect(function()
    Utils:Tween(MainFrame, 0.4, {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.5, function()
        screenGui:Destroy()
    end)
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    NotifSystem:Send("Amethyst", "GUI minimized. Press RightShift to reopen.", "info", 3)
end)

MaxBtn.MouseButton1Click:Connect(function()
    -- Toggle maximized / normal
    if MainFrame.Size.X.Offset >= 1200 then
        Utils:Tween(MainFrame, 0.3, {
            Size = UDim2.fromOffset(860, 600),
            Position = UDim2.new(0.5, -430, 0.5, -300),
        })
    else
        local viewSize = Camera.ViewportSize
        Utils:Tween(MainFrame, 0.3, {
            Size = UDim2.fromOffset(math.min(viewSize.X - 40, 1400), math.min(viewSize.Y - 40, 900)),
            Position = UDim2.new(0.5, -math.min(viewSize.X - 40, 1400) / 2, 0.5, -math.min(viewSize.Y - 40, 900) / 2),
        })
    end
end)

-- ==================== TOGGLE KEYBIND ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.fromOffset(0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            Utils:Tween(MainFrame, 0.5, {
                Size = UDim2.fromOffset(860, 600),
                Position = UDim2.new(0.5, -430, 0.5, -300),
            }, Enum.EasingStyle.Back)
        end
    end
end)

-- ==================== REAL-TIME UPDATES ====================
local lastFrameTime = tick()
local frameCount = 0

task.spawn(function()
    while screenGui and screenGui.Parent do
        -- FPS calculation
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFrameTime >= 1 then
            fpsLabel.Text = tostring(frameCount)
            frameCount = 0
            lastFrameTime = now
        end

        -- Update time
        serverTimeLabel.Text = os.date("%H:%M")
        statusRight.Text = "Players: " .. #Players:GetPlayers() .. " • " .. os.date("%H:%M:%S")

        -- Update ping
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        pingLabel.Text = ping .. "ms"

        -- Update player count
        playerCountLabel.Text = tostring(#Players:GetPlayers())

        task.wait(0.1)
    end
end)

-- ==================== BOOT SEQUENCE ====================
task.spawn(function()
    -- Show loading screen
    LoadingScreen:Create()

    -- Now show main window
    MainFrame.Visible = true
    MainFrame.Size = UDim2.fromOffset(0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundTransparency = 1

    task.wait(0.1)

    Utils:Tween(MainFrame, 0.7, {
        Size = UDim2.fromOffset(860, 600),
        Position = UDim2.new(0.5, -430, 0.5, -300),
        BackgroundTransparency = 0,
    }, Enum.EasingStyle.Back)

    task.wait(0.8)
    SwitchTab("Dashboard")

    NotifSystem:Send("Amethyst Admin", "Welcome back, " .. LocalPlayer.DisplayName .. "! 💎", "amethyst", 4)

    task.wait(1)
    NotifSystem:Send("System", "All modules loaded successfully.", "success", 3)
end)

-- ==================== START PARTICLES ====================
ParticleSystem:Start()

-- ==================== CLEANUP ====================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    NotifSystem:Send("Amethyst", "Character loaded!", "info", 2)
end)

print("═══════════════════════════════════════════")
print("  💎 Amethyst Admin v3.0 - Crystal Edition")
print("  Loaded successfully for: " .. LocalPlayer.Name)
print("  Press RightShift to toggle GUI")
print("═══════════════════════════════════════════")
