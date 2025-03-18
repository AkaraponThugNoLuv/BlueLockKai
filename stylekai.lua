local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local spinService = replicatedStorage.Packages.Knit.Services.StyleService.RE.Spin

-- ฟังก์ชันบันทึกข้อมูลลงไฟล์ JSON
local function saveToConfig(data)
    local configPath = "config.json"
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if success then
        writefile(configPath, encoded)
    else
        warn("Failed to encode data:", encoded)
    end
end

-- ฟังก์ชันโหลดข้อมูลจากไฟล์ JSON
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

-- ฟังก์ชันส่ง Webhook
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
                                 "\n **Spin:** " .. spins .. 
                                 "\n **FlowSpin:** " .. flowSpins,
                ["color"] = 0xff0000,  
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1346319254768844932/c27802c7-2c89-47d1-9f40-af365b3c1322.jpg"
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

-- ฟังก์ชันสุ่ม Style ไปเรื่อย ๆ
local function spinUntilDesiredStyle()
    if not player:FindFirstChild("PlayerStats") or not player.PlayerStats:FindFirstChild("Style") then
        warn("ไม่พบ PlayerStats หรือ Style")
        return
    end

    local styleValue = player.PlayerStats.Style
    local styleneed = {"Don Lorenzo", "Shidou", "Yukimiya", "Sae", "Kunigami", "Rin"}

    -- เช็คว่า Style ที่มีอยู่ตอนนี้เป็นหนึ่งในสไตล์ที่ต้องการแล้วหรือยัง
    if table.find(styleneed, styleValue.Value) then
        print("คุณมี Style ที่ต้องการอยู่แล้ว:", styleValue.Value)
        player:Kick("คุณมีสไตล์ " .. styleValue.Value .. " อยู่แล้ว!")
        return
    end

    -- สุ่มจนกว่าจะได้สไตล์ที่ต้องการ
    while not table.find(styleneed, styleValue.Value) do
        spinService:FireServer()
        task.wait(3) -- ลดเวลาให้สุ่มได้ไวขึ้น
    end

    -- บันทึกสไตล์ลง config.json
    local config = loadFromConfig() or {}
    config.lastStyle = styleValue.Value
    saveToConfig(config)

    -- เพิ่มดีเลย์ก่อนส่ง Webhook
    task.wait(2)  -- ดีเลย์ 2 วินาที

    -- ส่ง Webhook แจ้งเตือน
    sendWebhook(styleValue.Value)

    -- เตะผู้เล่นออกจากเกม
    player:Kick("คุณได้รับสไตล์ " .. styleValue.Value .. " แล้ว!")
end

-- เรียกใช้ฟังก์ชันสุ่มทันทีเมื่อเข้าระบบ
task.spawn(spinUntilDesiredStyle)

-- ตรวจสอบทุกครั้งที่ Style เปลี่ยนแปลง
if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
    player.PlayerStats.Style.Changed:Connect(function()
        task.spawn(spinUntilDesiredStyle)
    end)
end
