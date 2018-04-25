classdef (Abstract) Stack < handle %#codegen
    %Stack LIFO stack interface
    % Defines the interface of a stack (last-in-first-out) class for use in
    % code generation.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = protected)
        data
        type
        maxSize
    end
    
    methods
        function b = is_empty(obj)
            %Stack.empty Test whether stack is empty
            % Returns whether the size of the stack is zero
            coder.inline('always');
            b = ~(obj.size() > 0);
        end
    end
    methods (Abstract)
        s = size(obj)
        %Stack.size Return size
        % Returns the number of elements in the stack.
        e = top(obj)
        %Stack.top Access next element
        % Returns the top element in the stack, i.e. the last element
        % inserted into the stack. The top element is not removed from
        % the stack.
        push(obj,e)
        %Stack.push Insert element
        % Inserts a new element at the top of the stack, above its
        % current top element.
        e = pop(obj)
        %Stack.pop Remove top element
        % Removes the element on top of the stack, effectively reducing
        % its size by one.
    end
end