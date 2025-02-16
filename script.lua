local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- ตรวจสอบว่าผู้เล่นมี PlayerStats และ Style
if player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Style") then
    local styleValue = player.PlayerStats.Style
    local styleneed = {"Rin", "Aiku", "Shidou", "Sae","Kunigami","Yukimiya",}  -- ค่า Style ที่ต้องการตรวจสอบ

    -- ตรวจสอบว่า styleValue เป็นค่าที่ต้องการหรือไม่
    if table.find(styleneed, styleValue.Value) then
        -- กำหนด URL ของ Webhook (แทนที่ด้วย URL จริงของ Webhook)
        local url = _G.DiscordWebhookUrl

        -- สร้างข้อมูลที่จะส่งไปยัง Webhook
        local data = {
            ["username"] = "น้องยูไก่ Blue Lock",
            ["avatar_url"] = "https://img2.pic.in.th/pic/img-LFvxXRln1rNDhoAwznTyKf8f40159bfebcc49.jpeg",
            ["content"] = "ไก่มึงสุ่มได้สไตล์แดงครับไอ้โง่",  -- Tag ผู้เล่นใน Discord (สามารถใช้ UserId แทน)
            ["embeds"] = {
                {
                    ["title"] = "แจ้งเตือนสุ่ม Style",  -- ชื่อของ Embed
                    ["description"] = player.Name .. " ได้รับ Style: " .. styleValue.Value,  -- คำอธิบาย
                    ["color"] = 0x00FF00,  -- สีของ Embed (Green)
                    ["image"] = {
                        ["url"] = "https://media.discordapp.net/attachments/1285600624666476605/1340717423338197174/13c48f8c1fa28ec3cc188f1e639ad2b8.gif?ex=67b35fe7&is=67b20e67&hm=2179ac729f769fe2d8a16fdf69ed6acade6a0215268c93bc972ca6650ae96f61&="
                    },

                }
            }
        }

        -- เข้ารหัสข้อมูลเป็น JSON
        local success, newdata = pcall(function()
            return HttpService:JSONEncode(data)
        end)

        if not success then
            print("เกิดข้อผิดพลาดในการเข้ารหัสข้อมูลเป็น JSON:", newdata)
            return
        end

        -- ตรวจสอบตัวแปร `request` ที่สามารถใช้งานได้
        local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request)

        if not request then
            warn("ไม่พบคำขอ HTTP ที่สามารถใช้งานได้")
            return
        end

        -- กำหนด headers
        local headers = {
            ["Content-Type"] = "application/json"
        }

        -- ส่งคำขอ POST ไปยัง Webhook
        local success, response = pcall(function()
            return request({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = newdata
            })
        end)
if success then
            player:Kick("คุณมีสไตล์แดงแล้ว " .. styleValue.Value)
        end

        -- คืนค่าความสำเร็จของการส่งคำขอ
        return success
    end
end
