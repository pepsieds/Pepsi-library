-- ============================================================
--  ARMOR AUTH  |  Host this file on GitHub Raw / Pastebin
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local player      = Players.LocalPlayer

local SUPABASE_URL      = "https://qnftmkqrdegojzfjxdbi.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFuZnRta3FyZGVnb2p6Zmp4ZGJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxMzExNDgsImV4cCI6MjA5NDcwNzE0OH0.KkKGbvfdSYWKh_EgSrbeQ9Ccul8_xxNTfa1xIjn0sTM"

-- Read the key the user set before calling loadstring
local key = getgenv().script_key

if not key or key == "" or key == "YOUR_KEY_HERE" then
    error("[Armor] No key provided. Set script_key before loading.")
    return
end

key = key:gsub("%s+", ""):upper()

-- HWID fingerprint
local function getHWID()
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and id and id ~= "" then return id end
    return "UID-" .. tostring(player.UserId)
end

local hwid = getHWID()

-- HTTP request using executor's request() function
local function req(method, endpoint, body)
    local ok, res = pcall(function()
        return request({
            Url    = SUPABASE_URL .. "/rest/v1/" .. endpoint,
            Method = method,
            Headers = {
                ["apikey"]        = SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
                ["Content-Type"]  = "application/json",
                ["Prefer"]        = "return=minimal",
            },
            Body = body and HttpService:JSONEncode(body) or nil,
        })
    end)

    if not ok then return nil end
    if not res or res.StatusCode < 200 or res.StatusCode >= 300 then return nil end

    if res.Body and res.Body ~= "" then
        local decoded = HttpService:JSONDecode(res.Body)
        return decoded
    end

    return true -- PATCH returns empty body
end

local data = req("GET", "keys?key=eq." .. key .. "&select=key,status,hwid")

if not data or #data == 0 then
    error("[Armor] Invalid key.")
    return
end

local row = data[1]

if row.status == "revoked" then
    error("[Armor] Your key has been revoked.")
    return
end

if row.status ~= "active" then
    error("[Armor] Key not activated. Redeem it in Discord first.")
    return
end

if row.hwid == nil or row.hwid == HttpService.JSONNull then
    -- First use — lock HWID
    req("PATCH", "keys?key=eq." .. key, {
        hwid      = hwid,
        last_seen = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
    print("[Armor] Key locked to this device. Welcome!")
elseif row.hwid ~= hwid then
    error("[Armor] HWID mismatch. Reset your HWID in the Discord panel.")
    return
else
    -- Update last seen
    req("PATCH", "keys?key=eq." .. key, {
        last_seen = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
end

print("[Armor] Authenticated! Loading script...")

-- ============================================================
--  YOUR ACTUAL SCRIPT BELOW (or load it via another HttpGet)
-- ============================================================
loadstring(game:HttpGet("https://raw.githubusercontent.com/jojosbytes/Pepsi-library/refs/heads/main/Pepsi-Script/Script.lua"))()
