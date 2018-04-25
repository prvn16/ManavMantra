classdef ProceduralFileInformation < matlab.unittest.internal.fileinformation.FileInformation
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        MethodList  matlab.unittest.internal.fileinformation.CodeSegmentInformation = matlab.unittest.internal.fileinformation.MethodInformation.empty(1,0);
    end
    
    properties (SetAccess = private)
        ExecutableLines
    end
    
    properties (Access = private)
        SetExecutableLines = false;
    end
    
    methods (Access = ?matlab.unittest.internal.fileinformation.FileInformation)
        function info = ProceduralFileInformation(fullName,parseTree)
            info = info@matlab.unittest.internal.fileinformation.FileInformation(fullName,parseTree);
        end
    end
    
    methods
        function lines = get.ExecutableLines(info)
            if ~info.SetExecutableLines
                info.ExecutableLines = getExecutableLines(info);
                info.SetExecutableLines = true;
            end
            lines = info.ExecutableLines;
        end
    end
end

