--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- calc.lua This is calc assitant class for all math functions. It works as small stacks - accepts numbers and operands, outputs result
--

-- This library deals with huge numbers without losing precision
local bn = require("libs.bn")

local class = {}

local numZero = bn.Int("0")
-- First and second operands
class.operand1 = bn.Int("0")
class.operand2 = nil
-- Math operator
class.operator = ""
-- Division by zero error flag
class.error = false
-- This flag is set when a new result is generated
class.result = false
-- Temporary variable for operand2, used if we want to repeat last operation (by clicking "=" multiple times)
class.tmpOperand = nil

-- Method to set operands for our calculations
function class.setOperand(value)
	local num = bn.Float(value)
	if class.operand1 == numZero then
		class.operand1 = num
	else
		class.operand2 = num
	end
end

-- This method returns results, it's always stored as operand1
function class.getResult()
	return tostring(class.operand1)
end

-- Sets math operator, executes math function if needed and saves result to operand1
function class.setOperator(str)
	-- If we have saved operand2 and user clicked "=" - repeat last math function,
	-- so we need to restore operand2 from tmp variable
	if class.tmpOperand and str == "result" then
		class.operand2 = class.tmpOperand
	end
	class.tmpOperand = nil

	-- If we have both operands and operator - perform math function and save result to operand1
	if class.operand2 and class.operator ~= "" then
		-- Set flag that we will have some result
		class.result = true
		-- Math functions:
		if class.operator == "subtract" then
			class.operand1 = class.operand1 - class.operand2
		elseif class.operator == "percent" then
			class.operand1 = class.operand1 * class.operand2 / bn.Int("100")
		elseif class.operator == "add" then
			class.operand1 = class.operand1 + class.operand2
		elseif class.operator == "multiply" then
			class.operand1 = class.operand1 * class.operand2
		elseif class.operator == "divide" then
			-- Division - check if operand2 is not Zero, set error flag if needed
			if class.operand2 == numZero then
				class.clear()
				class.error = true
				return
			end
			-- Second operand not zero - perform division
			class.operand1 = class.operand1 / class.operand2
		end
		-- If user clicked "=" - save current operand2, so we can reuse it if user clicks "=" again
		if str == "result" then
			class.tmpOperand = class.operand2
		end
		-- Clear operand2, ready for the next operation
		class.operand2 = nil
	end
	-- Save curent operator
	if str ~= "result" then
		class.operator = str
	end
end

function class.invert(value)
	return tostring(-bn.Float(value))
end

-- This method clears everything
function class.clear()
	class.operand1 = bn.Int("0")
	class.operand2 = nil
	class.operator = "result"
	class.error = false
	class.tmpOperand = nil
end

-- This method clears last operand
function class.clearOperand()
	class.operand2 = nil
	class.tmpOperand = nil
end

return class
