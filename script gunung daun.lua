--[[
  Mount Daun Easy Summit
  Author: Sans27
  UI, Logic & Security by: Gemini
  Versi: 4.1 (Final Key System Fix)

  Fitur Lengkap:
  - PERBAIKAN: Sistem validasi kunci dinamis sekarang menggunakan metode yang cocok antara web dan Lua.
  - Sistem Keamanan berbasis Kunci (Key System) yang dinamis.
  - UI Login Profesional.
  - UI Utama hanya akan dimuat setelah validasi kunci berhasil.
]]

-- ================== KONFIGURASI UTAMA ==================
-- PASTIKAN PENGATURAN INI SAMA PERSIS DENGAN YANG ADA DI WEBSITE GENERATOR ANDA
local DYNAMIC_KEY_CONFIG = {
	SECRET_PHRASE = "MountDaunSecretKey2025",
	VALIDITY_MINUTES = 10
}
local TRIAL_KEY_URL = "https://gitsans-porto.github.io/Web-Generator-Key/" -- GANTI DENGAN LINK GENERATOR ANDA
-- =======================================================

-- Layanan & Variabel Global
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local theme = { Background = Color3.fromRGB(28, 29, 33), Primary = Color3.fromRGB(38, 39, 44), Secondary = Color3.fromRGB(55, 56, 62), Accent = Color3.fromRGB(76, 175, 80), MainText = Color3.fromRGB(235, 235, 235), SubText = Color3.fromRGB(160, 160, 165), Error = Color3.fromRGB(231, 76, 60) }

_G.AccessGranted = _G.AccessGranted or false

--------------------------------------------------------------------------------
-- BAGIAN 1: FUNGSI UTAMA (SKRIP GUNUNG DAUN ANDA)
--------------------------------------------------------------------------------
local function loadMainScript()
	local allLocations = {
		{Name = "Basecamp", Position = Vector3.new(-6.8, 14.9, -7.9)},
		{Name = "Checkpoint 1", Position = Vector3.new(-621.7, 251.3, -383.9)},
		{Name = "Checkpoint 2", Position = Vector3.new(-1203.2, 262.6, -487.1)},
		{Name = "Checkpoint 3", Position = Vector3.new(-1399.2, 579.4, -949.9)},
		{Name = "Checkpoint 4", Position = Vector3.new(-1701.0, 817.6, -1400.0)},
		{Name = "Lokasi 5", Position = Vector3.new(-1971.5, 843.0, -1671.8)},
		{Name = "Lokasi 6", Position = Vector3.new(-2180.3, 938.5, -1734.9)},
		{Name = "Puncak", Position = Vector3.new(-3231.3, 1714.4, -2590.8)}
	}
	local autoSummitPath = {
		{Name = "Checkpoint 1", Position = Vector3.new(-621.7, 251.3, -383.9), Delay = 4},
		{Name = "Checkpoint 2", Position = Vector3.new(-1203.2, 262.6, -487.1), Delay = 4},
		{Name = "Checkpoint 3", Position = Vector3.new(-1399.2, 579.4, -949.9), Delay = 4},
		{Name = "Checkpoint 4", Position = Vector3.new(-1701.0, 817.6, -1400.0), Delay = 4},
		{Name = "Lokasi 5", Position = Vector3.new(-1971.5, 843.0, -1671.8), Delay = 2.5},
		{Name = "Puncak", Position = Vector3.new(-3231.3, 1714.4, -2590.8), Delay = 4},
		{Name = "Basecamp", Position = Vector3.new(-6.8, 14.9, -7.9), Delay = 5}
	}
	local isLooping = false
	local currentPathIndex = 1
	local loopThread = nil
	local statusText = "Idle"
	local function teleportTo(position) pcall(function() local character = localPlayer.Character or localPlayer.CharacterAdded:Wait(); local humanoidRootPart = character:WaitForChild("HumanoidRootPart"); humanoidRootPart.CFrame = CFrame.new(position) end) end
	local function createUI()
		if playerGui:FindFirstChild("MountDaunUI") then playerGui.MountDaunUI:Destroy() end
		local screenGui = Instance.new("ScreenGui", playerGui); screenGui.Name = "MountDaunUI"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local mainFrame = Instance.new("Frame", screenGui); mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(0, 280, 0, 320); mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160); mainFrame.BackgroundColor3 = theme.Background; mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.Draggable = true; Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12); local stroke = Instance.new("UIStroke", mainFrame); stroke.Color = theme.Secondary; stroke.Thickness = 1.5
		local titleBar = Instance.new("Frame", mainFrame); titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1, 0, 0, 55); titleBar.BackgroundColor3 = theme.Primary; titleBar.BorderSizePixel = 0
		local titleLabel = Instance.new("TextLabel", titleBar); titleLabel.Size = UDim2.new(1, -60, 0, 30); titleLabel.Position = UDim2.new(0, 15, 0, 5); titleLabel.BackgroundTransparency = 1; titleLabel.TextColor3 = theme.MainText; titleLabel.Font = Enum.Font.SourceSansSemibold; titleLabel.Text = "Mount Daun Easy Summit"; titleLabel.TextSize = 19; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		local authorLabel = Instance.new("TextLabel", titleBar); authorLabel.Size = UDim2.new(1, -60, 0, 15); authorLabel.Position = UDim2.new(0, 15, 0, 30); authorLabel.BackgroundTransparency = 1; authorLabel.TextColor3 = theme.SubText; authorLabel.Font = Enum.Font.SourceSansItalic; authorLabel.Text = "Author: Sans27"; authorLabel.TextSize = 14; authorLabel.TextXAlignment = Enum.TextXAlignment.Left
		local closeButton = Instance.new("TextButton", titleBar); closeButton.Size = UDim2.new(0, 25, 0, 25); closeButton.Position = UDim2.new(1, -35, 0, 7); closeButton.BackgroundTransparency = 1; closeButton.Font = Enum.Font.SourceSansBold; closeButton.Text = "X"; closeButton.TextSize = 20; closeButton.TextColor3 = theme.SubText
		local minimizeButton = Instance.new("TextButton", titleBar); minimizeButton.Size = UDim2.new(0, 25, 0, 25); minimizeButton.Position = UDim2.new(1, -60, 0, 5); minimizeButton.BackgroundTransparency = 1; minimizeButton.Font = Enum.Font.SourceSansBold; minimizeButton.Text = "_"; minimizeButton.TextSize = 22; minimizeButton.TextColor3 = theme.SubText
		local navBar = Instance.new("Frame", mainFrame); navBar.Size = UDim2.new(1, 0, 0, 40); navBar.Position = UDim2.new(0, 0, 0, 55); navBar.BackgroundColor3 = theme.Background; navBar.BorderSizePixel = 0; local navLayout = Instance.new("UIListLayout", navBar); navLayout.FillDirection = Enum.FillDirection.Horizontal; navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; navLayout.VerticalAlignment = Enum.VerticalAlignment.Center; navLayout.SortOrder = Enum.SortOrder.LayoutOrder
		local manualNav = Instance.new("TextButton", navBar); manualNav.Name = "ManualNav"; manualNav.LayoutOrder = 1; manualNav.Size = UDim2.new(0.5, -1, 1, 0); manualNav.BackgroundColor3 = theme.Secondary; manualNav.Font = Enum.Font.SourceSansSemibold; manualNav.Text = "Manual"; manualNav.TextSize = 16; manualNav.TextColor3 = theme.MainText
		local autoNav = Instance.new("TextButton", navBar); autoNav.Name = "AutoNav"; autoNav.LayoutOrder = 2; autoNav.Size = UDim2.new(0.5, -1, 1, 0); autoNav.BackgroundColor3 = theme.Background; autoNav.Font = Enum.Font.SourceSansSemibold; autoNav.Text = "Automatic"; autoNav.TextSize = 16; autoNav.TextColor3 = theme.SubText
		local contentContainer = Instance.new("Frame", mainFrame); contentContainer.Name = "ContentContainer"; contentContainer.Size = UDim2.new(1, 0, 1, -95); contentContainer.Position = UDim2.new(0, 0, 0, 95); contentContainer.BackgroundTransparency = 1; contentContainer.ClipsDescendants = true; local pageLayout = Instance.new("UIPageLayout", contentContainer); pageLayout.TweenTime = 0.2; pageLayout.EasingStyle = Enum.EasingStyle.Quad; pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		local manualPage = Instance.new("ScrollingFrame", contentContainer); manualPage.Name = "ManualPage"; manualPage.LayoutOrder = 1; manualPage.Size = UDim2.new(1, 0, 1, 0); manualPage.BackgroundTransparency = 1; manualPage.BorderSizePixel = 0; manualPage.CanvasSize = UDim2.new(0, 0, 0, #allLocations * 45); manualPage.ScrollBarImageColor3 = theme.Accent; manualPage.ScrollBarThickness = 5; local manualListLayout = Instance.new("UIListLayout", manualPage); manualListLayout.Padding = UDim.new(0, 5); manualListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local autoPage = Instance.new("Frame", contentContainer); autoPage.Name = "AutoPage"; autoPage.LayoutOrder = 2; autoPage.Size = UDim2.new(1, 0, 1, 0); autoPage.BackgroundTransparency = 1; local autoPadding = Instance.new("UIPadding", autoPage); autoPadding.PaddingTop = UDim.new(0, 20); autoPadding.PaddingLeft = UDim.new(0, 20); autoPadding.PaddingRight = UDim.new(0, 20)
		local toggleLabel = Instance.new("TextLabel", autoPage); toggleLabel.Size = UDim2.new(0.6, 0, 0, 30); toggleLabel.BackgroundTransparency = 1; toggleLabel.Font = Enum.Font.SourceSansSemibold; toggleLabel.Text = "Auto Summit"; toggleLabel.TextColor3 = theme.MainText; toggleLabel.TextSize = 20; toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
		local toggleSwitch = Instance.new("TextButton", autoPage); toggleSwitch.Size = UDim2.new(0, 50, 0, 26); toggleSwitch.Position = UDim2.new(1, -50, 0, 2); toggleSwitch.BackgroundColor3 = theme.Secondary; toggleSwitch.Text = ""; Instance.new("UICorner", toggleSwitch).CornerRadius = UDim.new(1, 0); local tsKnob = Instance.new("Frame", toggleSwitch); tsKnob.Name = "Knob"; tsKnob.Size = UDim2.new(0, 20, 0, 20); tsKnob.Position = UDim2.new(0, 3, 0.5, -10); tsKnob.BackgroundColor3 = theme.MainText; tsKnob.BorderSizePixel = 0; Instance.new("UICorner", tsKnob).CornerRadius = UDim.new(1, 0)
		local statusLabel = Instance.new("TextLabel", autoPage); statusLabel.Size = UDim2.new(1, 0, 0, 50); statusLabel.Position = UDim2.new(0, 0, 0, 80); statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.SourceSansItalic; statusLabel.Text = "Status: Idle"; statusLabel.TextColor3 = theme.SubText; statusLabel.TextSize = 16; statusLabel.TextWrapped = true; statusLabel.TextXAlignment = Enum.TextXAlignment.Left; statusLabel.TextYAlignment = Enum.TextYAlignment.Top
		for i, locData in ipairs(allLocations) do local btn = Instance.new("TextButton", manualPage); btn.Name = locData.Name; btn.Size = UDim2.new(1, -20, 0, 40); btn.BackgroundColor3 = theme.Primary; btn.Font = Enum.Font.SourceSans; btn.Text = locData.Name; btn.TextColor3 = theme.MainText; btn.TextSize = 16; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); btn.AutoButtonColor = false; btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.Secondary}):Play() end); btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.Primary}):Play() end); btn.MouseButton1Click:Connect(function() statusText = "Teleporting to " .. locData.Name .. "..."; teleportTo(locData.Position); for j, pathData in ipairs(autoSummitPath) do if pathData.Name == locData.Name then currentPathIndex = j; break end end; statusText = "Arrived at " .. locData.Name end) end
		return { ScreenGui = screenGui, MainFrame = mainFrame, TitleBar = titleBar, CloseButton = closeButton, MinimizeButton = minimizeButton, ManualNav = manualNav, AutoNav = autoNav, PageLayout = pageLayout, ManualPage = manualPage, AutoPage = autoPage, ToggleSwitch = toggleSwitch, StatusLabel = statusLabel, Theme = theme }
	end
	local function makeDraggable(gui, dragPart) local dragging = false; local dragInput, lastPosition, startPosition; dragPart.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragInput = input; lastPosition = input.Position; startPosition = gui.Position end end); dragPart.InputEnded:Connect(function(input) if input == dragInput then dragging = false end end); UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - lastPosition; gui.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y) end end) end
	local function runAutoSummit() while isLooping do local success, err = pcall(function() if not isLooping then return end; local targetLocation = autoSummitPath[currentPathIndex]; statusText = "Teleporting to " .. targetLocation.Name .. "..."; teleportTo(targetLocation.Position); statusText = "Arrived at " .. targetLocation.Name .. ". Waiting..."; task.wait(targetLocation.Delay); if not isLooping then return end; currentPathIndex = (currentPathIndex % #autoSummitPath) + 1 end); if not success then warn("Auto Summit Error:", err); statusText = "An error occurred. Retrying..."; task.wait(2) end end; if not isLooping then statusText = "Looping paused. Ready to resume." end end
	local UI = createUI(); makeDraggable(UI.MainFrame, UI.TitleBar)
	UI.CloseButton.MouseButton1Click:Connect(function() UI.ScreenGui:Destroy() end)
	local isMinimized = false; UI.MinimizeButton.MouseButton1Click:Connect(function() isMinimized = not isMinimized; local contentParent = UI.ManualPage.Parent; contentParent.Visible = not isMinimized; UI.ManualNav.Parent.Visible = not isMinimized; if isMinimized then UI.MainFrame:TweenSize(UDim2.new(0, 280, 0, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true); UI.MinimizeButton.Text = "O" else UI.MainFrame:TweenSize(UDim2.new(0, 280, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true); UI.MinimizeButton.Text = "_" end end)
	local function switchTab(activeTab) if activeTab == "Manual" then UI.PageLayout:JumpTo(UI.ManualPage); UI.ManualNav.BackgroundColor3 = UI.Theme.Secondary; UI.AutoNav.BackgroundColor3 = UI.Theme.Background; UI.ManualNav.TextColor3 = UI.Theme.MainText; UI.AutoNav.TextColor3 = UI.Theme.SubText else UI.PageLayout:JumpTo(UI.AutoPage); UI.ManualNav.BackgroundColor3 = UI.Theme.Background; UI.AutoNav.BackgroundColor3 = UI.Theme.Secondary; UI.ManualNav.TextColor3 = UI.Theme.SubText; UI.AutoNav.TextColor3 = UI.Theme.MainText end end
	UI.ManualNav.MouseButton1Click:Connect(function() switchTab("Manual") end); UI.AutoNav.MouseButton1Click:Connect(function() switchTab("Automatic") end); switchTab("Manual")
	UI.ToggleSwitch.MouseButton1Click:Connect(function() isLooping = not isLooping; local knob = UI.ToggleSwitch:FindFirstChild("Knob"); local newPos = isLooping and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10); local newColor = isLooping and UI.Theme.Accent or UI.Theme.Secondary; TweenService:Create(knob, TweenInfo.new(0.2), {Position = newPos}):Play(); TweenService:Create(UI.ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play(); if isLooping then statusText = "Starting loop..."; loopThread = task.spawn(runAutoSummit) else statusText = "Looping paused."; if loopThread then task.cancel(loopThread); loopThread = nil end end end)
	RunService.RenderStepped:Connect(function() if UI.StatusLabel and UI.StatusLabel.Parent then UI.StatusLabel.Text = "Status: " .. statusText end end)
end

--------------------------------------------------------------------------------
-- BAGIAN 2: UI LOGIN & LOGIKA VALIDASI BARU
--------------------------------------------------------------------------------
local function createLoginUI()
	if playerGui:FindFirstChild("KeySystemLoginUI") then playerGui.KeySystemLoginUI:Destroy() end
	local screenGui = Instance.new("ScreenGui", playerGui); screenGui.Name = "KeySystemLoginUI"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local mainFrame = Instance.new("Frame", screenGui); mainFrame.Size = UDim2.new(0, 340, 0, 200); mainFrame.Position = UDim2.new(0.5, -170, 0.5, -100); mainFrame.BackgroundColor3 = theme.Background; Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12); local stroke = Instance.new("UIStroke", mainFrame); stroke.Color = theme.Secondary; stroke.Thickness = 1.5
	local titleLabel = Instance.new("TextLabel", mainFrame); titleLabel.Size = UDim2.new(1, 0, 0, 40); titleLabel.Position = UDim2.new(0, 0, 0, 15); titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.SourceSansBold; titleLabel.Text = "Aktivasi Skrip"; titleLabel.TextColor3 = theme.MainText; titleLabel.TextSize = 22
	local keyBox = Instance.new("TextBox", mainFrame); keyBox.Size = UDim2.new(1, -40, 0, 40); keyBox.Position = UDim2.new(0.5, 0, 0, 65); keyBox.AnchorPoint = Vector2.new(0.5, 0); keyBox.BackgroundColor3 = theme.Primary; keyBox.Font = Enum.Font.SourceSans; keyBox.Text = ""; keyBox.PlaceholderText = "Masukkan Kunci Trial Anda..."; keyBox.TextColor3 = theme.MainText; keyBox.PlaceholderColor3 = theme.SubText; keyBox.TextSize = 16; keyBox.ClearTextOnFocus = false; Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
	local loginButton = Instance.new("TextButton", mainFrame); loginButton.Size = UDim2.new(1, -40, 0, 40); loginButton.Position = UDim2.new(0.5, 0, 0, 115); loginButton.AnchorPoint = Vector2.new(0.5, 0); loginButton.BackgroundColor3 = theme.Accent; loginButton.Font = Enum.Font.SourceSansBold; loginButton.Text = "AKTIVASI"; loginButton.TextColor3 = Color3.new(1, 1, 1); loginButton.TextSize = 18; Instance.new("UICorner", loginButton).CornerRadius = UDim.new(0, 8)
	local trialButton = Instance.new("TextButton", mainFrame); trialButton.Size = UDim2.new(1, 0, 0, 20); trialButton.Position = UDim2.new(0, 0, 1, -20); trialButton.BackgroundTransparency = 1; trialButton.Font = Enum.Font.SourceSans; trialButton.Text = "Tidak punya kunci? Dapatkan Trial"; trialButton.TextColor3 = theme.SubText; trialButton.TextSize = 14
	local statusLabel = Instance.new("TextLabel", mainFrame); statusLabel.Size = UDim2.new(1, -40, 0, 20); statusLabel.Position = UDim2.new(0.5, 0, 1, -5); statusLabel.AnchorPoint = Vector2.new(0.5, 1); statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.SourceSansItalic; statusLabel.Text = ""; statusLabel.TextColor3 = theme.Error; statusLabel.TextSize = 14; statusLabel.Visible = false
	return screenGui, keyBox, loginButton, trialButton, statusLabel
end

-- ▼▼▼ FUNGSI VALIDASI KUNCI YANG SUDAH DIPERBAIKI ▼▼▼
local function validateDynamicKey(userInputKey)
	-- Fungsi untuk encode Base64 (standar dan andal)
	local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
	local function encodeB64(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b64:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end

	local now = os.time()
	local timeBucket = math.floor(now / (DYNAMIC_KEY_CONFIG.VALIDITY_MINUTES * 60))
	
	local potentialBuckets = {timeBucket, timeBucket - 1}
	
	for _, bucket in ipairs(potentialBuckets) do
		local dataToProcess = DYNAMIC_KEY_CONFIG.SECRET_PHRASE .. bucket
		
		-- Metode Baru: Balik urutan string, lalu encode ke Base64
		local reversedData = string.reverse(dataToProcess)
		local encodedData = encodeB64(reversedData)
		
		local expectedKey = "TRIAL-" .. string.upper(string.sub(encodedData, 1, 8))
		
		if string.upper(userInputKey) == expectedKey then
			return true, "Kunci trial valid! Akses diberikan."
		end
	end
	
	return false, "Kunci tidak valid atau telah kedaluwarsa."
end

-- ================== INISIALISASI AWAL ==================
if _G.AccessGranted then
	loadMainScript()
else
	local loginUI, keyBox, loginButton, trialButton, statusLabel = createLoginUI()
	
	trialButton.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(TRIAL_KEY_URL)
			statusLabel.TextColor3 = theme.Accent
			statusLabel.Text = "Link trial telah disalin ke clipboard!"
			statusLabel.Visible = true
		else
			statusLabel.TextColor3 = theme.Error
			statusLabel.Text = "Fungsi clipboard tidak didukung."
			statusLabel.Visible = true
		end
	end)

	loginButton.MouseButton1Click:Connect(function()
		local key = keyBox.Text
		if key == "" then return end

		loginButton.Text = "MEMVALIDASI..."
		task.wait(0.5)
		
		-- Di sini kita tambahkan kunci premium statis sebagai contoh
		if key == "SANS27-PREMIUM" then
			_G.AccessGranted = true
			loginUI:Destroy()
			loadMainScript()
			return
		end

		local isValid, message = validateDynamicKey(key)
		
		loginButton.Text = "AKTIVASI"

		if isValid then
			_G.AccessGranted = true
			loginUI:Destroy()
			loadMainScript()
		else
			statusLabel.TextColor3 = theme.Error
			statusLabel.Text = message
			statusLabel.Visible = true
		end
	end)
end
