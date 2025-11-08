-- Brainrot Scanner mit Low-Player Server Priorität
local webhookURL = "https://discord.com/api/webhooks/1394000370761732217/8pIdvrynVGaACBukFglwpAgdJUkHdbxlBF-yzG0br8GnHEFmMjBJ7vJy2A8RGJUz00zu"
local brainrotNames = {
    "Los Mobilis", "Tictac Sahur", "Tacorita Bicicleta", "Las Sis", 
    "Los Hotspotsitos", "Money Money Puggy", "Celularcini Viciosini", 
    "Los 67", "La Extinct Grande", "Los Bros", "Tralaledon", 
    "Esok Sekolah", "Chillin Chili", "Los Tacoritas", "Tang Tang Keletang", 
    "Ketupat Kepat", "La Supreme Combination", "Ketchuru and Masturu", 
    "Garama and Madundung", "Spaghetti Tualetti", "Dragon Cannelloni", 
    "La Secret Combinasion", "Burguro and Fryuro", "Strawberry Elephant"
}

-- Webhook Funktion
function sendWebhook(msg)
    pcall(function()
        local data = {content = msg, username = "Brainrot Scanner"}
        local json = game:GetService("HttpService"):JSONEncode(data)
        if request then request({Url=webhookURL, Method="POST", Body=json}) end
    end)
end

-- Erstelle GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 1, -10)
status.Position = UDim2.new(0, 5, 0, 5)
status.BackgroundTransparency = 1
status.Text = "Brainrot Scanner Gestartet"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

-- Scanner Funktion
function scan()
    for _, obj in pairs(workspace:GetDescendants()) do
        for _, name in pairs(brainrotNames) do
            if string.lower(obj.Name):find(string.lower(name)) then
                return true, obj.Name
            end
        end
    end
    return false
end

-- Funktion um Server mit wenigen Spielern zu finden
function findLowPlayerServer()
    local TeleportService = game:GetService("TeleportService")
    
    -- Versuche Serverliste zu bekommen
    local success, servers = pcall(function()
        return TeleportService:GetGameInstances(game.PlaceId)
    end)
    
    if success and servers and #servers > 0 then
        -- Sortiere Server nach Spieleranzahl (aufsteigend)
        table.sort(servers, function(a, b)
            return (a.Playing or 0) < (b.Playing or 0)
        end)
        
        -- Nimm die Server mit den wenigsten Spielern (erste 5)
        local lowPlayerServers = {}
        for i = 1, math.min(5, #servers) do
            if servers[i].Playing and servers[i].Playing < 10 then -- Weniger als 10 Spieler
                table.insert(lowPlayerServers, servers[i])
            end
        end
        
        if #lowPlayerServers > 0 then
            -- Wähle zufälligen Server aus den Low-Player Servern
            local randomServer = lowPlayerServers[math.random(1, #lowPlayerServers)]
            status.Text = "Wechsle zu Server mit " .. (randomServer.Playing or 0) .. " Spielern"
            return randomServer.JobId
        else
            -- Fallback: Normaler zufälliger Server
            local randomServer = servers[math.random(1, #servers)]
            status.Text = "Wechsle zu zufälligem Server"
            return randomServer.JobId
        end
    end
    
    return nil -- Fallback zu normalem Teleport
end

-- Verbesserter Serverwechsel
function changeServer()
    status.Text = "Suche Server mit wenigen Spielern..."
    
    local serverJobId = findLowPlayerServer()
    
    if serverJobId then
        -- Teleport zu spezifischem Server
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, serverJobId)
    else
        -- Fallback: Normaler Teleport
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
    
    wait(10)
end

-- Haupt Loop
spawn(function()
    local scanCount = 0
    while true do
        scanCount = scanCount + 1
        local found, name = scan()
        
        if found then
            status.Text = "🚨 BRAINROT GEFUNDEN: "..name.."\nWarte 30 Sekunden..."
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
            local msg = "@everyone\n**HIGH VALUE DETECTED**\n\n**Gefundene Brainrots:**\n• "..name.."\n\n**Server Info**\n"..game.JobId.."\n\n**Zeit:** "..os.date("%H:%M:%S")
            sendWebhook(msg)
            wait(30)
        else
            status.Text = "❌ Keine Brainrots gefunden\nSuche Low-Player Server...\nScans: "..scanCount
            status.TextColor3 = Color3.fromRGB(255, 255, 255)
            wait(10)
            pcall(changeServer)
            wait(10)
        end
        wait(5)
    end
end)
