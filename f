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
    UI = {
        SIZE = UDim2.new(0, 300, 0, 220),
        POSITION = UDim2.new(0.5, -150, 0.2, 0),
        BACKGROUND_COLOR = Color3.fromRGB(25, 25, 35),
        ACCENT_COLOR = Color3.fromRGB(0, 150, 255),
        SUCCESS_COLOR = Color3.fromRGB(50, 200, 100),
        WARNING_COLOR = Color3.fromRGB(255, 200, 50),
        DANGER_COLOR = Color3.fromRGB(220, 80, 80)
    },
    AUTO_CLICK = {
        DELAY = 1,
        DOUBLE_CLICK_INTERVAL = 0.1
    },
    GAME = {
        MAX_CARD_VALUE = 11,
        TARGET_SCORE = 21
    }
}

-- Create main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardCounter"
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

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

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

-- Control buttons container
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

local AutoButton = createControlButton("Auto", "A", CONFIG.UI.BACKGROUND_COLOR, UDim2.new(0, 0, 0, 3))
local SettingsButton = createControlButton("Settings", "⚙", CONFIG.UI.ACCENT_COLOR, UDim2.new(0, 30, 0, 3))
local CloseButton = createControlButton("Close", "×", CONFIG.UI.DANGER_COLOR, UDim2.new(0, 30, 0, 30))

-- Status indicator
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(0, 5, 0, 5)
StatusIndicator.BackgroundColor3 = CONFIG.UI.WARNING_COLOR
StatusIndicator.Parent = MainFrame
local StatusCorner = Instance.new("UICorner", StatusIndicator)
StatusCorner.CornerRadius = UDim.new(1, 0)

-- Recommendation display
local RecommendationContainer = Instance.new("Frame")
RecommendationContainer.Size = UDim2.new(1, -20, 0, 60)
RecommendationContainer.Position = UDim2.new(0, 10, 0, 45)
RecommendationContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
RecommendationContainer.Parent = MainFrame
local RecCorner = Instance.new("UICorner", RecommendationContainer)
RecCorner.CornerRadius = UDim.new(0, 8)

local RecommendationLabel = Instance.new("TextLabel")
RecommendationLabel.Size = UDim2.new(1, 0, 0.6, 0)
RecommendationLabel.Position = UDim2.new(0, 0, 0, 0)
RecommendationLabel.BackgroundTransparency = 1
RecommendationLabel.Font = Enum.Font.GothamBlack
RecommendationLabel.TextSize = 24
RecommendationLabel.Text = "ANALYZING..."
RecommendationLabel.TextColor3 = CONFIG.UI.WARNING_COLOR
RecommendationLabel.Parent = RecommendationContainer

local SubRecommendation = Instance.new("TextLabel")
SubRecommendation.Size = UDim2.new(1, 0, 0.4, 0)
SubRecommendation.Position = UDim2.new(0, 0, 0.6, 0)
SubRecommendation.BackgroundTransparency = 1
SubRecommendation.Font = Enum.Font.Gotham
SubRecommendation.TextSize = 12
SubRecommendation.Text = "Calculating optimal strategy..."
SubRecommendation.TextColor3 = Color3.fromRGB(180, 180, 200)
SubRecommendation.Parent = RecommendationContainer

-- Stats panel
local StatsPanel = Instance.new("Frame")
StatsPanel.Size = UDim2.new(1, -20, 0, 100)
StatsPanel.Position = UDim2.new(0, 10, 0, 115)
StatsPanel.BackgroundTransparency = 1
StatsPanel.Parent = MainFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 1, 0)
StatsLabel.Position = UDim2.new(0, 0, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.TextWrapped = true
StatsLabel.RichText = true
StatsLabel.Text = "Initializing card counter..."
StatsLabel.Parent = StatsPanel

-- Auto-click functionality
local AutoOn = false
local AutoLoopThread = nil
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

-- Settings menu
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -40, 0, 150)
SettingsFrame.Position = UDim2.new(0, 20, 0.5, -75)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame
local SettingsCorner = Instance.new("UICorner", SettingsFrame)
SettingsCorner.CornerRadius = UDim.new(0, 8)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
SettingsTitle.Position = UDim2.new(0, 0, 0, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "SETTINGS"
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 16
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.Parent = SettingsFrame

-- Risk tolerance slider
local RiskSlider = Instance.new("Frame")
RiskSlider.Size = UDim2.new(1, -20, 0, 40)
RiskSlider.Position = UDim2.new(0, 10, 0, 40)
RiskSlider.BackgroundTransparency = 1
RiskSlider.Parent = SettingsFrame

local RiskLabel = Instance.new("TextLabel")
RiskLabel.Size = UDim2.new(1, 0, 0, 20)
RiskLabel.Position = UDim2.new(0, 0, 0, 0)
RiskLabel.BackgroundTransparency = 1
RiskLabel.Text = "Risk Tolerance: Medium"
RiskLabel.Font = Enum.Font.Gotham
RiskLabel.TextSize = 12
RiskLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RiskLabel.TextXAlignment = Enum.TextXAlignment.Left
RiskLabel.Parent = RiskSlider

local RiskValue = 0.5 -- Default medium risk

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 1, -10)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SliderTrack.Parent = RiskSlider
local TrackCorner = Instance.new("UICorner", SliderTrack)
TrackCorner.CornerRadius = UDim.new(0, 3)

local SliderThumb = Instance.new("Frame")
SliderThumb.Size = UDim2.new(0, 16, 0, 16)
SliderThumb.Position = UDim2.new(RiskValue, -8, 1, -13)
SliderThumb.BackgroundColor3 = CONFIG.UI.ACCENT_COLOR
SliderThumb.Parent = RiskSlider
local ThumbCorner = Instance.new("UICorner", SliderThumb)
ThumbCorner.CornerRadius = UDim.new(1, 0)

-- Close settings button
local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0, 100, 0, 30)
CloseSettings.Position = UDim2.new(0.5, -50, 1, -40)
CloseSettings.BackgroundColor3 = CONFIG.UI.ACCENT_COLOR
CloseSettings.Text = "APPLY"
CloseSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseSettings.Font = Enum.Font.GothamBold
CloseSettings.TextSize = 14
CloseSettings.Parent = SettingsFrame
local CloseSettingsCorner = Instance.new("UICorner", CloseSettings)
CloseSettingsCorner.CornerRadius = UDim.new(0, 6)

-- UI Interactions
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
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

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button animations
local function animateButton(button)
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local shrink = TweenService:Create(button, tweenInfo, {Size = originalSize - UDim2.new(0, 2, 0, 2)})
    local grow = TweenService:Create(button, tweenInfo, {Size = originalSize})
    
    shrink:Play()
    shrink.Completed:Connect(function()
        grow:Play()
    end)
end

-- Auto-click functionality
local function setAutoAppearance(enabled)
    if enabled then
        AutoButton.BackgroundColor3 = CONFIG.UI.SUCCESS_COLOR
        StatusIndicator.BackgroundColor3 = CONFIG.UI.SUCCESS_COLOR
    else
        AutoButton.BackgroundColor3 = CONFIG.UI.BACKGROUND_COLOR
        StatusIndicator.BackgroundColor3 = CONFIG.UI.WARNING_COLOR
    end
end

local function performDoubleClick(buttonIndex)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    local function doClick()
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, false, game, 1)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            if buttonIndex == 0 then
                VirtualUser:Button1Down(Vector2.new(vx, vy))
                task.wait(0.02)
                VirtualUser:Button1Up(Vector2.new(vx, vy))
            elseif buttonIndex == 1 and VirtualUser.Button2Down then
                VirtualUser:Button2Down(Vector2.new(vx, vy))
                task.wait(0.02)
                VirtualUser:Button2Up(Vector2.new(vx, vy))
            end
        end
    end
    
    doClick()
    task.wait(CONFIG.AUTO_CLICK.DOUBLE_CLICK_INTERVAL)
    doClick()
end

local function startAutoLoop()
    if AutoLoopThread then return end
    
    AutoLoopThread = task.spawn(function()
        while AutoOn and ScreenGui.Parent do
            local rec = RecommendationLabel.Text:upper()
            
            if rec:find("TAKE") then
                performDoubleClick(0) -- Left click
            elseif rec:find("HOLD") then
                performDoubleClick(1) -- Right click
            end
            
            task.wait(CONFIG.AUTO_CLICK.DELAY)
        end
        AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    AutoOn = false
end

-- Button click handlers
AutoButton.MouseButton1Click:Connect(function()
    animateButton(AutoButton)
    
    if not AutoAvailable then
        local originalColor = AutoButton.BackgroundColor3
        AutoButton.BackgroundColor3 = CONFIG.UI.DANGER_COLOR
        task.delay(0.5, function()
            if AutoButton then
                AutoButton.BackgroundColor3 = originalColor
            end
        end)
        return
    end
    
    AutoOn = not AutoOn
    setAutoAppearance(AutoOn)
    
    if AutoOn then
        startAutoLoop()
        SubRecommendation.Text = "Auto-play: ENABLED"
    else
        stopAutoLoop()
        SubRecommendation.Text = "Auto-play: DISABLED"
    end
end)

SettingsButton.MouseButton1Click:Connect(function()
    animateButton(SettingsButton)
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    animateButton(CloseButton)
    ScreenGui:Destroy()
    if script then script:Destroy() end
end)

CloseSettings.MouseButton1Click:Connect(function()
    animateButton(CloseSettings)
    SettingsFrame.Visible = false
end)

-- Slider functionality
SliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                connection:Disconnect()
            end
        end)
    end
end)

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local trackAbsPos = SliderTrack.AbsolutePosition
        local trackAbsSize = SliderTrack.AbsoluteSize
        
        local relativeX = (mousePos.X - trackAbsPos.X) / trackAbsSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        RiskValue = relativeX
        SliderThumb.Position = UDim2.new(RiskValue, -8, 1, -13)
        
        local riskLevel
        if RiskValue < 0.33 then
            riskLevel = "Low"
        elseif RiskValue < 0.66 then
            riskLevel = "Medium"
        else
            riskLevel = "High"
        end
        
        RiskLabel.Text = "Risk Tolerance: " .. riskLevel
    end
end)

-- Advanced card counting algorithm
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
        RecommendationLabel.Text = "WAITING"
        RecommendationLabel.TextColor3 = CONFIG.UI.WARNING_COLOR
        SubRecommendation.Text = "Waiting for game to start..."
        StatsLabel.Text = "Searching for game components..."
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
        if v == "L" then return 99 end -- Special card
        return tonumber(v) or 0
    end

    -- Calculate sums
    local mySum = 0
    for _, v in ipairs(myCards) do
        mySum = mySum + cardValue(v)
    end

    local oppKnownSum, oppHiddenCount = 0, 0
    for _, v in ipairs(opponentCards) do
        local n = cardValue(v)
        if n > 0 and n ~= 99 then
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

    -- Advanced opponent prediction
    local sumOfDeck = 0
    for _, v in ipairs(deck) do sumOfDeck = sumOfDeck + v end
    local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

    -- Risk-adjusted decision making
    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue

    -- Dynamic risk threshold based on slider
    local baseRiskThreshold = 0.5
    local riskAdjustedThreshold = baseRiskThreshold - (RiskValue * 0.3) -- High risk = lower threshold
    
    -- Game state analysis
    local isWinning = mySum > oppExpectedSum
    local isLosing = mySum < oppExpectedSum
    local isClose = math.abs(mySum - oppExpectedSum) <= 2

    -- Decision logic
    local recommendation, reason, color
    
    if opponentBust then
        recommendation = "HOLD"
        reason = "Opponent has busted"
        color = CONFIG.UI.SUCCESS_COLOR
    elseif mySum > goalValue then
        recommendation = "BUST"
        reason = "You have busted"
        color = CONFIG.UI.DANGER_COLOR
    elseif mySum == goalValue then
        recommendation = "HOLD"
        reason = "Perfect score achieved"
        color = CONFIG.UI.SUCCESS_COLOR
    elseif safeChance >= riskAdjustedThreshold then
        recommendation = "TAKE"
        reason = string.format("Good odds (%.1f%%)", safeChance * 100)
        color = CONFIG.UI.SUCCESS_COLOR
    else
        recommendation = "HOLD"
        reason = string.format("Low odds (%.1f%%)", safeChance * 100)
        color = CONFIG.UI.DANGER_COLOR
    end

    -- Special considerations
    if recommendation == "TAKE" and isWinning and safeChance < 0.7 then
        recommendation = "HOLD"
        reason = "Playing safe with lead"
        color = CONFIG.UI.WARNING_COLOR
    end

    -- Update UI
    RecommendationLabel.Text = recommendation
    RecommendationLabel.TextColor3 = color
    SubRecommendation.Text = reason

    -- Update stats
    local deckText = ""
    for i, card in ipairs(deck) do
        local colorCode = (mySum + card <= goalValue) and "#32C820" or "#C83220"
        deckText = deckText .. string.format('<font color="%s">%d</font>', colorCode, card)
        if i < #deck then deckText = deckText .. ", " end
    end

    StatsLabel.Text = string.format(
        "Your Score: <b>%d</b>/%d\n" ..
        "Opponent Expected: <b>%.1f</b>\n" ..
        "Safe Chance: <b>%.1f%%</b> (%d/%d)\n" ..
        "Risk Level: <b>%s</b>\n" ..
        "Remaining Cards: %s",
        mySum, goalValue,
        oppExpectedSum,
        safeChance * 100, safeDraws, totalRemaining,
        RiskValue < 0.33 and "Low" or RiskValue < 0.66 and "Medium" or "High",
        deckText
    )
end

-- Initialize
RunService.RenderStepped:Connect(updateAdvisor)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        ScreenGui:Destroy()
    end
end)

print("Advanced Card Counter loaded successfully!")
