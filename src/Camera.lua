local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Camera")

local Camera = AceAddon:NewAddon("Camera", "AceConsole-3.0", "AceEvent-3.0")

-- track config value changes
Camera.dirty = false

function Camera:IsApplyDisabled()
	return (not self.db.profile.enabled) or (not self.dirty)
end

function Camera:MarkDirty()
	self.dirty = true
end

function Camera:IsDisabled()
	return not self.db.profile.enabled
end

local defaults = {
	profile = {
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
	name = L["Camera"],
	handler = Camera,
	type = "group",
	args = {
		-- Row 1: Enable alone
		enabled = {
			type = "toggle",
			name = L["Enable Camera"],
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
			get = function() return Camera.db.profile.maxZoomFactor end,
			set = function(_, value)
				Camera.db.profile.maxZoomFactor = value
				Camera:MarkDirty()
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
			get = function() return Camera.db.profile.cameraYawSmoothSpeed end,
			set = function(_, value)
				Camera.db.profile.cameraYawSmoothSpeed = value
				Camera:MarkDirty()
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
			get = function() return Camera.db.profile.cameraPitchSmoothSpeed end,
			set = function(_, value)
				Camera.db.profile.cameraPitchSmoothSpeed = value
				Camera:MarkDirty()
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
			get = function() return Camera.db.profile.cameraBobbing end,
			set = function(_, value)
				Camera.db.profile.cameraBobbing = value
				Camera:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraTerrainTilt = {
			type = "toggle",
			name = L["Terrain Tilt"] or "Terrain Tilt",
			desc = L["Camera tilts to follow the terrain."] or "Camera tilts to follow the terrain.",
			order = 6.1,
			get = function() return Camera.db.profile.cameraTerrainTilt end,
			set = function(_, value)
				Camera.db.profile.cameraTerrainTilt = value
				Camera:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraPivot = {
			type = "toggle",
			name = L["Camera Pivot"] or "Camera Pivot",
			desc = L["Camera stops when it hits the ground."] or "Camera stops when it hits the ground.",
			order = 6.2,
			get = function() return Camera.db.profile.cameraPivot end,
			set = function(_, value)
				Camera.db.profile.cameraPivot = value
				Camera:MarkDirty()
			end,
			disabled = "IsDisabled",
		},
		cameraWaterCollision = {
			type = "toggle",
			name = L["Water Collision"] or "Water Collision",
			desc = L["Camera collides with the water surface."] or "Camera collides with the water surface.",
			order = 6.3,
			get = function() return Camera.db.profile.cameraWaterCollision end,
			set = function(_, value)
				Camera.db.profile.cameraWaterCollision = value
				Camera:MarkDirty()
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
			func = "ApplySpeeds",
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

function Camera:OnInitialize()
	self.db = AceDB:New("CameraDB", defaults, true)
	AceConfig:RegisterOptionsTable("Camera", options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("Camera", L["Camera"])

	self:RegisterChatCommand("camera", "OpenOptions")
	self:RegisterChatCommand("cam", "OpenOptions")
end

function Camera:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplySpeeds")
	self:ApplySpeeds()
end

function Camera:OnDisable()
	self:RestoreDefaults()
end

function Camera:OpenOptions()
	-- Close the Blizzard Options/Settings panel if it is open
	if SettingsPanel and SettingsPanel:IsShown() then
		HideUIPanel(SettingsPanel)
	elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
		HideUIPanel(InterfaceOptionsFrame)
	end
	-- defer showing the Camera dialog in case the SettingsPanel was open
	C_Timer.After(0, function()
		local status  = AceConfigDialog:GetStatusTable("Camera")
		status.width  = 370
		status.height = 420

		local window  = AceConfigDialog.OpenFrames["Camera"]
		if not window or window.type ~= "Window" then
			local AceGUI = LibStub("AceGUI-3.0")
			window = AceGUI:Create("Window")
			window:SetTitle(L["Camera"])
			window:SetLayout("Fill")
			window:SetWidth(520)
			window:SetHeight(420)
			window:SetCallback("OnClose", function(widget)
				AceGUI:Release(widget)
				AceConfigDialog.OpenFrames["Camera"] = nil
			end)
			AceConfigDialog.OpenFrames["Camera"] = window
		end

		AceConfigDialog:Open("Camera")
	end)
end

function Camera:GetEnabled(info)
	return self.db.profile.enabled
end

function Camera:SetEnabled(info, value)
	self.db.profile.enabled = value
	self:ApplySpeeds()

	if value then
		self:Notify(L["Camera addon enabled – custom values applied"])
	else
		self:Notify(L["Camera addon disabled – Blizzard defaults restored"])
	end
end

function Camera:Notify(msg)
	UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 0.0)
	self:Print(msg)
end

function Camera:GetYawSpeed(info)
	return self.db.profile.yawSpeed
end

function Camera:SetYawSpeed(info, value)
	self.db.profile.yawSpeed = value
	self:MarkDirty()
end

function Camera:GetPitchSpeed(info)
	return self.db.profile.pitchSpeed
end

function Camera:SetPitchSpeed(info, value)
	self.db.profile.pitchSpeed = value
	self:MarkDirty()
end

function Camera:GetZoomSpeed(info)
	return self.db.profile.zoomSpeed
end

function Camera:SetZoomSpeed(info, value)
	self.db.profile.zoomSpeed = value
	self:MarkDirty()
end

function Camera:ApplySpeeds()
	if self.db.profile.enabled then
		SetCVar("cameraYawMoveSpeed", self.db.profile.yawSpeed)
		SetCVar("cameraPitchMoveSpeed", self.db.profile.pitchSpeed)
		SetCVar("cameraDistanceMaxZoomFactor", self.db.profile.maxZoomFactor)
		SetCVar("cameraZoomSpeed", self.db.profile.zoomSpeed)

		-- New options
		SetCVar("cameraBobbing", self.db.profile.cameraBobbing and 1 or 0)
		SetCVar("cameraTerrainTilt", self.db.profile.cameraTerrainTilt and 1 or 0)
		SetCVar("cameraPivot", self.db.profile.cameraPivot and 1 or 0)
		SetCVar("cameraWaterCollision", self.db.profile.cameraWaterCollision and 1 or 0)
		SetCVar("cameraYawSmoothSpeed", self.db.profile.cameraYawSmoothSpeed)
		SetCVar("cameraPitchSmoothSpeed", self.db.profile.cameraPitchSmoothSpeed)
	else
		self:RestoreDefaults()
	end

	self.dirty = false
end

function Camera:RestoreDefaults()
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

function Camera:ResetToDefaults()
	self.db.profile.yawSpeed               = tonumber(GetCVarDefault("cameraYawMoveSpeed")) or 180
	self.db.profile.pitchSpeed             = tonumber(GetCVarDefault("cameraPitchMoveSpeed")) or 90
	self.db.profile.maxZoomFactor          = tonumber(GetCVarDefault("cameraDistanceMaxZoomFactor")) or 1.9
	self.db.profile.zoomSpeed              = tonumber(GetCVarDefault("cameraZoomSpeed")) or 20

	self.db.profile.cameraBobbing          = (tonumber(GetCVarDefault("cameraBobbing")) or 0) == 1
	self.db.profile.cameraTerrainTilt      = (tonumber(GetCVarDefault("cameraTerrainTilt")) or 1) == 1
	self.db.profile.cameraPivot            = (tonumber(GetCVarDefault("cameraPivot")) or 1) == 1
	self.db.profile.cameraWaterCollision   = (tonumber(GetCVarDefault("cameraWaterCollision")) or 1) == 1
	self.db.profile.cameraYawSmoothSpeed   = tonumber(GetCVarDefault("cameraYawSmoothSpeed")) or 180
	self.db.profile.cameraPitchSmoothSpeed = tonumber(GetCVarDefault("cameraPitchSmoothSpeed")) or 45

	self.db.profile.enabled                = true
	self:ApplySpeeds()

	-- Only re-open the standalone window if the user already has it open
	if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["Camera"] then
		AceConfigDialog:Open("Camera")
	end
end
