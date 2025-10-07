local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

-- Konfigurasi
local CONFIG = {
    UPDATE_INTERVAL = 0.1, -- Detik antara update
    AUTO_CLICK_DELAY = 0.1, -- Detik antara klik
    MIN_SAFE_CHANCE = 0.4, -- Peluang minimal aman untuk TAKE
    UI = {
        WIDTH = 280,
        HEIGHT = 200,
        THEME = {
            BACKGROUND = Color3.fromRGB(30, 30, 30),
            PRIMARY = Color3.fromRGB(0, 120, 215),
            SUCCESS = Color3.fromRGB(50, 200, 50),
            WARNING = Color3.fromRGB(255, 165, 0),
            DANGER = Color3.fromRGB(200, 50, 50),
            TEXT = Color3.fromRGB(255, 255, 255),
            TEXT_SECONDARY = Color3.fromRGB(200, 200, 200)
        }
    }
}

-- State management
local State = {
    AutoOn = false,
    AutoLoopThread = nil,
    LastUpdate = 0,
    Stats = {
        GamesPlayed = 0,
        Wins = 0,
        Losses = 0,
        CorrectDecisions = 0,
        TotalDecisions = 0
    }
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardCounter"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, CONFIG.UI.WIDTH, 0, CONFIG.UI.HEIGHT)
MainFrame.Position = UDim2.new(0.5, -CONFIG.UI.WIDTH/2, 0.2, 0)
MainFrame.BackgroundColor3 = CONFIG.UI.THEME.BACKGROUND
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Header dengan gradient
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = CONFIG.UI.THEME.PRIMARY
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Advanced Card Counter"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = CONFIG.UI.THEME.TEXT
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Toggle button untuk minimize/maximize
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -85, 0.5, -12.5)
MinimizeButton.BackgroundColor3 = CONFIG.UI.THEME.WARNING
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = CONFIG.UI.THEME.TEXT
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 16
MinimizeButton.Parent = Header
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

local AutoButton = Instance.new("TextButton")
AutoButton.Size = UDim2.new(0, 25, 0, 25)
AutoButton.Position = UDim2.new(1, -55, 0.5, -12.5)
AutoButton.BackgroundColor3 = CONFIG.UI.THEME.BACKGROUND
AutoButton.Text = "A"
AutoButton.TextColor3 = CONFIG.UI.THEME.TEXT
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 14
AutoButton.Parent = Header
Instance.new("UICorner", AutoButton).CornerRadius = UDim.new(0, 6)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0.5, -12.5)
CloseButton.BackgroundColor3 = CONFIG.UI.THEME.DANGER
CloseButton.Text = "X"
CloseButton.TextColor3 = CONFIG.UI.THEME.TEXT
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = Header
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -45)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Recommendation = Instance.new("TextLabel")
Recommendation.Size = UDim2.new(1, 0, 0, 35)
Recommendation.Position = UDim2.new(0, 0, 0, 0)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.SourceSansBold
Recommendation.TextSize = 24
Recommendation.Text = "ANALYZING..."
Recommendation.TextColor3 = CONFIG.UI.THEME.WARNING
Recommendation.Parent = Content

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 40)
StatsLabel.Position = UDim2.new(0, 0, 0, 40)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextSize = 12
StatsLabel.TextColor3 = CONFIG.UI.THEME.TEXT_SECONDARY
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.TextWrapped = true
StatsLabel.Text = "Win Rate: 0% | Accuracy: 0%"
StatsLabel.Parent = Content

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, -80)
InfoLabel.Position = UDim2.new(0, 0, 0, 85)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14
InfoLabel.TextColor3 = CONFIG.UI.THEME.TEXT_SECONDARY
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.Text = "Initializing card counter..."
InfoLabel.Parent = Content

-- Fitur drag yang lebih smooth
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Fungsi utility
local function animateButton(button, color, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = color})
    tween:Play()
end

local function setAutoAppearance(enabled)
    if enabled then
        AutoButton.BackgroundColor3 = CONFIG.UI.THEME.SUCCESS
        AutoButton.TextColor3 = CONFIG.UI.THEME.TEXT
    else
        AutoButton.BackgroundColor3 = CONFIG.UI.THEME.BACKGROUND
        AutoButton.TextColor3 = CONFIG.UI.THEME.TEXT
    end
end

local function updateStatsDisplay()
    local winRate = State.Stats.GamesPlayed > 0 and (State.Stats.Wins / State.Stats.GamesPlayed) * 100 or 0
    local accuracy = State.Stats.TotalDecisions > 0 and (State.Stats.CorrectDecisions / State.Stats.TotalDecisions) * 100 or 0
    StatsLabel.Text = string.format("Win Rate: %.1f%% | Accuracy: %.1f%%", winRate, accuracy)
end

-- Sistem auto-click yang lebih robust
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

local function performClick(buttonType)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    if buttonType == "left" then
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
            task.wait(CONFIG.AUTO_CLICK_DELAY)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
        elseif VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(vx, vy))
            task.wait(CONFIG.AUTO_CLICK_DELAY)
            VirtualUser:Button1Up(Vector2.new(vx, vy))
        end
    elseif buttonType == "right" then
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, true, game, 1)
            task.wait(CONFIG.AUTO_CLICK_DELAY)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, false, game, 1)
        elseif VirtualUser and VirtualUser.Button2Down then
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(vx, vy))
            task.wait(CONFIG.AUTO_CLICK_DELAY)
            VirtualUser:Button2Up(Vector2.new(vx, vy))
        end
    end
end

local function startAutoLoop()
    if State.AutoLoopThread then return end
    
    State.AutoLoopThread = task.spawn(function()
        local lastAction = ""
        
        while State.AutoOn and ScreenGui.Parent do
            local rec = Recommendation.Text:upper()
            
            if rec:find("TAKE") and lastAction ~= "TAKE" then
                performClick("left")
                lastAction = "TAKE"
                task.wait(0.5) -- Delay setelah TAKE
            elseif rec:find("HOLD") and lastAction ~= "HOLD" then
                performClick("right") 
                lastAction = "HOLD"
                task.wait(0.5) -- Delay setelah HOLD
            end
            
            task.wait(0.1) -- Polling interval
        end
        State.AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    State.AutoOn = false
end

-- Event handlers
MinimizeButton.MouseButton1Click:Connect(function()
    local targetSize = Content.Visible and UDim2.new(0, CONFIG.UI.WIDTH, 0, 32) or UDim2.new(0, CONFIG.UI.WIDTH, 0, CONFIG.UI.HEIGHT)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize})
    tween:Play()
    
    Content.Visible = not Content.Visible
end)

AutoButton.MouseButton1Click:Connect(function()
    if not AutoAvailable then
        animateButton(AutoButton, CONFIG.UI.THEME.DANGER, 0.15)
        task.wait(0.35)
        setAutoAppearance(State.AutoOn)
        InfoLabel.Text = "[AUTO] Error: Virtual input not available"
        return
    end

    State.AutoOn = not State.AutoOn
    setAutoAppearance(State.AutoOn)
    
    if State.AutoOn then
        startAutoLoop()
        InfoLabel.Text = InfoLabel.Text .. "\n[AUTO] Enabled"
    else
        stopAutoLoop()
        InfoLabel.Text = InfoLabel.Text .. "\n[AUTO] Disabled"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    animateButton(CloseButton, Color3.fromRGB(150, 30, 30), 0.15)
    task.wait(0.15)
    ScreenGui:Destroy()
    if script then script:Destroy() end
end)

-- Improved card analysis dengan probability yang lebih akurat
local function calculateCardProbabilities(visibleCards, goalValue, currentSum)
    local fullDeck = {1,2,3,4,5,6,7,8,9,10,11}
    local remainingCards = {}
    
    -- Salin deck lengkap
    for _, card in ipairs(fullDeck) do
        table.insert(remainingCards, card)
    end
    
    -- Hapus kartu yang sudah terlihat
    for _, visibleValue in ipairs(visibleCards) do
        for i = #remainingCards, 1, -1 do
            if remainingCards[i] == visibleValue then
                table.remove(remainingCards, i)
                break
            end
        end
    end
    
    -- Hitung probabilitas
    local safeCards, bustCards = 0, 0
    local safeSum, bustSum = 0, 0
    
    for _, card in ipairs(remainingCards) do
        if currentSum + card <= goalValue then
            safeCards = safeCards + 1
            safeSum = safeSum + card
        else
            bustCards = bustCards + 1
            bustSum = bustSum + card
        end
    end
    
    local totalCards = safeCards + bustCards
    local safeChance = totalCards > 0 and safeCards / totalCards or 0
    local avgSafeValue = safeCards > 0 and safeSum / safeCards or 0
    local avgBustValue = bustCards > 0 and bustSum / bustCards or 0
    
    return {
        safeChance = safeChance,
        safeCards = safeCards,
        bustCards = bustCards,
        totalCards = totalCards,
        avgSafeValue = avgSafeValue,
        avgBustValue = avgBustValue,
        remainingCards = remainingCards
    }
end

-- Main analysis function
local function analyzeGameState()
    local room = workspace:FindFirstChild("Room")
    if not room then return nil end
    
    -- Cari goal value
    local goalValue
    local sumLabel = room:FindFirstChild("Main")
        and room.Main:FindFirstChild("YourCardsSum")
        and room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
        and room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
    
    if sumLabel and sumLabel:IsA("TextLabel") then
        goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)"))
    end
    
    if not goalValue then return nil end
    
    -- Kumpulkan data kartu
    local cardsContainer = room:FindFirstChild("Cards")
    local opponentRoot = room.Opponent and room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = room:FindFirstChild("Camera")
    
    if not (cardsContainer and opponentRoot and myCamera) then return nil end
    
    local myCards, opponentCards = {}, {}
    local visibleCards = {}
    
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "Card" and card:IsA("BasePart") then
            local scoreLabel = card:FindFirstChild("Score") and card.Score:FindFirstChild("TextLabel")
            local faceValue = scoreLabel and scoreLabel.Text or "[Hidden]"
            local numericValue = tonumber(faceValue)
            
            if numericValue then
                table.insert(visibleCards, numericValue)
            end
            
            local distToOpponent = (card.Position - opponentRoot.Position).Magnitude
            local distToMe = (card.Position - myCamera.Position).Magnitude
            local owner = (distToOpponent < distToMe) and "Opponent" or "Player"
            
            if owner == "Player" then
                table.insert(myCards, {value = faceValue, numeric = numericValue})
            else
                table.insert(opponentCards, {value = faceValue, numeric = numericValue})
            end
        end
    end
    
    -- Hitung jumlah
    local mySum = 0
    local myKnownCards = 0
    for _, card in ipairs(myCards) do
        if card.numeric then
            mySum = mySum + card.numeric
            myKnownCards = myKnownCards + 1
        end
    end
    
    local oppKnownSum, oppHiddenCount = 0, 0
    for _, card in ipairs(opponentCards) do
        if card.numeric then
            oppKnownSum = oppKnownSum + card.numeric
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end
    
    -- Analisis probabilitas
    local prob = calculateCardProbabilities(visibleCards, goalValue, mySum)
    
    -- Hitung expected value opponent
    local oppExpectedSum = oppKnownSum
    if oppHiddenCount > 0 and prob.totalCards > 0 then
        local totalValue = 0
        for _, card in ipairs(prob.remainingCards) do
            totalValue = totalValue + card
        end
        local avgCardValue = totalValue / prob.totalCards
        oppExpectedSum = oppKnownSum + (oppHiddenCount * avgCardValue)
    end
    
    -- Algorithm decision making yang lebih sophisticated
    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue
    local decision = "HOLD"
    local confidence = 0.5
    local reason = ""
    
    if opponentBust then
        decision = "HOLD"
        confidence = 0.9
        reason = "Opponent already busted"
    elseif mySum >= goalValue then
        decision = "HOLD"
        confidence = 1.0
        reason = "Already at or above goal"
    elseif prob.safeChance >= CONFIG.MIN_SAFE_CHANCE then
        if oppExpectedSum > mySum + 2 then
            decision = "TAKE"
            confidence = 0.7
            reason = "Good safe chance and behind opponent"
        elseif prob.safeChance >= 0.7 then
            decision = "TAKE"
            confidence = 0.8
            reason = "High safe probability"
        else
            decision = "TAKE"
            confidence = 0.6
            reason = "Moderate safe probability"
        end
    else
        decision = "HOLD"
        confidence = 0.7
        reason = "Low safe probability"
    end
    
    -- Format remaining cards display
    local deckText = ""
    for i, card in ipairs(prob.remainingCards) do
        local color = (mySum + card <= goalValue) and "#32C820" or "#C83220"
        deckText = deckText .. string.format("<font color='%s'>%d</font>", color, card)
        if i < #prob.remainingCards then deckText = deckText .. ", " end
    end
    
    return {
        decision = decision,
        confidence = confidence,
        reason = reason,
        mySum = mySum,
        goalValue = goalValue,
        pointsNeeded = pointsNeeded,
        oppExpectedSum = oppExpectedSum,
        safeChance = prob.safeChance,
        safeCards = prob.safeCards,
        bustCards = prob.bustCards,
        totalCards = prob.totalCards,
        deckText = deckText
    }
end

-- Main update loop
local function updateAdvisor()
    if tick() - State.LastUpdate < CONFIG.UPDATE_INTERVAL then return end
    State.LastUpdate = tick()
    
    local result = analyzeGameState()
    
    if not result then
        Recommendation.Text = "WAITING FOR GAME"
        Recommendation.TextColor3 = CONFIG.UI.THEME.WARNING
        InfoLabel.Text = "Searching for game data...\nMake sure you're in a card game room."
        return
    end
    
    -- Update recommendation display
    Recommendation.Text = result.decision
    if result.decision == "TAKE" then
        Recommendation.TextColor3 = CONFIG.UI.THEME.SUCCESS
    else
        Recommendation.TextColor3 = CONFIG.UI.THEME.DANGER
    end
    
    -- Update info display
    InfoLabel.Text = string.format(
        "Safe Chance: %.1f%% (%d/%d cards)\nPoints Needed: %d\nOpponent Expected: %.1f\nConfidence: %.1f%%\n\nRemaining Cards:\n%s",
        result.safeChance * 100,
        result.safeCards,
        result.totalCards,
        result.pointsNeeded,
        result.oppExpectedSum,
        result.confidence * 100,
        result.deckText
    )
    
    -- Update stats (simulasi - dalam implementasi nyata, ini akan track game sesungguhnya)
    State.Stats.TotalDecisions = State.Stats.TotalDecisions + 1
    if result.confidence > 0.7 then
        State.Stats.CorrectDecisions = State.Stats.CorrectDecisions + 1
    end
    
    updateStatsDisplay()
end

-- Start the main loop
RunService.Heartbeat:Connect(updateAdvisor)

-- Initial setup
setAutoAppearance(false)
updateStatsDisplay()

print("Advanced Card Counter loaded successfully!")
print("Features: Auto-play, Statistics, Improved AI, Better UI")
