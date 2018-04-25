classdef LogicalArrayViewModel < ...
        internal.matlab.variableeditor.ArrayViewModel
    % LOGICALARRAYVIEWMODEL
    % Logical Array View Model

    % Copyright 2015 The MathWorks, Inc.

    % Public Abstract Methods
    methods (Access = public)
        % Constructor
        function this = LogicalArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
    end
end