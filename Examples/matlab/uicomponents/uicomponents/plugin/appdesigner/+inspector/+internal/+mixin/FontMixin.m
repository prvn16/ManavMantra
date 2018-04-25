classdef FontMixin < handle	
	
	properties(SetObservable = true)		
		 FontName@matlab.graphics.datatype.FontName
		 FontSize@matlab.graphics.datatype.PositiveWithZero
		 FontWeight@inspector.internal.datatype.FontWeight
         FontAngle@inspector.internal.datatype.FontAngle
	end		
end