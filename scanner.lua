-- Brainrot Scanner - Scannt nur nach Namen mit Job ID
local webhookURL = "https://discord.com/api/webhooks/1394000370761732217/8pIdvrynVGaACBukFglwpAgdJUkHdbxlBF-yzG0br8GnHEFmMjBJ7vJy2A8RGJUz00zu"

print("🎯 Name-Only Brainrot Scanner wird geladen...")

-- Webhook Funktion
function sendToWebhook(message)
    local success, err = pcall(function()
        if http_request then
            local response = http_request({
                Url = webhookURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({
                    content = message,
                    username = "Brainrot Scanner"
                })
            })
            return response.Success
        end
        return false
    end)
    
    if success then
        print("✅ Webhook gesendet")
        return true
    else
        print("❌ Webhook Fehler: " .. tostring(err))
        return false
    end
end

-- Funktion zum Abrufen der Job ID
function getJobId()
    return game.JobId
end

-- Liste der Brainrot-Namen die wir suchen
local brainrotNames = {
    "Los Mobilis",
    "Tictac Sahur",
    "Tacorita Bicicleta",
    "Las Sis", 
    "Los Hotspotsitos",
    "Money Money Puggy",
    "Celularcini Viciosini",
    "Los 67",
    "La Extinct Grande",
    "Los Bros",
    "Tralaledon",
    "Esok Sekolah",
    "Chillin Chili",
    "Los Tacoritas",
    "Tang Tang Keletang",
    "Ketupat Kepat",
    "La Supreme Combination",
    "Ketchuru and Masturu",
    "Garama and Madundung",
    "Spaghetti Tualetti",
    "Dragon Cannelloni",
    "La Secret Combinasion",
    "Burguro and Fryuro",
    "Strawberry Elephant"
}

-- Einfache Scan Funktion nur nach Namen
function scanForBrainrots()
    print("🔍 Scanne nur nach Brainrot-Namen...")
    local foundBrainrots = {}
    
    -- Scanne ALLE Objekte im Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        for _, name in pairs(brainrotNames) do
            if obj.Name:lower():find(name:lower()) then
                print("🎯 Brainrot gefunden: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                
                table.insert(foundBrainrots, {
                    name = obj.Name,
                    className = obj.ClassName,
                    path = obj:GetFullName()
                })
                
                break
            end
        end
    end
    
    -- Zeige Ergebnis
    print("\n📊 NAME-ONLY SCAN ERGEBNIS:")
    if #foundBrainrots > 0 then
        print("🎉 GEFUNDENE BRAINROTS: " .. #foundBrainrots)
        
        for i, brainrot in ipairs(foundBrainrots) do
            print("   ✅ " .. i .. ". " .. brainrot.name)
            print("      📍 Pfad: " .. brainrot.path)
        end
        
        return true, #foundBrainrots, foundBrainrots
    else
        print("❌ Keine Brainrots mit den gesuchten Namen gefunden")
        return false, 0, {}
    end
end

-- Serverwechsel
function changeServer()
    print("🔄 Wechsle Server...")
    game:GetService("TeleportService"):Teleport(game.PlaceId)
    wait(10)
end

-- Haupt-Loop
function mainLoop()
    print("🚀 Name-Only Brainrot Scanner gestartet!")
    print("🎯 Sucht nach " .. #brainrotNames .. " Brainrot-Namen")
    print("🆔 Aktuelle Job ID: " .. getJobId())
    
    local scanCount = 0
    
    while true do
        scanCount = scanCount + 1
        print("\n" .. string.rep("=", 70))
        print("=== SCAN #" .. scanCount .. " - " .. os.date("%H:%M:%S") .. " ===")
        
        local success, found, count, brainrots = pcall(scanForBrainrots)
        
        if not success then
            print("❌ Scan Fehler: " .. tostring(found))
        else
            if found then
                -- Formatierte Nachricht wie gewünscht
                local message = string.format(
                    "@everyone\n" ..
                    "**HIGH VALUE DETECTED**\n\n" ..
                    "**Gefundene Brainrots:**\n" ..
                    "%s\n\n" ..
                    "**Server Info**\n" ..
                    "%s\n\n" ..
                    "**Zeit:** %s",
                    table.concat(pluckNames(brainrots), "\n"), 
                    getJobId(),
                    os.date("%H:%M:%S")
                )
                
                print("💰 High Value gefunden - Sende Webhook")
                sendToWebhook(message)
                
                wait(30) -- 30 Sekunden warten wenn gefunden <-- GEÄNDERT
            else
                print("❌ Keine Brainrots gefunden - Warte 10 Sekunden bis Serverwechsel")
                wait(10) -- 10 Sekunden warten vor Serverwechsel <-- GEÄNDERT
                pcall(changeServer)
                wait(10)
            end
        end
        
        wait(5)
    end
end

-- Hilfsfunktion um Namen aus Tabelle zu extrahieren
function pluckNames(brainrots)
    local names = {}
    for _, brainrot in ipairs(brainrots) do
        table.insert(names, "• " .. brainrot.name)
    end
    return names
end

-- Start
print("=== 🧠 NAME-ONLY BRAINROT SCANNER ===")
print("🔍 Scannt nach " .. #brainrotNames .. " Brainrot-Namen")
print("📨 Webhook nur bei Fund mit @everyone")
print("⏱️  30 Sekunden Wartezeit bei Fund")
print("⏱️  10 Sekunden Wartezeit vor Serverwechsel")
wait(3)

spawn(mainLoop)
print("✅ Scanner läuft...")