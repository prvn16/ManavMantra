classdef BorderTypeMixin < handle	
	
	properties(SetObservable = true)		
		BorderType@inspector.internal.datatype.BorderType
	end
	
	methods
		function set.BorderType(obj, inspectorValue)
			obj.OriginalObjects.BorderType = char(inspectorValue);
		end		
		
		function value = get.BorderType(obj)
			value = inspector.internal.datatype.BorderType.(obj.OriginalObjects.BorderType);
		end
	end
end