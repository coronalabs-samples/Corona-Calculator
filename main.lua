--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- main.lua -- App entry point. Sets up the User Interface, handles button presses
--

-- List of all colors
local colors = require("classes.colors")
--Loading our helper classes : button, calculator display and math helper
local newButton = require("classes.button").newButton
local newScreen = require("classes.screen").newScreen
local calculator = require("classes.calculator")

--Buttons positions, labels and color settings. Order matters! Colors are 0-255 based and are converted to Corona SDK's 0..1 base later.
local buttons = {
	{label = "AC",  action = "reset",    backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "⁺∕₋", action = "sign",     backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "%",   action = "percent",  backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "÷",   action = "divide",   backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "7",   action = 7,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "8",   action = 8,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "9",   action = 9,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "×",   action = "multiply", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "4",   action = 4,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "5",   action = 5,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "6",   action = 6,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "‒",   action = "subtract", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "1",   action = 1,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "2",   action = 2,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "3",   action = 3,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "+",   action = "add",      backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "0",   action = 0,          backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel, isWide = true},
	{label = ".",   action = "point",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "=",   action = "result",   backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel}
}

-- AC button is special
local acButton

--Width and height of our buttons - we have 4 buttons in a row.
local buttonWidth = display.actualContentWidth / 4
local buttonHeight = math.floor(buttonWidth * 0.82)
--Space for display - all free space
local top = display.actualContentHeight - buttonHeight * 6
--Numeric button pressed flag
local numPressed = true
--Calculator display string
local displayStr = "0"
--How many symblos will fit on screen
local maxLength = 40

--Creating display screen
local calcScreen = newScreen(top + buttonHeight)

--
-- Buttons touch event handler
-- This code will do the work for each button press.
--
local function buttonTouch(self, event)
	--This code changes button state/color.
	--Handle touch only if touch ended
	if event.phase == "began" then
		self:setPressed(true)
		self.isFocused = true
		display.getCurrentStage():setFocus(self)
		return true
	elseif self.isFocused then
		if event.phase == "moved" then
			return true
		else
			self:setPressed(false)
			self.isFocused = false
			display.getCurrentStage():setFocus(nil)
		end
	end

	--What button pressed?
	local action = self.action
	if type(action) == "number" then
		--It's numeric or decimal button
		--Check if we started new input
		if not numPressed or displayStr == "0" then
			displayStr = ""
		end

		--Set flag that numeric button clicked, all next numbers will be appended to 1 string, until any func button clicked
		numPressed = true
		--AC button to C
		acButton:toC()
		--Limit maxLength symbols on screen
		if displayStr:len() < maxLength then
			displayStr = displayStr .. action
			--Display number
			calcScreen:setLabel(displayStr)
		end
	elseif action == "point" then
		if not numPressed then
			displayStr = "0."
			--AC button to C
			acButton:toC()
		elseif not displayStr:find("%.") and displayStr:len() < maxLength then
			displayStr = displayStr .. "."
		end
		numPressed = true
		--Display number
		calcScreen:setLabel(displayStr)
	elseif action == "sign" then
		--Sign button clicked - convert number
		numPressed = true
		if displayStr ~= "0" then
			--Invert number
			displayStr = calculator.invert(displayStr)
			calcScreen:setLabel(displayStr)
		end
	elseif action == "clear" then
		--C button clicked - clear operand
		displayStr = "0"
		numPressed = true
		calculator.clearOperand()
		calcScreen:setLabel(displayStr)
		--C button to AC
		acButton:toAC()
	elseif action == "reset" then
		--AC button clicked - reset everything
		displayStr = "0"
		numPressed = true
		calculator.clear()
		calcScreen:setLabel(displayStr)
	else
		--IF any of functional buttons clicked - pass operands and operator to calc class, get and display results
		--Pass new typed number to calc class
		if numPressed then
			calculator.setOperand(displayStr)
		end
		--Pass current math operator to calc class
		calculator.setOperator(action)
		--Get result from calc class
		displayStr = calculator.getResult()
		-- If there is error(division by zero) - display "Error" on display
		if calculator.error then
			displayStr = "ERROR"
		end
		--If there is new result - show animation
		calcScreen:setLabel(displayStr)
		numPressed = false
	end
	return true
end

--Draws all butoons
--We have 5 rows X 4 columns, all buttons has same width and height, except "0" - we have a special flag for this button
local pos = 0
for i = 1, #buttons do --Go over all buttons in our config table
	local b = buttons[i]
	pos = pos + 1	--real screen pos, we need this because of  "0" double width button
	local w, h = buttonWidth, buttonHeight
	--If there is double width flag
	if b.isWide then
		w = w * 2
	end
	--Create new button using our calculator button class
	local button = newButton(b.label, w, h, b.backgroundColor, b.labelColor, b.isWide)
	button.action = b.action
	-- button(center) position - 4 buttons in a row
	button.x = display.screenOriginX + math.floor((pos - 1) % 4) * w + w / 2
	button.y = display.screenOriginY + math.floor((pos - 1) / 4) * h + top + h
	--if current button("0") has double width - move actual position to next column
	if b.isWide then
		pos = pos + 1
	end
	--Button touch listener. We using touch, instead of tap, because we need to handle buttons normal/pushed states.
	button.touch = buttonTouch
	button:addEventListener("touch")

	if b.label == "AC" then
		acButton = button
		function acButton:toAC()
			self:setLabel("AC")
			self.action = "reset"
		end
		function acButton:toC()
			self:setLabel("C")
			self.action = "clear"
		end
	end
end
