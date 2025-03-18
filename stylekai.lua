local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- ฟังก์ชันสำหรับบันทึกข้อมูลลงในไฟล์ JSON
local function saveToConfig(data)
    local configPath = "config.json"
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if success then
        writefile(configPath, encoded)
    else
        warn("Failed to encode data:", encoded)
    end
end

-- ฟังก์ชันสำหรับโหลดข้อมูลจากไฟล์ JSON
local function loadFromConfig()
    local configPath = "config.json"
    if isfile(configPath) then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(configPath))
        if success then
            return decoded
        else
            warn("Failed to decode data:", decoded)
        end
    end
    return nil
end

-- ฟังก์ชันสำหรับส่ง Webhook
local function sendWebhook(styleValue)
    local money = player.ProfileStats.Money.Value
    local spins = player.ProfileStats.Spins.Value
    local flowSpins = player.ProfileStats.FlowSpins.Value

    local data = {
        ["username"] = "น้องยูไก่ Blue Lock",
        ["avatar_url"] = "https://img2.pic.in.th/pic/img-LFvxXRln1rNDhoAwznTyKf8f40159bfebcc49.jpeg",
        ["content"] = "<@" .. "387914271943557130" .. "> ชื่อPC: " .. _G.PC,
        ["embeds"] = {
            {
                ["title"] = "แจ้งเตือนสุ่ม Style",
                ["description"] = "**Name** ||\n" .. player.Name .. "\n|| **Style : **" .. styleValue ..
                                 "\n **Money :** " .. money ..
                                 "\n **Spin:** : " .. spins ..
                                 "\n **FlowSpin:** : " .. flowSpins,
                ["color"] = 0xff0000,  -- สีของ Embed (Red)
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1346319254768844932/c27802c7-2c89-47d1-9f40-af365b3c1322.jpg?ex=67c7c103&is=67c66f83&hm=5821191cf5d8bc2c0cf2cde5f924702266ca766bb31b95a951ffc1ca70341c30&=&format=webp"
                },
            }
        }
    }

    local success, newdata = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then
        warn("Failed to encode data:", newdata)
        return false
    end

    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request)
    if not request then
        warn("ไม่พบคำขอ HTTP ที่สามารถใช้งานได้")
        return false
    end

    local headers = {
        ["Content-Type"] = "application/json"
    }

    local success, response = pcall(function()
        return request({
            Url = _G.DiscordWebhookUrl,
            Method = "POST",
            Headers = headers,
            Body = newdata
        })
    end)

    if not success then
        warn("Failed to send webhook:", response)
    end

    return success
end

-- ตรวจสอบและดำเนินการ
local function checkStyle()
    if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
        local styleValue = player.PlayerStats.Style.Value
        local styleneed = {"Don Lorenzo","Shidou","Yukimiya","Sae","Kunigami","Rin"}

        if table.find(styleneed, styleValue) then
            local config = loadFromConfig() or {}
            local lastStyle = config.lastStyle

            if lastStyle ~= styleValue then
                config.lastStyle = styleValue
                saveToConfig(config)
                local success = sendWebhook(styleValue)
                if success then
                    player:Kick("คุณได้รับสไตล์ " .. styleValue .. " แล้ว ")
                end
            else
                player:Kick("คุณได้รับสไตล์ " .. styleValue .. " แล้ว ")
            end
        end
    end
end

-- เรียกฟังก์ชันตรวจสอบเมื่อเกมเริ่มต้น
checkStyle()

-- ตรวจสอบทุกครั้งที่ Style เปลี่ยนแปลง
if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
    player.PlayerStats.Style.Changed:Connect(checkStyle)
end
