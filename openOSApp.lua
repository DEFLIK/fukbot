-- ~.09.2020 v
local component = require('component') -- подгрузить обертку из OpenOS
local computer = require('computer')
local event = require("event")
local GUI = require("GUI")
local system = require("System")
local internet = require("Internet")
local filesystem = require("Filesystem")
local paths = require("Paths")
local message1="prgrs0"
local progressValue = 0
local portLength = 7
local chunksLength = 15
local optionsLength = 18
local batteryValue = 0
local handle
local logoText = "|-=Bot Yanni=-|"
local settingsLength = portLength + chunksLength + optionsLength + 3
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local workspace, window, menu = system.addWindow(GUI.tabbedWindow(5, 1, 70, 46))

control = window.tabBar:addItem("Control")
setup = window.tabBar:addItem("Setup")
manual = window.tabBar:addItem("Manual")

local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))
local layout2 = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

control.onTouch = function()
		layout.hidden = false
		layout2.hidden = true
end

setup.onTouch = function()
		layout.hidden = true
		layout2.hidden = false
end

layout:addChild(GUI.text(1, 1, 0x4B4B4B, ""))
layout:addChild(GUI.text(1, 1, 0x4B4B4B, ""))
local logo = window:addChild(GUI.text(window.width - string.len(logoText), 2, 0x4B4B4B, logoText))
local settings = layout:addChild(GUI.container(0, 0, settingsLength, 3))
local port = settings:addChild(GUI.input(1, 1, portLength, 3, 0xC6C9D3, 0xe5e7ee, 0xdfe2ee, 0x454a5c, 0x0784f6, "Порт", "Порт", "textMask"))
settings:addChild(GUI.panel(portLength + 2, 1, chunksLength, 3, 0xC6C9D3))
settings:addChild(GUI.text(portLength + 3, 1, 0x4B4B4B, "Кол-во чанков"))

local chunksSlider = settings:addChild(GUI.slider(portLength + 5, 2, chunksLength - 6, 0x66DB80, 0x0, 0xFFFFFF, 0xdfe2ee, 1, 9, 1, true, "Выбрано: ", ""))
chunksSlider.roundValues = true

settings:addChild(GUI.framedButton(portLength + chunksLength + 3, 1, optionsLength, 3, 0xC6C9D3, 0x4B4B4B, 0x880000, 0x880000, "Доп. настройки")).onTouch = function()
end

layout:addChild(GUI.roundedButton(1, 5, 10, 3, 0xC6C9D3, 0x258922, 0x74777E, 0x123C10, "Готово")).onTouch = function()
  port.text = tonumber(port.text)
  component.modem.open(port.text)
  component.modem.broadcast(port.text, math.floor(chunksSlider.value))
  computer.beep("..")
  GUI.alert("Конфигурация отправлена!", port.text, math.floor(chunksSlider.value))
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
layout:addChild(GUI.text(1, 1, 0x4B4B4B, "|ПАНЕЛЬ УПРАВЛЕНИЯ|"))
layout:addChild(GUI.button(1, 1, 24, 3, 0xC6C9D3, 0xBA2020, 0x74777E, 0x123C10, "Принудительный возврат")).onTouch = function()
  component.modem.broadcast(port.text, "pcgohome1239")
  computer.beep(".")
  GUI.alert("Принудительный возврат отправлен. Данная функция для экстренных случаев!")
end

local textBox = layout:addChild(GUI.textBox(2, 2, 60, 23, 0xe5e5e5, 0x2D2D2D, {}, 1, 1, 0))
table.insert(textBox.lines, {text = "                  _ЛОГИРОВАНИЕ ДЕЙСТВИЙ_", color = 0xfd9b21})
  function inmess(msg123,receiverAddress123,senderAddress123,port123,distance123,messageK)
    if msg123 == "modem_message" and port123 == port.text then
    --table.insert(textBox.lines, {text = messageK:sub(10,10), color = 0xffa700})
    if (messageK:sub(1,1) == "I") then
      table.insert(textBox.lines, {text = messageK, color = 0xffa700})
    end
    if (messageK:sub(1,1) == "W") then
      table.insert(textBox.lines, {text = messageK, color = 0x990000})
    end
    if (messageK:sub(1,1) == ">") then
      table.insert(textBox.lines, {text = messageK, color = 0x990000})
    end
    if (messageK:sub(1,1) == "D") then
      computer.beep('...')
      table.insert(textBox.lines, {text = messageK, color = 0x0ad622})
    end
  end
end
event.addHandler(inmess)

local progressBar = layout:addChild(GUI.progressBar(0, 0, 50, 0x258922, 0xe5e5e5, 0xe5e5e5, progressValue, true, false, "bruh", "bruh"))
function ProgressUpdate(msg12,receiverAddress12,senderAddress12,port12,distance12,message1)
  if msg12 == "modem_message" and port12 == port.text and message1:sub(1,5) == "prgrs" then
    progressBar.value = tonumber(message1:sub(6,string.len(message1)))
  end
end
event.addHandler(ProgressUpdate)

local bat = layout:addChild(GUI.text(0, 0, 0x78dbe2, 'Заряд: '..batteryValue..'%'))
function BatteryUpdate(msg13,receiverAddress13,senderAddress13,port13,distance13,message13)
  if msg13 == "modem_message" and port13 == port.text and message13:sub(1,5) == "bttry" then
    bat:remove()
    batteryValue = tonumber(message13:sub(6,7))
    local bat = layout:addChild(GUI.text(0, 0, 0x78dbe2, 'Заряд: '..batteryValue..'%'))
  end
end
event.addHandler(BatteryUpdate)

local poss = layout:addChild(GUI.text(0, 0, 0x78dbe2, '| X Y Z |'))
function PositionUpdate(msg14,receiverAddress14,senderAddress14,port14,distance14,message14)
  if msg14 == "modem_message" and port14 == port.text and message14:sub(1,4) == "poss" then
    poss:remove()
    local poss = layout:addChild(GUI.text(0, 0, 0x78dbe2, message14:sub(5,string.len(message14))))
  end
end
event.addHandler(PositionUpdate)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local link = "https://raw.githubusercontent.com/DEFLIK/fukbot/master/init.lua"
local formatText = "Format disk before setup"
local idText = "First 3 ID char. of selected drive"

layout2:addChild(GUI.text(1, 1, 0x4B4B4B, "Installation"))

local versionBox = layout2:addChild(GUI.comboBox(3, 2, 30, 3, 0xe5e5e5, 0x2D2D2D, 0xCCCCCC, 0x888888))
versionBox:addItem("Moded").onTouch = function()
	link = "https://raw.githubusercontent.com/DEFLIK/fukbot/master/init.lua"
end
versionBox:addItem("Original (unconnectable!)").onTouch = function()
	link = "https://raw.githubusercontent.com/DOOBW/geominer/master/miner.lua"
end

local formatBox = layout2:addChild(GUI.container(0, 0, string.len(formatText) + 10, 1))
formatBox:addChild(GUI.text(2, 1, 0x4B4B4B, formatText))
local format = formatBox:addChild(GUI.switch(string.len(formatText) + 5, 1, 5, 0x66DB80, 0x1D1D1D, 0x888888, false))

local proxy = layout2:addChild(GUI.input(1, 1, string.len(idText), 3, 0xC6C9D3, 0xe5e7ee, 0xdfe2ee, 0x454a5c, 0x0784f6, idText, idText, "textMask"))

layout2:addChild(GUI.roundedButton(1, 5, 10, 3, 0xC6C9D3, 0x258922, 0x74777E, 0x123C10, "Готово")).onTouch = function()
	mountsList = filesystem.list(paths.system.mounts)
	local resultId = "none"
	for num in pairs(mountsList) do
		if proxy.text == idText then
			GUI.alert("Enter drive ID")
			break
		end
		if tostring(mountsList[num]):sub(1,3) == proxy.text then
			resultId = mountsList[num]
			break
		end
	end
	if resultId == "none" and proxy.text ~= idText then
		GUI.alert("Unable to find drive called: "..proxy.text.."...")
	elseif proxy.text ~= idText then
		local setupPanel = window:addChild(GUI.window(23, 20, 25, 6))
		setupPanel:addChild(GUI.panel(1, 1, setupPanel.width, setupPanel.height, 0xF0F0F0))
		local setupStatus = setupPanel:addChild(GUI.container(0, 3, setupPanel.width, 3))
		local setupIndicator = setupPanel:addChild(GUI.progressIndicator(12, 4, 0x3C3C3C, 0x00B640, 0x99FF80))
		local setupStatusText = setupStatus:addChild(GUI.text(9, 1, 0x4B4B4B, "Preparing..."))
		setupIndicator.active = true
		workspace:draw()
		if format.state == true then
			setupStatusText:remove()
			local setupStatusText = setupStatus:addChild(GUI.text(9, 1, 0x4B4B4B, "Formating..."))
			workspace:draw()
			driveList = filesystem.list(paths.system.mounts..resultId)
			for file in pairs(driveList) do
				filesystem.remove(paths.system.mounts..resultId..driveList[file])
			end
		end
		setupStatusText:remove()
		local setupStatusText = setupStatus:addChild(GUI.text(9, 1, 0x4B4B4B, "Downloading..."))
		workspace:draw()
		result = internet.request(link)
		setupStatusText:remove()
		local setupStatusText = setupStatus:addChild(GUI.text(9, 1, 0x4B4B4B, "Installing..."))
		workspace:draw()
		filesystem.write(paths.system.mounts..resultId.."init.lua", result)
		setupStatusText:remove()
		setupIndicator:remove()
		local setupStatusText = setupStatus:addChild(GUI.text(12, 1, 0x4B4B4B, "Done!"))
		setupPanel:addChild(GUI.roundedButton(9, 4, 9, 3, 0xC6C9D3, 0x258922, 0x74777E, 0x123C10, "Alright bruh")).onTouch = function()
			setupPanel:remove()
		end
	end
end

layout2.hidden = true
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
window.actionButtons.close.onTouch = function()
	window:remove()
	workspace:draw()
end

window.actionButtons.maximize.onTouch = function()
	window:maximize()
	workspace:draw()
end

window.onResize = function(newWidth, newHeight)
	window.tabBar.width = newWidth
	window.backgroundPanel.width = newWidth
	window.backgroundPanel.height = newHeight - window.tabBar.height

	layout.width = newWidth
	layout.height = newHeight - window.tabBar.height + 2

	layout2.width = newWidth
	layout2.height = newHeight - window.tabBar.height + 0

	workspace:draw()
end
