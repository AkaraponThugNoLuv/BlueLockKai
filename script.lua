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
    local data = {
        ["username"] = "น้องยูไก่ Blue Lock",
        ["avatar_url"] = "https://img2.pic.in.th/pic/img-LFvxXRln1rNDhoAwznTyKf8f40159bfebcc49.jpeg",
        ["content"] = "<@" .. "387914271943557130" .. ">ชื่อPC: ".._G.PC ,  -- Tag ผู้เล่นใน Discord
        ["embeds"] = {
            {
                ["title"] = "แจ้งเตือนสุ่ม Style",
                ["description"] = "**ชื่อตัวละคร** ||" .. player.Name .."|| ได้รับสไตล์: " .. styleValue,
                ["color"] = 0xff0000,  -- สีของ Embed (Green)
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1340717423338197174/13c48f8c1fa28ec3cc188f1e639ad2b8.gif?ex=67b35fe7&is=67b20e67&hm=2179ac729f769fe2d8a16fdf69ed6acade6a0215268c93bc972ca6650ae96f61&="
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
        local styleneed = {"Rin", "Aiku", "Shidou", "Sae", "Kunigami", "Yukimiya"}

        -- ตรวจสอบว่า styleValue เป็นค่าที่ต้องการหรือไม่
        if table.find(styleneed, styleValue) then
            -- โหลดข้อมูลจากไฟล์ config
            local config = loadFromConfig() or {}
            local lastStyle = config.lastStyle

            -- ถ้า styleValue เปลี่ยนและยังไม่เคยส่ง Webhook
            if lastStyle ~= styleValue then
                -- บันทึกค่าใหม่ลงในไฟล์ config
                config.lastStyle = styleValue
                saveToConfig(config)

                -- ส่ง Webhook
                local success = sendWebhook(styleValue)
                if success then
                    -- เตะผู้เล่นหลังจากส่ง Webhook สำเร็จ
                    player:Kick("คุณได้รับสไตล์ " .. styleValue .. " แล้ว ")
                end
            else
                -- ถ้าเคยส่ง Webhook ไปแล้ว ให้เตะผู้เล่น
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
