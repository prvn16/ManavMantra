classdef(Hidden) Class < internal.matlab.codetools.reports.matlabType.MatlabFileType

    %Copyright 2009 The MathWorks, Inc.
    properties
    end
    
    methods
        function string = char(~)
            string = getString(message('MATLAB:codetools:reports:Class'));
        end
    end
    
end

