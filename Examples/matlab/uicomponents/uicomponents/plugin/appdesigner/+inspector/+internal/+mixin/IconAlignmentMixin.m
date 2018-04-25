classdef IconAlignmentMixin < handle	
	
	properties(SetObservable = true)		
		IconAlignment@inspector.internal.datatype.IconAlignment
	end
	
	methods
		function set.IconAlignment(obj, inspectorValue)
			obj.OriginalObjects.IconAlignment = char(inspectorValue);
		end		
		
		function value = get.IconAlignment(obj)
			value = inspector.internal.datatype.IconAlignment.(obj.OriginalObjects.IconAlignment);
		end
	end
end