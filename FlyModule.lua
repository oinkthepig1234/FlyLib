local FlyModule = {
	FlyMethods = {"CFrame", "Velocity", "BodyMovers"},
	Keybinds = {
		[Enum.KeyCode.W] = "+Z",
		[Enum.KeyCode.S] = "-Z",
		[Enum.KeyCode.A] = "-X",
		[Enum.KeyCode.D] = "+X",
		[Enum.KeyCode.Q] = "-Y",
		[Enum.KeyCode.E] = "+Y"
	},
	Settings = {
		Speed = 15,
		VerticalSpeed = 15
	}
}

local RSettings = {
	FlyMethod = "CFrame",
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

setmetatable(FlyModule.Settings, {
	__index = RSettings,
	__newindex = function(self, i, v)
		if v == "BodyMovers" then
			RSettings[i] = v
			if not LP.Character then
				LP.CharacterAdded:Wait()
			end
			if not LP.Character:FindFirstChild("HumanoidRootPart") then
				repeat local c = LP.Character.ChildAdded:Wait() until c.Name == "HumanoidRootPart"
			end
			if LP.Character.HumanoidRootPart:FindFirstChild("OFlyVelocity") then
				return
			end
			if RSettings[i] ~= v then
				return
			end
			local BM = Instance.new("LinearVelocity", LP.Character.HumanoidRootPart)
			BM.Enabled = false
			BM.Attachment0 = LP.Character.HumanoidRootPart.RootAttachment
			BM.ForceLimitsEnabled = false
			BM.Name = "OFlyVelocity"
			return
		end
		if RSettings[i] == "BodyMovers" then
			RSettings[i] = v
			if not LP.Character then
				return
			end
			if not LP.Character:FindFirstChild("HumanoidRootPart") then
				return
			end
			for i,v in pairs(RSettings) do
				if v == "BodyMovers" then
					return
				end
			end
			if LP.Character.HumanoidRootPart:FindFirstChild("OFlyVelocity") then
				LP.Character.HumanoidRootPart.OFlyVelocity:Destroy()
			end
			return
		end
		if not table.find(FlyModule, i .. "s") then
			warn("Not a Writable Index")
			return
		end
		if not table.find(FlyModule[i .. "s"], v) then
			warn("Not a Valid " .. i)
			return
		end
		RSettings[i] = v
	end,
})

if FlyModule.Settings.FlyMethod == "BodyMovers" then
	print("hi")
	if not LP.Character then
		LP.CharacterAdded:Wait()
	end
	print("hi3")
	if not LP.Character:FindFirstChild("HumanoidRootPart") then
		repeat local c = LP.Character.ChildAdded:Wait() print("hi2") until c.Name == "HumanoidRootPart"
	end
	if LP.Character.HumanoidRootPart:FindFirstChild("OFlyVelocity") then
		return
	end
	local BM = Instance.new("LinearVelocity", LP.Character.HumanoidRootPart)
	BM.Enabled = false
	BM.Attachment0 = LP.Character.HumanoidRootPart.RootAttachment
	BM.ForceLimitsEnabled = false
	BM.Name = "OFlyVelocity"
end

local Connections = {}

function FlyModule:Fly(Toggle:boolean)
	for i,v in pairs(Connections) do
		v:Disconnect()
		Connections[i] = nil
	end

	if not Toggle then
		return
	end

	local Movement = {X = 0, Y = 0, Z = 0}
	local KBP = {}

	for i,v in pairs(FlyModule.Keybinds) do
		if not UserInputService:IsKeyDown(i) then

		end
		table.insert(KBP, i)
		local MD = string.sub(v, 1, 1)
		local MV = string.sub(v, 2, 2)
		if MD == "+" then
			Movement[MV] += 1
		else
			Movement[MV] -= 1
		end
	end

	table.insert(Connections, UserInputService.InputBegan:Connect(function(i, g)
		if g then
			return
		end
		local m = FlyModule.Keybinds[i.KeyCode]
		if not m then
			return
		end
		table.insert(KBP, i.KeyCode)
		local MD = string.sub(m, 1, 1)
		local MV = string.sub(m, 2, 2)
		if MD == "+" then
			Movement[MV] += 1
		else
			Movement[MV] -= 1
		end
	end))

	table.insert(Connections, UserInputService.InputEnded:Connect(function(i, g)
		local m = FlyModule.Keybinds[i.KeyCode]
		if not m then
			return
		end
		if not table.find(KBP, i.KeyCode) then
			return
		end
		table.remove(KBP, table.find(KBP, i.KeyCode))
		local MD = string.sub(m, 1, 1)
		local MV = string.sub(m, 2, 2)
		if MD == "-" then
			Movement[MV] += 1
		else
			Movement[MV] -= 1
		end
	end))
	local YL

	table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
		if not LP.Character then
			return
		end
		if not LP.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local camCF = workspace.CurrentCamera.CFrame
		local AMovement = {}
		if Movement.X ~= 0 and Movement.Z ~= 0 then
			AMovement.X = Movement.X * math.sqrt(0.5)
			AMovement.Z = Movement.Z * math.sqrt(0.5)
		end

		local AV = Vector3.new(
			((AMovement.X or Movement.X) * camCF.RightVector.X + (AMovement.Z or Movement.Z) * camCF.LookVector.X) * FlyModule.Settings.Speed,
			Movement.Y * FlyModule.Settings.VerticalSpeed,
			((AMovement.X or Movement.X) * camCF.RightVector.Z + (AMovement.Z or Movement.Z) * camCF.LookVector.Z) * FlyModule.Settings.Speed
		)

		if FlyModule.Settings.FlyMethod == "BodyMovers" then
			local BM = LP.Character.HumanoidRootPart:WaitForChild("OFlyVelocity")
			if BM.Enabled == false then
				BM.Enabled = true
			end
			BM.VectorVelocity = AV
			return
		end

		if FlyModule.Settings.FlyMethod == "Velocity" then
			LP.Character.HumanoidRootPart.AssemblyLinearVelocity = AV + Vector3.new(0, workspace.Gravity / 100, 0)
			return
		end
		
		if not YL then
			YL = LP.Character.HumanoidRootPart.Position.Y
		end
		
		YL = YL + (Movement.Y * FlyModule.Settings.VerticalSpeed * dt)
		
		LP.Character.HumanoidRootPart.Velocity *= Vector3.new(1, 0, 1)
		LP.Character.HumanoidRootPart.CFrame += AV / 60 + Vector3.new(0, YL - LP.Character.HumanoidRootPart.Position.Y, 0)
	end))
end

return FlyModule
