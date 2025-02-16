local HttpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	-- Auto Save: บันทึกการตั้งค่าเมื่อมีการเปลี่ยนแปลง
	function SaveManager:EnableAutoSave()
		for idx, option in next, SaveManager.Options do
			if self.Parser[option.Type] then
				option.Changed:Connect(function()
					self:Save("AutoSave")
				end)
			end
		end
	end

	-- Auto Load: โหลดการตั้งค่าเมื่อเกมเริ่มต้น
	function SaveManager:EnableAutoLoad()
		local success, data = self:Load("AutoSave")
		if success then
			print("Auto Load: Settings loaded successfully!")
		else
			warn("Auto Load: Failed to load settings - " .. tostring(data))
		end
	end

	-- บันทึกการตั้งค่าลงในไฟล์ JSON
	function SaveManager:Save(name)
		local data = {
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end

		local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
		if not success then
			return false, "failed to encode data"
		end

		-- บันทึกลงในไฟล์ JSON
		local filePath = self.Folder .. "/" .. name .. ".json"
		writefile(filePath, encoded)
		return true
	end

	-- โหลดการตั้งค่าจากไฟล์ JSON
	function SaveManager:Load(name)
		local filePath = self.Folder .. "/" .. name .. ".json"
		if not isfile(filePath) then
			return false, "file does not exist"
		end

		local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(filePath))
		if not success then
			return false, "failed to decode data"
		end

		if decoded.objects then
			for _, option in next, decoded.objects do
				if self.Parser[option.type] then
					task.spawn(function()
						self.Parser[option.type].Load(option.idx, option)
					end)
				end
			end
		end

		return true
	end

	-- ตั้งค่า Library และ Options
	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
	end

	-- สร้างโฟลเดอร์หากไม่มี
	function SaveManager:BuildFolderTree()
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
	end

	-- เริ่มต้นระบบ
	SaveManager:BuildFolderTree()
end

return SaveManager
