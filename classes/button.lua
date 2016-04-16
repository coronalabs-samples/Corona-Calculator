--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- Class that draws calculator button
--
local class = {}
-- Create method - accepts button label, width and height, button color and text color
function class.newButton(labelTxt, width, height, backgroundColor, labelColor, isWide)
	-- Let's create new display group for our button objects
	local button = display.newGroup()
	button.anchorY = 0
	button.anchorChildren = true
	-- Button background - filled rect object
	local back = display.newRect(0, 0, width, height)
	-- Buttons label - text object
	local label = display.newText(labelTxt, 0, 0, "Roboto-Thin.ttf", 32)
	-- Align to top left corner in display group
	back.x, back.y, label.x, label.y = 0, 0, 0, 0
	if isWide then
		label.x = -width / 4
	end
	-- Let's set background and text colors
	back:setFillColor(unpack(backgroundColor))
	label:setFillColor(unpack(labelColor))
	-- Button border width and color
	back.strokeWidth = 1
	back:setStrokeColor(0.55686274509804)
	-- Set's buttons label
	button.label = labelTxt
	-- Adding our objects to display group
	button:insert(back)
	button:insert(label)

	-- Compute a color for the pressed state
	local backgroundPressedColor = {}
	for i = 1, #backgroundColor do
		backgroundPressedColor[i] = backgroundColor[i] * 0.75
	end
	-- Method to set buttons state - pushed or not. This method used in touch event listener.
	function button:setPressed(pressed)
		-- If pushed - set a darker background color
		if pressed then
			back:setFillColor(unpack(backgroundPressedColor))
		else
			back:setFillColor(unpack(backgroundColor))
		end
	end
	function button:setLabel(value)
		label.text = value
	end
	return button
end

return class
