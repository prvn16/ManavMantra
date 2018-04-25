classdef VariableSizeStack < images.internal.coder.Stack %#codegen
    %VariableSizeStack LIFO stack with an undefinied capacity
    % Implementation of a stack (last-in-first-out) for use in code 
    % generation when the maximum number of elements is undefined. Memory
    % reallocation will be necessary if pushing more elements than the
    % underlying array can contain. For better performance use
    % FixedSizeStack.
    %
    % Note: Stack.push() does *NOT* check that the type of the element
    %       being push is the same as the type for which the stack was
    %       created. Implicit casting will happen if no error is thrown.
    %       Check your generated code.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    %#ok<*EMCA>
    
    methods
        function obj = VariableSizeStack(type)
            %VariableSizeStack Class constructor.
            % Create a stack (last-in-first-out) by specifying the maximum 
            % size of the stack and the type of the data. type can be the 
            % string 'indexInt' or any type supported by MATLAB Coder 
            % specified as a string. The default value of type is 
            % 'indexInt'.
            coder.inline('always');
            narginchk(0,1);
            
            % Check type
            if (nargin == 0)
                type = 'indexInt'; % default
            else
                % type must be a compile-time constant
                coder.internal.errorIf(~coder.internal.isConst(type), ...
                    'MATLAB:images:validate:codegenInputNotConst','type');
                
                validatestring(type,{'indexInt','logical','single', ...
                    'double','uint8','uint16','uint32','uint64', ...
                    'int8','int16','int32','int64'},mfilename,'TYPE',1);
            end
            obj.type = type;
            
            % Set the size of the underlying array
            coder.varsize('arr',[1,Inf],[0,1]);
            
            % Set the type of the underlying array
            if (strcmp(type,'indexInt'))
                arr = coder.internal.indexInt(zeros(1,0));
            else
                arr = cast(zeros(1,0),type);
            end
            obj.data = arr;
        end
        function s = size(obj)
            %Stack.size Return size
            % Returns the number of elements in the stack.
            coder.inline('always');
            s = coder.internal.indexInt(size(obj.data,2));
        end
        function e = top(obj)
            %Stack.top Access next element
            % Returns the top element in the stack, i.e. the last element
            % inserted into the stack. The top element is not removed from
            % the stack.
            coder.inline('always');
            
            % Check that there is an element to retrieve
            coder.internal.errorIf(obj.is_empty(), ...
                'images:Stack:stackIsEmpty');
            
            e = obj.data(end);
        end
        function push(obj,e)
            %Stack.push Insert element
            % Inserts a new element at the top of the stack, above its
            % current top element.
            coder.inline('always');
            coder.internal.prefer_const(e);
            
            % Empty elements are not supported
            coder.internal.errorIf(isempty(e),'images:Stack:emptyElement');
            
            % Only scalars are supported
            coder.internal.errorIf(~isscalar(e), ...
                'images:Stack:mustBeScalar');
            
            obj.data = [obj.data,e]; % implicit casting happens here
        end
        function e = pop(obj)
            %Stack.pop Remove top element
            % Removes the element on top of the stack, effectively reducing
            % its size by one.
            coder.inline('always');
            
            % Check that there is an element to pop
            coder.internal.errorIf(obj.is_empty(), ...
                'images:Stack:stackIsEmpty');
            
            e = obj.data(end);
            obj.data = obj.data(1:end-1);
        end
    end
end
