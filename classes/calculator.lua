--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- calc.lua This is calc assistant class for all math functions. It works as small stacks - accepts numbers and operands, outputs result
--

-- This library deals with huge numbers without losing precision
local bn = require("libs.bn")

local class = {}

local numZero = bn.Int("0")
-- First and second operands
class.operand1 = nil
class.operand2 = nil
-- Result storage
class.result = bn.Int("0")
-- Temporary variable for operand2, used if we want to repeat last operation (by clicking "=" multiple times)
class.tmpOperand = nil
-- Memory storage
class.memory = bn.Int("0")
-- Math operator
class.operator = nil
-- Division by zero error flag
class.error = false

-- Method to set operands for our calculations
function class.setOperand(value)
	local num = bn.Float(value)
	if class.operand1 == nil then
		class.operand1 = num
	else
		class.operand2 = num
	end
end

-- This method returns results, it's always stored as operand1
function class.getResult()
	return tostring(class.result)
end

-- Sets math operator, executes math function if needed and saves result to operand1
function class.setOperator(str)
	local hasResult = false
	-- If we have saved operand2 and user clicked "=" - repeat last math function,
	-- so we need to restore operand2 from tmp variable
	if class.operand1 and class.tmpOperand and str == "result" then
		class.operand2 = bn.Float(class.tmpOperand)
	end
	class.tmpOperand = nil

	-- If we have both operands and operator - perform math function and save result to operand1
	if class.operand1 and class.operand2 and class.operator then
		hasResult = true
		-- Math functions:
		if class.operator == "subtract" then
			class.result = class.operand1 - class.operand2
		elseif class.operator == "percent" then
			class.result = class.operand1 * class.operand2 / bn.Int("100")
		elseif class.operator == "add" then
			class.result = class.operand1 + class.operand2
		elseif class.operator == "multiply" then
			class.result = class.operand1 * class.operand2
		elseif class.operator == "divide" then
			-- Division - check if operand2 is not Zero, set error flag if needed
			if class.operand2 == numZero then
				class.clear()
				class.error = true
				return hasResult
			end
			-- Second operand not zero - perform division
			class.result = class.operand1 / class.operand2
		end
		-- If user clicked "=" - save current operand2, so we can reuse it if user clicks "=" again
		if str == "result" then
			class.tmpOperand = class.operand2
		end
		-- Copy result to the operand1
		class.operand1 = bn.Float(class.result)
		-- Clear operand2, ready for the next operation
		class.operand2 = nil
	end
	-- Save curent operator
	if str ~= "result" then
		class.operator = str
	end
	return hasResult
end

function class.invert(value)
	return tostring(-bn.Float(value))
end

-- This method clears everything
function class.clear()
	class.operand1 = nil
	class.operand2 = nil
	class.result = bn.Int("0")
	class.tmpOperand = nil
	class.operator = nil
	class.error = false
end

-- This method clears last operand
function class.clearOperand()
	class.tmpOperand = bn.Float(class.result)
	class.operand1 = nil
	class.operand2 = nil
end

-- This method clears memory
function class.memoryClear()
	class.memory = bn.Int("0")
end

-- This method returns the current memory value
function class.memoryRecall()
	if class.operand2 == nil then
		if class.tmpOperand == nil then
			class.operand2 = bn.Float(class.memory)
		else
			class.operand1 = bn.Float(class.memory)
		end
	end
	return tostring(class.memory)
end

-- This method will increment the saved memory value
function class.memoryAdd(value)
	class.memory = class.memory + bn.Float(value)
	class.setOperand(value)
end

-- This method will decrement the saved memory value
function class.memorySubtract(value)
	class.memory = class.memory - bn.Float(value)
	class.setOperand(value)
end

return class
