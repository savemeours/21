local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardAdvisor"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 240)
Frame.Position = UDim2.new(0.5, -150, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.FillDirection = Enum.FillDirection.Vertical

local UIPadding = Instance.new("UIPadding", Frame)
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "Header"
HeaderFrame.Size = UDim2.new(1, 0, 0, 30)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.LayoutOrder = 1
HeaderFrame.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ADVANCED CARD ADVISOR"
Title.Font = Enum.Font.SourceSansSemibold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(230, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 2)
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
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
RecommendationFrame.Size = UDim2.new(1, 0, 0, 40)
RecommendationFrame.BackgroundTransparency = 1
RecommendationFrame.LayoutOrder = 2
RecommendationFrame.Parent = Frame

local Recommendation = Instance.new("TextLabel")
Recommendation.Name = "RecommendationText"
Recommendation.Size = UDim2.new(1, 0, 1, 0)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.SourceSansBold
Recommendation.TextSize = 32
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
InfoLabel.Size = UDim2.new(1, 0, 0, 140)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 15
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.LayoutOrder = 4
InfoLabel.Text = "Fetching current game state data..."
InfoLabel.Parent = Frame

local function cardValue(v)
	if v == "L" then return 99 end
	return tonumber(v)
end

local function updateAdvisor()
	local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
	local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
	local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

	local goalValue
	local sumLabel = workspace.Room
		and workspace.Room.Main
		and workspace.Room.Main:FindFirstChild("YourCardsSum")
		and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
		and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")

	if sumLabel and sumLabel:IsA("TextLabel") then
		local match = (sumLabel.Text or ""):match("%d+/(%d+)")
		goalValue = match and tonumber(match)
	end

	if not (cardsContainer and opponentRoot and myCamera and goalValue) then
		Recommendation.Text = "WAITING"
		Recommendation.TextColor3 = Color3.fromRGB(255, 191, 0)
		InfoLabel.Text = "<font color='#D4AC0D'>Menunggu data permainan (Kartu, Target, Pemain).</font>\nPastikan Anda berada dalam pertandingan dan data UI terlihat."
		return
	end

	local myCards, opponentCards = {}, {}
	local mySum, oppKnownSum, oppHiddenCount = 0, 0, 0
	local visibleCardValues = {}

	for _, obj in ipairs(cardsContainer:GetChildren()) do
		if obj.Name == "Card" and obj:IsA("BasePart") then
			local scoreLabel = obj:FindFirstChild("Score") and obj.Score:FindFirstChild("TextLabel")
			local faceValue = scoreLabel and scoreLabel.Text or nil
			if not faceValue then continue end

			local distToOpponent = (obj.Position - opponentRoot.Position).Magnitude
			local distToMe = (obj.Position - myCamera.Position).Magnitude
			local isMine = (distToMe < distToOpponent)

			local value = cardValue(faceValue)

			if isMine then
				table.insert(myCards, faceValue)
				if value and value ~= 99 then mySum += value end
			else
				table.insert(opponentCards, faceValue)
				if value and value ~= 99 then
					oppKnownSum += value
				else
					oppHiddenCount += 1
				end
			end

			if value and value ~= 99 then table.insert(visibleCardValues, value) end
		end
	end

	-- Hitungan Kartu Sisa (Deck Composition)
	local fullDeck = {1,2,3,4,5,6,7,8,9,10,11, 1,2,3,4,5,6,7,8,9,10,11} -- Misal 2 set kartu
	local remainingDeck = {}
	local tempDeck = {}
	for _, v in ipairs(fullDeck) do table.insert(tempDeck, v) end

	for _, visibleValue in ipairs(visibleCardValues) do
		for i, deckCard in ipairs(tempDeck) do
			if deckCard == visibleValue then
				table.remove(tempDeck, i)
				break
			end
		end
	end
	remainingDeck = tempDeck

	local safeDraws, bustDraws = 0, 0
	for _, value in ipairs(remainingDeck) do
		if mySum + value <= goalValue then
			safeDraws += 1
		else
			bustDraws += 1
		end
	end
	local totalRemaining = safeDraws + bustDraws
	local safeChance = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0
	local bustChance = 1 - safeChance

	-- Estimasi Lawan
	local sumOfRemainingDeck = 0
	for _, v in ipairs(remainingDeck) do sumOfRemainingDeck += v end
	local avgRemainingValue = (totalRemaining > 0) and (sumOfRemainingDeck / totalRemaining) or 5.5 -- 5.5 adalah rata-rata standar jika deck kosong

	local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgRemainingValue)
	local pointsNeeded = goalValue - mySum
	local opponentBust = oppKnownSum > goalValue

	-- Logika Rekomendasi yang Lebih Canggih
	local recommendationText, color
	local requiredSafeChance = 0.55 -- Batas aman standar

	if opponentBust then
		recommendationText = "HOLD (OPP. BUST)"
		color = Color3.fromRGB(231, 76, 60)
	elseif mySum == goalValue then
		recommendationText = "HOLD (MAX SUM)"
		color = Color3.fromRGB(46, 204, 113)
	elseif mySum > goalValue then
		recommendationText = "BUST!"
		color = Color3.fromRGB(192, 57, 43)
	elseif pointsNeeded >= 10 then -- Poin yang dibutuhkan besar, ambil risiko lebih tinggi
		requiredSafeChance = 0.30
	elseif pointsNeeded <= 3 then -- Hampir mencapai target, bermain sangat aman
		requiredSafeChance = 0.80
	end

	-- Penyesuaian Berdasarkan Status Lawan
	local oppAdvantage = math.max(0, oppExpectedSum - mySum)
	requiredSafeChance = requiredSafeChance - (oppAdvantage * 0.05) -- Kurangi syarat jika lawan diperkirakan lebih kuat
	requiredSafeChance = math.max(0.20, requiredSafeChance) -- Batas minimum

	if recommendationText == nil then
		if safeChance >= requiredSafeChance then
			recommendationText = "TAKE"
			color = Color3.fromRGB(46, 204, 113)
		else
			recommendationText = "HOLD"
			color = Color3.fromRGB(243, 156, 18)
		end
	end

	Recommendation.Text = recommendationText
	Recommendation.TextColor3 = color

	-- Teks Info Detail
	local deckText = ""
	local sortedDeck = {}
	for _, card in ipairs(remainingDeck) do table.insert(sortedDeck, card) end
	table.sort(sortedDeck)
	
	local cardCounts = {}
	for _, card in ipairs(sortedDeck) do
		cardCounts[card] = (cardCounts[card] or 0) + 1
	end
	
	local uniqueCards = {}
	for card, count in pairs(cardCounts) do
		table.insert(uniqueCards, {card = card, count = count})
	end
	table.sort(uniqueCards, function(a, b) return a.card < b.card end)

	for i, data in ipairs(uniqueCards) do
		local card = data.card
		local count = data.count
		local isSafe = mySum + card <= goalValue
		local colorCode = isSafe and "#32C820" or "#C83220"
		deckText = deckText .. string.format("<font color='%s'>%d (x%d)</font>", colorCode, card, count)
		if i < #uniqueCards then deckText = deckText .. ", " end
	end

	InfoLabel.Text = string.format(
		"<b><font color='#FFFFFF'>TARGET:</font></b> <font color='#F39C12'>%d</font>\n" ..
		"<b><font color='#FFFFFF'>SUM SAYA:</font></b> <font color='%s'>%d</font> (Butuh: %d)\n" ..
		"<b><font color='#FFFFFF'>SUM LAWAN (E):</font></b> <font color='#9B59B6'>%.1f</font> (%d Tersembunyi)\n" ..
		"<b><font color='#FFFFFF'>PELUANG AMAN:</font></b> <font color='%s'>%.1f%%</font> (BUST: %.1f%%)\n" ..
		"<b><font color='#FFFFFF'>SISA KARTU DECK (%d):</font></b>\n%s",
		goalValue,
		mySum > goalValue and "#E74C3C" or "#46C657", mySum, math.max(0, pointsNeeded),
		oppExpectedSum, oppHiddenCount,
		safeChance >= requiredSafeChance and "#46C657" or "#E74C3C", safeChance * 100, bustChance * 100,
		totalRemaining,
		deckText
	)
end

RunService.RenderStepped:Connect(updateAdvisor)
