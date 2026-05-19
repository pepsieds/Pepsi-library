-- ============================================================
--  ARMOR AUTH  |  XOR Protected
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local player      = Players.LocalPlayer

-- XOR Decoder
local function xd(hex, key)
    local out = {}
    local i = 1
    for byte in hex:gmatch("(%x%x)") do
        local c = bit32.bxor(tonumber(byte, 16), string.byte(key, ((i - 1) % #key) + 1))
        table.insert(out, string.char(c))
        i = i + 1
    end
    return table.concat(out)
end

-- Encrypted strings (no plain URLs/keys visible in file)
local _K  = "PepsiArmor2024"
local _U  = "381104031a7b5d421e1c54445f5f211714160e2e181709184a54505d7e1605030823131e0a5c515f"
local _AK = "351c3a1b0b061104201b7879674e19543e1a20323b033d4751737b02190e002b3f02385441174b7a42576328193c000b080937305a695f722a3f233a1a081c2703285b79047d3e2305290713060c5c344b6a75623e0742035f1b1f1d5b28757a427d39121910047801373c3b04795f7225074247000d31271f2b6a615b7b3a20433d132a0a2015374a7e7653232c1d255d223124593f5871077a1406073d1304422227421c7b597f170706150d122b3a241a6d7555672207152250021118034a6d484a7a04031142110818035f01667d"
local _SU = "381104031a7b5d421d13451e555d240d05111c32171f0c1d5c44575a244b131c046e1802051d41524b4035165f230c310104421e5b524055221c5f010c27014207175354411b3d04191d4611171d1c1b1f6351463915045c3a2200041f061c5c4755"

local SUPABASE_URL      = xd(_U,  _K)
local SUPABASE_ANON_KEY = xd(_AK, _K)
local SCRIPT_URL        = xd(_SU, _K)

local function _ad()
    local _d = false
    local _ols = loadstring
    if getgenv().loadstring and getgenv().loadstring ~= _ols then _d = true end
    pcall(function()
        if shared.GCDump or shared.ScanShared or shared.FindURLs or shared.DumperCleanup then _d = true end
    end)
    pcall(function()
        if isfolder and isfolder("dumps") then
            local f = listfiles and listfiles("dumps") or {}
            if #f > 0 then _d = true end
        end
    end)
    if _d then
        game:GetService("Players").LocalPlayer:Kick("\n[Clarity Anti-Dump]\n\nDumper detected.\nDisable dumping tools and try again.")
        return false
    end
    return true
end

if not _ad() then return end

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

-- HTTP request using executor request()
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
    if res.Body and res.Body ~= "" then return HttpService:JSONDecode(res.Body) end
    return true
end

-- Validate key
local data = req("GET", "keys?key=eq." .. key .. "&select=key,status,hwid")

if not data or type(data) ~= "table" or #data == 0 then
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

if row.hwid == nil then
    req("PATCH", "keys?key=eq." .. key, {
        hwid      = hwid,
        last_seen = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
    print("[Armor] Key locked to this device. Welcome!")
elseif row.hwid ~= hwid then
    error("[Armor] HWID mismatch. Reset your HWID in the Discord panel.")
    return
else
    req("PATCH", "keys?key=eq." .. key, {
        last_seen = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    })
    print("[Armor] Authenticated!")
end

-- Load actual script
loadstring(game:HttpGet(SCRIPT_URL))()
