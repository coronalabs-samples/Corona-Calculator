--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- screen.lua - This is a class for our calculator display.
-- It has only one Create and setLabel methods
local colors = require("classes.colors")

local class = {}

local defaultFontSize = 96
local fontSizeIncrement = 8
-- Creates Calculator display object, accepts only 1 param - display height. width is always 100%
function class.newScreen(height)
	local width = display.actualContentWidth
	-- New display group that will contain our objects(only 1 object for now)
	local screen = display.newGroup()
	-- Button background - filled rect object. Adjust for status bars when our buttons want to fill the screen like on tablets.
	local back = display.newRect(display.screenOriginX + width / 2, display.screenOriginY + display.topStatusBarContentHeight + height / 2, width, height - display.topStatusBarContentHeight)
	-- On tablets with status bars and soft button bars, our text could extend into the top status bar. If
	-- we don't have enough room to fit the text bring it's point size down to something that will fit.
	if (height - display.topStatusBarContentHeight - 5) < defaultFontSize then
		defaultFontSize = height - display.topStatusBarContentHeight - 5
	end
	-- New text object. New syntax used, so "align" property supported there.
	local text = display.newText({text = "0", x = 0, y = 0, fontSize = defaultFontSize, font = "Roboto-Light.ttf", align = "right"})
	-- Background color
	back:setFillColor(unpack(colors.screenBackground))
	-- Text color
	text:setFillColor(unpack(colors.screenLabel))
	-- Object anchor points:
	-- X=0 and Y=0, means bottom left corner
	text.anchorX = 1
	text.anchorY = 1
	-- Setting display position(setting coordiantes of the bottom left corner)
	text.x = display.screenOriginX + width * 0.95
	text.y = display.screenOriginY + height + display.topStatusBarContentHeight
	-- Insert our back and text objects to screen group.
	screen:insert(back)
	screen:insert(text)
	-- Method to set display text
	function screen:setLabel(str)
		text.text = str
		-- Automatically adjust font size
		text.size = defaultFontSize
		while text.width > width * 0.95 and text.size > fontSizeIncrement do
			text.size = text.size - fontSizeIncrement
		end
	end
	return screen
end

return class
