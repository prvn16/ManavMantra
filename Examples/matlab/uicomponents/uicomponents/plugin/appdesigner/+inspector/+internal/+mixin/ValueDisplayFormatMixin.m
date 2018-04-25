classdef ValueDisplayFormatMixin < handle	
	
	properties(SetObservable = true)		
		ValueDisplayFormat@internal.matlab.variableeditor.datatype.DisplayFormat
	end
	
	methods
		function val = get.ValueDisplayFormat(obj)
           val = internal.matlab.variableeditor.datatype.DisplayFormat(obj.OriginalObjects.ValueDisplayFormat);
        end
        
        function set.ValueDisplayFormat(obj, filePath)
           obj.OriginalObject.ValueDisplayFormat = filePath.getText();
        end
	end
end