-- Optional external load (Solara supports this, but you can remove if needed)
pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/Lololoololoolollolooo/refs/heads/main/Lol"))()
end)

task.wait(2)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Settings
local radius = 100
local attractionStrength = 800
local ringPartsEnabled = false

-- Parts table
local parts = {}

-- Validate part
local function isValidPart(part)
	if not part:IsA("BasePart") then return false end
	if part.Anchored then return false end
	if not part:IsDescendantOf(Workspace) then return false end
	if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
		return false
	end
	return true
end

-- Add part
local function addPart(part)
	if isValidPart(part) and not table.find(parts, part) then
		part.CanCollide = false
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		table.insert(parts, part)
	end
end

-- Remove part
local function removePart(part)
	local i = table.find(parts, part)
	if i then
		table.remove(parts, i)
	end
end

-- Initial scan
for _, obj in ipairs(Workspace:GetDescendants()) do
	addPart(obj)
end

Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

-- Ring logic
RunService.Heartbeat:Connect(function()
	if not ringPartsEnabled then return end

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local center = hrp.Position

	for _, part in ipairs(parts) do
		if part.Parent and not part.Anchored then
			local offset = Vector3.new(
				part.Position.X - center.X,
				0,
				part.Position.Z - center.Z
			)

			if offset.Magnitude < 0.1 then
				offset = Vector3.new(1, 0, 0)
			end

			local targetPos = center + offset.Unit * radius
			targetPos = Vector3.new(targetPos.X, center.Y, targetPos.Z)

			local velocity = (targetPos - part.Position)
			part.Velocity = velocity.Unit * attractionStrength
		end
	end
end)

-- Toggle with R key
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		ringPartsEnabled = not ringPartsEnabled
		warn("Ring Parts:", ringPartsEnabled and "ON" or "OFF")
	end
end)

warn("Solara ring script loaded. Press R to toggle.")

