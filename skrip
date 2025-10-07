local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    AUTO_CLICK_DELAY = 0.5,
    UPDATE_INTERVAL = 0.1,
    REQUIRED_SAFE_CHANCE = 0.50,
    MIN_SAFE_CHANCE = 0.40,
    OPPONENT_ADVANTAGE_FACTOR = 0.05,
    SMOOTH_ANIMATIONS = true
}

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CardCounter_" .. HttpService:GenerateGUID(false):sub(1, 8)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner", TitleBar)
TitleBarCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Card Counter Pro"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Control Buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 75, 1, 0)
buttonContainer.Position = UDim2.new(1, -80, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = TitleBar

local AutoButton = Instance.new("TextButton")
AutoButton.Size = UDim2.new(0, 25, 0, 25)
AutoButton.Position = UDim2.new(0, 5, 0.5, -12.5)
AutoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
AutoButton.Text = "🤖"
AutoButton.TextColor3 = Color3.fromRGB(200, 200, 255)
AutoButton.Font = Enum.Font.Gotham
AutoButton.TextSize = 12
AutoButton.Parent = buttonContainer

local AutoUICorner = Instance.new("UICorner", AutoButton)
AutoUICorner.CornerRadius = UDim.new(0, 6)

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 25, 0, 25)
SettingsButton.Position = UDim2.new(0, 35, 0.5, -12.5)
SettingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SettingsButton.Text = "⚙️"
SettingsButton.TextColor3 = Color3.fromRGB(200, 200, 255)
SettingsButton.Font = Enum.Font.Gotham
SettingsButton.TextSize = 12
SettingsButton.Parent = buttonContainer

local SettingsUICorner = Instance.new("UICorner", SettingsButton)
SettingsUICorner.CornerRadius = UDim.new(0, 6)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(0, 65, 0.5, -12.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = buttonContainer

local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0, 6)

-- Stats Display
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -20, 0, 80)
StatsFrame.Position = UDim2.new(0, 10, 0, 40)
StatsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MainFrame

local StatsCorner = Instance.new("UICorner", StatsFrame)
StatsCorner.CornerRadius = UDim.new(0, 8)

local StatsStroke = Instance.new("UIStroke", StatsFrame)
StatsStroke.Color = Color3.fromRGB(60, 60, 80)
StatsStroke.Thickness = 1

local MyScoreLabel = Instance.new("TextLabel")
MyScoreLabel.Size = UDim2.new(0.45, 0, 0.4, 0)
MyScoreLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
MyScoreLabel.BackgroundTransparency = 1
MyScoreLabel.Text = "My Score: 0"
MyScoreLabel.Font = Enum.Font.Gotham
MyScoreLabel.TextSize = 14
MyScoreLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
MyScoreLabel.TextXAlignment = Enum.TextXAlignment.Left
MyScoreLabel.Parent = StatsFrame

local OppScoreLabel = Instance.new("TextLabel")
OppScoreLabel.Size = UDim2.new(0.45, 0, 0.4, 0)
OppScoreLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
OppScoreLabel.BackgroundTransparency = 1
OppScoreLabel.Text = "Opponent: 0"
OppScoreLabel.Font = Enum.Font.Gotham
OppScoreLabel.TextSize = 14
MyScoreLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
OppScoreLabel.TextXAlignment = Enum.TextXAlignment.Left
OppScoreLabel.Parent = StatsFrame

local SafeChanceLabel = Instance.new("TextLabel")
SafeChanceLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
SafeChanceLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
SafeChanceLabel.BackgroundTransparency = 1
SafeChanceLabel.Text = "Safe Chance: 0%"
SafeChanceLabel.Font = Enum.Font.Gotham
SafeChanceLabel.TextSize = 14
SafeChanceLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
SafeChanceLabel.TextXAlignment = Enum.TextXAlignment.Left
SafeChanceLabel.Parent = StatsFrame

-- Recommendation Display
local RecommendationFrame = Instance.new("Frame")
RecommendationFrame.Size = UDim2.new(1, -20, 0, 50)
RecommendationFrame.Position = UDim2.new(0, 10, 0, 125)
RecommendationFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
RecommendationFrame.BorderSizePixel = 0
RecommendationFrame.Parent = MainFrame

local RecCorner = Instance.new("UICorner", RecommendationFrame)
RecCorner.CornerRadius = UDim.new(0, 8)

local RecStroke = Instance.new("UIStroke", RecommendationFrame)
RecStroke.Color = Color3.fromRGB(60, 60, 80)
RecStroke.Thickness = 1

local Recommendation = Instance.new("TextLabel")
Recommendation.Size = UDim2.new(1, 0, 1, 0)
Recommendation.Position = UDim2.new(0, 0, 0, 0)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.GothamBlack
Recommendation.TextSize = 20
Recommendation.Text = "ANALYZING..."
Recommendation.TextColor3 = Color3.fromRGB(255, 255, 100)
Recommendation.Parent = RecommendationFrame

-- Info Display
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 180)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 12
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.Text = "Initializing card counter..."
InfoLabel.Parent = MainFrame

-- Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -40, 0, 150)
SettingsFrame.Position = UDim2.new(0, 20, 0.5, -75)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame

local SettingsCorner = Instance.new("UICorner", SettingsFrame)
SettingsCorner.CornerRadius = UDim.new(0, 10)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
SettingsTitle.Position = UDim2.new(0, 0, 0, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 16
SettingsTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
SettingsTitle.Parent = SettingsFrame

-- Auto-click delay slider
local DelaySlider = Instance.new("Frame")
DelaySlider.Size = UDim2.new(0.9, 0, 0, 40)
DelaySlider.Position = UDim2.new(0.05, 0, 0.3, 0)
DelaySlider.BackgroundTransparency = 1
DelaySlider.Parent = SettingsFrame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, 0, 0.5, 0)
DelayLabel.Position = UDim2.new(0, 0, 0, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Auto-click Delay: " .. CONFIG.AUTO_CLICK_DELAY .. "s"
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 12
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = DelaySlider

local CloseSettingsButton = Instance.new("TextButton")
CloseSettingsButton.Size = UDim2.new(0, 80, 0, 25)
CloseSettingsButton.Position = UDim2.new(0.5, -40, 1, -35)
CloseSettingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CloseSettingsButton.Text = "Close"
CloseSettingsButton.TextColor3 = Color3.fromRGB(220, 220, 255)
CloseSettingsButton.Font = Enum.Font.Gotham
CloseSettingsButton.TextSize = 12
CloseSettingsButton.Parent = SettingsFrame

local CloseSettingsCorner = Instance.new("UICorner", CloseSettingsButton)
CloseSettingsCorner.CornerRadius = UDim.new(0, 6)

-- State variables
local AutoOn = false
local AutoLoopThread = nil
local LastUpdate = 0
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)
local SettingsOpen = false

-- Animation functions
local function tweenProperty(instance, property, targetValue, duration)
    if not CONFIG.SMOOTH_ANIMATIONS then
        instance[property] = targetValue
        return
    end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, {[property] = targetValue})
    tween:Play()
    return tween
end

local function pulseAnimation(instance)
    local originalSize = instance.Size
    tweenProperty(instance, "Size", originalSize + UDim2.new(0, 5, 0, 5), 0.1)
    task.delay(0.1, function()
        tweenProperty(instance, "Size", originalSize, 0.1)
    end)
end

-- UI Interaction functions
CloseButton.MouseButton1Click:Connect(function()
    tweenProperty(MainFrame, "BackgroundTransparency", 1, 0.2)
    tweenProperty(UIStroke, "Transparency", 1, 0.2)
    task.wait(0.2)
    ScreenGui:Destroy()
    if script then script:Destroy() end
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsOpen = not SettingsOpen
    SettingsFrame.Visible = SettingsOpen
    pulseAnimation(SettingsButton)
end)

CloseSettingsButton.MouseButton1Click:Connect(function()
    SettingsOpen = false
    SettingsFrame.Visible = false
end)

-- Dragging functionality
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Auto-click functionality
local function setAutoAppearance(on)
    if on then
        tweenProperty(AutoButton, "BackgroundColor3", Color3.fromRGB(80, 180, 80), 0.2)
        AutoButton.Text = "✅"
    else
        tweenProperty(AutoButton, "BackgroundColor3", Color3.fromRGB(60, 60, 80), 0.2)
        AutoButton.Text = "🤖"
    end
end

local function simulateClick(buttonType)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    if buttonType == "left" then
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(vx, vy))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(vx, vy))
        end
    elseif buttonType == "right" then
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, false, game, 1)
        elseif VirtualUser and VirtualUser.Button2Down then
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(vx, vy))
            task.wait(0.05)
            VirtualUser:Button2Up(Vector2.new(vx, vy))
        end
    end
end

local function startAutoLoop()
    if AutoLoopThread then return end
    
    AutoLoopThread = task.spawn(function()
        while AutoOn and ScreenGui.Parent do
            local rec = Recommendation.Text:upper()
            
            if rec:find("TAKE") then
                simulateClick("left")
                task.wait(CONFIG.AUTO_CLICK_DELAY)
            elseif rec:find("HOLD") then
                simulateClick("right")
                task.wait(CONFIG.AUTO_CLICK_DELAY)
            end
            
            task.wait(0.1)
        end
        AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    AutoOn = false
end

AutoButton.MouseButton1Click:Connect(function()
    if not AutoAvailable then
        local originalColor = AutoButton.BackgroundColor3
        tweenProperty(AutoButton, "BackgroundColor3", Color3.fromRGB(180, 60, 60), 0.2)
        task.delay(1, function()
            if AutoButton then
                tweenProperty(AutoButton, "BackgroundColor3", originalColor, 0.2)
            end
        end)
        InfoLabel.Text = "❌ Auto-click not available in this environment"
        return
    end

    AutoOn = not AutoOn
    setAutoAppearance(AutoOn)
    pulseAnimation(AutoButton)
    
    if AutoOn then
        InfoLabel.Text = "🤖 Auto-play: ENABLED"
        startAutoLoop()
    else
        InfoLabel.Text = "🤖 Auto-play: DISABLED"
        stopAutoLoop()
    end
end)

-- Enhanced card analysis function
local function updateAdvisor()
    if tick() - LastUpdate < CONFIG.UPDATE_INTERVAL then
        return
    end
    LastUpdate = tick()
    
    local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
    local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

    -- Get goal value
    local goalValue
    local sumLabel = workspace.Room
        and workspace.Room.Main
        and workspace.Room.Main:FindFirstChild("YourCardsSum")
        and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
        and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
    
    if sumLabel and sumLabel:IsA("TextLabel") then
        goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)"))
    end

    if not (cardsContainer and opponentRoot and myCamera and goalValue) then
        Recommendation.Text = "WAITING..."
        Recommendation.TextColor3 = Color3.fromRGB(255, 255, 100)
        MyScoreLabel.Text = "My Score: --"
        OppScoreLabel.Text = "Opponent: --"
        SafeChanceLabel.Text = "Safe Chance: --%"
        InfoLabel.Text = "🔄 Waiting for game to start..."
        return
    end

    -- Analyze cards
    local myCards, opponentCards = {}, {}
    for _, obj in ipairs(cardsContainer:GetChildren()) do
        if obj.Name == "Card" and obj:IsA("BasePart") then
            local scoreLabel = obj:FindFirstChild("Score") and obj.Score:FindFirstChild("TextLabel")
            local faceValue = scoreLabel and scoreLabel.Text or "[Hidden]"
            local distToOpponent = (obj.Position - opponentRoot.Position).Magnitude
            local distToMe = (obj.Position - myCamera.Position).Magnitude
            local owner = (distToOpponent < distToMe) and "Opponent" or "Me"
            
            if owner == "Me" then
                table.insert(myCards, faceValue)
            else
                table.insert(opponentCards, faceValue)
            end
        end
    end

    local function cardValue(v)
        if v == "L" then return 99 end
        return tonumber(v)
    end

    -- Calculate sums
    local mySum = 0
    for _, v in ipairs(myCards) do
        local n = cardValue(v)
        if n then mySum = mySum + n end
    end

    local oppKnownSum, oppHiddenCount = 0, 0
    for _, v in ipairs(opponentCards) do
        local n = cardValue(v)
        if n then
            oppKnownSum = oppKnownSum + n
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end

    -- Update stat displays
    MyScoreLabel.Text = string.format("My Score: %d/%d", mySum, goalValue)
    OppScoreLabel.Text = string.format("Opponent: %d+%d", oppKnownSum, oppHiddenCount)

    -- Deck analysis
    local deck = {1,2,3,4,5,6,7,8,9,10,11}
    local visibleCards = {}
    
    for _, v in ipairs(myCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    for _, v in ipairs(opponentCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    
    -- Remove visible cards from deck
    for _, cardValue in ipairs(visibleCards) do
        for i, deckCard in ipairs(deck) do
            if deckCard == cardValue then
                table.remove(deck, i)
                break
            end
        end
    end

    -- Calculate probabilities
    local safeDraws, bustDraws = 0, 0
    for _, value in ipairs(deck) do
        if mySum + value <= goalValue then
            safeDraws += 1
        else
            bustDraws += 1
        end
    end
    
    local totalRemaining = safeDraws + bustDraws
    local safeChance = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0

    -- Update safe chance display with color coding
    SafeChanceLabel.Text = string.format("Safe Chance: %.1f%%", safeChance * 100)
    if safeChance >= 0.7 then
        SafeChanceLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
    elseif safeChance >= 0.4 then
        SafeChanceLabel.TextColor3 = Color3.fromRGB(220, 220, 80)
    else
        SafeChanceLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
    end

    -- Advanced decision making
    local sumOfDeck = 0
    for _, v in ipairs(deck) do sumOfDeck += v end
    local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue

    -- Dynamic threshold based on game state
    local requiredSafeChance = CONFIG.REQUIRED_SAFE_CHANCE
    local opponentAdvantage = math.max(0, oppExpectedSum - mySum)
    requiredSafeChance = requiredSafeChance - (opponentAdvantage * CONFIG.OPPONENT_ADVANTAGE_FACTOR)
    requiredSafeChance = math.max(CONFIG.MIN_SAFE_CHANCE, requiredSafeChance)

    -- Make recommendation
    local recommendationText, recommendationColor
    
    if opponentBust then
        recommendationText = "HOLD"
        recommendationColor = Color3.fromRGB(80, 180, 255)  -- Blue for safe hold
    elseif mySum >= goalValue then
        recommendationText = "HOLD"
        recommendationColor = Color3.fromRGB(80, 180, 255)
    elseif (1 - safeChance) >= 0.6 and oppExpectedSum <= mySum then
        recommendationText = "HOLD"
        recommendationColor = Color3.fromRGB(255, 180, 80)  -- Orange for cautious hold
    elseif safeChance >= requiredSafeChance then
        recommendationText = "TAKE"
        recommendationColor = Color3.fromRGB(80, 220, 80)   -- Green for take
    else
        recommendationText = "HOLD"
        recommendationColor = Color3.fromRGB(220, 80, 80)   -- Red for risky hold
    end

    -- Apply recommendation with animation
    if Recommendation.Text ~= recommendationText then
        tweenProperty(Recommendation, "TextColor3", recommendationColor, 0.3)
        Recommendation.Text = recommendationText
        pulseAnimation(RecommendationFrame)
    end

    -- Update info display
    local deckText = ""
    for i, card in ipairs(deck) do
        local color = (mySum + card <= goalValue) and "<font color='#50D250'>" or "<font color='#D25050'>"
        deckText = deckText .. color .. card .. "</font>"
        if i < #deck then deckText = deckText .. ", " end
    end

    InfoLabel.Text = string.format(
        "Points Needed: %d | Opponent Expected: %.1f\nRemaining: %s",
        pointsNeeded,
        oppExpectedSum,
        deckText
    )
end

-- Initialize
setAutoAppearance(false)
InfoLabel.Text = "🎯 Card Counter Pro Initialized!\nWaiting for game data..."

-- Start update loop
RunService.Heartbeat:Connect(updateAdvisor)

-- Welcome message
task.wait(1)
InfoLabel.Text = "🎯 Card Counter Pro Ready!\nAnalyzing game state..."

warn("Card Counter Pro loaded! GUI should be visible on screen.")
