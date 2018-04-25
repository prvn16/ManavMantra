classdef AddVerificationEventDecorator < matlab.unittest.internal.TaskDecorator
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function objArray = AddVerificationEventDecorator(tasks)
            objArray = objArray@matlab.unittest.internal.TaskDecorator(tasks);
        end
    end
    
    methods (Access=protected)
        function diags = getElementVerificationDiagnostics(task)
            diags = task.getDefaultQualificationDiagnostics;
        end
    end
end

% LocalWords:  ADDVERIFYEVENTDECORATOR TASKDECORATOR diags
