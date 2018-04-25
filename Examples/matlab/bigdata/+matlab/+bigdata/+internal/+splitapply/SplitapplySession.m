%SplitapplySession
% Class that holds state shared by all GroupedPartitionedArray objects
% within one call to splitapply.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef SplitapplySession < handle
    properties (SetAccess = immutable)
        % The underlying function handle for error purposes.
        FunctionHandle;
    end
    
    properties (SetAccess = private)
        % A logical scalar that is true if and only if we are still in the
        % call to splitapply. This is intended as a guard to prevent valid
        % GroupedPartitionedArray escaping out of the splitapply function.
        IsValid = true;
    end
    
    methods
        function obj = SplitapplySession(fun)
            obj.FunctionHandle = fun;
        end
        
        % Close the session.
        function close(obj)
            obj.IsValid = false;
        end
    end
end
