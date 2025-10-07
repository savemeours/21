local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Color Scheme
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 30),
    CARD_BG = Color3.fromRGB(30, 30, 45),
    ACCENT = Color3.fromRGB(0, 150, 255),
    SUCCESS = Color3.fromRGB(50, 200, 100),
    WARNING = Color3.fromRGB(255, 180, 50),
    DANGER = Color3.fromRGB(220, 80, 80),
    TEXT_MAIN = Color3.fromRGB(255, 255, 255),
    TEXT_SUB = Color3.fromRGB(180, 180, 200),
    TEXT_DIM = Color3.fromRGB(120, 120, 150)
}

-- Create Main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CardMasterPro"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 340, 0, 400)
MainContainer.Position = UDim2.new(0.5, -170, 0.5, -200)
MainContainer.BackgroundColor3 = COLORS.BACKGROUND
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true
MainContainer.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 16)
ContainerCorner.Parent = MainContainer

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(50, 50, 70)
ContainerStroke.Thickness = 2
ContainerStroke.Parent = MainContainer

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundTransparency = 1
Header.Parent = MainContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CARD MASTER PRO"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextColor3 = COLORS.TEXT_MAIN
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 20)
Title.Position = UDim2.new(0, 20, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Advanced Card Counter"
Title.Font = Enum.Font.Gotham
Title.TextSize = 12
Title.TextColor3 = COLORS.TEXT_SUB
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Status Indicator
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(0, 10, 0, 10)
StatusIndicator.BackgroundColor3 = COLORS.WARNING
StatusIndicator.Parent = Header

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

-- Control Buttons
local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(0, 80, 1, 0)
ControlContainer.Position = UDim2.new(1, -85, 0, 0)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = Header

local function createControlButton(text, color, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 32, 0, 32)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = ControlContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = button
    
    return button
end

local AutoButton = createControlButton("A", Color3.fromRGB(60, 60, 80), UDim2.new(0, 0, 0, 5))
local SettingsButton = createControlButton("⚙", COLORS.ACCENT, UDim2.new(0, 40, 0, 5))
local CloseButton = createControlButton("×", COLORS.DANGER, UDim2.new(0, 40, 0, 40))

-- Main Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 60)
Content.BackgroundTransparency = 1
Content.Parent = MainContainer

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = Content

-- Recommendation Card
local RecCard = Instance.new("Frame")
RecCard.Size = UDim2.new(1, 0, 0, 100)
RecCard.BackgroundColor3 = COLORS.CARD_BG
RecCard.Parent = Content

local RecCorner = Instance.new("UICorner")
RecCorner.CornerRadius = UDim.new(0, 12)
RecCorner.Parent = RecCard

local RecStroke = Instance.new("UIStroke")
RecStroke.Color = Color3.fromRGB(50, 50, 70)
RecStroke.Thickness = 1
RecStroke.Parent = RecCard

local RecLabel = Instance.new("TextLabel")
RecLabel.Size = UDim2.new(1, 0, 0, 50)
RecLabel.Position = UDim2.new(0, 0, 0, 0)
RecLabel.BackgroundTransparency = 1
RecLabel.Text = "ANALYZING..."
RecLabel.Font = Enum.Font.GothamBlack
RecLabel.TextSize = 24
RecLabel.TextColor3 = COLORS.WARNING
RecLabel.Parent = RecCard

local RecSubLabel = Instance.new("TextLabel")
RecSubLabel.Size = UDim2.new(1, -20, 0, 30)
RecSubLabel.Position = UDim2.new(0, 10, 0, 50)
RecSubLabel.BackgroundTransparency = 1
RecSubLabel.Text = "Initializing card counter..."
RecSubLabel.Font = Enum.Font.Gotham
RecSubLabel.TextSize = 12
RecSubLabel.TextColor3 = COLORS.TEXT_SUB
RecSubLabel.TextXAlignment = Enum.TextXAlignment.Left
RecSubLabel.Parent = RecCard

-- Stats Grid
local StatsGrid = Instance.new("Frame")
StatsGrid.Size = UDim2.new(1, 0, 0, 120)
StatsGrid.BackgroundColor3 = COLORS.CARD_BG
StatsGrid.Parent = Content

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 12)
StatsCorner.Parent = StatsGrid

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Color3.fromRGB(50, 50, 70)
StatsStroke.Thickness = 1
StatsStroke.Parent = StatsGrid

-- Stats Content
local StatsContent = Instance.new("Frame")
StatsContent.Size = UDim2.new(1, -20, 1, -20)
StatsContent.Position = UDim2.new(0, 10, 0, 10)
StatsContent.BackgroundTransparency = 1
StatsContent.Parent = StatsGrid

local StatsLayout = Instance.new("UIGridLayout")
StatsLayout.CellPadding = UDim2.new(0, 10, 0, 8)
StatsLayout.CellSize = UDim2.new(0.5, -5, 0, 20)
StatsLayout.Parent = StatsContent

-- Stat Items
local function createStatItem(label, value, color)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = StatsContent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, -5, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextColor3 = COLORS.TEXT_SUB
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.5, -5, 1, 0)
    valueText.Position = UDim2.new(0.5, 5, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = value
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextColor3 = color or COLORS.TEXT_MAIN
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = container
    
    return valueText
end

local YourScoreStat = createStatItem("Your Score", "--/--", COLORS.TEXT_MAIN)
local OpponentStat = createStatItem("Opponent", "--", COLORS.TEXT_MAIN)
local SafeChanceStat = createStatItem("Safe Chance", "--%", COLORS.TEXT_MAIN)
local RiskLevelStat = createStatItem("Risk Level", "Medium", COLORS.TEXT_MAIN)
local CardsLeftStat = createStatItem("Cards Left", "--", COLORS.TEXT_MAIN)
local WinRateStat = createStatItem("Win Chance", "--%", COLORS.TEXT_MAIN)

-- Cards Display
local CardsCard = Instance.new("Frame")
CardsCard.Size = UDim2.new(1, 0, 0, 100)
CardsCard.BackgroundColor3 = COLORS.CARD_BG
CardsCard.Parent = Content

local CardsCorner = Instance.new("UICorner")
CardsCorner.CornerRadius = UDim.new(0, 12)
CardsCorner.Parent = CardsCard

local CardsStroke = Instance.new("UIStroke")
CardsStroke.Color = Color3.fromRGB(50, 50, 70)
CardsStroke.Thickness = 1
CardsStroke.Parent = CardsCard

local CardsTitle = Instance.new("TextLabel")
CardsTitle.Size = UDim2.new(1, -20, 0, 20)
CardsTitle.Position = UDim2.new(0, 10, 0, 5)
CardsTitle.BackgroundTransparency = 1
CardsTitle.Text = "REMAINING CARDS"
CardsTitle.Font = Enum.Font.GothamBold
CardsTitle.TextSize = 12
CardsTitle.TextColor3 = COLORS.TEXT_SUB
CardsTitle.TextXAlignment = Enum.TextXAlignment.Left
CardsTitle.Parent = CardsCard

local CardsContainer = Instance.new("TextLabel")
CardsContainer.Size = UDim2.new(1, -20, 1, -30)
CardsContainer.Position = UDim2.new(0, 10, 0, 25)
CardsContainer.BackgroundTransparency = 1
CardsContainer.Text = "Loading..."
CardsContainer.Font = Enum.Font.Gotham
CardsContainer.TextSize = 11
CardsContainer.TextColor3 = COLORS.TEXT_DIM
CardsContainer.TextXAlignment = Enum.TextXAlignment.Left
CardsContainer.TextYAlignment = Enum.TextYAlignment.Top
CardsContainer.TextWrapped = true
CardsContainer.RichText = true
CardsContainer.Parent = CardsCard

-- Settings Panel
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(1, -40, 0, 180)
SettingsPanel.Position = UDim2.new(0, 20, 0.5, -90)
SettingsPanel.BackgroundColor3 = COLORS.CARD_BG
SettingsPanel.Visible = false
SettingsPanel.Parent = MainContainer

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
SettingsCorner.Parent = SettingsPanel

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = COLORS.ACCENT
SettingsStroke.Thickness = 2
SettingsStroke.Parent = SettingsPanel

local SettingsHeader = Instance.new("TextLabel")
SettingsHeader.Size = UDim2.new(1, 0, 0, 40)
SettingsHeader.Position = UDim2.new(0, 0, 0, 0)
SettingsHeader.BackgroundTransparency = 1
SettingsHeader.Text = "SETTINGS"
SettingsHeader.Font = Enum.Font.GothamBlack
SettingsHeader.TextSize = 16
SettingsHeader.TextColor3 = COLORS.TEXT_MAIN
SettingsHeader.Parent = SettingsPanel

-- Risk Slider
local RiskContainer = Instance.new("Frame")
RiskContainer.Size = UDim2.new(1, -20, 0, 60)
RiskContainer.Position = UDim2.new(0, 10, 0, 45)
RiskContainer.BackgroundTransparency = 1
RiskContainer.Parent = SettingsPanel

local RiskLabel = Instance.new("TextLabel")
RiskLabel.Size = UDim2.new(1, 0, 0, 20)
RiskLabel.Position = UDim2.new(0, 0, 0, 0)
RiskLabel.BackgroundTransparency = 1
RiskLabel.Text = "RISK TOLERANCE: MEDIUM"
RiskLabel.Font = Enum.Font.GothamBold
RiskLabel.TextSize = 12
RiskLabel.TextColor3 = COLORS.TEXT_MAIN
RiskLabel.TextXAlignment = Enum.TextXAlignment.Left
RiskLabel.Parent = RiskContainer

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 1, -25)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SliderTrack.Parent = RiskContainer

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 3)
TrackCorner.Parent = SliderTrack

local SliderThumb = Instance.new("Frame")
SliderThumb.Size = UDim2.new(0, 20, 0, 20)
SliderThumb.Position = UDim2.new(0.5, -10, 1, -30)
SliderThumb.BackgroundColor3 = COLORS.ACCENT
SliderThumb.Parent = RiskContainer

local ThumbCorner = Instance.new("UICorner")
ThumbCorner.CornerRadius = UDim.new(1, 0)
ThumbCorner.Parent = SliderThumb

local ApplyButton = Instance.new("TextButton")
ApplyButton.Size = UDim2.new(0, 120, 0, 32)
ApplyButton.Position = UDim2.new(0.5, -60, 1, -40)
ApplyButton.BackgroundColor3 = COLORS.ACCENT
ApplyButton.Text = "APPLY SETTINGS"
ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyButton.Font = Enum.Font.GothamBold
ApplyButton.TextSize = 14
ApplyButton.Parent = SettingsPanel

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 8)
ApplyCorner.Parent = ApplyButton

-- UI Interactions
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
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
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button Animations
local function animateButton(button)
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local shrink = TweenService:Create(button, tweenInfo, {Size = button.Size - UDim2.new(0, 2, 0, 2)})
    local grow = TweenService:Create(button, tweenInfo, {Size = button.Size})
    
    shrink:Play()
    shrink.Completed:Connect(function()
        grow:Play()
    end)
end

-- Auto-click System
local AutoOn = false
local AutoLoopThread = nil
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)
local RiskValue = 0.5

local function setAutoAppearance(enabled)
    if enabled then
        AutoButton.BackgroundColor3 = COLORS.SUCCESS
        StatusIndicator.BackgroundColor3 = COLORS.SUCCESS
    else
        AutoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        StatusIndicator.BackgroundColor3 = COLORS.WARNING
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
    task.wait(0.1)
    doClick()
end

local function startAutoLoop()
    if AutoLoopThread then return end
    
    AutoLoopThread = task.spawn(function()
        while AutoOn and ScreenGui.Parent do
            local rec = RecLabel.Text:upper()
            
            if rec:find("TAKE") then
                performDoubleClick(0)
            elseif rec:find("HOLD") then
                performDoubleClick(1)
            end
            
            task.wait(1)
        end
        AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    AutoOn = false
end

-- Button Handlers
AutoButton.MouseButton1Click:Connect(function()
    animateButton(AutoButton)
    
    if not AutoAvailable then
        AutoButton.BackgroundColor3 = COLORS.DANGER
        task.delay(0.5, function()
            setAutoAppearance(AutoOn)
        end)
        RecSubLabel.Text = "Auto-click not available"
        return
    end
    
    AutoOn = not AutoOn
    setAutoAppearance(AutoOn)
    
    if AutoOn then
        startAutoLoop()
        RecSubLabel.Text = "Auto-play: ENABLED"
    else
        stopAutoLoop()
        RecSubLabel.Text = "Auto-play: DISABLED"
    end
end)

SettingsButton.MouseButton1Click:Connect(function()
    animateButton(SettingsButton)
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    animateButton(CloseButton)
    ScreenGui:Destroy()
    if script then script:Destroy() end
end)

ApplyButton.MouseButton1Click:Connect(function()
    animateButton(ApplyButton)
    SettingsPanel.Visible = false
end)

-- Slider Logic
SliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        local function updateSlider()
            local mousePos = UserInputService:GetMouseLocation()
            local trackAbsPos = SliderTrack.AbsolutePosition
            local trackAbsSize = SliderTrack.AbsoluteSize
            
            local relativeX = (mousePos.X - trackAbsPos.X) / trackAbsSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            RiskValue = relativeX
            SliderThumb.Position = UDim2.new(RiskValue, -10, 1, -30)
            
            local riskLevel
            if RiskValue < 0.33 then
                riskLevel = "LOW"
            elseif RiskValue < 0.66 then
                riskLevel = "MEDIUM"
            else
                riskLevel = "HIGH"
            end
            
            RiskLabel.Text = "RISK TOLERANCE: " .. riskLevel
        end
        
        updateSlider()
        connection = RunService.RenderStepped:Connect(updateSlider)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                connection:Disconnect()
            end
        end)
    end
end)

-- Card Counting Algorithm
local function updateAdvisor()
    local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
    local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

    local goalValue = 21
    local sumLabel = workspace.Room
        and workspace.Room.Main
        and workspace.Room.Main:FindFirstChild("YourCardsSum")
        and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
        and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
    
    if sumLabel and sumLabel:IsA("TextLabel") then
        goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)")) or 21
    end

    if not (cardsContainer and opponentRoot and myCamera) then
        RecLabel.Text = "WAITING"
        RecLabel.TextColor3 = COLORS.WARNING
        RecSubLabel.Text = "Waiting for game to start..."
        
        YourScoreStat.Text = "--/--"
        OpponentStat.Text = "--"
        SafeChanceStat.Text = "--%"
        CardsLeftStat.Text = "--"
        WinRateStat.Text = "--%"
        CardsContainer.Text = "Waiting for game data..."
        return
    end

    -- Card Analysis
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
        return tonumber(v) or 0
    end

    -- Calculate Sums
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

    -- Deck Analysis
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
    
    for _, cardValue in ipairs(visibleCards) do
        for i, deckCard in ipairs(deck) do
            if deckCard == cardValue then
                table.remove(deck, i)
                break
            end
        end
    end

    -- Probability Calculation
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

    -- Opponent Prediction
    local sumOfDeck = 0
    for _, v in ipairs(deck) do sumOfDeck = sumOfDeck + v end
    local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

    -- Win Chance Calculation
    local winChance = 0
    if mySum <= goalValue then
        if oppExpectedSum > goalValue then
            winChance = 100
        else
            winChance = math.clamp((mySum / goalValue) * 100, 0, 100)
        end
    end

    -- Decision Logic
    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue

    local riskAdjustedThreshold = 0.5 - (RiskValue * 0.3)
    
    local recommendation, reason, color
    
    if opponentBust then
        recommendation = "HOLD"
        reason = "Opponent has busted - Play safe"
        color = COLORS.SUCCESS
    elseif mySum > goalValue then
        recommendation = "BUST"
        reason = "You have busted"
        color = COLORS.DANGER
    elseif mySum == goalValue then
        recommendation = "HOLD"
        reason = "Perfect score achieved!"
        color = COLORS.SUCCESS
    elseif safeChance >= riskAdjustedThreshold then
        recommendation = "TAKE"
        reason = string.format("Good odds (%.0f%%) - Take card", safeChance * 100)
        color = COLORS.SUCCESS
    else
        recommendation = "HOLD"
        reason = string.format("Low odds (%.0f%%) - Play safe", safeChance * 100)
        color = COLORS.DANGER
    end

    -- Update UI
    RecLabel.Text = recommendation
    RecLabel.TextColor3 = color
    RecSubLabel.Text = reason

    -- Update Stats
    YourScoreStat.Text = string.format("%d/%d", mySum, goalValue)
    OpponentStat.Text = string.format("%.1f", oppExpectedSum)
    SafeChanceStat.Text = string.format("%.0f%%", safeChance * 100)
    CardsLeftStat.Text = tostring(totalRemaining)
    WinRateStat.Text = string.format("%.0f%%", winChance)
    
    local riskLevel = RiskValue < 0.33 and "Low" or RiskValue < 0.66 and "Medium" or "High"
    RiskLevelStat.Text = riskLevel

    -- Update Cards Display
    local cardsText = ""
    for i, card in ipairs(deck) do
        local cardColor = (mySum + card <= goalValue) and COLORS.SUCCESS or COLORS.DANGER
        local hexColor = string.format("rgb(%d,%d,%d)", 
            math.floor(cardColor.R * 255), 
            math.floor(cardColor.G * 255), 
            math.floor(cardColor.B * 255))
        cardsText = cardsText .. string.format('<font color="%s"><b>%d</b></font>', hexColor, card)
        if i < #deck then cardsText = cardsText .. " " end
        if i % 6 == 0 and i < #deck then cardsText = cardsText .. "\n" end
    end
    
    CardsContainer.Text = cardsText
end

-- Initialize
RunService.RenderStepped:Connect(updateAdvisor)

-- Cleanup
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        ScreenGui:Destroy()
    end
end)

print("🎯 Card Master Pro loaded successfully!")
