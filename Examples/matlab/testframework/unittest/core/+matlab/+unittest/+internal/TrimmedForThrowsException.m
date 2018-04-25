classdef TrimmedForThrowsException < matlab.unittest.internal.TrimmedException
% This class is undocumented.

% Copyright 2015-2017 MathWorks, Inc. 
    methods
        function trimmed = TrimmedForThrowsException(other)
            trimmed = trimmed@matlab.unittest.internal.TrimmedException(other);
        end
    end
    methods(Access=protected)
        function stack = getStack(trimmed)
            % Get the stack
            stack = trimmed.OriginalException.getStack;
            
            % Get the location of the Function Handle Constraint
            frameworkFolder = matlab.unittest.internal.getFrameworkFolder;
            fcnHandleConstraintLocation = fullfile(frameworkFolder, 'unittest', 'core', '+matlab','+unittest', '+internal', '+constraints', 'FunctionHandleConstraint.');
                    
            % find the first index of the frame corresponding to FunctionHandleConstraint in the stack
            files = {stack.file};
            fcnHandleConstraintMethodIndex = find(strncmp(files, fcnHandleConstraintLocation, ...
                                                  numel(fcnHandleConstraintLocation)), 1, 'first');
            
            % Trim anything under FunctionHandleConstraint
            stack(fcnHandleConstraintMethodIndex:end)=[];
        end        
    end
end