--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- main.lua -- App entry point. Sets up the User Interface, handles button presses
--
display.setStatusBar( display.TranslucentStatusBar )
-- List of all colors
local colors = require("classes.colors")
--Loading our helper classes : button, calculator display and math helper
local newButton = require("classes.button").newButton
local newScreen = require("classes.screen").newScreen
local calculator = require("classes.calculator")

--Buttons positions, labels and color settings. Order matters! Colors are 0-255 based and are converted to Corona SDK's 0..1 base later.
local buttonData = {
	{label = "AC",  action = "reset",    key = "c", backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "+/-",  action = "sign", key = "sign", backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "%",   action = "percent",  key = "%", backgroundColor = colors.secondaryBackground, labelColor = colors.secondaryLabel},
	{label = "÷",   action = "divide",   key = "/", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "7",   action = 7,          key = "7", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "8",   action = 8,          key = "8", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "9",   action = 9,          key = "9", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "×",   action = "multiply", key = "*", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "4",   action = 4,          key = "4", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "5",   action = 5,          key = "5", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "6",   action = 6,          key = "6", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "‒",   action = "subtract", key = "-", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "1",   action = 1,          key = "1", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "2",   action = 2,          key = "2", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "3",   action = 3,          key = "3", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "+",   action = "add",      key = "+", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel},
	{label = "0",   action = 0,          key = "0", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel, isWide = true},
	{label = ".",   action = "point",    key = ".", backgroundColor = colors.numpadBackground,    labelColor = colors.numpadLabel},
	{label = "=",   action = "result",   key = "=", backgroundColor = colors.primaryBackground,   labelColor = colors.primaryLabel}
}

-- AC button is special
local acButton
-- store a local reference to the buttons. We need this to support key events
local buttons = {} 

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
for i = 1, #buttonData do --Go over all buttons in our config table
	local b = buttonData[i]
	pos = pos + 1	--real screen pos, we need this because of  "0" double width button
	local w, h = buttonWidth, buttonHeight
	--If there is double width flag
	if b.isWide then
		w = w * 2
	end
	--Create new button using our calculator button class
	local button = newButton(b.label, w, h, b.backgroundColor, b.labelColor, b.isWide)
	button.action = b.action
	button.key = b.key
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
	-- Save a reference to the button
	buttons[ #buttons + 1 ] = button

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
-- Make a new "touch" event table and map "up" and "down" key phases to "ended" and "began" touch phases.
-- Map any keys with weirdness. For instance + is SHIFT-=, * is SHIFT-8. The Numeric KeyPad keys all need
-- mapped as well. Make both enter keys the same as =
-- Loop over the buttons and see if our pressed key matches the defined key and if so
-- Call the touch function for that button with our made up event table
-- The touch function currently only cares about the phase of the touch, so we don't need to 
-- pass in the x, y, and other variables. If the touch handler gets updated in the future to need
-- any of these extra values, then this function will need to be updated to pass them.pass
--
local function onKeyEvent( event )
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
			buttons[i]:touch( e )
			return true
		end
	end
    return false
end
Runtime:addEventListener( "key", onKeyEvent )