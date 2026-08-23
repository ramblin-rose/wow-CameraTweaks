-- LocaleForce.lua
-- Must be the FIRST file in the TOC
-- this code is for verifying locale support. do not use this feature as a user.

local function ApplyForcedLocale()
    local db = rawget(_G, "CameraTweaksLocaleDB")
    if type(db) == "table" and db.locale and db.locale ~= "" then
        GAME_LOCALE = db.locale
        return db.locale
    end
    return nil
end

local forced = ApplyForcedLocale()

if forced then
    print("|cff00ff00CameraTweaks:|r Locale forced to |cffffff00" .. forced .. "|r")
else
    -- SavedVariables not ready yet – apply on next frame and reload once
    C_Timer.After(0, function()
        local locale = ApplyForcedLocale()
        if locale then
            print("|cff00ff00CameraTweaks:|r Locale applied (" .. locale .. "). Reloading UI to activate...")
            C_Timer.After(0.2, ReloadUI)
        end
    end)
end