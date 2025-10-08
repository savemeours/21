local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Membuat GUI Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AdvancedCardAdvisor"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Membuat Frame (Kotak Utama)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 200) -- Ukuran lebih besar untuk info yang lebih jelas
Frame.Position = UDim2.new(0.5, -160, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Latar belakang sangat gelap
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Card Advisor v2.0"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Tombol Tutup
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -35, 0, 12)
CloseButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43) -- Merah yang lebih profesional
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = Frame
local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0, 5)
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
	if script then script:Destroy() end
end)

-- Handle Drag
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Parent = Frame
DragHandle.Size = UDim2.new(1, 0, 0, 40)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.ZIndex = 2

local dragging, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				connection:Disconnect()
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

-- Rekomendasi Utama (TAKE/HOLD)
local Recommendation = Instance.new("TextLabel")
Recommendation.Size = UDim2.new(1, -30, 0, 35)
Recommendation.Position = UDim2.new(0, 15, 0, 50)
Recommendation.BackgroundTransparency = 1
Recommendation.Font = Enum.Font.GothamBold
Recommendation.TextSize = 30
Recommendation.TextColor3 = Color3.fromRGB(255, 255, 255)
Recommendation.TextXAlignment = Enum.TextXAlignment.Left
Recommendation.Parent = Frame

-- Label Informasi Detail
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -30, 1, -100)
InfoLabel.Position = UDim2.new(0, 15, 0, 90)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 15
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180) -- Abu-abu terang
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.RichText = true
InfoLabel.Parent = Frame

-- Fungsi Utama untuk Update Penasihat Kartu
local function updateAdvisor()
	local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
	local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
	local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

	local goalValue -- Nilai Target (e.g., 21)
	do
		local sumLabel = workspace.Room
			and workspace.Room.Main
			and workspace.Room.Main:FindFirstChild("YourCardsSum")
			and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
			and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
		if sumLabel and sumLabel:IsA("TextLabel") then
			local match = (sumLabel.Text or ""):match("%d+/(%d+)")
			goalValue = match and tonumber(match)
		end
	end

	-- Cek ketersediaan data permainan
	if not (cardsContainer and opponentRoot and myCamera and goalValue) then
		Recommendation.Text = "MENUNGGU DATA"
		Recommendation.TextColor3 = Color3.fromRGB(255, 191, 0) -- Kuning
		InfoLabel.Text = "Tidak dapat menemukan data permainan yang diperlukan. Pastikan Anda berada dalam permainan."
		return
	end

	local myCards, opponentCards = {}, {}
	for _, obj in ipairs(cardsContainer:GetChildren()) do
		if obj.Name == "Card" and obj:IsA("BasePart") then
			local scoreLabel = obj:FindFirstChild("Score") and obj.Score:FindFirstChild("TextLabel")
			local faceValue = scoreLabel and scoreLabel.Text or "[HIDDEN]"
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
		if v == "L" then return 99 end -- Nilai tinggi untuk kartu 'L' (Loss/Joker)
		return tonumber(v)
	end

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

	-- Inisialisasi Dek Penuh
	local deck = {1,2,3,4,5,6,7,8,9,10,11}
	local visibleCards = {}
	for _, v in ipairs(myCards) do
		local n = tonumber(v)
		if n and n <= 11 then table.insert(visibleCards, n) end
	end
	for _, v in ipairs(opponentCards) do
		local n = tonumber(v)
		if n and n <= 11 then table.insert(visibleCards, n) end
	end
	
	-- Hapus kartu yang sudah terlihat dari Dek
	for _, cardValue in ipairs(visibleCards) do
		for i, deckCard in ipairs(deck) do
			if deckCard == cardValue then
				table.remove(deck, i)
				break
			end
		end
	end

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

	local sumOfDeck = 0
	for _, v in ipairs(deck) do sumOfDeck += v end
	local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
	
	-- Estimasi Nilai Lawan
	local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

	local pointsNeeded = goalValue - mySum
	local opponentBust = oppKnownSum > goalValue

	-- Logika Rekomendasi yang Lebih Canggih
	
	local recommendationText = "HOLD"
	local recommendationColor = Color3.fromRGB(192, 57, 43) -- Merah

	if mySum > goalValue then
		recommendationText = "BUSTER" -- Status baru jika sudah bust
		recommendationColor = Color3.fromRGB(192, 57, 43) -- Merah
	elseif opponentBust then
		recommendationText = "HOLD (LAW. BUST)"
		recommendationColor = Color3.fromRGB(39, 174, 96) -- Hijau
	elseif safeChance >= 0.70 then
		recommendationText = "TAKE (HIGH CHANCE)"
		recommendationColor = Color3.fromRGB(39, 174, 96) -- Hijau
	elseif safeChance >= 0.50 and oppExpectedSum < mySum then
		recommendationText = "TAKE (EDGE)"
		recommendationColor = Color3.fromRGB(243, 156, 18) -- Oranye
	elseif mySum + 1 > goalValue then -- Kartu terkecil (1) sudah membuat bust
		recommendationText = "HOLD (CRITICAL)"
		recommendationColor = Color3.fromRGB(192, 57, 43) -- Merah
	else
		recommendationText = "HOLD"
		recommendationColor = Color3.fromRGB(192, 57, 43) -- Merah
	end

	Recommendation.Text = recommendationText
	Recommendation.TextColor3 = recommendationColor

	-- Detail Informasi
	local deckText = ""
	for i, card in ipairs(deck) do
		local color = (mySum + card <= goalValue) and "<font color='#39E75F'>" or "<font color='#E7395F'>" -- Hijau Terang atau Merah Terang
		deckText = deckText .. color .. card .. "</font>"
		if i < #deck then deckText = deckText .. ", " end
	end
	
	local myCardsText = table.concat(myCards, ", ")
	local oppKnownCardsText = {}
	for _, v in ipairs(opponentCards) do
		if tonumber(v) then table.insert(oppKnownCardsText, v) end
	end
	local oppHiddenText = string.rep("?", oppHiddenCount)
	if #oppKnownCardsText > 0 then
		oppHiddenText = ", " .. oppHiddenText
	end
	local oppCardsText = table.concat(oppKnownCardsText, ", ") .. oppHiddenText

	InfoLabel.Text = string.format(
		"<b>STATUS SAYA:</b> %d / %d\n" ..
		"<b>KARTU SAYA:</b> %s\n" ..
		"<b>LAWAN TERLIHAT:</b> %s\n\n" ..
		"<b>PELUANG AMAN (HIT):</b> <font color='%s'>%.1f%%</font>\n" ..
		"<b>EKSP. LAWAN:</b> %.1f (Total: %d Kartu Sisa)\n" ..
		"<b>KARTU SISA DEK:</b> %s",
		mySum, goalValue,
		myCardsText,
		oppCardsText,
		(safeChance >= 0.5 and '#39E75F' or '#E7395F'), safeChance*100,
		oppExpectedSum, totalRemaining,
		deckText
	)
end

-- Update setiap frame untuk memastikan informasi selalu real-time
RunService.RenderStepped:Connect(updateAdvisor)
