--This is calc assitant class for all math functions. It works as small stacks - accepts numbers and operands, outputs result
local class = {}

--First and second operands
class.operand1 = 0;
class.operand2 = nil;
--operator - math func
class.operator = "";
--Division by zero error flag
class.error = false;
--This flag set when new result generated, used for animation in main code
class.result = false;
--Temporary variable for operand2, used if we want to repeat last operation(clicking "=" multiple times)
class.tmpOperand=nil;

--Method to set operands for our func
function class.setOperand(value)
	if class.operand1==0 then
		class.operand1 = value;
	else
		class.operand2=value;
	end
end
--This method returns results, it's always stored as operand1
function class.getResult()
	return class.operand1;
end
--Sets math operator, executes math function if needed and saves result to operand1
function class.setOperator(str)
	--If we have saved operand2 and user clicked "=" - repeat last math function,
	--so we need to restore operand2 from tmp variable
	if class.tmpOperand~=nil and str == "=" then
		class.operand2=class.tmpOperand;
	end
	class.tmpOperand=nil;
	
	--If we have have both operands and operator - perform math function and save result to operand1
	if class.operand2~=nil and class.operator~= "" then
		--set flag that we will have some result
		class.result = true;
		--Math functions:
		if class.operator == "-" then
			class.operand1=class.operand1 - class.operand2;
		elseif class.operator == "%" then
			class.operand1=class.operand1*class.operand2/100;
		elseif class.operator == "+" then
			class.operand1=class.operand1 + class.operand2;
		elseif class.operator == "X" then
			class.operand1=class.operand1 * class.operand2;
		elseif class.operator == "/" then
			--Division - check if operand2 not Zero, set error flag if needed.
			if class.operand2==0 then
				class.clear();
				class.error=true;
				return;
			end
			--Second operand not zero - perform division
			class.operand1=class.operand1/class.operand2;
		end
		--If user clicked "=" - save current operand2, so we can reuse it if user clicks "=" again
		if str == "=" then
			class.tmpOperand=class.operand2	
		end
		--Clear operand2, ready for next operation
		class.operand2=nil;	
	end
	--Save curent operator
	if str ~= "=" then
			class.operator = str;
	end
end
--This method clears everything
function class.clear()
	class.operand1=0
	class.operand2=nil
	class.operator="=";
	class.error = false;
	class.tmpOperand=nil;
end

return class;