local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Enhanced virtual input detection
local VirtualInputManager, VirtualUser
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    UI = {
        SIZE = UDim2.new(0, 280, 0, 200),
        POSITION = UDim2.new(0.5, -140, 0.2, 0),
        BACKGROUND_COLOR = Color3.fromRGB(25, 25, 25),
        ACCENT_COLOR = Color3.fromRGB(0, 120, 215),
        SUCCESS_COLOR = Color3.fromRGB(45, 180, 90),
        WARNING_COLOR = Color3.fromRGB(220, 160, 40),
        DANGER_COLOR = Color3.fromRGB(220, 60, 60),
        CORNER_RADIUS = 8
    },
    AUTO_CLICK = {
        DELAY = 1.0,
        DOUBLE_CLICK_INTERVAL = 0.1,
        CLICK_DURATION = 0.02
    },
    GAME = {
        MAX_SCORE = 21,
        SPECIAL_CARD_VALUE = 99
    }
}

-- State management
local State = {
    AutoEnabled = false,
    AutoLoopThread = nil,
    LastUpdate = 0,
    UpdateInterval = 0.1,
    DebugMode = false
}

-- Create modern UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedCardCounter"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main container with subtle shadow effect
local MainFrame = Instance.new("Frame")
MainFrame.Size = CONFIG.UI.SIZE
MainFrame.Position = CONFIG.UI.POSITION
MainFrame.BackgroundColor3 = CONFIG.UI.BACKGROUND_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Modern shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, CONFIG.UI.CORNER_RADIUS)
UICorner.Parent = MainFrame

-- Header with gradient
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = CONFIG.UI.ACCENT_COLOR
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, CONFIG.UI.CORNER_RADIUS)
HeaderCorner.Parent = Header

-- Only round top corners for header
local Mask = Instance.new("Frame")
Mask.Name = "Mask"
Mask.Size = UDim2.new(1, 0, 1, 10)
Mask.Position = UDim2.new(0, 0, 0, 0)
Mask.BackgroundColor3 = Header.BackgroundColor3
Mask.BorderSizePixel = 0
Mask.Parent = Header

-- Title with icon
local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(1, -80, 1, 0)
TitleContainer.Position = UDim2.new(0, 10, 0, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.Parent = Header

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 20, 0, 20)
TitleIcon.Position = UDim2.new(0, 0, 0.5, -10)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🎴"
TitleIcon.TextSize = 14
TitleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleIcon.Font = Enum.Font.SourceSans
TitleIcon.Parent = TitleContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -25, 1, 0)
Title.Position = UDim2.new(0, 25, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ADVANCED CARD COUNTER"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleContainer

-- Control buttons
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0, 60, 1, 0)
ButtonContainer.Position = UDim2.new(1, -65, 0, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = Header

local function createControlButton(name, text, color, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = ButtonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3})
    local unhoverTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0})
    
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        unhoverTween:Play()
    end)
    
    return button
end

local AutoButton = createControlButton("AutoButton", "A", Color3.fromRGB(40, 40, 40), UDim2.new(0, 0, 0.5, -12.5))
local CloseButton = createControlButton("CloseButton", "×", Color3.fromRGB(180, 40, 40), UDim2.new(1, -25, 0.5, -12.5))

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Recommendation display
local RecommendationCard = Instance.new("Frame")
RecommendationCard.Size = UDim2.new(1, 0, 0, 50)
RecommendationCard.Position = UDim2.new(0, 0, 0, 0)
RecommendationCard.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RecommendationCard.Parent = Content

local RecommendationCorner = Instance.new("UICorner")
RecommendationCorner.CornerRadius = UDim.new(0, 6)
RecommendationCorner.Parent = RecommendationCard

local RecommendationLabel = Instance.new("TextLabel")
RecommendationLabel.Size = UDim2.new(1, 0, 0.6, 0)
RecommendationLabel.Position = UDim2.new(0, 0, 0, 0)
RecommendationLabel.BackgroundTransparency = 1
RecommendationLabel.Text = "ANALYZING..."
RecommendationLabel.Font = Enum.Font.GothamBlack
RecommendationLabel.TextSize = 18
RecommendationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RecommendationLabel.Parent = RecommendationCard

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, 0, 0.4, 0)
SubtitleLabel.Position = UDim2.new(0, 0, 0.6, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Calculating optimal strategy..."
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 11
SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SubtitleLabel.Parent = RecommendationCard

-- Stats display
local StatsContainer = Instance.new("Frame")
StatsContainer.Size = UDim2.new(1, 0, 0, 100)
StatsContainer.Position = UDim2.new(0, 0, 0, 60)
StatsContainer.BackgroundTransparency = 1
StatsContainer.Parent = Content

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 1, 0)
StatsLabel.Position = UDim2.new(0, 0, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.TextWrapped = true
StatsLabel.RichText = true
StatsLabel.Text = "Initializing card counter..."
StatsLabel.Parent = StatsContainer

-- Enhanced dragging with smooth animation
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
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Enhanced auto-click functionality
local function performDoubleClick(buttonType)
    local camera = workspace.CurrentCamera
    if not camera then return false end
    
    local vx, vy = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
    local success = true
    
    local function executeClick(down, up)
        if VirtualInputManager then
            local buttonIndex = (buttonType == "right") and 1 or 0
            if not pcall(function()
                VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, down, game, 1)
                task.wait(CONFIG.AUTO_CLICK.CLICK_DURATION)
                VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, up, game, 1)
            end) then
                success = false
            end
        elseif VirtualUser then
            if not pcall(function()
                VirtualUser:CaptureController()
                if buttonType == "right" then
                    if down then VirtualUser:Button2Down(Vector2.new(vx, vy)) end
                    if up then VirtualUser:Button2Up(Vector2.new(vx, vy)) end
                else
                    if down then VirtualUser:Button1Down(Vector2.new(vx, vy)) end
                    if up then VirtualUser:Button1Up(Vector2.new(vx, vy)) end
                end
            end) then
                success = false
            end
        else
            success = false
        end
    end
    
    -- First click
    executeClick(true, true)
    task.wait(CONFIG.AUTO_CLICK.DOUBLE_CLICK_INTERVAL)
    -- Second click
    executeClick(true, true)
    
    return success
end

-- Enhanced card analysis
local function analyzeGameState()
    local room = workspace:FindFirstChild("Room")
    if not room then return nil end
    
    -- Get goal value
    local goalValue
    local sumLabel = room:FindFirstChild("Main")
        and room.Main:FindFirstChild("YourCardsSum")
        and room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
        and room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
    
    if sumLabel and sumLabel:IsA("TextLabel") then
        goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)"))
    end
    
    if not goalValue then return nil end
    
    -- Get cards and ownership
    local cardsContainer = room:FindFirstChild("Cards")
    local opponentRoot = room.Opponent and room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = room:FindFirstChild("Camera")
    
    if not (cardsContainer and opponentRoot and myCamera) then return nil end
    
    local myCards, opponentCards = {}, {}
    
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "Card" and card:IsA("BasePart") then
            local scoreLabel = card:FindFirstChild("Score") and card.Score:FindFirstChild("TextLabel")
            local faceValue = scoreLabel and scoreLabel.Text or "[Hidden]"
            
            local distToOpponent = (card.Position - opponentRoot.Position).Magnitude
            local distToMe = (card.Position - myCamera.Position).Magnitude
            
            if distToMe < distToOpponent then
                table.insert(myCards, {value = faceValue, part = card})
            else
                table.insert(opponentCards, {value = faceValue, part = card})
            end
        end
    end
    
    return {
        goalValue = goalValue,
        myCards = myCards,
        opponentCards = opponentCards,
        room = room
    }
end

-- Advanced probability calculation
local function calculateOptimalStrategy(gameData)
    local function parseCardValue(valueStr)
        if valueStr == "L" then return CONFIG.GAME.SPECIAL_CARD_VALUE end
        return tonumber(valueStr) or 0
    end
    
    -- Calculate current sums
    local mySum = 0
    for _, card in ipairs(gameData.myCards) do
        mySum = mySum + parseCardValue(card.value)
    end
    
    local oppKnownSum, oppHiddenCount = 0, 0
    for _, card in ipairs(gameData.opponentCards) do
        local value = parseCardValue(card.value)
        if value > 0 then
            oppKnownSum = oppKnownSum + value
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end
    
    -- Build deck and remove visible cards
    local fullDeck = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
    local visibleCards = {}
    
    for _, card in ipairs(gameData.myCards) do
        local value = parseCardValue(card.value)
        if value > 0 and value <= 11 then
            table.insert(visibleCards, value)
        end
    end
    
    for _, card in ipairs(gameData.opponentCards) do
        local value = parseCardValue(card.value)
        if value > 0 and value <= 11 then
            table.insert(visibleCards, value)
        end
    end
    
    local remainingDeck = {}
    for _, cardValue in ipairs(fullDeck) do
        local countInVisible = 0
        for _, visibleValue in ipairs(visibleCards) do
            if visibleValue == cardValue then
                countInVisible = countInVisible + 1
            end
        end
        
        local totalInDeck = (cardValue == 10) and 4 or 1
        local remaining = math.max(0, totalInDeck - countInVisible)
        
        for i = 1, remaining do
            table.insert(remainingDeck, cardValue)
        end
    end
    
    -- Calculate probabilities
    local safeDraws, bustDraws = 0, 0
    local safeCards, bustCards = {}, {}
    
    for _, cardValue in ipairs(remainingDeck) do
        if mySum + cardValue <= gameData.goalValue then
            safeDraws = safeDraws + 1
            table.insert(safeCards, cardValue)
        else
            bustDraws = bustDraws + 1
            table.insert(bustCards, cardValue)
        end
    end
    
    local totalRemaining = #remainingDeck
    local safeProbability = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0
    
    -- Calculate opponent's expected score
    local deckSum = 0
    for _, card in ipairs(remainingDeck) do
        deckSum = deckSum + card
    end
    local avgCardValue = (totalRemaining > 0) and (deckSum / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgCardValue)
    
    -- Advanced decision making
    local pointsNeeded = gameData.goalValue - mySum
    local opponentBust = oppKnownSum > gameData.goalValue
    
    -- Dynamic threshold based on game state
    local baseThreshold = 0.5
    local scoreDifference = oppExpectedSum - mySum
    
    -- Adjust threshold based on opponent's advantage
    local dynamicThreshold = baseThreshold - (scoreDifference * 0.03)
    dynamicThreshold = math.clamp(dynamicThreshold, 0.35, 0.65)
    
    -- Adjust for points needed
    if pointsNeeded <= 3 then
        dynamicThreshold = dynamicThreshold - 0.1
    elseif pointsNeeded >= 8 then
        dynamicThreshold = dynamicThreshold + 0.1
    end
    
    local recommendation, confidence, color
    
    if opponentBust then
        recommendation = "HOLD"
        confidence = "Opponent likely bust!"
        color = CONFIG.UI.SUCCESS_COLOR
    elseif mySum >= gameData.goalValue then
        recommendation = "HOLD"
        confidence = "Maximum score reached"
        color = CONFIG.UI.SUCCESS_COLOR
    elseif safeProbability >= dynamicThreshold then
        recommendation = "TAKE"
        confidence = string.format("Good chance (%.1f%%)", safeProbability * 100)
        color = CONFIG.UI.SUCCESS_COLOR
    else
        recommendation = "HOLD"
        confidence = string.format("Risky (%.1f%% safe)", safeProbability * 100)
        color = CONFIG.UI.DANGER_COLOR
    end
    
    -- Prepare stats display
    local statsText = string.format(
        "My Score: <font color='#FFFFFF'>%d</font> | Need: <font color='#%s'>%d</font>\n" ..
        "Opponent: <font color='#FFFFFF'>%.1f</font> (known: %d)\n" ..
        "Safe Chance: <font color='#%s'>%.1f%%</font> | Cards Left: <font color='#FFFFFF'>%d</font>\n" ..
        "Safe Cards: <font color='#32C832'>%s</font>",
        mySum,
        (pointsNeeded <= 3) and "32C832" or (pointsNeeded <= 6) and "C8C832" or "C83232",
        pointsNeeded,
        oppExpectedSum,
        oppKnownSum,
        (safeProbability >= 0.6) and "32C832" or (safeProbability >= 0.4) and "C8C832" or "C83232",
        safeProbability * 100,
        totalRemaining,
        table.concat(safeCards, ", ")
    )
    
    return {
        recommendation = recommendation,
        confidence = confidence,
        color = color,
        stats = statsText,
        shouldTake = (recommendation == "TAKE")
    }
end

-- Enhanced auto-loop
local function startAutoLoop()
    if State.AutoLoopThread then return end
    
    State.AutoLoopThread = task.spawn(function()
        local lastActionTime = 0
        
        while State.AutoEnabled and ScreenGui.Parent do
            local currentTime = tick()
            
            if currentTime - lastActionTime >= CONFIG.AUTO_CLICK.DELAY then
                local gameData = analyzeGameState()
                
                if gameData then
                    local strategy = calculateOptimalStrategy(gameData)
                    
                    if strategy then
                        local success = false
                        
                        if strategy.shouldTake then
                            success = performDoubleClick("left")
                        else
                            success = performDoubleClick("right")
                        end
                        
                        if success then
                            lastActionTime = currentTime
                        else
                            State.DebugMode = true
                            warn("Auto-click: Input method failed")
                        end
                    end
                end
            end
            
            task.wait(0.1)
        end
        State.AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    State.AutoEnabled = false
end

-- UI update function
local function updateUI()
    local currentTime = tick()
    if currentTime - State.LastUpdate < State.UpdateInterval then return end
    State.LastUpdate = currentTime
    
    local gameData = analyzeGameState()
    
    if not gameData then
        RecommendationLabel.Text = "WAITING FOR GAME"
        SubtitleLabel.Text = "Join a card game to begin analysis"
        RecommendationLabel.TextColor3 = CONFIG.UI.WARNING_COLOR
        StatsLabel.Text = "No active game detected. Please join a card game room."
        return
    end
    
    local strategy = calculateOptimalStrategy(gameData)
    
    if strategy then
        RecommendationLabel.Text = strategy.recommendation
        SubtitleLabel.Text = strategy.confidence
        RecommendationLabel.TextColor3 = strategy.color
        
        -- Animate recommendation card
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(RecommendationCard, tweenInfo, {BackgroundColor3 = Color3.fromRGB(
            math.floor(strategy.color.R * 0.1 * 255),
            math.floor(strategy.color.G * 0.1 * 255),
            math.floor(strategy.color.B * 0.1 * 255)
        )})
        tween:Play()
        
        StatsLabel.Text = strategy.stats
    end
end

-- Auto button functionality
local function setAutoAppearance(enabled)
    if enabled then
        AutoButton.BackgroundColor3 = CONFIG.UI.SUCCESS_COLOR
        AutoButton.Text = "⏸"
    else
        AutoButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        AutoButton.Text = "▶"
    end
end

AutoButton.MouseButton1Click:Connect(function()
    if not (VirtualInputManager or VirtualUser) then
        local originalColor = AutoButton.BackgroundColor3
        AutoButton.BackgroundColor3 = CONFIG.UI.DANGER_COLOR
        task.delay(0.5, function()
            if AutoButton then
                AutoButton.BackgroundColor3 = originalColor
            end
        end)
        StatsLabel.Text = StatsLabel.Text .. "\n[ERROR] No supported input method found!"
        return
    end
    
    State.AutoEnabled = not State.AutoEnabled
    setAutoAppearance(State.AutoEnabled)
    
    if State.AutoEnabled then
        startAutoLoop()
        SubtitleLabel.Text = "Auto-play enabled"
    else
        stopAutoLoop()
        SubtitleLabel.Text = "Auto-play disabled"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    stopAutoLoop()
    ScreenGui:Destroy()
    if script then
        script:Destroy()
    end
end)

-- Initialize
setAutoAppearance(false)

-- Start UI updates
RunService.Heartbeat:Connect(updateUI)

-- Smooth entrance animation
local entranceTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = CONFIG.UI.POSITION + UDim2.new(0, 0, 0, -10)
})
MainFrame.Position = CONFIG.UI.POSITION + UDim2.new(0, 0, 0, 50)
MainFrame.BackgroundTransparency = 1
Header.BackgroundTransparency = 1
RecommendationCard.BackgroundTransparency = 1

task.spawn(function()
    task.wait(0.1)
    entranceTween:Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Header, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(RecommendationCard, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end)

print("Advanced Card Counter v2.0 loaded successfully!")
