--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- screen.lua - This is a class for our calculator screen.
local colors = require("classes.colors")

local class = {}

local defaultFontSize = 96
local fontSizeIncrement = 4 -- Step size for font size adjustments
-- Creates Calculator screen object, accepts only 1 param - display height. width is always 100%
function class.newScreen(height)
	local width = display.actualContentWidth
	-- New display group that will contain our objects(only 1 object for now)
	local screen = display.newGroup()
	-- Button background - filled rect object.
	local back = display.newRect(display.screenOriginX + width / 2, display.screenOriginY + height / 2, width, height)
	-- New text object. New syntax used, so "align" property supported there
	local text = display.newText({text = "", x = 0, y = 0, fontSize = defaultFontSize, font = "Roboto-Light.ttf", align = "right"})
	-- Background color
	back:setFillColor(unpack(colors.screenBackground))
	-- Text color
	text:setFillColor(unpack(colors.screenLabel))
	-- Align to the bottom right corner
	text.anchorX = 1
	text.anchorY = 1
	-- Setting screen position (coordiantes of the bottom right corner)
	text.x = display.screenOriginX + width * 0.95
	text.y = display.screenOriginY + height
	-- Insert our back and text objects to the screen group
	screen:insert(back)
	screen:insert(text)
	-- Method to set the screen label text
	function screen:setLabel(str)
		text.text = str
		-- Automatically adjust font size to fit on the screen
		text.size = defaultFontSize
		while (text.width > width * 0.95 or text.height > height - display.topStatusBarContentHeight) and text.size > fontSizeIncrement do
			text.size = text.size - fontSizeIncrement
		end
	end
	screen:setLabel("0")

	-- Blink the screen to indicate an update
	function screen:blink()
		text.isVisible = false
		timer.performWithDelay(50, function()
			text.isVisible = true
		end)
	end
	return screen
end

return class
