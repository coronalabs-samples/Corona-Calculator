--Loading our helper classes : button, calculator display and math helper
local buttonsClass = require "button";
local ScreenClass = require "screen";
local calc = require "calc";

--Buttons positions, labels and color settings
local buttons={
{label="AC",doublew=false,bg={188,189,191},txt={0,0,0}},{label="+/-",doublew=false,bg={188,189,191},txt={0,0,0}},{label="%",doublew=false,bg={188,189,191},txt={0,0,0}},{label="/",doublew=false,bg={243,123,17},txt={255,255,255}},
{label="7",doublew=false,bg={195,197,200},txt={0,0,0}},{label="8",doublew=false,bg={195,197,200},txt={0,0,0}},{label="9",doublew=false,bg={195,197,200},txt={0,0,0}},{label="X",doublew=false,bg={243,123,17},txt={255,255,255}},
{label="4",doublew=false,bg={195,197,200},txt={0,0,0}},{label="5",doublew=false,bg={195,197,200},txt={0,0,0}},{label="6",doublew=false,bg={195,197,200},txt={0,0,0}},{label="-",doublew=false,bg={243,123,17},txt={255,255,255}},
{label="1",doublew=false,bg={195,197,200},txt={0,0,0}},{label="2",doublew=false,bg={195,197,200},txt={0,0,0}},{label="3",doublew=false,bg={195,197,200},txt={0,0,0}},{label="+",doublew=false,bg={243,123,17},txt={255,255,255}},
{label="0",doublew=true,bg={195,197,200},txt={0,0,0}},{label=".",doublew=false,bg={195,197,200},txt={0,0,0}},{label="=",doublew=false,bg={243,123,17},txt={255,255,255}}
};
--Width of our buttons - we have 4 buttons in a row.
local width=display.contentWidth/4;
--Space for display - all free space
local top=display.contentHeight-width*5;
--Creating display screen
local calcScreen = ScreenClass.Create(top+width/2);
--Numeric button pressed flag
local numPressed=true;
--Negative button pressed flag
local negPressed=false;
--Calculator display string
local displayStr='0';

--Buttons tap event handler
function buttonTap(event)
	--This code changes button state/color. 
	if ( event.phase == "began" ) then
  		event.target.setPushed(true);
    elseif ( event.phase == "ended" ) then
        event.target.setPushed(false);
    end
    --Handle touch only if touch ended
    if event.phase~="ended" then
    	return
	end
	--What button pressed?
	local label = event.target.label;
	--Check if it's numeric or decimal button
	local numValue = tonumber( label )
	if numValue ~= nil or label=="." then
		--Check if we started new input
		if numPressed~=true then 
			displayStr = "0"; 
		end
		--Set flag that numeric button clicked, all next numbers will be appended to 1 string, until any func button clicked
		numPressed=true;	
		--Limit 9 numbers on screen, except "." and "-" symbols
		local len=string.len(displayStr);
		if string.find(displayStr,"-") then
			len=len-1;
		end
		if string.find(displayStr,".") then
			len=len-1;
		end
		if len<9 then
		displayStr = displayStr .. label;
		end
		--If previous button was "+/-", add a "-" to beginning of display string
		if negPressed then
			displayStr = "-"..displayStr;
			negPressed = false;
		end
		--If "."(decimal) button clicked - add it to a string. If it's first symbol in a string - conver to "0.X"
		if label~="." then
			displayStr = tonumber(displayStr);
			if displayStr and displayStr<1 and displayStr>0 then
				displayStr = "0"..tostring(displayStr);
			else
				displayStr=tostring(displayStr);	
			end
		end		
		--Display number
		calcScreen.setLabel(displayStr);
		return true
	else
		--If Clear button clicked - reset everything
		if label=="AC" then
			displayStr = "0"; 
			negPressed=false;
			numPressed=true;
			calc.clear();
			calcScreen.setLabel(displayStr);
			return;
		--If negative button clicked - convert number or save negative flag, so "-" will be added when next numeric button clicked
		elseif label=="+/-" then
			numPressed=true;
		 	local num = tonumber(displayStr);
		 	--Invert number
			if num and num<0 then
				displayStr = string.sub(displayStr,2);
			elseif num and num>0 then
				displayStr = "-"..displayStr;
			end
			--We will add "-" at next step if current number zero
			if num~=0 then 
				calcScreen.setLabel(displayStr);
			else
				negPressed=true;
			end
			return;
		--IF any of functional buttons clicked - pass operands and operator to calc class, get and display results
		else
			--Pass new typed number to calc class
			if numPressed then
				calc.setOperand(tonumber(displayStr));
			end
			--Pass current math operator to calc class
			calc.setOperator(label);
			--Get result from calc class
			displayStr = calc.getResult();
			-- If there is error(division by zero) - display "Error" on display
   			if calc.error then 
   				displayStr = "ERROR"; 
   			end
   			--If there is new result - show animation
 			calcScreen.setLabel(displayStr);

   			--[[if calc.result then
   				calc.result=false;
   				--Move current number out of screen and display new(result) on screen.
   				local tmpScreen=calcScreen;
   				transition.to(tmpScreen,{time=250,y=-top*2});
   				calcScreen=ScreenClass.Create(top+width/2);
   				calcScreen.setLabel(displayStr);
    		end]]--
		end
		numPressed=false;
		
	end
end

--Draws all butoons
--We have 5 rows X 4 columns, all buttons has same width and height, except "0" - we have a special flag for this button
local pos=0;
for i=1,#buttons do --Go over all buttons in our config table
	pos=pos+1;	--real screen pos, we need this because of  "0" double width button
	local w=width;
	--If there is double width flag 
	if(buttons[i].doublew) then
		w=w*2;
	end
	--Create new button using our calculator button class
	local tmpButton= buttonsClass.Create(buttons[i].label,w,width,buttons[i].bg,buttons[i].txt);
	-- button(center) position - 4 buttons in a row
	tmpButton.x=(math.floor((pos-1) % 4))*w+w/2;
    tmpButton.y = (math.floor((pos-1) / 4))*width+top+width;
    --if current button("0") has double width - move actual position to next column
    if(buttons[i].doublew) then
    	pos=pos+1;
    end
    --Button touch listener. We using touch, instead of tap, because we need to handle buttons normal/pushed states.
    tmpButton:addEventListener("touch",buttonTap);

end

