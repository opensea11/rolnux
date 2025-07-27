local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Flying = false
local CarriedPlayer = nil
local CarryWeld = nil
local Speed = 60
local BodyGyro = nil
local BodyVelocity = nil

local CarryUI -- referensi global biar bisa di-update
local MainFrame

-- FLY
local function StartFlying()
	if not BodyGyro then
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.P = 9e4
		BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BodyGyro.CFrame = workspace.CurrentCamera.CFrame
		BodyGyro.Parent = HumanoidRootPart
	end
	if not BodyVelocity then
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		BodyVelocity.Parent = HumanoidRootPart
	end
end

local function StopFlying()
	if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
	if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
end

-- CARRY FUNCTION
local function carryPlayerByName(name)
	local target = Players:FindFirstChild(name)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		if CarryWeld then CarryWeld:Destroy(); CarryWeld = nil; CarriedPlayer = nil end
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		CarryWeld = Instance.new("WeldConstraint")
		CarryWeld.Part0 = targetRoot
		CarryWeld.Part1 = HumanoidRootPart
		CarryWeld.Parent = targetRoot
		CarriedPlayer = target
	end
end

local function CarryNearestPlayer()
	if CarryWeld then CarryWeld:Destroy(); CarryWeld = nil; CarriedPlayer = nil return end
	local closestDistance = 10
	local closestPlayer = nil
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
			if dist < closestDistance then
				closestDistance = dist
				closestPlayer = otherPlayer
			end
		end
	end
	if closestPlayer then carryPlayerByName(closestPlayer.Name) end
end

-- GUI BUILDER
local function buildCarryGUI()
	if CarryUI then CarryUI:Destroy() end

	CarryUI = Instance.new("ScreenGui")
	CarryUI.Name = "CarryUI"
	CarryUI.Parent = CoreGui
	CarryUI.ResetOnSpawn = false

	MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 200, 0, 150)
	MainFrame.Position = UDim2.new(0.5, -100, 0.8, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	MainFrame.BackgroundTransparency = 0.3
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = CarryUI

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = MainFrame
end

local function refreshCarryList()
	if not MainFrame then return end
	for _, child in pairs(MainFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= Player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 25)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Text = p.Name .. " [Carry]"
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.Parent = MainFrame

			btn.MouseButton1Click:Connect(function()
				carryPlayerByName(p.Name)
			end)
		end
	end
end

-- AUTO REFRESH GUI
Players.PlayerAdded:Connect(refreshCarryList)
Players.PlayerRemoving:Connect(refreshCarryList)

-- INPUT CONTROL
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		Flying = not Flying
		if Flying then StartFlying() else StopFlying() end
	elseif input.KeyCode == Enum.KeyCode.R then
		CarryNearestPlayer()
	end
end)

-- FLY MOTION
RunService.RenderStepped:Connect(function()
	if Flying and BodyVelocity and BodyGyro then
		local cam = workspace.CurrentCamera
		local moveVec = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end

		BodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * Speed or Vector3.zero
		BodyGyro.CFrame = cam.CFrame
	end
end)

-- INIT GUI
buildCarryGUI()
refreshCarryList()
