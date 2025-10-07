local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Virtual input detection
local VirtualInputManager, VirtualUser
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    UI = {
        SIZE = UDim2.new(0, 300, 0, 220),
        POSITION = UDim2.new(0.5, -150, 0.2, 0),
        BACKGROUND_COLOR = Color3.fromRGB(25, 25, 35),
        ACCENT_COLOR = Color3.fromRGB(0, 150, 255),
        SUCCESS_COLOR = Color3.fromRGB(50, 200, 100),
        WARNING_COLOR = Color3.fromRGB(255, 170, 0),
        DANGER_COLOR = Color3.fromRGB(220, 60, 60),
        TEXT_COLOR = Color3.fromRGB(240, 240, 240),
        SECONDARY_TEXT = Color3.fromRGB(180, 180, 190)
    },
    AUTO_CLICK = {
        DELAY = 1,
        CLICK_DURATION = 0.02,
        DOUBLE_CLICK_DELAY = 0.1
    },
    GAME = {
        MAX_CARD_VALUE = 11,
        TARGET_SCORE = 21,
        SAFE_THRESHOLD = 0.5
    }
}

-- Create main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedCardCounter"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = CONFIG.UI.SIZE
MainFrame.Position = CONFIG.UI.POSITION
MainFrame.BackgroundColor3 = CONFIG.UI.BACKGROUND_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Modern styling
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2

-- Header with gradient
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = CONFIG.UI.BACKGROUND_COLOR
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)))
})
HeaderGradient.Rotation = -15

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🃏 ADVANCED CARD COUNTER"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Control buttons
local ControlButtons = Instance.new("Frame")
ControlButtons.Size = UDim2.new(0, 60, 1, 0)
ControlButtons.Position = UDim2.new(1, -65, 0, 0)
ControlButtons.BackgroundTransparency = 1
ControlButtons.Parent = Header

local function createControlButton(name, text, color, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = ControlButtons
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    
    return button
end

local AutoButton = createControlButton("Auto", "A", CONFIG.UI.ACCENT_COLOR, UDim2.new(0, 0, 0.5, -13))
local CloseButton = createControlButton("Close", "×", CONFIG.UI.DANGER_COLOR, UDim2.new(0, 30, 0.5, -13))

-- Status indicator
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(0, 5, 0.5, -4)
StatusIndicator.BackgroundColor3 = CONFIG.UI.WARNING_COLOR
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Parent = Header

local StatusCorner = Instance.new("UICorner", StatusIndicator)
StatusCorner.CornerRadius = UDim.new(1, 0)

-- Main content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Recommendation display
local RecommendationContainer = Instance.new("Frame")
RecommendationContainer.Size = UDim2.new(1, 0, 0, 50)
RecommendationContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RecommendationContainer.BorderSizePixel = 0
RecommendationContainer.Parent = Content

local RecCorner = Instance.new("UICorner", RecommendationContainer)
RecCorner.CornerRadius = UDim.new(0, 8)

local Recommendation = Instance.new("TextLabel")
Recommendation.Size = UDim2.new(1, 0, 1, 0)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.GothamBlack
Recommendation.TextSize = 24
Recommendation.Text = "ANALYZING..."
Recommendation.TextColor3 = CONFIG.UI.WARNING_COLOR
Recommendation.Parent = RecommendationContainer

local RecommendationSub = Instance.new("TextLabel")
RecommendationSub.Size = UDim2.new(1, 0, 0, 15)
RecommendationSub.Position = UDim2.new(0, 0, 1, -15)
RecommendationSub.BackgroundTransparency = 1
RecommendationSub.Font = Enum.Font.Gotham
RecommendationSub.TextSize = 11
RecommendationSub.TextColor3 = CONFIG.UI.SECONDARY_TEXT
RecommendationSub.Text = "Calculating optimal move..."
RecommendationSub.Parent = RecommendationContainer

-- Stats display
local StatsContainer = Instance.new("Frame")
StatsContainer.Size = UDim2.new(1, 0, 1, -60)
StatsContainer.Position = UDim2.new(0, 0, 0, 55)
StatsContainer.BackgroundTransparency = 1
StatsContainer.Parent = Content

local StatLabels = {}
local function createStatLabel(name, yPosition)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 20)
    container.Position = UDim2.new(0, 0, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = StatsContainer
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Gotham
    title.TextSize = 12
    title.Text = name
    title.TextColor3 = CONFIG.UI.SECONDARY_TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0.5, 0, 1, 0)
    value.Position = UDim2.new(0.5, 0, 0, 0)
    value.BackgroundTransparency = 1
    value.Font = Enum.Font.GothamBold
    value.TextSize = 12
    value.Text = "---"
    value.TextColor3 = CONFIG.UI.TEXT_COLOR
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.Parent = container
    
    StatLabels[name] = value
    return value
end

createStatLabel("Your Score", 0)
createStatLabel("Safe Chance", 25)
createStatLabel("Points Needed", 50)
createStatLabel("Opponent Expected", 75)
createStatLabel("Remaining Cards", 100)

-- Auto-click functionality
local AutoOn = false
local AutoLoopThread = nil
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

-- Enhanced dragging with smooth movement
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- UI Animations
local function tweenColor(object, property, targetColor, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, {[property] = targetColor})
    tween:Play()
    return tween
end

local function pulseAnimation(object)
    local pulseIn = TweenService:Create(object, TweenInfo.new(0.1), {TextSize = 26})
    local pulseOut = TweenService:Create(object, TweenInfo.new(0.1), {TextSize = 24})
    pulseIn:Play()
    pulseIn.Completed:Connect(function()
        pulseOut:Play()
    end)
end

-- Auto-click appearance management
local function setAutoAppearance(enabled)
    if enabled then
        tweenColor(AutoButton, "BackgroundColor3", CONFIG.UI.SUCCESS_COLOR)
        tweenColor(StatusIndicator, "BackgroundColor3", CONFIG.UI.SUCCESS_COLOR)
        AutoButton.Text = "⏹"
    else
        tweenColor(AutoButton, "BackgroundColor3", CONFIG.UI.ACCENT_COLOR)
        tweenColor(StatusIndicator, "BackgroundColor3", CONFIG.UI.WARNING_COLOR)
        AutoButton.Text = "A"
    end
end

-- Enhanced auto-click system
local function performDoubleClick(buttonType)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    local function doClick(isRightClick)
        if VirtualInputManager then
            local button = isRightClick and 1 or 0
            VirtualInputManager:SendMouseButtonEvent(vx, vy, button, true, game, 1)
            task.wait(CONFIG.AUTO_CLICK.CLICK_DURATION)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, button, false, game, 1)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            if isRightClick and VirtualUser.Button2Down then
                VirtualUser:Button2Down(Vector2.new(vx, vy))
                task.wait(CONFIG.AUTO_CLICK.CLICK_DURATION)
                VirtualUser:Button2Up(Vector2.new(vx, vy))
            elseif not isRightClick then
                VirtualUser:Button1Down(Vector2.new(vx, vy))
                task.wait(CONFIG.AUTO_CLICK.CLICK_DURATION)
                VirtualUser:Button1Up(Vector2.new(vx, vy))
            end
        end
    end
    
    local isRightClick = (buttonType == "right")
    doClick(isRightClick)
    task.wait(CONFIG.AUTO_CLICK.DOUBLE_CLICK_DELAY)
    doClick(isRightClick)
end

local function startAutoLoop()
    if AutoLoopThread then return end
    
    AutoLoopThread = task.spawn(function()
        while AutoOn and ScreenGui.Parent do
            local recText = string.upper(Recommendation.Text or "")
            
            if recText:find("TAKE") then
                performDoubleClick("left")
            elseif recText:find("HOLD") then
                performDoubleClick("right")
            end
            
            task.wait(CONFIG.AUTO_CLICK.DELAY)
        end
        AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    AutoOn = false
end

-- Button interactions with animations
AutoButton.MouseButton1Click:Connect(function()
    if not AutoAvailable then
        tweenColor(AutoButton, "BackgroundColor3", CONFIG.UI.DANGER_COLOR)
        task.delay(0.5, function()
            tweenColor(AutoButton, "BackgroundColor3", CONFIG.UI.ACCENT_COLOR)
        end)
        return
    end

    AutoOn = not AutoOn
    setAutoAppearance(AutoOn)
    
    if AutoOn then
        startAutoLoop()
        RecommendationSub.Text = "Auto-play: ENABLED"
    else
        stopAutoLoop()
        RecommendationSub.Text = "Auto-play: DISABLED"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    tweenColor(CloseButton, "BackgroundColor3", Color3.fromRGB(150, 30, 30))
    task.wait(0.1)
    ScreenGui:Destroy()
    if script then script:Destroy() end
end)

-- Enhanced card analysis system
local function updateAdvisor()
    local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
    local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

    -- Get target score
    local goalValue
    local sumLabel = workspace.Room
        and workspace.Room.Main
        and workspace.Room.Main:FindFirstChild("YourCardsSum")
        and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
        and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
    
    if sumLabel and sumLabel:IsA("TextLabel") then
        goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)")) or CONFIG.GAME.TARGET_SCORE
    else
        goalValue = CONFIG.GAME.TARGET_SCORE
    end

    if not (cardsContainer and opponentRoot and myCamera) then
        Recommendation.Text = "WAITING"
        RecommendationSub.Text = "Waiting for game to start..."
        tweenColor(Recommendation, "TextColor3", CONFIG.UI.WARNING_COLOR)
        StatusIndicator.BackgroundColor3 = CONFIG.UI.WARNING_COLOR
        return
    end

    -- Analyze cards
    local myCards, opponentCards = {}, {}
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "Card" and card:IsA("BasePart") then
            local scoreLabel = card:FindFirstChild("Score") and card.Score:FindFirstChild("TextLabel")
            local faceValue = scoreLabel and scoreLabel.Text or "[Hidden]"
            local distToOpponent = (card.Position - opponentRoot.Position).Magnitude
            local distToMe = (card.Position - myCamera.Position).Magnitude
            local owner = (distToOpponent < distToMe) and "Opponent" or "Me"
            
            if owner == "Me" then
                table.insert(myCards, faceValue)
            else
                table.insert(opponentCards, faceValue)
            end
        end
    end

    -- Calculate scores
    local function cardValue(v)
        if v == "L" then return 99 end -- Special card
        return tonumber(v) or 0
    end

    local mySum = 0
    for _, v in ipairs(myCards) do
        mySum = mySum + (cardValue(v) or 0)
    end

    local oppKnownSum, oppHiddenCount = 0, 0
    for _, v in ipairs(opponentCards) do
        local n = cardValue(v)
        if n and n ~= 99 then
            oppKnownSum = oppKnownSum + n
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end

    -- Deck analysis
    local deck = {}
    for i = 1, CONFIG.GAME.MAX_CARD_VALUE do
        table.insert(deck, i)
    end

    -- Remove visible cards from deck
    local visibleCards = {}
    for _, v in ipairs(myCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    for _, v in ipairs(opponentCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end

    for _, cardValue in ipairs(visibleCards) do
        for i, deckCard in ipairs(deck) do
            if deckCard == cardValue then
                table.remove(deck, i)
                break
            end
        end
    end

    -- Probability calculation
    local safeDraws, bustDraws = 0, 0
    for _, value in ipairs(deck) do
        if mySum + value <= goalValue then
            safeDraws = safeDraws + 1
        else
            bustDraws = bustDraws + 1
        end
    end

    local totalRemaining = #deck
    local safeChance = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0

    -- Opponent prediction
    local sumOfDeck = 0
    for _, v in ipairs(deck) do sumOfDeck = sumOfDeck + v end
    local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue

    -- Advanced decision making
    local requiredSafeChance = CONFIG.GAME.SAFE_THRESHOLD
    local opponentAdvantage = math.max(0, oppExpectedSum - mySum)
    requiredSafeChance = math.max(0.35, requiredSafeChance - (opponentAdvantage * 0.03))

    local recommendation, reason, color
    if opponentBust then
        recommendation, reason, color = "HOLD", "Opponent will bust!", CONFIG.UI.SUCCESS_COLOR
    elseif mySum >= goalValue then
        recommendation, reason, color = "HOLD", "You've reached the target!", CONFIG.UI.SUCCESS_COLOR
    elseif safeChance >= requiredSafeChance then
        recommendation, reason, color = "TAKE", "High chance of safe draw", CONFIG.UI.SUCCESS_COLOR
    elseif (1 - safeChance) >= 0.6 and oppExpectedSum <= mySum then
        recommendation, reason, color = "HOLD", "Low safe chance but you're ahead", CONFIG.UI.WARNING_COLOR
    else
        recommendation, reason, color = "HOLD", "Too risky to draw", CONFIG.UI.DANGER_COLOR
    end

    -- Update UI
    Recommendation.Text = recommendation
    RecommendationSub.Text = reason
    tweenColor(Recommendation, "TextColor3", color)
    pulseAnimation(Recommendation)

    -- Update stats
    StatLabels["Your Score"].Text = string.format("%d/%d", mySum, goalValue)
    StatLabels["Safe Chance"].Text = string.format("%.1f%%", safeChance * 100)
    StatLabels["Points Needed"].Text = tostring(pointsNeeded)
    StatLabels["Opponent Expected"].Text = string.format("%.1f", oppExpectedSum)
    StatLabels["Remaining Cards"].Text = string.format("%d cards", totalRemaining)

    -- Update status indicator based on risk
    if safeChance >= 0.7 then
        StatusIndicator.BackgroundColor3 = CONFIG.UI.SUCCESS_COLOR
    elseif safeChance >= 0.4 then
        StatusIndicator.BackgroundColor3 = CONFIG.UI.WARNING_COLOR
    else
        StatusIndicator.BackgroundColor3 = CONFIG.UI.DANGER_COLOR
    end
end

-- Initialize with smooth appearance
local function initializeUI()
    MainFrame.Position = CONFIG.UI.POSITION + UDim2.new(0, 0, 0, -50)
    MainFrame.BackgroundTransparency = 1
    
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5), {
        Position = CONFIG.UI.POSITION,
        BackgroundTransparency = 0
    })
    tween:Play()
end

initializeUI()
RunService.RenderStepped:Connect(updateAdvisor)
