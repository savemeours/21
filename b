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
    UPDATE_INTERVAL = 0.1, -- seconds between updates
    AUTO_CLICK_DELAY = 0.1, -- seconds between auto clicks
    REQUIRED_SAFE_CHANCE = 0.50,
    MIN_SAFE_CHANCE = 0.40,
    OPPONENT_ADVANTAGE_FACTOR = 0.05,
    HIGH_RISK_THRESHOLD = 0.3,
    GAME_END_CHECK_INTERVAL = 2 -- seconds between game state checks
}

-- State management
local State = {
    AutoOn = false,
    AutoLoopThread = nil,
    GameStateThread = nil,
    LastUpdate = 0,
    IsMinimized = false,
    LastGameState = "Waiting",
    CurrentGameId = nil,
    Stats = {
        GamesPlayed = 0,
        Wins = 0,
        Losses = 0,
        CurrentStreak = 0,
        BestStreak = 0,
        TotalPoints = 0,
        AveragePoints = 0
    }
}

-- Game state tracking variables
local GameTracker = {
    LastYourSum = 0,
    LastOpponentSum = 0,
    GameStartTime = 0,
    RoundCount = 0,
    IsGameActive = false,
    LastResult = nil,
    YourFinalScore = 0,
    OpponentFinalScore = 0
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardCounter"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Add drop shadow
local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Parent = MainFrame
DropShadow.BackgroundTransparency = 1
DropShadow.BorderSizePixel = 0
DropShadow.Size = UDim2.new(1, 14, 1, 14)
DropShadow.Position = UDim2.new(0, -7, 0, -7)
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.8
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.ZIndex = -1

-- Header with gradient
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🃏 Advanced Card Counter"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Control buttons
local ControlButtons = {
    Auto = {
        Button = Instance.new("TextButton"),
        Icon = "▶️",
        ActiveIcon = "⏸️",
        Tooltip = "Toggle Auto Play"
    },
    Stats = {
        Button = Instance.new("TextButton"),
        Icon = "📊",
        Tooltip = "Show Statistics"
    },
    Settings = {
        Button = Instance.new("TextButton"),
        Icon = "⚙️",
        Tooltip = "Settings"
    },
    Minimize = {
        Button = Instance.new("TextButton"),
        Icon = "─",
        ExpandedIcon = "─",
        MinimizedIcon = "＋",
        Tooltip = "Minimize"
    },
    Close = {
        Button = Instance.new("TextButton"),
        Icon = "×",
        Tooltip = "Close"
    }
}

local buttonSize = 25
local buttonSpacing = 5
local startX = MainFrame.Size.X.Offset - (buttonSize + buttonSpacing) * 5 - 10

for i, buttonConfig in pairs(ControlButtons) do
    local button = buttonConfig.Button
    button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    button.Position = UDim2.new(1, -((buttonSize + buttonSpacing) * (6 - i) - 5), 0, 8)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.Text = buttonConfig.Icon
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.ZIndex = 2
    button.Parent = Header
    
    local buttonCorner = Instance.new("UICorner", button)
    buttonCorner.CornerRadius = UDim.new(0, 6)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if not (i == "Close" and State.AutoOn) then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if i == "Auto" and State.AutoOn then
            button.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        elseif i == "Close" and State.AutoOn then
            button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
end

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Recommendation display
local RecommendationContainer = Instance.new("Frame")
RecommendationContainer.Size = UDim2.new(1, 0, 0, 50)
RecommendationContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
RecommendationContainer.Parent = ContentFrame

local RecommendationCorner = Instance.new("UICorner", RecommendationContainer)
RecommendationCorner.CornerRadius = UDim.new(0, 8)

local RecommendationLabel = Instance.new("TextLabel")
RecommendationLabel.Size = UDim2.new(1, 0, 1, 0)
RecommendationLabel.BackgroundTransparency = 1
RecommendationLabel.Font = Enum.Font.GothamBlack
RecommendationLabel.TextSize = 24
RecommendationLabel.Text = "ANALYZING..."
RecommendationLabel.Parent = RecommendationContainer

local ChanceLabel = Instance.new("TextLabel")
ChanceLabel.Size = UDim2.new(1, 0, 0, 20)
ChanceLabel.Position = UDim2.new(0, 0, 1, -20)
ChanceLabel.BackgroundTransparency = 1
ChanceLabel.Font = Enum.Font.Gotham
ChanceLabel.TextSize = 12
ChanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ChanceLabel.Text = "Calculating odds..."
ChanceLabel.Parent = RecommendationContainer

-- Info display
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, -60)
InfoLabel.Position = UDim2.new(0, 0, 0, 55)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 12
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.Text = "Initializing card counter..."
InfoLabel.Parent = ContentFrame

-- Stats panel (hidden by default)
local StatsPanel = Instance.new("Frame")
StatsPanel.Size = UDim2.new(1, 0, 0, 80)
StatsPanel.Position = UDim2.new(0, 0, 1, 5)
StatsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatsPanel.Visible = false
StatsPanel.Parent = ContentFrame

local StatsCorner = Instance.new("UICorner", StatsPanel)
StatsCorner.CornerRadius = UDim.new(0, 8)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 1, -10)
StatsLabel.Position = UDim2.new(0, 5, 0, 5)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 11
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.TextWrapped = true
StatsLabel.Text = "Games: 0 | Wins: 0 (0%) | Streak: 0"
StatsLabel.Parent = StatsPanel

-- Game status display
local GameStatusLabel = Instance.new("TextLabel")
GameStatusLabel.Size = UDim2.new(1, 0, 0, 15)
GameStatusLabel.Position = UDim2.new(0, 0, 1, -15)
GameStatusLabel.BackgroundTransparency = 1
GameStatusLabel.Font = Enum.Font.Gotham
GameStatusLabel.TextSize = 10
GameStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
GameStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
GameStatusLabel.Text = "Game: Waiting..."
GameStatusLabel.Parent = ContentFrame

-- Button functionality
ControlButtons.Close.Button.MouseButton1Click:Connect(function()
    if State.AutoOn then
        local oldColor = ControlButtons.Close.Button.BackgroundColor3
        ControlButtons.Close.Button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(ControlButtons.Close.Button, TweenInfo.new(0.5), {BackgroundColor3 = oldColor}):Play()
        return
    end
    ScreenGui:Destroy()
end)

ControlButtons.Minimize.Button.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    if State.IsMinimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        ControlButtons.Minimize.Button.Text = ControlButtons.Minimize.MinimizedIcon
        ContentFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 250)
        ControlButtons.Minimize.Button.Text = ControlButtons.Minimize.ExpandedIcon
        ContentFrame.Visible = true
    end
end)

ControlButtons.Stats.Button.MouseButton1Click:Connect(function()
    StatsPanel.Visible = not StatsPanel.Visible
    ControlButtons.Stats.Button.BackgroundColor3 = StatsPanel.Visible and 
        Color3.fromRGB(80, 80, 120) or Color3.fromRGB(60, 60, 80)
end)

-- Auto functionality
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

local function setAutoAppearance(on)
    if on then
        ControlButtons.Auto.Button.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        ControlButtons.Auto.Button.Text = ControlButtons.Auto.ActiveIcon
        ControlButtons.Close.Button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    else
        ControlButtons.Auto.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        ControlButtons.Auto.Button.Text = ControlButtons.Auto.Icon
        ControlButtons.Close.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

local function performClick(buttonIndex)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    for i = 1, 2 do -- Double click for reliability
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(vx, vy, buttonIndex, false, game, 1)
        elseif VirtualUser then
            if buttonIndex == 0 then
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(vx, vy))
                task.wait(0.02)
                VirtualUser:Button1Up(Vector2.new(vx, vy))
            elseif buttonIndex == 1 and VirtualUser.Button2Down then
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(vx, vy))
                task.wait(0.02)
                VirtualUser:Button2Up(Vector2.new(vx, vy))
            end
        end
        task.wait(CONFIG.AUTO_CLICK_DELAY)
    end
end

local function startAutoLoop()
    if State.AutoLoopThread then return end
    
    State.AutoLoopThread = task.spawn(function()
        while State.AutoOn and ScreenGui.Parent do
            local rec = string.upper(RecommendationLabel.Text or "")
            
            if rec:find("TAKE") then
                performClick(0) -- Left click
            elseif rec:find("HOLD") then
                performClick(1) -- Right click
            end
            
            task.wait(1) -- Check every second
        end
        State.AutoLoopThread = nil
    end)
end

local function stopAutoLoop()
    State.AutoOn = false
end

ControlButtons.Auto.Button.MouseButton1Click:Connect(function()
    if not AutoAvailable then
        local oldColor = ControlButtons.Auto.Button.BackgroundColor3
        ControlButtons.Auto.Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        TweenService:Create(ControlButtons.Auto.Button, TweenInfo.new(0.5), {BackgroundColor3 = oldColor}):Play()
        InfoLabel.Text = "❌ Auto-play not available in this environment"
        return
    end

    State.AutoOn = not State.AutoOn
    setAutoAppearance(State.AutoOn)
    
    if State.AutoOn then
        startAutoLoop()
        InfoLabel.Text = InfoLabel.Text .. "\n🤖 Auto-play: ENABLED"
    else
        stopAutoLoop()
        InfoLabel.Text = InfoLabel.Text .. "\n🤖 Auto-play: DISABLED"
    end
end)

-- Game state tracking functions
local function detectGameStart()
    local room = workspace:FindFirstChild("Room")
    if not room then return false end
    
    local cardsContainer = room:FindFirstChild("Cards")
    local yourCardsSum = room.Main and room.Main:FindFirstChild("YourCardsSum")
    
    if cardsContainer and yourCardsSum then
        local cards = cardsContainer:GetChildren()
        if #cards >= 2 then -- At least 2 cards dealt
            return true
        end
    end
    
    return false
end

local function detectGameEnd()
    local room = workspace:FindFirstChild("Room")
    if not room then return false, nil end
    
    -- Method 1: Check for win/lose messages
    local main = room:FindFirstChild("Main")
    if main then
        for _, child in ipairs(main:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("BillboardGui") then
                local text = string.lower(tostring(child.Text or child.Name))
                if text:find("win") or text:find("lose") or text:find("bust") then
                    return true, text
                end
            end
        end
    end
    
    -- Method 2: Check if cards are being cleared/reset
    local cardsContainer = room:FindFirstChild("Cards")
    if cardsContainer then
        local cardCount = #cardsContainer:GetChildren()
        if cardCount == 0 and GameTracker.IsGameActive then
            return true, "Round Ended"
        end
    end
    
    -- Method 3: Check for score changes that indicate round end
    local yourSumLabel = room.Main and room.Main:FindFirstChild("YourCardsSum")
    if yourSumLabel then
        local surfaceGui = yourSumLabel:FindFirstChild("SurfaceGui")
        if surfaceGui then
            local textLabel = surfaceGui:FindFirstChild("TextLabel")
            if textLabel and textLabel:IsA("TextLabel") then
                local text = textLabel.Text or ""
                if text:find("/") then
                    local current, target = text:match("(%d+)/(%d+)")
                    current, target = tonumber(current), tonumber(target)
                    
                    if current and target then
                        if current >= target then
                            return true, "Target Reached"
                        end
                    end
                end
            end
        end
    end
    
    return false, nil
end

local function getFinalScores()
    local room = workspace:FindFirstChild("Room")
    if not room then return 0, 0 end
    
    local yourScore, opponentScore = 0, 0
    
    -- Try to get your score
    local yourSumLabel = room.Main and room.Main:FindFirstChild("YourCardsSum")
    if yourSumLabel then
        local surfaceGui = yourSumLabel:FindFirstChild("SurfaceGui")
        if surfaceGui then
            local textLabel = surfaceGui:FindFirstChild("TextLabel")
            if textLabel and textLabel:IsA("TextLabel") then
                local text = textLabel.Text or ""
                local current = text:match("(%d+)/")
                yourScore = tonumber(current) or 0
            end
        end
    end
    
    -- Try to get opponent score (this might need adjustment based on the game)
    local opponentSumLabel = room.Main and room.Main:FindFirstChild("OpponentCardsSum")
    if opponentSumLabel then
        local surfaceGui = opponentSumLabel:FindFirstChild("SurfaceGui")
        if surfaceGui then
            local textLabel = surfaceGui:FindFirstChild("TextLabel")
            if textLabel and textLabel:IsA("TextLabel") then
                local text = textLabel.Text or ""
                local current = text:match("(%d+)/")
                opponentScore = tonumber(current) or 0
            end
        end
    end
    
    return yourScore, opponentScore
end

local function determineWinner(yourScore, opponentScore, gameEndReason)
    if not gameEndReason then
        if yourScore > opponentScore then return "win"
        elseif yourScore < opponentScore then return "loss"
        else return "tie" end
    end
    
    local reason = string.lower(gameEndReason)
    
    if reason:find("win") or reason:find("victory") then
        return "win"
    elseif reason:find("lose") or reason:find("defeat") or reason:find("bust") then
        return "loss"
    else
        if yourScore > opponentScore then return "win"
        elseif yourScore < opponentScore then return "loss"
        else return "tie" end
    end
end

local function updateGameStats(result, yourScore, opponentScore)
    if result == "win" then
        State.Stats.Wins = State.Stats.Wins + 1
        State.Stats.CurrentStreak = math.max(1, State.Stats.CurrentStreak + 1)
        State.Stats.BestStreak = math.max(State.Stats.BestStreak, State.Stats.CurrentStreak)
    elseif result == "loss" then
        State.Stats.Losses = State.Stats.Losses + 1
        State.Stats.CurrentStreak = 0
    end
    
    State.Stats.GamesPlayed = State.Stats.Wins + State.Stats.Losses
    State.Stats.TotalPoints = State.Stats.TotalPoints + (yourScore or 0)
    
    if State.Stats.GamesPlayed > 0 then
        State.Stats.AveragePoints = State.Stats.TotalPoints / State.Stats.GamesPlayed
    end
    
    -- Update stats display
    StatsLabel.Text = string.format(
        "Games: %d | Wins: %d (%.1f%%) | Streak: %d\nBest Streak: %d | Avg Points: %.1f",
        State.Stats.GamesPlayed,
        State.Stats.Wins,
        State.Stats.GamesPlayed > 0 and (State.Stats.Wins / State.Stats.GamesPlayed * 100) or 0,
        State.Stats.CurrentStreak,
        State.Stats.BestStreak,
        State.Stats.AveragePoints
    )
end

local function trackGameState()
    if State.GameStateThread then return end
    
    State.GameStateThread = task.spawn(function()
        while ScreenGui.Parent do
            -- Check for game start
            if not GameTracker.IsGameActive and detectGameStart() then
                GameTracker.IsGameActive = true
                GameTracker.GameStartTime = tick()
                GameTracker.RoundCount = GameTracker.RoundCount + 1
                GameTracker.LastResult = nil
                State.CurrentGameId = tostring(tick())
                
                GameStatusLabel.Text = "Game: Active - Round " .. GameTracker.RoundCount
                GameStatusLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
                
                -- Add to info
                InfoLabel.Text = InfoLabel.Text .. "\n🎮 Game started!"
            end
            
            -- Check for game end
            if GameTracker.IsGameActive then
                local gameEnded, endReason = detectGameEnd()
                if gameEnded then
                    local yourScore, opponentScore = getFinalScores()
                    local result = determineWinner(yourScore, opponentScore, endReason)
                    
                    GameTracker.LastResult = result
                    GameTracker.YourFinalScore = yourScore
                    GameTracker.OpponentFinalScore = opponentScore
                    GameTracker.IsGameActive = false
                    
                    -- Update statistics
                    updateGameStats(result, yourScore, opponentScore)
                    
                    -- Update game status
                    local resultColor = result == "win" and Color3.fromRGB(50, 200, 50) or 
                                      result == "loss" and Color3.fromRGB(220, 80, 80) or 
                                      Color3.fromRGB(255, 165, 0)
                    
                    local resultText = result:upper()
                    GameStatusLabel.Text = string.format("Game: %s (You: %d vs Opp: %d)", resultText, yourScore, opponentScore)
                    GameStatusLabel.TextColor3 = resultColor
                    
                    -- Add result to info
                    local resultIcon = result == "win" and "🏆" or result == "loss" and "💀" or "🤝"
                    InfoLabel.Text = InfoLabel.Text .. string.format("\n%s Game ended: %s (%d-%d)", 
                        resultIcon, resultText, yourScore, opponentScore)
                    
                    -- Reset for next game after a delay
                    task.wait(3)
                    GameStatusLabel.Text = "Game: Waiting for next round..."
                    GameStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            task.wait(CONFIG.GAME_END_CHECK_INTERVAL)
        end
    end)
end

-- Enhanced card analysis
local function updateAdvisor()
    local currentTime = tick()
    if currentTime - State.LastUpdate < CONFIG.UPDATE_INTERVAL then
        return
    end
    State.LastUpdate = currentTime
    
    local room = workspace:FindFirstChild("Room")
    if not room then
        RecommendationLabel.Text = "WAITING"
        RecommendationLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        ChanceLabel.Text = "Game not detected"
        InfoLabel.Text = "Searching for game room..."
        return
    end
    
    local cardsContainer = room:FindFirstChild("Cards")
    local opponentRoot = room.Opponent and room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = room:FindFirstChild("Camera")

    -- Get target score
    local goalValue
    local sumLabel = room.Main and room.Main:FindFirstChild("YourCardsSum")
    if sumLabel then
        local surfaceGui = sumLabel:FindFirstChild("SurfaceGui")
        if surfaceGui then
            local textLabel = surfaceGui:FindFirstChild("TextLabel")
            if textLabel and textLabel:IsA("TextLabel") then
                goalValue = tonumber((textLabel.Text or ""):match("%d+/(%d+)"))
            end
        end
    end

    if not (cardsContainer and opponentRoot and myCamera and goalValue) then
        RecommendationLabel.Text = "WAITING"
        RecommendationLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        ChanceLabel.Text = "Initializing game..."
        InfoLabel.Text = "Waiting for game data..."
        return
    end

    -- Analyze cards
    local myCards, opponentCards = {}, {}
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "Card" and card:IsA("BasePart") then
            local scoreLabel = card:FindFirstChild("Score")
            local textLabel = scoreLabel and scoreLabel:FindFirstChild("TextLabel")
            local faceValue = textLabel and textLabel.Text or "[Hidden]"
            
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

    -- Calculate values
    local function cardValue(v)
        if v == "L" then return 99 end -- Special card
        return tonumber(v) or 0
    end

    local mySum = 0
    for _, v in ipairs(myCards) do
        mySum = mySum + cardValue(v)
    end

    local oppKnownSum, oppHiddenCount = 0, 0
    for _, v in ipairs(opponentCards) do
        local val = cardValue(v)
        if val > 0 and val ~= 99 then
            oppKnownSum = oppKnownSum + val
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end

    -- Deck analysis
    local fullDeck = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
    local visibleCards = {}
    
    for _, v in ipairs(myCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    for _, v in ipairs(opponentCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    
    local remainingDeck = {}
    for _, card in ipairs(fullDeck) do
        local found = false
        for _, visible in ipairs(visibleCards) do
            if visible == card then
                found = true
                break
            end
        end
        if not found then
            table.insert(remainingDeck, card)
        end
    end

    -- Probability calculation
    local safeDraws, bustDraws = 0, 0
    for _, card in ipairs(remainingDeck) do
        if mySum + card <= goalValue then
            safeDraws = safeDraws + 1
        else
            bustDraws = bustDraws + 1
        end
    end
    
    local totalRemaining = #remainingDeck
    local safeChance = totalRemaining > 0 and safeDraws / totalRemaining or 0
    
    -- Advanced opponent prediction
    local deckSum = 0
    for _, card in ipairs(remainingDeck) do
        deckSum = deckSum + card
    end
    local avgCardValue = totalRemaining > 0 and deckSum / totalRemaining or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgCardValue)
    
    -- Dynamic strategy adjustment
    local pointsNeeded = goalValue - mySum
    local requiredSafeChance = CONFIG.REQUIRED_SAFE_CHANCE
    
    -- Adjust strategy based on opponent's position
    local opponentAdvantage = math.max(0, oppExpectedSum - mySum)
    requiredSafeChance = requiredSafeChance - (opponentAdvantage * CONFIG.OPPONENT_ADVANTAGE_FACTOR)
    requiredSafeChance = math.max(CONFIG.MIN_SAFE_CHANCE, requiredSafeChance)
    
    -- Make recommendation
    local opponentBust = oppKnownSum > goalValue
    local isHighRisk = safeChance < CONFIG.HIGH_RISK_THRESHOLD
    
    if opponentBust then
        RecommendationLabel.Text = "HOLD"
        RecommendationLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
        ChanceLabel.Text = string.format("Opponent bust! (%.1f%%)", safeChance * 100)
    elseif mySum >= goalValue then
        RecommendationLabel.Text = "HOLD"
        RecommendationLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
        ChanceLabel.Text = string.format("Goal reached! (%.1f%%)", safeChance * 100)
    elseif safeChance >= requiredSafeChance and not isHighRisk then
        RecommendationLabel.Text = "TAKE"
        RecommendationLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
        ChanceLabel.Text = string.format("Good chance (%.1f%%)", safeChance * 100)
    elseif safeChance >= requiredSafeChance and isHighRisk then
        RecommendationLabel.Text = "RISKY TAKE"
        RecommendationLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        ChanceLabel.Text = string.format("Risky (%.1f%%)", safeChance * 100)
    else
        RecommendationLabel.Text = "HOLD"
        RecommendationLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        ChanceLabel.Text = string.format("Low chance (%.1f%%)", safeChance * 100)
    end
    
    -- Update info display
    local deckDisplay = ""
    for i, card in ipairs(remainingDeck) do
        local color = (mySum + card <= goalValue) and "32C832" or "C83232"
        deckDisplay = deckDisplay .. string.format('<font color="#%s">%d</font>', color, card)
        if i < #remainingDeck then deckDisplay = deckDisplay .. ", " end
    end
    
    InfoLabel.Text = string.format(
        "Your Sum: %d/%d | Need: %d\nOpponent: %.1f (Known: %d)\nSafe/Bust: %d/%d\nDeck: %s",
        mySum, goalValue, pointsNeeded,
        oppExpectedSum, oppKnownSum,
        safeDraws, bustDraws,
        deckDisplay
    )
end

-- Connect update loop
RunService.Heartbeat:Connect(updateAdvisor)

-- Initialize
setAutoAppearance(false)
trackGameState() -- Start game state tracking
InfoLabel.Text = "🃏 Advanced Card Counter v2.0 Loaded!\nWaiting for game data..."

warn("Advanced Card Counter v2.0 successfully loaded!")
