classdef EnableMixin < handle	
	
	properties(SetObservable = true)		
		Enable@inspector.internal.datatype.Enable
	end
	
	methods
		function set.Enable(obj, inspectorValue)
			obj.OriginalObjects.Enable = char(inspectorValue);
		end		
		
		function value = get.Enable(obj)
			value = inspector.internal.datatype.Enable.(obj.OriginalObjects.Enable);
		end
	end
end