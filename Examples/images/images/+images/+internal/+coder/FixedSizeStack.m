classdef FixedSizeStack < images.internal.coder.Stack %#codegen
    %FixedSizeStack LIFO stack with a fixed capacity
    % Implementation of a stack (last-in-first-out) for use in code 
    % generation when the capacity of the stack is known ahead of time and
    % cannot change.
    %
    % Note: Stack.push() does *NOT* check that the type of the element
    %       being push is the same as the type for which the stack was
    %       created. Implicit casting will happen if no error is thrown.
    %       Check your generated code.
    
    % Possible future enhancements:
    %   - add a "resize" function
    %   - add the ability to automatically resize the stack when it is full
    %     (as an alternative to VariableSizeStack)
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    %#ok<*EMCA>
    
    properties (Access = protected)
        indexTop
    end
    
    methods
        function obj = FixedSizeStack(maxSize,type)
            %FixedSizeStack Class constructor.
            % Create a stack (last-in-first-out) by specifying the maximum 
            % size of the stack and the type of the data. type can be the 
            % string 'indexInt' or any type supported by MATLAB Coder 
            % specified as a string. The default value of type is 
            % 'indexInt'.
            coder.inline('always');
            narginchk(1,2);
                        
            % Check maxSize
            validateattributes(maxSize,{'numeric'}, ...
                {'scalar','integer','positive'}, ...
                mfilename,'MAXSIZE',1);
            
            % maxSize must be a compile-time constant
            coder.internal.errorIf(~coder.internal.isConst(maxSize), ...
                'MATLAB:images:validate:codegenInputNotConst','maxSize');
            
            obj.maxSize = maxSize;
            
            % Check type
            if (nargin < 2)
                type = 'indexInt'; % default
            else
                % type must be a compile-time constant
                coder.internal.errorIf(~coder.internal.isConst(type), ...
                    'MATLAB:images:validate:codegenInputNotConst','type');
                
                validatestring(type,{'indexInt','logical','single', ...
                    'double','uint8','uint16','uint32','uint64', ...
                    'int8','int16','int32','int64'},mfilename,'TYPE',1);
            end
            obj.type = coder.const(type);
            
            % Declare the underlying array without initializing
            if (strcmp(type,'indexInt'))
                arr = coder.nullcopy(coder.internal.indexInt(zeros(1,maxSize)));
            else
                arr = coder.nullcopy(cast(zeros(1,0),type));
            end
            obj.data = arr;
            
            % The array is empty at creation
            obj.indexTop = coder.internal.indexInt(0);
        end
        function s = size(obj)
            %Stack.size Return size
            % Returns the number of elements in the stack.
            coder.inline('always');
            s = obj.indexTop;
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
            
            e = obj.data(obj.indexTop); 
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
            
            nextIndex = coder.internal.indexPlus(obj.indexTop,1);
            
            % Check for stack overflow
            coder.internal.errorIf(nextIndex > obj.maxSize, ...
                'images:Stack:stackIsFull');
            
            obj.data(nextIndex) = e; % implicit casting happens here
            obj.indexTop = nextIndex;
        end
        function e = pop(obj)
            %Stack.pop Remove top element
            % Removes the element on top of the stack, effectively reducing
            % its size by one.
            coder.inline('always');
            
            % Check that there is an element to pop
            coder.internal.errorIf(obj.is_empty(), ...
                'images:Stack:stackIsEmpty');
            
            e = obj.data(obj.indexTop);
            obj.indexTop = coder.internal.indexMinus(obj.indexTop,1);
        end
    end
end
