%InternalStackFrame
% Helper RAII class that marks the current stack frame as internal-only.
% This means it will not be included in the stack thrown by tall/gather.

%   Copyright 2016 The MathWorks, Inc.

classdef InternalStackFrame < handle
    
    properties (SetAccess = immutable)
        % A logical scalar that specifies if this is the first
        % InternalStackFrame on the stack.
        IsTopLevel = false;
    end
    
    methods
        % Construct a internal frame marker for the current function.
        %
        % This optionally accepts an override to the user stack frame. This
        % is to allow the tall/invoke methods to insert the name of the
        % method as a stack frame.
        function obj = InternalStackFrame(userStack)
            stack = obj.userStackState();
            if isequal(stack, [])
                if ~nargin
                    userStack = dbstack('-completenames', 2);
                end
                obj.userStackState(userStack);
                obj.IsTopLevel = true;
            end
        end
        
        function delete(obj)
            if obj.IsTopLevel
                obj.userStackState([]);
            end
        end
    end
    
    methods (Static)
        % Static method that returns true if and only if InternalStackFrame
        % objects exist.
        function tf = hasInternalStackFrames()
            stack = matlab.bigdata.internal.InternalStackFrame.userStackState();
            tf = ~isequal(stack, []);
        end
        
        % Static method that returns the user-visible part of the stack.
        function stack = userStack()
            stack = matlab.bigdata.internal.InternalStackFrame.userStackState();
            if isequal(stack, [])
                stack = dbstack('-completenames', 1);
            end
        end
    end
    
    methods (Static, Access = private)
        % Singleton state for the current non-internal stack.
        function out = userStackState(in)
            persistent value;
            if isequal(value, [])
                value = [];
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
    end
end
