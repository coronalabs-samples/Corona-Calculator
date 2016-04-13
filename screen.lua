--
-- Corona-Calculator
-- A simple calcuator made with Corona SDK
--
-- MIT Licensed
--
-- screen.lua - This is a class for our calculator display.
-- It has only one Create and setLabel methods
local class = {};
-- Creates Calculator display object, accepts only 1 param - display height. width is always 100%
	function class.Create(height)
		-- New display group that will contain our objects(only 1 object for now)
		local screen = display.newGroup();
		-- New text object. New syntax used, so "align" property supported there.
		local text = display.newText( {text = "0", x = 0, y = 0, fontSize = 52, font = native.systemFont, width = display.contentWidth, align = "right" })
		-- text color
		text:setFillColor(1,1,1);
		-- Object anchor points:
		-- X=0 and Y=0, means bottom left corner
		text.anchorX = 0;
		text.anchorY = 1;
		-- Setting display position(setting coordiantes of the bottom left corner)
		text.x = 0;
		text.y = height;
		-- Insert our text object to screen group.
		screen:insert( text );
		-- Method to set display text
		function screen.setLabel( str )
			text.text = str;
		end
		return screen;
	end
return class;