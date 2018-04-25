classdef (Sealed) Properties < handle
%

% Copyright 2011 The MathWorks, Inc.

    properties (SetAccess = private, Hidden = true)
        SupportsPartialAccess = true;
    end % end properties (SetAccess = private, Hidden = true)

    properties(SetAccess = private)
        Source = '';
    end % end properties(SetAccess = private)
    
    properties
        Writable = false;
    end % end properties

    methods

        function source = get.Source(obj)
            source = obj.Source;
        end

        function isWritable = get.Writable(obj)
            isWritable = obj.Writable;
        end
        
        function set.Writable(obj, isWritable)
            if ~islogical(isWritable) || ~isscalar(isWritable)
                error(message('MATLAB:MatFile:PropertiesWritableType'));
            end
            obj.Writable = isWritable;
        end
        
    end % end methods
    
    methods(Access = public, Hidden = true)

        function obj = Properties(Source)
            obj.Source = Source;
            % Set properties dependent on Source existence and version
            if exist(obj.Source, 'file')
                % obj.Writable is false by default for existing files
                obj.SupportsPartialAccess = matlab.internal.language.isPartialMATArrayAccessEfficient(obj.Source);
            else
                % obj.SupportsPartialAccess is true by default for new files
                obj.Writable = true;
            end
        end
        
        % Methods that we inherit, but do not want to show
        function out = eq(obj1, obj2)
            out = eq@dynamicprops(obj1, obj2);
        end
        function out = ge(obj1, obj2)
            out = ge@dynamicprops(obj1, obj2);
        end
        function out = gt(obj1, obj2)
            out = gt@dynamicprops(obj1, obj2);
        end
        function out = le(obj1, obj2)
            out = le@dynamicprops(obj1, obj2);
        end
        function out = lt(obj1, obj2)
            out = lt@dynamicprops(obj1, obj2);
        end
        function out = ne(obj1, obj2)
            out = ne@dynamicprops(obj1, obj2);
        end
        function out = findobj(obj1, obj2)
            out = findobj@handle(obj1, obj2);
        end
        function out = findprop(obj1, obj2)
            out = findprop@handle(obj1, obj2);
        end
        function out = addlistener(obj1, obj2)
            out = addlistener@handle(obj1, obj2);
        end
        function out = notify(obj1, obj2)
            out = notify@handle(obj1, obj2);
        end
        function delete(obj)
            delete@handle(obj);
        end
        
    end % end methods(Access = public, Hidden = true)     
end
