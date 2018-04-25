%NullProgressReporter
% Implementation of the ProgressReporter interface that is silent.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) NullProgressReporter < matlab.bigdata.internal.executor.ProgressReporter
    methods
        function startOfExecution(~, ~, ~, ~)
        end
        
        function startOfNextTask(~, ~)
        end
        
        function progress(~, ~)
        end
        
        function endOfTask(~)
        end
        
        function endOfExecution(~)
        end
    end
end
