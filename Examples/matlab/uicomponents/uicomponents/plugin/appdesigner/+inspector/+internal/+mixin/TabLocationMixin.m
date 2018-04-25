classdef TabLocationMixin < handle	
	
	properties(SetObservable = true)		
		TabLocation@inspector.internal.datatype.TabLocation
	end
	
	methods
		function set.TabLocation(obj, inspectorValue)
			obj.OriginalObjects.TabLocation = char(inspectorValue);
		end		
		
		function value = get.TabLocation(obj)
			value = inspector.internal.datatype.TabLocation.(obj.OriginalObjects.TabLocation);
		end
	end
end