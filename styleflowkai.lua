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
local function sendWebhook(styleValue, flowValue)
    local data = {
        ["username"] = "น้องยูไก่ Blue Lock",
        ["avatar_url"] = "https://img2.pic.in.th/pic/img-LFvxXRln1rNDhoAwznTyKf8f40159bfebcc49.jpeg",
        ["content"] = "<@" .. "387914271943557130" .. "> ชื่อPC: ".._G.PC ,
        ["embeds"] = {
            {
                ["title"] = "แจ้งเตือนสุ่ม Style",
                ["description"] = "**ชื่อตัวละคร: **||".. player.Name .."||\n**ได้รับStyle:** " .. styleValue .. "\n**ได้รับFlow:** " .. flowValue,
                ["color"] = 0xff0000,
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1342194431452905502/blue-lock-itoshi-sae.gif?ex=67b8bf79&is=67b76df9&hm=04bf97ec15a70a5a9698f91c967d415cf63263d957ab0c9ab432c570b5009d58&="
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
    if player:FindFirstChild("PlayerStats") then
        local stats = player.PlayerStats
        if stats:FindFirstChild("Style") and stats:FindFirstChild("Flow") then
            local styleValue = stats.Style.Value
            local flowValue = stats.Flow.Value
            
            local styleNeed = {"Rin","Shidou", "Sae", "Kunigami", "Yukimiya","Aiku"}
            local flowNeed = {"Dribbler", "Awakened Genius", "Prodigy", "Snake"}
            
            -- ตรวจสอบว่า Style และ Flow เป็นค่าที่ต้องการหรือไม่
            if table.find(styleNeed, styleValue) and table.find(flowNeed, flowValue) then
                -- โหลดข้อมูลจากไฟล์ config
                local config = loadFromConfig() or {}
                local lastStyle = config.lastStyle
                local lastFlow = config.lastFlow

                -- ถ้า styleValue หรือ flowValue เปลี่ยนและยังไม่เคยส่ง Webhook
                if lastStyle ~= styleValue or lastFlow ~= flowValue then
                    -- บันทึกค่าใหม่ลงในไฟล์ config
                    config.lastStyle = styleValue
                    config.lastFlow = flowValue
                    saveToConfig(config)

                    -- ส่ง Webhook
                    local success = sendWebhook(styleValue, flowValue)
                    if success then
                        -- เตะผู้เล่นหลังจากส่ง Webhook สำเร็จ
                        player:Kick("คุณได้รับสไตล์ " .. styleValue .. " และ Flow " .. flowValue .. " แล้ว")
                    end
                else
                    -- ถ้าเคยส่ง Webhook ไปแล้ว ให้เตะผู้เล่น
                    player:Kick("คุณได้รับสไตล์ " .. styleValue .. " และ Flow " .. flowValue .. " แล้ว")
                end
            end
        end
    end
end

-- เรียกฟังก์ชันตรวจสอบเมื่อเกมเริ่มต้น
checkStyle()

-- ตรวจสอบทุกครั้งที่ Style หรือ Flow เปลี่ยนแปลง
if player:FindFirstChild("PlayerStats") then
    if player.PlayerStats:FindFirstChild("Style") then
        player.PlayerStats.Style.Changed:Connect(checkStyle)
    end
    if player.PlayerStats:FindFirstChild("Flow") then
        player.PlayerStats.Flow.Changed:Connect(checkStyle)
    end
end
