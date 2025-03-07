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

-- ตรวจสอบว่า Level มากกว่าหรือเท่ากับ 10 หรือไม่
if player.ProfileStats.Level.Value >= 10 then
    local config = loadFromConfig() or {}
    
    if config.usedCode then
        player:Kick("คุณเลเวล 10 และ ใส่โค้ดแล้ว")
    else
        local codes = {"1BVISITS"}
        
        for _, code in ipairs(codes) do
            local args = {[1] = code}
            game:GetService("ReplicatedStorage").Packages.Knit.Services.CodesService.RF.Redeem:InvokeServer(unpack(args))
            wait(2)
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
                ["content"] = "<@387914271943557130> ชื่อPC: ".._G.PC,
                ["embeds"] = {
                    {
                        ["title"] = "แจ้งเตือนไก่เวล10",
                        ["description"] = "**Name** ||\n".. player.Name .."\n||" ..
                                         "\n **Level :** " .. level ..
                                         "\n **Money :** " .. money ..
                                         "\n **Spin:** " .. spins ..
                                         "\n **FlowSpin:** " .. flowSpins,
                        ["color"] = 0xff0000,
                        ["image"] = {
                            ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1347718780578562058/1b3485bab8f021908244c6daea187de4.gif?ex=67ccd86c&is=67cb86ec&hm=679eba1bbf664ff5b81ae08e3db209dfefbe9f79d09672a83c39afb3cba36670&="
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

        -- ดำเนินการส่ง Webhook และบันทึกลง Config
        local success = sendWebhook()
        if success then
            config.usedCode = true
            saveToConfig(config)
            player:Kick("คุณพึ่งเลเวล 10 และ ใส่โค้ดแล้ว")
        end
    end
end
