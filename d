local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    AUTO_CLICK_DELAY = 0.5,
    UPDATE_INTERVAL = 0.1,
    MIN_SAFE_CHANCE = 0.4,
    MAX_SAFE_CHANCE = 0.7,
    OPPONENT_ADVANTAGE_FACTOR = 0.05,
    CARD_VALUES = {
        L = 99, -- Special card value
        A = 1,  -- Ace
        J = 10, -- Jack
        Q = 10, -- Queen
        K = 10  -- King
    }
}

-- State management
local STATE = {
    AutoOn = false,
    AutoLoopThread = nil,
    LastUpdate = 0,
    GameStats = {
        GamesPlayed = 0,
        Wins = 0,
        Losses = 0
    },
    SessionStats = {
        Clicks = 0,
        Recommendations = {TAKE = 0, HOLD = 0}
    }
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardCounter"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner", TitleBar)
TitleBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🃏 Advanced Card Counter"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Control Buttons
local ControlButtons = Instance.new("Frame")
ControlButtons.Size = UDim2.new(0, 60, 1, 0)
ControlButtons.Position = UDim2.new(1, -65, 0, 0)
ControlButtons.BackgroundTransparency = 1
ControlButtons.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(0, 5, 0.5, -10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = ControlButtons
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(0, 30, 0.5, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = ControlButtons
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Content Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Recommendation Display
local RecFrame = Instance.new("Frame")
RecFrame.Size = UDim2.new(1, 0, 0, 80)
RecFrame.Position = UDim2.new(0, 0, 0, 0)
RecFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RecFrame.Parent = ContentFrame
Instance.new("UICorner", RecFrame).CornerRadius = UDim.new(0, 8)

local RecLabel = Instance.new("TextLabel")
RecLabel.Size = UDim2.new(1, 0, 0.5, 0)
RecLabel.Position = UDim2.new(0, 0, 0, 0)
RecLabel.BackgroundTransparency = 1
RecLabel.Font = Enum.Font.SourceSansBold
RecLabel.TextSize = 24
RecLabel.Text = "ANALYZING..."
RecLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RecLabel.Parent = RecFrame

local RecSubLabel = Instance.new("TextLabel")
RecSubLabel.Size = UDim2.new(1, 0, 0.5, 0)
RecSubLabel.Position = UDim2.new(0, 0, 0.5, 0)
RecSubLabel.BackgroundTransparency = 1
RecSubLabel.Font = Enum.Font.SourceSans
RecSubLabel.TextSize = 14
RecSubLabel.Text = "Calculating optimal move..."
RecSubLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RecSubLabel.Parent = RecFrame

-- Stats Display
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, 0, 0, 100)
StatsFrame.Position = UDim2.new(0, 0, 0, 90)
StatsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatsFrame.Parent = ContentFrame
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 1, -10)
StatsLabel.Position = UDim2.new(0, 5, 0, 5)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextSize = 12
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.TextWrapped = true
StatsLabel.RichText = true
StatsLabel.Text = "Session Stats:\n- Games: 0\n- Wins: 0 (0%)\n- Clicks: 0"
StatsLabel.Parent = StatsFrame

-- Control Panel
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(1, 0, 0, 120)
ControlFrame.Position = UDim2.new(0, 0, 0, 200)
ControlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ControlFrame.Parent = ContentFrame
Instance.new("UICorner", ControlFrame).CornerRadius = UDim.new(0, 8)

-- Auto Play Button
local AutoButton = Instance.new("TextButton")
AutoButton.Size = UDim2.new(1, -20, 0, 35)
AutoButton.Position = UDim2.new(0, 10, 0, 10)
AutoButton.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
AutoButton.Text = "🤖 AUTO PLAY: OFF"
AutoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 14
AutoButton.Parent = ControlFrame
Instance.new("UICorner", AutoButton).CornerRadius = UDim.new(0, 6)

local AutoStatus = Instance.new("TextLabel")
AutoStatus.Size = UDim2.new(1, -20, 0, 20)
AutoStatus.Position = UDim2.new(0, 10, 0, 50)
AutoStatus.BackgroundTransparency = 1
AutoStatus.Font = Enum.Font.SourceSans
AutoStatus.TextSize = 12
AutoStatus.Text = "Status: Ready"
AutoStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
AutoStatus.Parent = ControlFrame

-- Manual Control Buttons
local ManualControls = Instance.new("Frame")
ManualControls.Size = UDim2.new(1, -20, 0, 35)
ManualControls.Position = UDim2.new(0, 10, 0, 75)
ManualControls.BackgroundTransparency = 1
ManualControls.Parent = ControlFrame

local TakeButton = Instance.new("TextButton")
TakeButton.Size = UDim2.new(0.48, 0, 1, 0)
TakeButton.Position = UDim2.new(0, 0, 0, 0)
TakeButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
TakeButton.Text = "🎯 TAKE"
TakeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TakeButton.Font = Enum.Font.SourceSansBold
TakeButton.TextSize = 14
TakeButton.Parent = ManualControls
Instance.new("UICorner", TakeButton).CornerRadius = UDim.new(0, 6)

local HoldButton = Instance.new("TextButton")
HoldButton.Size = UDim2.new(0.48, 0, 1, 0)
HoldButton.Position = UDim2.new(0.52, 0, 0, 0)
HoldButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
HoldButton.Text = "✋ HOLD"
HoldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HoldButton.Font = Enum.Font.SourceSansBold
HoldButton.TextSize = 14
HoldButton.Parent = ManualControls
Instance.new("UICorner", HoldButton).CornerRadius = UDim.new(0, 6)

-- UI Interaction Functions
local function animateButton(button)
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local shrinkTween = TweenService:Create(button, tweenInfo, {Size = originalSize - UDim2.new(0, 4, 0, 4)})
    local growTween = TweenService:Create(button, tweenInfo, {Size = originalSize})
    
    shrinkTween:Play()
    shrinkTween.Completed:Connect(function()
        growTween:Play()
    end)
end

local function setRecommendation(rec, confidence)
    RecLabel.Text = rec
    RecSubLabel.Text = string.format("Confidence: %.1f%%", confidence * 100)
    
    if rec == "TAKE" then
        RecLabel.TextColor3 = Color3.fromRGB(40, 167, 69)
        RecFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
    else
        RecLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
        RecFrame.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
    end
    
    STATE.SessionStats.Recommendations[rec] = (STATE.SessionStats.Recommendations[rec] or 0) + 1
end

local function updateStatsDisplay()
    local winRate = STATE.GameStats.GamesPlayed > 0 and 
        (STATE.GameStats.Wins / STATE.GameStats.GamesPlayed) * 100 or 0
    
    StatsLabel.Text = string.format(
        "Session Stats:\n- Games: %d\n- Wins: %d (%.1f%%)\n- Clicks: %d\n- Recommendations: TAKE(%d) HOLD(%d)",
        STATE.GameStats.GamesPlayed,
        STATE.GameStats.Wins,
        winRate,
        STATE.SessionStats.Clicks,
        STATE.SessionStats.Recommendations.TAKE or 0,
        STATE.SessionStats.Recommendations.HOLD or 0
    )
end

-- Auto Play Functions
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

local function setAutoAppearance(enabled)
    if enabled then
        AutoButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
        AutoButton.Text = "🤖 AUTO PLAY: ON"
        AutoStatus.Text = "Status: Active - Following recommendations"
        AutoStatus.TextColor3 = Color3.fromRGB(40, 167, 69)
    else
        AutoButton.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
        AutoButton.Text = "🤖 AUTO PLAY: OFF"
        AutoStatus.Text = "Status: Ready"
        AutoStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

local function simulateClick(button)
    if not AutoAvailable then return false end
    
    local camera = workspace.CurrentCamera
    if not camera then return false end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    local success = pcall(function()
        if VirtualInputManager then
            local buttonCode = (button == "left") and 0 or 1
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonCode, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonCode, false, game, 1)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            if button == "left" then
                VirtualUser:Button1Down(Vector2.new(vx, vy))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(vx, vy))
            else
                if VirtualUser.Button2Down then
                    VirtualUser:Button2Down(Vector2.new(vx, vy))
                    task.wait(0.05)
                    VirtualUser:Button2Up(Vector2.new(vx, vy))
                end
            end
        end
    end)
    
    if success then
        STATE.SessionStats.Clicks = STATE.SessionStats.Clicks + 1
        updateStatsDisplay()
    end
    
    return success
end

local function startAutoPlay()
    if STATE.AutoLoopThread or not STATE.AutoOn then return end
    
    STATE.AutoLoopThread = task.spawn(function()
        while STATE.AutoOn and ScreenGui.Parent do
            local rec = RecLabel.Text:upper()
            local confidence = tonumber(RecSubLabel.Text:match("([%d.]+)%%")) or 0
            
            if rec == "TAKE" and confidence > 60 then
                AutoStatus.Text = "Action: Taking card..."
                simulateClick("left")
            elseif rec == "HOLD" and confidence > 60 then
                AutoStatus.Text = "Action: Holding..."
                simulateClick("right")
            else
                AutoStatus.Text = "Waiting: Low confidence..."
            end
            
            task.wait(CONFIG.AUTO_CLICK_DELAY)
        end
        STATE.AutoLoopThread = nil
    end)
end

local function stopAutoPlay()
    STATE.AutoOn = false
    if STATE.AutoLoopThread then
        task.cancel(STATE.AutoLoopThread)
        STATE.AutoLoopThread = nil
    end
end

-- Card Analysis Functions
local function getCardValue(cardText)
    if not cardText then return nil end
    
    cardText = cardText:upper():gsub("%s+", "")
    
    -- Check for special cards
    for special, value in pairs(CONFIG.CARD_VALUES) do
        if cardText:find(special) then
            return value
        end
    end
    
    -- Extract numeric value
    local number = cardText:match("%d+")
    return number and tonumber(number) or nil
end

local function calculateDeckProbabilities(mySum, goalValue, visibleCards)
    local deck = {}
    for i = 1, 11 do table.insert(deck, i) end -- Cards 1-11
    
    -- Remove visible cards from deck
    for _, value in ipairs(visibleCards) do
        for i = #deck, 1, -1 do
            if deck[i] == value then
                table.remove(deck, i)
                break
            end
        end
    end
    
    local safeDraws, bustDraws = 0, 0
    local safeValues, bustValues = {}, {}
    
    for _, value in ipairs(deck) do
        if mySum + value <= goalValue then
            safeDraws += 1
            table.insert(safeValues, value)
        else
            bustDraws += 1
            table.insert(bustValues, value)
        end
    end
    
    local totalRemaining = #deck
    local safeChance = totalRemaining > 0 and safeDraws / totalRemaining or 0
    
    return safeChance, safeValues, bustValues, deck
end

local function analyzeGameState()
    local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
    local opponentRoot = workspace.Room and workspace.Room.Opponent and 
                        workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
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
        setRecommendation("WAITING", 0)
        return
    end

    -- Analyze cards
    local myCards, opponentCards, visibleCards = {}, {}, {}
    local mySum, oppKnownSum, oppHiddenCount = 0, 0, 0

    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "Card" and card:IsA("BasePart") then
            local scoreLabel = card:FindFirstChild("Score") and card.Score:FindFirstChild("TextLabel")
            local cardValue = scoreLabel and getCardValue(scoreLabel.Text)
            
            if cardValue then
                table.insert(visibleCards, cardValue)
                
                local distToOpponent = (card.Position - opponentRoot.Position).Magnitude
                local distToMe = (card.Position - myCamera.Position).Magnitude
                local owner = (distToOpponent < distToMe) and "Opponent" or "Me"
                
                if owner == "Me" then
                    table.insert(myCards, cardValue)
                    mySum = mySum + cardValue
                else
                    table.insert(opponentCards, cardValue)
                    oppKnownSum = oppKnownSum + cardValue
                end
            else
                oppHiddenCount = oppHiddenCount + 1
            end
        end
    end

    -- Calculate probabilities
    local safeChance, safeValues, bustValues, remainingDeck = 
        calculateDeckProbabilities(mySum, goalValue, visibleCards)
    
    -- Calculate opponent's expected sum
    local sumOfDeck = 0
    for _, v in ipairs(remainingDeck) do sumOfDeck += v end
    local avgDeckValue = #remainingDeck > 0 and sumOfDeck / #remainingDeck or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)
    
    -- Advanced decision making
    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue
    
    -- Dynamic threshold based on game state
    local requiredSafeChance = CONFIG.MIN_SAFE_CHANCE
    local opponentAdvantage = math.max(0, oppExpectedSum - mySum)
    requiredSafeChance = math.max(CONFIG.MIN_SAFE_CHANCE, 
        requiredSafeChance - (opponentAdvantage * CONFIG.OPPONENT_ADVANTAGE_FACTOR))
    
    -- Make recommendation
    local confidence = 0
    local recommendation = "HOLD"
    
    if opponentBust then
        recommendation = "HOLD"
        confidence = 0.95
    elseif safeChance >= requiredSafeChance and pointsNeeded > 0 then
        recommendation = "TAKE"
        confidence = safeChance
    elseif mySum >= oppExpectedSum and pointsNeeded <= 0 then
        recommendation = "HOLD"
        confidence = 0.85
    else
        recommendation = "HOLD"
        confidence = 1 - safeChance
    end
    
    setRecommendation(recommendation, confidence)
    
    -- Update stats label with detailed info
    local deckText = ""
    for i, card in ipairs(remainingDeck) do
        local color = (mySum + card <= goalValue) and "<font color='#28a745'>" or "<font color='#dc3545'>"
        deckText = deckText .. color .. card .. "</font>"
        if i < #remainingDeck then deckText = deckText .. ", " end
    end
    
    StatsLabel.Text = string.format(
        "My Sum: %d/%d | Opponent: %.1f\nSafe Chance: %.1f%% | Need: %d\nRemaining: %s",
        mySum, goalValue, oppExpectedSum, safeChance * 100, pointsNeeded, deckText
    )
end

-- Event Handlers
MinimizeButton.MouseButton1Click:Connect(function()
    animateButton(MinimizeButton)
    ContentFrame.Visible = not ContentFrame.Visible
    MainFrame.Size = ContentFrame.Visible and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 300, 0, 40)
end)

CloseButton.MouseButton1Click:Connect(function()
    animateButton(CloseButton)
    stopAutoPlay()
    ScreenGui:Destroy()
end)

AutoButton.MouseButton1Click:Connect(function()
    animateButton(AutoButton)
    
    if not AutoAvailable then
        AutoStatus.Text = "Error: Auto-click not supported"
        AutoStatus.TextColor3 = Color3.fromRGB(220, 53, 69)
        task.wait(2)
        AutoStatus.Text = "Status: Ready"
        return
    end
    
    STATE.AutoOn = not STATE.AutoOn
    setAutoAppearance(STATE.AutoOn)
    
    if STATE.AutoOn then
        startAutoPlay()
    else
        stopAutoPlay()
    end
end)

TakeButton.MouseButton1Click:Connect(function()
    animateButton(TakeButton)
    simulateClick("left")
    STATE.GameStats.GamesPlayed = STATE.GameStats.GamesPlayed + 1
    updateStatsDisplay()
end)

HoldButton.MouseButton1Click:Connect(function()
    animateButton(HoldButton)
    simulateClick("right")
    STATE.GameStats.GamesPlayed = STATE.GameStats.GamesPlayed + 1
    updateStatsDisplay()
end)

-- Drag functionality
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

-- Main update loop
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate >= CONFIG.UPDATE_INTERVAL then
        analyzeGameState()
        lastUpdate = now
    end
end)

-- Initialize
setAutoAppearance(false)
updateStatsDisplay()

warn("Advanced Card Counter loaded! Features: Auto-play, Manual controls, Statistics, Enhanced UI")
