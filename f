local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Diperlukan untuk koordinat layar

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

local AutoOn = false
local AutoLoopThread = nil
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ProfessionalBlackjackAdvisor"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 260)
Frame.Position = UDim2.new(0.5, -160, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.FillDirection = Enum.FillDirection.Vertical

local UIPadding = Instance.new("UIPadding", Frame)
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "Header"
HeaderFrame.Size = UDim2.new(1, 0, 0, 30)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.LayoutOrder = 1
HeaderFrame.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -65, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BLACKJACK STRATEGY ADVISOR"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(170, 200, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderFrame

local AutoButton = Instance.new("TextButton")
AutoButton.Name = "AutoButton"
AutoButton.Size = UDim2.new(0, 25, 0, 25)
AutoButton.Position = UDim2.new(1, -55, 0, 2)
AutoButton.AnchorPoint = Vector2.new(1, 0)
AutoButton.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
AutoButton.Text = "A"
AutoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 18
AutoButton.Parent = HeaderFrame
local AutoUICorner = Instance.new("UICorner", AutoButton)
AutoUICorner.CornerRadius = UDim.new(0, 6)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 2)
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.Text = "✖"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = HeaderFrame

local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0, 6)

CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Parent = HeaderFrame
DragHandle.Size = UDim2.new(1, 0, 1, 0)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.ZIndex = 2

local dragging, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
DragHandle.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local RecommendationFrame = Instance.new("Frame")
RecommendationFrame.Name = "RecommendationDisplay"
RecommendationFrame.Size = UDim2.new(1, 0, 0, 45)
RecommendationFrame.BackgroundTransparency = 1
RecommendationFrame.LayoutOrder = 2
RecommendationFrame.Parent = Frame

local Recommendation = Instance.new("TextLabel")
Recommendation.Name = "RecommendationText"
Recommendation.Size = UDim2.new(1, 0, 1, 0)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.SourceSansBold
Recommendation.TextSize = 36
Recommendation.TextColor3 = Color3.fromRGB(255, 255, 255)
Recommendation.Text = "INITIALIZING..."
Recommendation.Parent = RecommendationFrame

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
Divider.LayoutOrder = 3
Divider.Parent = Frame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "DetailedInfo"
InfoLabel.Size = UDim2.new(1, 0, 0, 150)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.LayoutOrder = 4
InfoLabel.Text = "Fetching current game state data..."
InfoLabel.Parent = Frame

local function getCardNumericalValue(v)
	if v == "L" or v == "J" or v == "Q" or v == "K" then return 10 end
	if v == "A" then return 1 end
	return tonumber(v)
end

local function calculateBestSum(cardValues)
	local sum = 0
	local aceCount = 0
	for _, v in ipairs(cardValues) do
		if v == 1 then
			aceCount += 1
			sum += 11
		else
			sum += v
		end
	end

	while sum > 21 and aceCount > 0 do
		sum -= 10
		aceCount -= 1
	end
	return sum
end

local CurrentRecommendation = ""

local function updateAdvisor()
	local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
	local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
	local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")
	local goalValue = 21

	if not (cardsContainer and opponentRoot and myCamera) then
		CurrentRecommendation = "WAITING"
		Recommendation.Text = "WAITING"
		Recommendation.TextColor3 = Color3.fromRGB(255, 191, 0)
		InfoLabel.Text = "<font color='#D4AC0D'>Menunggu data permainan (Kartu dan Pemain).</font>\nPastikan Anda berada dalam pertandingan Blackjack."
		return
	end

	local myCardValues, opponentKnownValues = {}, {}
	local oppHiddenCount = 0
	local visibleCardValues = {}

	for _, obj in ipairs(cardsContainer:GetChildren()) do
		if obj.Name == "Card" and obj:IsA("BasePart") then
			local scoreLabel = obj:FindFirstChild("Score") and obj.Score:FindFirstChild("TextLabel")
			local faceValueText = scoreLabel and scoreLabel.Text or nil
			if not faceValueText then continue end

			local distToOpponent = (obj.Position - opponentRoot.Position).Magnitude
			local distToMe = (obj.Position - myCamera.Position).Magnitude
			local isMine = (distToMe < distToOpponent)

			local value = getCardNumericalValue(faceValueText)

			if isMine then
				if value then table.insert(myCardValues, value) end
			else
				if value and value < 99 then
					table.insert(opponentKnownValues, value)
				else
					oppHiddenCount += 1
				end
			end

			if value and value < 99 then table.insert(visibleCardValues, value) end
		end
	end

	local mySum = calculateBestSum(myCardValues)
	local oppKnownSum = calculateBestSum(opponentKnownValues)
	local dealerUpCardValue = oppKnownSum
	
	local fullDeck = {}
	local standardCards = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10}
	for s = 1, 4 do
		for _, v in ipairs(standardCards) do
			table.insert(fullDeck, v)
		end
	end

	local remainingDeck = {}
	local tempDeck = {}
	for _, v in ipairs(fullDeck) do table.insert(tempDeck, v) end

	for _, visibleValue in ipairs(visibleCardValues) do
		local val = visibleValue
		for i, deckCard in ipairs(tempDeck) do
			if deckCard == val then
				table.remove(tempDeck, i)
				break
			end
		end
	end
	remainingDeck = tempDeck

	local bustDraws = 0
	for _, drawCardValue in ipairs(remainingDeck) do
		local potentialNewHand = table.clone(myCardValues)
		table.insert(potentialNewHand, drawCardValue)
		local newSum = calculateBestSum(potentialNewHand)
		
		if newSum > 21 then
			bustDraws += 1
		end
	end
	
	local totalRemaining = #remainingDeck
	local safeDraws = totalRemaining - bustDraws
	local safeChance = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0
	local bustChance = 1 - safeChance
	
	local pointsNeeded = goalValue - mySum

	local recommendationText, color
	local strategyBasedValue = dealerUpCardValue
	
	if dealerUpCardValue == 1 then strategyBasedValue = 11 end

	if mySum > 21 then
		recommendationText = "BUST!"
		color = Color3.fromRGB(192, 57, 43)
	elseif mySum == 21 then
		recommendationText = "BLACKJACK/HOLD"
		color = Color3.fromRGB(46, 204, 113)
	elseif mySum <= 11 then
		recommendationText = "HIT/TAKE"
		color = Color3.fromRGB(46, 204, 113)
	elseif mySum == 12 then
		if strategyBasedValue >= 4 and strategyBasedValue <= 6 then
			recommendationText = "STAND/HOLD"
			color = Color3.fromRGB(243, 156, 18)
		else
			recommendationText = "HIT/TAKE"
			color = Color3.fromRGB(46, 204, 113)
		end
	elseif mySum >= 13 and mySum <= 16 then
		if strategyBasedValue >= 2 and strategyBasedValue <= 6 then
			recommendationText = "STAND/HOLD"
			color = Color3.fromRGB(243, 156, 18)
		else
			recommendationText = "HIT/TAKE"
			color = Color3.fromRGB(46, 204, 113)
		end
	elseif mySum >= 17 then
		recommendationText = "STAND/HOLD"
		color = Color3.fromRGB(243, 156, 18)
	else
		if safeChance >= 0.70 then
			recommendationText = "HIT/TAKE (SAFE)"
			color = Color3.fromRGB(46, 204, 113)
		else
			recommendationText = "STAND/HOLD (RISK)"
			color = Color3.fromRGB(243, 156, 18)
		end
	end

	CurrentRecommendation = recommendationText
	Recommendation.Text = recommendationText
	Recommendation.TextColor3 = color

	local deckText = ""
	local cardCounts = {}
	for _, card in ipairs(remainingDeck) do
		local cardDisplay = (card == 1) and "A" or tostring(card)
		cardCounts[cardDisplay] = (cardCounts[cardDisplay] or 0) + 1
	end
	
	local uniqueCards = {}
	for card, count in pairs(cardCounts) do
		local numVal = (card == "A") and 1 or tonumber(card)
		table.insert(uniqueCards, {card = card, count = count, numVal = numVal})
	end
	table.sort(uniqueCards, function(a, b) return a.numVal < b.numVal end)

	for i, data in ipairs(uniqueCards) do
		local card = data.card
		local count = data.count
		local cardValue = data.numVal

		local potentialNewHand = table.clone(myCardValues)
		table.insert(potentialNewHand, cardValue)
		local newSum = calculateBestSum(potentialNewHand)

		local isSafe = newSum <= goalValue
		local colorCode = isSafe and "#46C657" or "#E74C3C"
		deckText = deckText .. string.format("<font color='%s'>%s (x%d)</font>", colorCode, card, count)
		if i < #uniqueCards then deckText = deckText .. ", " end
	end

	InfoLabel.Text = string.format(
		"<b><font color='#FFFFFF'>TARGET:</font></b> <font color='#F39C12'>%d</font>\n" ..
		"<b><font color='#FFFFFF'>SUM SAYA (Optimal):</font></b> <font color='%s'>%d</font> (Butuh: %d)\n" ..
		"<b><font color='#FFFFFF'>DEALER UP CARD:</font></b> <font color='#9B59B6'>%s</font> (%d Kartu Tersembunyi)\n" ..
		"<b><font color='#FFFFFF'>PELUANG AMAN (NON-BUST):</font></b> <font color='%s'>%.1f%%</font> (BUST: %.1f%%)\n" ..
		"<b><font color='#FFFFFF'>SISA KARTU DECK (%d):</font></b>\n%s",
		goalValue,
		mySum > goalValue and "#E74C3C" or "#46C657", mySum, math.max(0, pointsNeeded),
		(dealerUpCardValue == 1) and "A" or tostring(dealerUpCardValue), oppHiddenCount,
		safeChance >= 0.70 and "#46C657" or "#E74C3C", safeChance * 100, bustChance * 100,
		totalRemaining,
		deckText
	)
end

local function setAutoAppearance(on)
	if on then
		AutoButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	else
		AutoButton.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
	end
end

local function doClick(button, count)
	local vx = workspace.CurrentCamera.ViewportSize.X / 2
	local vy = workspace.CurrentCamera.ViewportSize.Y / 2
	local clickButton = (button == "Left") and 0 or 1

	for i = 1, count do
		if VirtualInputManager then
			VirtualInputManager:SendMouseButtonEvent(vx, vy, clickButton, true, game, 1)
			task.wait(0.02)
			VirtualInputManager:SendMouseButtonEvent(vx, vy, clickButton, false, game, 1)
		elseif VirtualUser then
			VirtualUser:CaptureController()
			if button == "Left" then
				VirtualUser:Button1Down(Vector2.new(vx, vy))
				task.wait(0.02)
				VirtualUser:Button1Up(Vector2.new(vx, vy))
			elseif button == "Right" and VirtualUser.Button2Down then
				VirtualUser:Button2Down(Vector2.new(vx, vy))
				task.wait(0.02)
				VirtualUser:Button2Up(Vector2.new(vx, vy))
			end
		end
		task.wait(0.1) -- Jeda antar klik ganda
	end
end

local function startAutoLoop()
	if AutoLoopThread then return end
	AutoLoopThread = task.spawn(function()
		while AutoOn and ScreenGui.Parent do
			local rec = (CurrentRecommendation or ""):upper()

			if rec:find("HIT") or rec:find("TAKE") then
				doClick("Left", 2)
			elseif rec:find("STAND") or rec:find("HOLD") or rec:find("BLACKJACK") then
				doClick("Right", 2)
			end

			task.wait(0.5) -- Cek ulang setiap 0.5 detik
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
		AutoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		task.delay(0.35, function()
			AutoButton.BackgroundColor3 = originalColor
		end)
		InfoLabel.Text = InfoLabel.Text .. "\n<font color='#E74C3C'>[AUTO] Metode simulasi klik tidak ditemukan.</font>"
		return
	end

	AutoOn = not AutoOn
	setAutoAppearance(AutoOn)
	if AutoOn then
		startAutoLoop()
	else
		stopAutoLoop()
	end
end)

-- Loop utama untuk update data
task.spawn(function()
	while ScreenGui.Parent do
		updateAdvisor()
		task.wait(0.2)
	end
end)
