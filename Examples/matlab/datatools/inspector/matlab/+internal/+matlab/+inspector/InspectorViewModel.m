classdef InspectorViewModel < internal.matlab.variableeditor.ObjectViewModel
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % View Model for the Property Inspector.  Extends the ObjectViewModel
    % to provide functionality specific to the Inspector
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Access = public)
        % Constructor
        function this = InspectorViewModel(dataModel)
            this@internal.matlab.variableeditor.ObjectViewModel(dataModel);
        end
    end
    
    methods(Access = protected)
        
        % Override the getFieldData method to call the getPropertyValue
        % method on the InspectorProxyMixin class.
        function fieldData = getFieldData(~, data, fn)
            if nargin == 2
                % Gaurd against the field name not being specified
                fieldData = [];
            else
                fieldData = data.getPropertyValue(fn);
            end
        end
    end
end