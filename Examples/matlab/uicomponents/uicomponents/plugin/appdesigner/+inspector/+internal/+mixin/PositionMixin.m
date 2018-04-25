classdef PositionMixin < handle
	% This class provides the property definition and groupings for Lamp
	
	properties(SetObservable = true)
		
		Position@matlab.graphics.datatype.Position
	end
	
	methods
		function set.Position(obj, newPosition)
			
			obj.OriginalObjects.Position = newPosition;
		end
		
		function pos = get.Position(obj)			
			pos = obj.OriginalObjects.Position;
		end
	end
end