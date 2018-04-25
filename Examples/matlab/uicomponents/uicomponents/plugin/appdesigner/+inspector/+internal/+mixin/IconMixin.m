classdef IconMixin < handle	
	
	properties(SetObservable = true)		
		Icon@internal.matlab.variableeditor.datatype.FullPath
	end
	
	methods
		function val = get.Icon(obj)
           val = internal.matlab.variableeditor.datatype.FullPath(obj.OriginalObjects.Icon);
        end
        
        function set.Icon(obj, filePath)
           obj.OriginalObject.Icon = filePath.getText();
        end
	end
end