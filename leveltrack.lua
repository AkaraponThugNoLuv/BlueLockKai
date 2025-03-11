local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local configPath = player.Name .. ".json"

-- ฟังก์ชันสำหรับบันทึกข้อมูลลงในไฟล์ JSON
local function saveToConfig(data)
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if success then
        writefile(configPath, encoded)
    else
        warn("Failed to encode data:", encoded)
    end
end

-- ฟังก์ชันสำหรับโหลดข้อมูลจากไฟล์ JSON
local function loadFromConfig()
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
local function sendWebhook()
    local money = player.ProfileStats.Money.Value
    local spins = player.ProfileStats.Spins.Value
    local flowSpins = player.ProfileStats.FlowSpins.Value
    local level = player.ProfileStats.Level.Value

    local data = {
        ["username"] = "น้องยูไก่ Blue Lock",
        ["avatar_url"] = "https://img2.pic.in.th/pic/img-LFvxXRln1rNDhoAwznTyKf8f40159bfebcc49.jpeg",
        ["content"] = "<@387914271943557130> ชื่อPC: " .. (_G.PC or "Unknown"),
        ["embeds"] = {
            {
                ["title"] = "แจ้งเตือนการใช้ Code",
                ["description"] = "**Name:** ||\n" .. player.Name .. "\n||" ..
                                 "\n **Level :** " .. level ..
                                 "\n **Money :** " .. money ..
                                 "\n **Spin:** " .. spins ..
                                 "\n **FlowSpin:** " .. flowSpins,
                ["color"] = 0xff0000,
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1347718780578562058/1b3485bab8f021908244c6daea187de4.gif"
                }
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

    local headers = { ["Content-Type"] = "application/json" }
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

-- วนลูปตลอดเวลา
while true do
    task.wait(5) -- ตรวจสอบทุก 5 วินาที

    if player.ProfileStats.Level.Value >= 10 then
        local config = loadFromConfig() or {}
        config.usedCodes = config.usedCodes or {}

        local codes = {"100KCHRO", "10KDEVS"} -- รายชื่อโค้ด
        local allUsed = true
        local usedNewCode = false

        for _, code in ipairs(codes) do
            if not config.usedCodes[code] then
                local args = {code}
                game:GetService("ReplicatedStorage").Packages.Knit.Services.CodesService.RF.Redeem:InvokeServer(unpack(args))
                task.wait(2)
                config.usedCodes[code] = true
                saveToConfig(config)
                usedNewCode = true
                allUsed = false
            end
        end

        if usedNewCode then
            sendWebhook()
            player:Kick("คุณใช้ Code แล้ว และข้อมูลถูกบันทึกลง Config")
            break
        elseif allUsed then
            player:Kick("คุณได้ใช้ทุกโค้ดไปแล้ว!")
            break
        end
    end
end
