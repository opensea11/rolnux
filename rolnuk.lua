local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 100
local bodyGyro
local bodyVelocity

-- Fungsi untuk mulai terbang
local function startFlying()
 flying = true

 bodyGyro = Instance.new("BodyGyro")
 bodyGyro.P = 9e4
 bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
 bodyGyro.CFrame = humanoidRootPart.CFrame
 bodyGyro.Parent = humanoidRootPart

 bodyVelocity = Instance.new("BodyVelocity")
 bodyVelocity.Velocity = Vector3.new(0, 0, 0)
 bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
 bodyVelocity.Parent = humanoidRootPart
end

-- Fungsi untuk berhenti terbang
local function stopFlying()
 flying = false
 if bodyGyro then bodyGyro:Destroy() end
 if bodyVelocity then bodyVelocity:Destroy() end
end

-- Fungsi toggle
local function toggleFly()
 if flying then
  stopFlying()
  flyButton.Text = "Fly"
 else
  startFlying()
  flyButton.Text = "Unfly"
 end
end

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 100, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 20)
flyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Text = "Fly"
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 20
flyButton.Parent = screenGui
flyButton.AutoButtonColor = true

-- Klik tombol
flyButton.MouseButton1Click:Connect(toggleFly)

-- Update posisi saat terbang
RunService.RenderStepped:Connect(function()
 if flying and bodyVelocity and bodyGyro then
  local cam = workspace.CurrentCamera
  local moveDirection = Vector3.new()

  if UIS:IsKeyDown(Enum.KeyCode.W) then
   moveDirection = moveDirection + cam.CFrame.LookVector
  end
  if UIS:IsKeyDown(Enum.KeyCode.S) then
   moveDirection = moveDirection - cam.CFrame.LookVector
  end
  if UIS:IsKeyDown(Enum.KeyCode.A) then
   moveDirection = moveDirection - cam.CFrame.RightVector
  end
  if UIS:IsKeyDown(Enum.KeyCode.D) then
   moveDirection = moveDirection + cam.CFrame.RightVector
  end
  if UIS:IsKeyDown(Enum.KeyCode.Space) then
   moveDirection = moveDirection + Vector3.new(0, 1, 0)
  end
  if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
   moveDirection = moveDirection - Vector3.new(0, 1, 0)
  end

  if moveDirection.Magnitude > 0 then
   bodyVelocity.Velocity = moveDirection.Unit * speed
  else
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
  end

  bodyGyro.CFrame = cam.CFrame
 end
end)

print("Fly GUI Loaded for", player.Name)
