classdef(Hidden) Function < internal.matlab.codetools.reports.matlabType.MatlabFileType

    %Copyright 2009-2011 The MathWorks, Inc.
    properties
    end
    
    methods
        function string = char(~)
            string = getString(message('MATLAB:codetools:reports:Function'));
        end

    end
    
end

