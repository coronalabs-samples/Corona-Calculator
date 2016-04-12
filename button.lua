--Class that draws calculator button
local class = {};
--Create method - accepts button label, width and height, button color and text color
function class.Create(labelTxt,width,height,bgColor,txtColor)
	--Let's create new display group for our button objects
	local button = display.newGroup();
	--Button background - filled rect object
	local back = display.newRect(0,0,width,height);
	--Buttons label - text object
	local label = display.newText(labelTxt,0,0,native.systemFont, 18)
	--Align to top left corner in display group
	back.x,back.y,label.x,label.y=0,0,0,0;
	--Let's set background and text colors
	back:setFillColor(bgColor[1]/255,bgColor[2]/255,bgColor[3]/255);
	label:setFillColor(txtColor[1]/255,txtColor[2]/255,txtColor[3]/255);
	--Button border width and color
	back.strokeWidth = 1
	back:setStrokeColor(0,0,0,1)
	--Set's buttons label
	button.label=labelTxt;
	--Adding our objects to display group
	button:insert(back);
	button:insert(label);
	--Method to set buttons state - pushed or not. This method used in touch event listener.
	function button.setPushed(pushed)
		--If pushed - set a darker background color
			if pushed then
				back:setFillColor(bgColor[1]/255-10/255,bgColor[2]/255-10/255,bgColor[3]/255-10/255);
			else
				back:setFillColor(bgColor[1]/255,bgColor[2]/255,bgColor[3]/255);
			end
		end
	return button;
end
return class;
