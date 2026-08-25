local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Perspectives")

local Perspectives = AceAddon:NewAddon("Perspectives", "AceConsole-3.0", "AceEvent-3.0")

Perspectives.working = {}
-- Captured when the dialog opens; never mutated until the next OpenOptions.
Perspectives.initialState = {}

local function CopySettings(src)
	local dest = {}
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end

local defaults = {
	realm = {
		yawSpeed = 30,
		pitchSpeed = 30,
		zoomSpeed = 20,
		maxZoomFactor = 2.6,
		enabled = true,

		cameraBobbing = false,
		cameraTerrainTilt = true,
		cameraPivot = true,
		cameraWaterCollision = true,
		cameraYawSmoothSpeed = 180,
		cameraPitchSmoothSpeed = 45,
	}
}

local options = {
	name = L["Perspectives"],
	handler = Perspectives,
	type = "group",
	args = {
		-- Status text
		statusText = {
			type = "description",
			name = function()
				local text = Perspectives.statusText or L["Waiting for Changes"]
				if text == L["Changes Are Live"] then
					return "|cff00ff00" .. text .. "|r"
				else
					return "|cffffff00" .. text .. "|r"
				end
			end,
			order = 0,
			width = "full",
			fontSize = "medium",
		},

		spacer0 = {
			type = "description",
			name = " ",
			order = 0.5,
			width = "full",
		},

		enabled = {
			type = "toggle",
			name = L["Enable Perspectives"],
			desc = L["Apply the custom camera speeds"],
			order = 1,
			get = "GetWorking",
			set = "SetWorking",
		},

		spacer1 = {
			type = "description",
			name = " ",
			order = 1.5,
			width = "full",
		},

		yawSpeed = {
			type = "range",
			name = L["Yaw Speed (Horizontal)"],
			desc = L["Lower = slower horizontal mouse look. Default game value is ~90-180."],
			min = 5,
			max = 180,
			step = 1,
			order = 2,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},
		pitchSpeed = {
			type = "range",
			name = L["Pitch Speed (Vertical)"],
			desc = L["Lower = slower vertical mouse look."],
			min = 5,
			max = 180,
			step = 1,
			order = 3,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},

		spacer2 = {
			type = "description",
			name = " ",
			order = 3.5,
			width = "full",
		},

		maxZoomFactor = {
			type = "range",
			name = "Max Zoom Factor",
			desc = "Higher = further zoom out.\nClassic: try 3.5 – 4.0\nRetail: max is usually 2.6",
			min = 1.0,
			max = 4.0,
			step = 0.1,
			order = 4,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
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
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},

		spacer3 = {
			type = "description",
			name = " ",
			order = 4.5,
			width = "full",
		},

		cameraYawSmoothSpeed = {
			type = "range",
			name = L["Yaw Smooth Speed"] or "Yaw Smooth Speed",
			desc = L["How quickly the camera smooths horizontally."] or "How quickly the camera smooths horizontally.",
			min = 0,
			max = 270,
			step = 1,
			order = 5,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},
		cameraPitchSmoothSpeed = {
			type = "range",
			name = L["Pitch Smooth Speed"] or "Pitch Smooth Speed",
			desc = L["How quickly the camera smooths vertically."] or "How quickly the camera smooths vertically.",
			min = 0,
			max = 90,
			step = 1,
			order = 5.2,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},

		spacer4 = {
			type = "description",
			name = " ",
			order = 5.5,
			width = "full",
		},

		cameraBobbing = {
			type = "toggle",
			name = L["Camera Bobbing"] or "Camera Bobbing",
			desc = L["Enable head-bob while moving."] or "Enable head-bob while moving.",
			order = 6,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},
		cameraTerrainTilt = {
			type = "toggle",
			name = L["Terrain Tilt"] or "Terrain Tilt",
			desc = L["Camera tilts to follow the terrain."] or "Camera tilts to follow the terrain.",
			order = 6.1,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},
		cameraPivot = {
			type = "toggle",
			name = L["Camera Pivot"] or "Camera Pivot",
			desc = L["Camera stops when it hits the ground."] or "Camera stops when it hits the ground.",
			order = 6.2,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},
		cameraWaterCollision = {
			type = "toggle",
			name = L["Water Collision"] or "Water Collision",
			desc = L["Camera collides with the water surface."] or "Camera collides with the water surface.",
			order = 6.3,
			get = "GetWorking",
			set = "SetWorking",
			disabled = "IsWorkingDisabled",
		},

		row_spacer = {
			type = "description",
			name = "\n\n",
			order = 7,
			width = "full",
		},

		-- Buttons
		defaults = {
			type = "execute",
			name = L["Defaults"] or "Defaults",
			desc = L["Set all values to Blizzard defaults (live)"],
			order = 8,
			func = "Defaults",
			disabled = "IsWorkingDisabled",
		},
		reset = {
			type = "execute",
			name = L["Reset"],
			desc = L["Restore the values that were present when the dialog was opened"],
			order = 9,
			func = "Reset",
			disabled = "IsWorkingDisabled",
		},
		save = {
			type = "execute",
			name = L["Save"],
			desc = L["Save the current values"],
			order = 10,
			func = "Save",
			disabled = "IsSaveDisabled",
		},
		cancel = {
			type = "execute",
			name = L["Cancel"],
			desc = L["Discard changes and close"],
			order = 11,
			func = "Cancel",
		},
	},
}

function Perspectives:OnInitialize()
	self.db = AceDB:New("PerspectivesDB", defaults, true)
	AceConfig:RegisterOptionsTable("Perspectives", options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("Perspectives", L["Perspectives"])

	self:RegisterChatCommand("perspectives", "ChatCommand")
	self:RegisterChatCommand("pvs", "ChatCommand")
end

function Perspectives:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplySettings")
	self:ApplySettings()
end

function Perspectives:OnDisable()
	self:RestoreDefaults()
end

function Perspectives:ChatCommand(input)
	self:OpenOptions()
end

function Perspectives:OpenOptions()
	self.initialState = {
		enabled                = self.db.realm.enabled,
		yawSpeed               = tonumber(GetCVar("cameraYawMoveSpeed")) or 180,
		pitchSpeed             = tonumber(GetCVar("cameraPitchMoveSpeed")) or 90,
		maxZoomFactor          = tonumber(GetCVar("cameraDistanceMaxZoomFactor")) or 1.9,
		zoomSpeed              = tonumber(GetCVar("cameraZoomSpeed")) or 20,
		cameraBobbing          = (tonumber(GetCVar("cameraBobbing")) or 0) == 1,
		cameraTerrainTilt      = (tonumber(GetCVar("cameraTerrainTilt")) or 1) == 1,
		cameraPivot            = (tonumber(GetCVar("cameraPivot")) or 1) == 1,
		cameraWaterCollision   = (tonumber(GetCVar("cameraWaterCollision")) or 1) == 1,
		cameraYawSmoothSpeed   = tonumber(GetCVar("cameraYawSmoothSpeed")) or 180,
		cameraPitchSmoothSpeed = tonumber(GetCVar("cameraPitchSmoothSpeed")) or 45,
	}

	self.working = CopySettings(self.initialState)

	self.statusText = L["Waiting for Changes"]

	if SettingsPanel and SettingsPanel:IsShown() then
		HideUIPanel(SettingsPanel)
	elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
		HideUIPanel(InterfaceOptionsFrame)
	end

	C_Timer.After(0, function()
		local status  = AceConfigDialog:GetStatusTable("Perspectives")
		status.width  = 366
		status.height = 460

		local window  = AceConfigDialog.OpenFrames["Perspectives"]
		if not window or window.type ~= "Window" then
			local AceGUI = LibStub("AceGUI-3.0")
			window = AceGUI:Create("Window")
			window:SetTitle(L["Perspectives"])
			window:SetLayout("Fill")
			window:SetWidth(366)
			window:SetHeight(460)
			window:SetCallback("OnClose", function(widget)
				AceGUI:Release(widget)
				AceConfigDialog.OpenFrames["Perspectives"] = nil
			end)
			AceConfigDialog.OpenFrames["Perspectives"] = window
		end

		AceConfigDialog:Open("Perspectives")
	end)
end

function Perspectives:GetWorking(info)
	return self.working[info[#info]]
end

function Perspectives:SetWorking(info, value)
	local key = info[#info]

	if key == "enabled" then
		self.working.enabled = value

		if value then
			-- Enabling → load database values
			for k, v in pairs(self.db.realm) do
				if k ~= "enabled" then
					self.working[k] = v
				end
			end
			for k, v in pairs(self.working) do
				self:ApplySingle(k, v)
			end
		else
			-- Disabling → apply Blizzard defaults but keep enabled = false
			self:ApplyBlizzardDefaults(false)
		end
	else
		self.working[key] = value
		self:ApplySingle(key, value)
	end

	self:UpdateDialogState()
end

function Perspectives:IsWorkingDisabled()
	return not self.working.enabled
end

function Perspectives:IsSaveDisabled()
	-- Disabled when addon is off OR when working already matches the last save
	return (not self.working.enabled) or (not self:HasUnsavedChanges())
end

function Perspectives:HasUnsavedChanges()
	for k, v in pairs(self.working) do
		if self.db.realm[k] ~= v then
			return true
		end
	end
	return false
end

function Perspectives:UpdateDialogState()
	if self:HasUnsavedChanges() then
		self.statusText = L["Changes Are Live"]
	else
		self.statusText = L["Waiting for Changes"]
	end

	if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["Perspectives"] then
		AceConfigDialog:Open("Perspectives")
	end
end

function Perspectives:ApplySingle(key, value)
	if key == "enabled" then return end

	if key == "yawSpeed" then
		SetCVar("cameraYawMoveSpeed", value)
	elseif key == "pitchSpeed" then
		SetCVar("cameraPitchMoveSpeed", value)
	elseif key == "maxZoomFactor" then
		SetCVar("cameraDistanceMaxZoomFactor", value)
	elseif key == "zoomSpeed" then
		SetCVar("cameraZoomSpeed", value)
	elseif key == "cameraBobbing" then
		SetCVar("cameraBobbing", value and 1 or 0)
	elseif key == "cameraTerrainTilt" then
		SetCVar("cameraTerrainTilt", value and 1 or 0)
	elseif key == "cameraPivot" then
		SetCVar("cameraPivot", value and 1 or 0)
	elseif key == "cameraWaterCollision" then
		SetCVar("cameraWaterCollision", value and 1 or 0)
	elseif key == "cameraYawSmoothSpeed" then
		SetCVar("cameraYawSmoothSpeed", value)
	elseif key == "cameraPitchSmoothSpeed" then
		SetCVar("cameraPitchSmoothSpeed", value)
	end
end

function Perspectives:ApplyBlizzardDefaults(keepEnabled)
	self.working.yawSpeed               = tonumber(GetCVarDefault("cameraYawMoveSpeed")) or 180
	self.working.pitchSpeed             = tonumber(GetCVarDefault("cameraPitchMoveSpeed")) or 90
	self.working.maxZoomFactor          = tonumber(GetCVarDefault("cameraDistanceMaxZoomFactor")) or 1.9
	self.working.zoomSpeed              = tonumber(GetCVarDefault("cameraZoomSpeed")) or 20
	self.working.cameraBobbing          = (tonumber(GetCVarDefault("cameraBobbing")) or 0) == 1
	self.working.cameraTerrainTilt      = (tonumber(GetCVarDefault("cameraTerrainTilt")) or 1) == 1
	self.working.cameraPivot            = (tonumber(GetCVarDefault("cameraPivot")) or 1) == 1
	self.working.cameraWaterCollision   = (tonumber(GetCVarDefault("cameraWaterCollision")) or 1) == 1
	self.working.cameraYawSmoothSpeed   = tonumber(GetCVarDefault("cameraYawSmoothSpeed")) or 180
	self.working.cameraPitchSmoothSpeed = tonumber(GetCVarDefault("cameraPitchSmoothSpeed")) or 45

	if keepEnabled ~= false then
		self.working.enabled = true
	end

	for k, v in pairs(self.working) do
		self:ApplySingle(k, v)
	end
end

function Perspectives:Defaults()
	self:ApplyBlizzardDefaults(true)
	self:UpdateDialogState()
end

function Perspectives:Reset()
	self.working = CopySettings(self.initialState)
	for k, v in pairs(self.working) do
		self:ApplySingle(k, v)
	end
	self:UpdateDialogState()
end

function Perspectives:Save()
	for k, v in pairs(self.working) do
		self.db.realm[k] = v
	end
	self:ApplySettings()
	self:UpdateDialogState()
end

function Perspectives:Cancel()
	for k, v in pairs(self.initialState) do
		self:ApplySingle(k, v)
	end
	self:CloseOptions()
end

function Perspectives:CloseOptions()
	if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["Perspectives"] then
		AceConfigDialog:Close("Perspectives")
	end
end

function Perspectives:ApplySettings()
	if self.db.realm.enabled then
		SetCVar("cameraYawMoveSpeed", self.db.realm.yawSpeed)
		SetCVar("cameraPitchMoveSpeed", self.db.realm.pitchSpeed)
		SetCVar("cameraDistanceMaxZoomFactor", self.db.realm.maxZoomFactor)
		SetCVar("cameraZoomSpeed", self.db.realm.zoomSpeed)
		SetCVar("cameraBobbing", self.db.realm.cameraBobbing and 1 or 0)
		SetCVar("cameraTerrainTilt", self.db.realm.cameraTerrainTilt and 1 or 0)
		SetCVar("cameraPivot", self.db.realm.cameraPivot and 1 or 0)
		SetCVar("cameraWaterCollision", self.db.realm.cameraWaterCollision and 1 or 0)
		SetCVar("cameraYawSmoothSpeed", self.db.realm.cameraYawSmoothSpeed)
		SetCVar("cameraPitchSmoothSpeed", self.db.realm.cameraPitchSmoothSpeed)
	else
		self:RestoreDefaults()
	end
end

function Perspectives:RestoreDefaults()
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
