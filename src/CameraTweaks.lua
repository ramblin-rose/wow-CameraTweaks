local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CameraTweaks")

local CameraTweaks = AceAddon:NewAddon("CameraTweaks", "AceConsole-3.0", "AceEvent-3.0")

-- track config value changes
CameraTweaks.dirty = false

function CameraTweaks:IsApplyDisabled()
	return (not self.db.realm.enabled) or (not self.dirty)
end

function CameraTweaks:MarkDirty()
	self.dirty = true
end

function CameraTweaks:IsDisabled()
	return not self.db.realm.enabled
end

local defaults = {
	realm = {
		yawSpeed = 30,
		pitchSpeed = 30,
		zoomSpeed = 20,
		maxZoomFactor = 2.6,
		enabled = true,

		-- New universal options
		cameraBobbing = false,
		cameraTerrainTilt = true,
		cameraPivot = true,
		cameraWaterCollision = true,
		cameraYawSmoothSpeed = 180,
		cameraPitchSmoothSpeed = 45,
	}
}

local options = {
	name = L["Camera Tweaks"],
	handler = CameraTweaks,
	type = "group",
	args = {
		-- Row 1: Enable alone
		enabled = {
			type = "toggle",
			name = L["Enable Camera Tweaks"],
			desc = L["Apply the custom camera speeds"],
			order = 1,
			get = "GetEnabled",
			set = "SetEnabled",
		},

		spacer1 = {
			type = "description",
			name = " ",
			order = 1.5,
			width = "full",
		},

		-- Row 2: Yaw + Pitch
		yawSpeed = {
			type = "range",
			name = L["Yaw Speed (Horizontal)"],
			desc = L["Lower = slower horizontal mouse look. Default game value is ~90-180."],
			min = 5,
			max = 180,
			step = 1,
			order = 2,
			get = "GetYawSpeed",
			set = "SetYawSpeed",
			disabled = "IsDisabled",
		},
		pitchSpeed = {
			type = "range",
			name = L["Pitch Speed (Vertical)"],
			desc = L["Lower = slower vertical mouse look."],
			min = 5,
			max = 180,
			step = 1,
			order = 3,
			get = "GetPitchSpeed",
			set = "SetPitchSpeed",
			disabled = "IsDisabled",
		},

		spacer2 = {
			type = "description",
			name = " ",
			order = 3.5,
			width = "full",
		},

		-- Row 3: Max Zoom + Zoom Speed
		maxZoomFactor = {
			type = "range",
			name = "Max Zoom Factor",
			desc = "Higher = further zoom out.\nClassic: try 3.5 – 4.0\nRetail: max is usually 2.6",
			min = 1.0,
			max = 4.0,
			step = 0.1,
			order = 4,
			get = function() return CameraTweaks.db.realm.maxZoomFactor end,
			set = function(_, value)
				CameraTweaks.db.realm.maxZoomFactor = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		zoomSpeed = {
			type = "range",
			name = L["Zoom Speed"] or "Zoom Speed",
			desc = L["How fast the mouse wheel zooms in and out. Default is usually 20."] or
				"How fast the mouse wheel zooms in and out. Default is usually 20.",
			min = 1,
			max = 50,
			step = 1,
			order = 4.2,
			get = "GetZoomSpeed",
			set = "SetZoomSpeed",
			disabled = "IsDisabled",
		},

		spacer3 = {
			type = "description",
			name = " ",
			order = 4.5,
			width = "full",
		},

		-- Row 4: Smooth speeds
		cameraYawSmoothSpeed = {
			type = "range",
			name = L["Yaw Smooth Speed"] or "Yaw Smooth Speed",
			desc = L["How quickly the camera smooths horizontally."] or "How quickly the camera smooths horizontally.",
			min = 0,
			max = 270,
			step = 1,
			order = 5,
			get = function() return CameraTweaks.db.realm.cameraYawSmoothSpeed end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraYawSmoothSpeed = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraPitchSmoothSpeed = {
			type = "range",
			name = L["Pitch Smooth Speed"] or "Pitch Smooth Speed",
			desc = L["How quickly the camera smooths vertically."] or "How quickly the camera smooths vertically.",
			min = 0,
			max = 90,
			step = 1,
			order = 5.2,
			get = function() return CameraTweaks.db.realm.cameraPitchSmoothSpeed end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraPitchSmoothSpeed = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},

		spacer4 = {
			type = "description",
			name = " ",
			order = 5.5,
			width = "full",
		},

		-- Row 5: Toggles
		cameraBobbing = {
			type = "toggle",
			name = L["Camera Bobbing"] or "Camera Bobbing",
			desc = L["Enable head-bob while moving."] or "Enable head-bob while moving.",
			order = 6,
			get = function() return CameraTweaks.db.realm.cameraBobbing end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraBobbing = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraTerrainTilt = {
			type = "toggle",
			name = L["Terrain Tilt"] or "Terrain Tilt",
			desc = L["Camera tilts to follow the terrain."] or "Camera tilts to follow the terrain.",
			order = 6.1,
			get = function() return CameraTweaks.db.realm.cameraTerrainTilt end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraTerrainTilt = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraPivot = {
			type = "toggle",
			name = L["Camera Pivot"] or "Camera Pivot",
			desc = L["Camera stops when it hits the ground."] or "Camera stops when it hits the ground.",
			order = 6.2,
			get = function() return CameraTweaks.db.realm.cameraPivot end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraPivot = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraWaterCollision = {
			type = "toggle",
			name = L["Water Collision"] or "Water Collision",
			desc = L["Camera collides with the water surface."] or "Camera collides with the water surface.",
			order = 6.3,
			get = function() return CameraTweaks.db.realm.cameraWaterCollision end,
			set = function(_, value)
				CameraTweaks.db.realm.cameraWaterCollision = value
				CameraTweaks:MarkDirty()
			end,
			disabled = "IsDisabled",
		},

		-- Extra vertical space before the buttons
		row_spacer = {
			type = "description",
			name = "\n\n",
			order = 7,
			width = "full",
		},

		apply = {
			type = "execute",
			name = L["Apply Now"],
			desc = L["Apply the current values immediately"],
			order = 8,
			func = "ApplySettings",
			disabled = "IsApplyDisabled",
		},
		defaults = {
			type = "execute",
			name = L["Defaults"] or "Defaults",
			desc = L["Reset to standard Blizzard camera values"] or "Reset to standard Blizzard camera values",
			order = 9,
			func = "ResetToDefaults",
			disabled = "IsDisabled",
		},
	},
}

function CameraTweaks:OnInitialize()
	self.db = AceDB:New("CameraTweaksDB", defaults, true)
	AceConfig:RegisterOptionsTable("CameraTweaks", options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("CameraTweaks", L["Camera Tweaks"])

	self:RegisterChatCommand("camera", "ChatCommand")
	self:RegisterChatCommand("cam", "ChatCommand")
end

function CameraTweaks:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplySettings")
	self:ApplySettings()
end

function CameraTweaks:OnDisable()
	self:RestoreDefaults()
end

function CameraTweaks:ChatCommand(input)
	input = input and input:trim() or ""

	if input == "" then
		self:OpenOptions()
		return
	end

	local command, arg = input:match("^(%S+)%s*(.*)$")
	command = command and command:lower() or ""

	if command == "stub" then
	else
		self:OpenOptions()
	end
end

function CameraTweaks:OpenOptions()
	-- Close the Blizzard Options/Settings panel if it is open
	if SettingsPanel and SettingsPanel:IsShown() then
		HideUIPanel(SettingsPanel)
	elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
		HideUIPanel(InterfaceOptionsFrame)
	end
	-- defer showing the Camera dialog in case the SettingsPanel was open
	C_Timer.After(0, function()
		local status  = AceConfigDialog:GetStatusTable("CameraTweaks")
		status.width  = 370
		status.height = 420

		local window  = AceConfigDialog.OpenFrames["CameraTweaks"]
		if not window or window.type ~= "Window" then
			local AceGUI = LibStub("AceGUI-3.0")
			window = AceGUI:Create("Window")
			window:SetTitle(L["Camera Tweaks"])
			window:SetLayout("Fill")
			window:SetWidth(520)
			window:SetHeight(420)
			window:SetCallback("OnClose", function(widget)
				AceGUI:Release(widget)
				AceConfigDialog.OpenFrames["CameraTweaks"] = nil
			end)
			AceConfigDialog.OpenFrames["CameraTweaks"] = window
		end

		AceConfigDialog:Open("CameraTweaks")
	end)
end

function CameraTweaks:GetEnabled(info)
	return self.db.realm.enabled
end

function CameraTweaks:SetEnabled(info, value)
	self.db.realm.enabled = value
	self:ApplySettings()

	if value then
		self:Notify(L["Camera addon enabled – custom values applied"])
	else
		self:Notify(L["Camera addon disabled – Blizzard defaults restored"])
	end
end

function CameraTweaks:Notify(msg)
	UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 0.0)
	self:Print(msg)
end

function CameraTweaks:GetYawSpeed(info)
	return self.db.realm.yawSpeed
end

function CameraTweaks:SetYawSpeed(info, value)
	self.db.realm.yawSpeed = value
	self:MarkDirty()
end

function CameraTweaks:GetPitchSpeed(info)
	return self.db.realm.pitchSpeed
end

function CameraTweaks:SetPitchSpeed(info, value)
	self.db.realm.pitchSpeed = value
	self:MarkDirty()
end

function CameraTweaks:GetZoomSpeed(info)
	return self.db.realm.zoomSpeed
end

function CameraTweaks:SetZoomSpeed(info, value)
	self.db.realm.zoomSpeed = value
	self:MarkDirty()
end

function CameraTweaks:ApplySettings()
	if self.db.realm.enabled then
		SetCVar("cameraYawMoveSpeed", self.db.realm.yawSpeed)
		SetCVar("cameraPitchMoveSpeed", self.db.realm.pitchSpeed)
		SetCVar("cameraDistanceMaxZoomFactor", self.db.realm.maxZoomFactor)
		SetCVar("cameraZoomSpeed", self.db.realm.zoomSpeed)

		-- New options
		SetCVar("cameraBobbing", self.db.realm.cameraBobbing and 1 or 0)
		SetCVar("cameraTerrainTilt", self.db.realm.cameraTerrainTilt and 1 or 0)
		SetCVar("cameraPivot", self.db.realm.cameraPivot and 1 or 0)
		SetCVar("cameraWaterCollision", self.db.realm.cameraWaterCollision and 1 or 0)
		SetCVar("cameraYawSmoothSpeed", self.db.realm.cameraYawSmoothSpeed)
		SetCVar("cameraPitchSmoothSpeed", self.db.realm.cameraPitchSmoothSpeed)
	else
		self:RestoreDefaults()
	end

	self.dirty = false
end

function CameraTweaks:RestoreDefaults()
	SetCVar("cameraYawMoveSpeed", GetCVarDefault("cameraYawMoveSpeed") or 180)
	SetCVar("cameraPitchMoveSpeed", GetCVarDefault("cameraPitchMoveSpeed") or 90)
	SetCVar("cameraDistanceMaxZoomFactor", GetCVarDefault("cameraDistanceMaxZoomFactor") or 1.9)
	SetCVar("cameraZoomSpeed", GetCVarDefault("cameraZoomSpeed") or 20)

	SetCVar("cameraBobbing", GetCVarDefault("cameraBobbing") or 0)
	SetCVar("cameraTerrainTilt", GetCVarDefault("cameraTerrainTilt") or 1)
	SetCVar("cameraPivot", GetCVarDefault("cameraPivot") or 1)
	SetCVar("cameraWaterCollision", GetCVarDefault("cameraWaterCollision") or 1)
	SetCVar("cameraYawSmoothSpeed", GetCVarDefault("cameraYawSmoothSpeed") or 180)
	SetCVar("cameraPitchSmoothSpeed", GetCVarDefault("cameraPitchSmoothSpeed") or 45)
end

function CameraTweaks:ResetToDefaults()
	self.db.realm.yawSpeed               = tonumber(GetCVarDefault("cameraYawMoveSpeed")) or 180
	self.db.realm.pitchSpeed             = tonumber(GetCVarDefault("cameraPitchMoveSpeed")) or 90
	self.db.realm.maxZoomFactor          = tonumber(GetCVarDefault("cameraDistanceMaxZoomFactor")) or 1.9
	self.db.realm.zoomSpeed              = tonumber(GetCVarDefault("cameraZoomSpeed")) or 20

	self.db.realm.cameraBobbing          = (tonumber(GetCVarDefault("cameraBobbing")) or 0) == 1
	self.db.realm.cameraTerrainTilt      = (tonumber(GetCVarDefault("cameraTerrainTilt")) or 1) == 1
	self.db.realm.cameraPivot            = (tonumber(GetCVarDefault("cameraPivot")) or 1) == 1
	self.db.realm.cameraWaterCollision   = (tonumber(GetCVarDefault("cameraWaterCollision")) or 1) == 1
	self.db.realm.cameraYawSmoothSpeed   = tonumber(GetCVarDefault("cameraYawSmoothSpeed")) or 180
	self.db.realm.cameraPitchSmoothSpeed = tonumber(GetCVarDefault("cameraPitchSmoothSpeed")) or 45

	self.db.realm.enabled                = true
	self:ApplySettings()

	-- Only re-open the standalone window if the user already has it open
	if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["CameraTweaks"] then
		AceConfigDialog:Open("CameraTweaks")
	end
end
