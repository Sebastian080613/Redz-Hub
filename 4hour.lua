-- ===== LOAD RAYFIELD =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===== SETTINGS =====
local TARGET_UPTIME = 4 * 60 * 60 -- 4 hours
local PLACE_ID = game.PlaceId

-- ===== SERVICES =====
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- ===== AUTO RE-EXECUTE =====
local reexec = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Sebastian080613/Redz-Hub/main/4hour.lua
"))()
]]

if queue_on_teleport then
    queue_on_teleport(reexec)
elseif syn and syn.queue_on_teleport then
    syn.queue_on_teleport(reexec)
end

-- ===== UI =====
local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits | 4H Server Hopper",
    LoadingTitle = "Server Hopper",
    LoadingSubtitle = "Checking uptime...",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Server Hop", 4483362458)

local StatusLabel = Tab:CreateLabel("Status: Waiting")

-- ===== FUNCTIONS =====
local function ServerOldEnough()
    return workspace:GetServerTimeNow() >= TARGET_UPTIME
end

local function GetServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    return HttpService:JSONDecode(game:HttpGet(url))
end

local function HopServers()
    StatusLabel:Set("Status: Hopping servers...")
    local cursor

    repeat
        local data = GetServers(cursor)

        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(
                    PLACE_ID,
                    server.id,
                    Players.LocalPlayer
                )
                task.wait(3)
            end
        end

        cursor = data.nextPageCursor
    until not cursor
end

-- ===== TOGGLE =====
Tab:CreateToggle({
    Name = "Auto Find 4 Hour Server",
    CurrentValue = true,
    Callback = function(Value)
        if not Value then return end

        if ServerOldEnough() then
            StatusLabel:Set("Status: ✅ Server is 4+ hours old")
        else
            StatusLabel:Set("Status: ❌ Server too new")
            HopServers()
        end
    end
})
