--
-- Corona-Calculator
-- A simple calculator made with Corona SDK
--
-- MIT Licensed
--
-- main.lua -- App entry point. Sets up the User Interface, handles button presses
--
display.setStatusBar(display.TranslucentStatusBar)
-- List of all colors
local colors = require("classes.colors")
-- Loading our helper classes : button, calculator display and math helper
local newButton = require("classes.button").newButton
local newScreen = require("classes.screen").newScreen
local calculator = require("classes.calculator")

-- Buttons positions, labels and color settings. In order of displaying in the grid
local buttonData = {
	{label = "MC",  action = "memclear",  key = "MC",   backgroundColor = colors.memoryBackground,    labelColor = colors.memoryLabel},
	{label = "M+",  action = "memadd",    key = "M+",   backgroundColor = colors.memoryBackground,    labelColor = colors.memoryLabel},
	{label = "M-",  action = "memsub",    key = "M-",   backgroundColor = colors.memoryBackground,    labelColor = colors.memoryLabel},
	{label = "MR",  action = "memrecall", key = "MR",   backgroundColor = colors.memoryBackground,    labelColor = colors.memoryLabel},
	{label = "AC",  action = "reset",     key = "c",    backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "+/-", action = "sign",      key = "sign", backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "%",   action = "percent",   key = "%",    backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "÷",   action = "divide",    key = "/",    backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "7",   action = 7,           key = "7",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "8",   action = 8,           key = "8",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "9",   action = 9,           key = "9",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "×",   action = "multiply",  key = "*",    backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "4",   action = 4,           key = "4",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "5",   action = 5,           key = "5",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "6",   action = 6,           key = "6",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "–",   action = "subtract",  key = "-",    backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "1",   action = 1,           key = "1",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "2",   action = 2,           key = "2",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "3",   action = 3,           key = "3",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "+",   action = "add",       key = "+",    backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "0",   action = 0,           key = "0",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel, isWide = true},
	{label = ".",   action = "point",     key = ".",    backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "=",   action = "result",    key = "=",    backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel}
}

-- AC button is special
local acButton
-- Store a local reference to the buttons. We need this to support key events
local buttons = {}

-- Width and height of our buttons - we have 4 buttons in a row
local buttonWidth = display.actualContentWidth / 4
local buttonHeight = math.floor(buttonWidth * 0.75)
-- Space for display - all free space
local top = display.actualContentHeight - buttonHeight * 7
-- Functional button pressed flag
local isLastFunctional = true
-- Calculator display string
local displayStr = "0"
-- How many symbols will fit on screen
local maxLength = 42

--Creating display screen
local calcScreen = newScreen(top + buttonHeight)

--
-- Buttons touch event handler
-- This code will do the work for each button press
--
local function buttonTouch(self, event)
	-- This code changes button state/color
	-- Handle touch only if touch ended
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

	-- What button is pressed?
	local action = self.action
	if type(action) == "number" then
		-- It's a numeric or decimal button
		-- Check if we started a new input
		if isLastFunctional or displayStr == "0" then
			displayStr = ""
		end

		-- Turn AC button into C
		acButton:toC()
		-- Limit maxLength symbols on screen
		if displayStr and displayStr:len() < maxLength then
			displayStr = displayStr .. action
			-- Display the number
			calcScreen:setLabel(displayStr)
		end
		-- Set flag that a numeric button clicked, all next numbers will be appended to displayStr, until any func button is clicked
		isLastFunctional = false
	elseif action == "point" then
		if isLastFunctional then
			displayStr = "0."
			-- Turn AC button into C
			acButton:toC()
			isLastFunctional = false
		elseif not displayStr:find("%.") and displayStr:len() < maxLength then
			displayStr = displayStr .. "."
		end
		-- Display the number
		calcScreen:setLabel(displayStr)
	elseif action == "sign" then
		-- Sign button is clicked - invert number
		if displayStr ~= "0" then
			-- Invert number
			displayStr = calculator.invert(displayStr)
			calcScreen:setLabel(displayStr)
		end
		calcScreen:blink()
	elseif action == "memclear" then
		-- This will clear the memory, but will not update the display.
		calculator.memoryClear()
	elseif action == "memadd" then
		-- this works behind the scene. It will not change the display.
		calculator.memoryAdd(displayStr)
	elseif action == "memsub" then
		-- this works behind the scene. It will not change the display.
		calculator.memorySubtract(displayStr)
	elseif action == "memrecall" then
		displayStr = calculator.memoryRecall()
		calcScreen:setLabel(displayStr)
	elseif action == "clear" then
		-- C button is clicked - clear operand
		displayStr = "0"
		calculator.clearOperand()
		calcScreen:setLabel(displayStr)
		calcScreen:blink()
		-- Turn C button into AC
		acButton:toAC()
	elseif action == "reset" then
		-- AC button is clicked - reset everything
		displayStr = "0"
		calculator.clear()
		calcScreen:setLabel(displayStr)
	else
		-- If any of the functional buttons is clicked - pass operands and operator to the calculator class, get and display the result
		-- Pass current number to the calculator class
		if not isLastFunctional or action == "result" then
			calculator.setOperand(displayStr)
		end
		-- Pass current math operator to the calculator class and see if there is a result available
		if calculator.setOperator(action) then
			-- Get the result from the calculator class
			displayStr = calculator.getResult()
			-- If there is an error (division by zero) - display "Error" on the screen
			if calculator.error then
				displayStr = "ERROR"
			end
		end
		calcScreen:setLabel(displayStr)
		calcScreen:blink()
	end
	if type(action) ~= "number" and action ~= "point" then
		isLastFunctional = true
	end
	return true
end

-- Draw all the buttons
-- We have 6 rows X 4 columns grid, all buttons have the same width and height, except "0" - we have a special flag for that button
local position = 0
for i = 1, #buttonData do -- Iterate over all buttons in our config table
	local b = buttonData[i]
	position = position + 1 -- real screen position, we need this because of  "0" double width button
	local w, h = buttonWidth, buttonHeight
	-- If there is a double width flag
	if b.isWide then
		w = w * 2
	end
	-- Create a new button using our button class
	local button = newButton(b.label, w, h, b.backgroundColor, b.labelColor, b.isWide)
	button.action = b.action -- What action performs this button
	button.key = b.key -- What is the keyboard binding key for this button
	-- Screen coordinats, 4 buttons in a row
	button.x = display.screenOriginX + math.floor((position - 1) % 4) * w + w / 2
	button.y = display.screenOriginY + math.floor((position - 1) / 4) * h + top + h
	-- If the current button has double width - move actual position to the next column
	if b.isWide then
		position = position + 1
	end
	-- Button touch listener. We use touch instead of tap because we need to handle normal/pressed states
	button.touch = buttonTouch
	button:addEventListener("touch")
	-- Save a reference to the button
	buttons[#buttons + 1] = button

	-- Give our special button special ability - support both AC and C modes
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

--
-- Add key support for desktop builds
--
-- Capture the keystroke
-- Make a new "touch" event table and map "up" and "down" key phases to "ended" and "began" touch phases
-- Map any keys with weirdness. For instance + is SHIFT-=, * is SHIFT-8. The Numeric KeyPad keys all need
-- mapped as well. Make both enter keys the same as =
-- Loop over the buttons and see if our pressed key matches the defined key and if so
-- Call the touch function for that button with our made up event table
-- The touch function currently only cares about the phase of the touch, so we don't need to
-- pass in the x, y, and other variables. If the touch handler gets updated in the future to need
-- any of these extra values, then this function will need to be updated to pass them.pass
--
local function onKeyEvent(event)
	local e = {}
	e.name = "touch"
	if event.phase == "up" then
		e.phase = "ended"
	else
		e.phase = "began"
	end
	local key = event.keyName
	if key == "=" and event.isShiftDown then
		key = "+"
	elseif key == "8" and event.isShiftDown then
		key = "*"
	elseif key == "5" and event.isShiftDown then
		key = "%"
	elseif key == "-" and event.isAltDown then -- OS X mapping for +/- (Option Minus)
		key = "sign"
	elseif key == "f9" then -- Windows desktop mapping for +/-
		key = "sign"
	elseif key == "l" and event.isCtrlDown then
		key = "MC"
	elseif key == "p" and event.isCtrlDown then
		key = "M+"
	elseif key == "o" and event.isCtrlDown then
		key = "M-"
	elseif key == "r" and event.isCtrlDown then
		key = "MR"
	elseif key == "numPad0" then
		key = "0"
	elseif key == "numPad1" then
		key = "1"
	elseif key == "numPad2" then
		key = "2"
	elseif key == "numPad3" then
		key = "3"
	elseif key == "numPad4" then
		key = "4"
	elseif key == "numPad5" then
		key = "5"
	elseif key == "numPad6" then
		key = "6"
	elseif key == "numPad7" then
		key = "7"
	elseif key == "numPad8" then
		key = "8"
	elseif key == "numPad9" then
		key = "9"
	elseif key == "numPadEqual" then
		key = "="
	elseif key == "numPadEnter" then
		key = "="
	elseif key == "enter" then
		key = "="
	elseif key == "numPad+" then
		key = "+"
	elseif key == "numPad-" then
		key = "-"
	elseif key == "numPad." then
		key = "."
	elseif key == "numPad*" then
		key = "*"
	elseif key == "numPad/" then
		key = "/"
	elseif key == "escape" then
		key = "c"
	end
	for i = 1, #buttons do
		if buttons[i].key == key then
			buttons[i]:touch(e)
			return true
		end
	end
    return false
end
Runtime:addEventListener("key", onKeyEvent)
