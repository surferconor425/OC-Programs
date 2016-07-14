local component = require("component")
local event = require("event")
local keyboard = require("keyboard")
local gpu = component.gpu

local endProgram = false

--config. Here's stuff you can safely change with no knowledge of lua or whatever.
--Note that the bars resolution is 52x7 and cannot be changed without rewriting stuff.
aeRf = 2 --How many RF you get per unit of AE
euRf = 3.3 --How many RF you get per unit of EU

x = 5 --X (left-right) start position of the bar.
y = 2 --Y (up-down) Start position of the bar.

xSize = 60 --X resolution of the screen. DOES NOT CHANGE SIZE OF BAR.
ySize = 14 --Y resolution of the screen. ^^^^^^

textY = 9 --Start position of the text below the bar.

--Pre-enter any extra power here. Number should be in RF (Use the conversions from above)
--This is, for example, if you have dedicated cells on machines which -should- always be full.
pre = 0
--end config

gpu.setResolution(xSize, ySize)
gpu.setBackground(0x111111)
gpu.fill(0, 0, 160, 50, " ")

gpu.setForeground(0x5555FF)
gpu.set(16, 1, "Scanning Network; Please Wait.")

gpu.setBackground(0x333333)
gpu.fill(x, y, 51, 7, " ")

gpu.setBackground(0x888888)
gpu.setForeground(0x333333)
gpu.fill(x, y, 1, 7, " ")
gpu.fill(x+51, y, 1, 7, " ")
gpu.fill(x+1, y, 50, 1, "▄")
gpu.fill(x+1, y+6, 50, 1, "▀")

--Create palette for rendering
gpu.setPaletteColor(0, 0x5D0000)
gpu.setPaletteColor(1, 0x720000)
gpu.setPaletteColor(2, 0xAD0000)
gpu.setPaletteColor(3, 0x570000)

gpu.setPaletteColor(4, 0x820000)
gpu.setPaletteColor(5, 0xA80000)
gpu.setPaletteColor(6, 0xE00000)

gpu.setPaletteColor(7, 0x1D0606)
gpu.setPaletteColor(8, 0x240808)
gpu.setPaletteColor(9, 0x310B0B)
gpu.setPaletteColor(10, 0x370C0C)

gpu.setPaletteColor(11, 0x2A0909)
gpu.setPaletteColor(12, 0x360B0B)
gpu.setPaletteColor(13, 0x440E0E)
gpu.setPaletteColor(14, 0x470F0F)
gpu.setPaletteColor(15, 0x250808)

function drawLineA(xPos)
	gpu.setBackground(0x888888)
	gpu.setForeground(gpu.getPaletteColor(0))
	gpu.set(xPos, y, "▄")
	gpu.setBackground(gpu.getPaletteColor(1))
	gpu.set(xPos, y+1, " ")
	gpu.setBackground(0x990000)
	gpu.setForeground(gpu.getPaletteColor(2))
	gpu.set(xPos, y+2, "▄")
	gpu.set(xPos, y+3, "▀")
	gpu.setBackground(gpu.getPaletteColor(1))
	gpu.set(xPos, y+4, " ")
	gpu.setBackground(gpu.getPaletteColor(0))
	gpu.setForeground(gpu.getPaletteColor(3))
	gpu.set(xPos, y+5, "▄")
	gpu.setBackground(gpu.getPaletteColor(3))
	gpu.setForeground(0x888888)
	gpu.set(xPos, y+6, "▄")
end

function drawLineB(xPos)
	gpu.setBackground(0x888888)
	gpu.setForeground(gpu.getPaletteColor(4))
	gpu.set(xPos, y, "▄")
	gpu.setBackground(gpu.getPaletteColor(5))
	gpu.set(xPos, y+1, " ")
	gpu.setBackground(0xCC0000)
	gpu.setForeground(gpu.getPaletteColor(6))
	gpu.set(xPos, y+2, "▄")
	gpu.set(xPos, y+3, "▀")
	gpu.setBackground(gpu.getPaletteColor(5))
	gpu.set(xPos, y+4, " ")
	gpu.setBackground(gpu.getPaletteColor(4))
	gpu.setForeground(gpu.getPaletteColor(1))
	gpu.set(xPos, y+5, "▄")
	gpu.setBackground(gpu.getPaletteColor(1))
	gpu.setForeground(0x888888)
	gpu.set(xPos, y+6, "▄")
end

function drawLineC(xPos)
	gpu.setBackground(0x888888)
	gpu.setForeground(gpu.getPaletteColor(7))
	gpu.set(xPos, y, "▄")
	gpu.setBackground(gpu.getPaletteColor(8))
	gpu.set(xPos, y+1, " ")
	gpu.setBackground(gpu.getPaletteColor(9))
	gpu.setForeground(gpu.getPaletteColor(10))
	gpu.set(xPos, y+2, "▄")
	gpu.set(xPos, y+3, "▀")
	gpu.setBackground(gpu.getPaletteColor(8))
	gpu.set(xPos, y+4, " ")
	gpu.setBackground(gpu.getPaletteColor(7))
	gpu.setForeground(0x000000)
	gpu.set(xPos, y+5, "▄")
	gpu.setBackground(0x000000)
	gpu.setForeground(0x888888)
	gpu.set(xPos, y+6, "▄")
end

function drawLineD(xPos)
	gpu.setBackground(0x888888)
	gpu.setForeground(gpu.getPaletteColor(11))
	gpu.set(xPos, y, "▄")
	gpu.setBackground(gpu.getPaletteColor(12))
	gpu.set(xPos, y+1, " ")
	gpu.setBackground(gpu.getPaletteColor(13))
	gpu.setForeground(gpu.getPaletteColor(14))
	gpu.set(xPos, y+2, "▄")
	gpu.set(xPos, y+3, "▀")
	gpu.setBackground(gpu.getPaletteColor(12))
	gpu.set(xPos, y+4, " ")
	gpu.setBackground(gpu.getPaletteColor(11))
	gpu.setForeground(gpu.getPaletteColor(15))
	gpu.set(xPos, y+5, "▄")
	gpu.setBackground(gpu.getPaletteColor(15))
	gpu.setForeground(0x888888)
	gpu.set(xPos, y+6, "▄")
end


while endProgram == false do
	stored = pre
	max = pre
	for k,v in pairs(component.list()) do
		if string.find(v, "thermalexpansion_cell") then
			stored = stored + component.invoke(k, "getEnergyStored")
			max = max + component.invoke(k, "getMaxEnergyStored")
		elseif v == "ie_lv_capacitor" or v == "ie_mv_capacitor" or v == "ie_hv_capacitor" then
			stored = stored + component.invoke(k, "getEnergyStored")
			max = max + component.invoke(k, "getMaxEnergyStored")
		elseif v == "big_battery" then
			stored = stored + component.invoke(k, "getEnergyStored")
			max = max + component.invoke(k, "getMaxEnergyStored")
		elseif v == "gt_batterybuffer" then
			stored = stored + math.ceil(component.invoke(k, "getEUStored")*euRf)
			max = stored + math.ceil(component.invoke(k, "getEUCapacity")*euRf)
		elseif v == "batbox" or v == "cesu" or v == "mfe" or v == "mfsu" then
			stored = stored + math.ceil(component.invoke(k, "getStored")*euRf)
			max = stored + math.ceil(component.invoke(k, "getCapacity")*euRf)
		end
	end

	aeStored = 0
	aeMax = 0

	for k,v in pairs(component.list("me_controller")) do
		aeStored = aeStored + math.ceil(component.invoke(component.get("d3404"), "getStoredPower"))
		aeMax = aeMax + math.ceil(component.invoke(k, "getMaxStoredPower"))
	end

	fill = math.ceil(stored/max*50)
	i = 1
	while i <= fill do
		if (i % 2 == 0) then
			drawLineA(x+i)
		else
			drawLineB(x+i)
		end
		i = i+1
	end

	while i <= 50 do
		if (i % 2 == 0) then
			drawLineC(x+i)
		else
			drawLineD(x+i)
		end
		i = i+1
	end

	gpu.setBackground(0x111111)

	gpu.fill(1, 1, 60, 1, " ")
	gpu.setForeground(0xFF0000)
	gpu.set(25, 1, "Stored Power")

	gpu.setForeground(0xFF0000)

	buffer = ""
	aeBuffer = ""

	if fill*2 < 100 then buffer = " " end
	if math.floor((aeStored/aeMax)*100)  < 100 then aeBuffer = " " end

	gpu.set(5, textY, "Power Cells:")
	gpu.set(18, textY, "" .. stored)
	gpu.set(31, textY, "/")
	gpu.set(33, textY, "" .. max)
	gpu.set(48, textY, "RF " .. buffer .. "(" .. fill*2 .. "%)")

	gpu.set(18, textY+1, "" .. math.floor(stored/euRf))
	gpu.set(31, textY+1, "/")
	gpu.set(33, textY+1, "" .. math.floor(max/euRf))
	gpu.set(48, textY+1, "EU " .. buffer .. "(" .. fill*2 .. "%)")

	if aeStored > 0 then
		gpu.setForeground(0x4444FF)
		gpu.set(5, textY+2, "AE Power: ")
		gpu.set(18, textY+2, "" .. math.floor(aeStored*aeRf))
		gpu.set(31, textY+2, "/")
		gpu.set(33, textY+2, "" .. math.floor(aeMax * aeRf))
		gpu.set(48, textY+2, "RF " .. aeBuffer .. "(" .. math.floor((aeStored/aeMax)*100) .. "%)  ")

		gpu.setForeground(0x00FF00)
		gpu.set(5, textY+4, "Total:")
		gpu.set(18, textY+4, "" .. math.floor((stored+(aeStored*aeRf))))
		gpu.set(31, textY+4, "/")
		gpu.set(33, textY+4, "" .. math.floor((max+(aeMax*aeRf))))
		gpu.set(48, textY+4, "RF " .. buffer .. "(" .. fill*2 .. "%)")

		gpu.set(18, textY+5, "" .. math.floor(((stored+(aeStored*aeRf))/euRf)))
		gpu.set(31, textY+5, "/")
		gpu.set(33, textY+5, "" .. math.floor(((max+(aeMax*aeRf))/euRf)))
		gpu.set(48, textY+5, "EU " .. buffer .. "(" .. fill*2 .. "%)")
	end

	if select(4, event.pull(0, "key_down")) == keyboard.keys.enter then
		endProgram = true
		gpu.setResolution(160, 50)
		gpu.fill(0, 0, 160, 50, " ")
	end
end
