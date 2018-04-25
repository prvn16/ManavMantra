classdef StrictObjectComparator < matlab.unittest.constraints.Comparator
    % This class is undocumented and will change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = matlab.unittest.internal.constraints.isobject(value);
        end
        
        function bool = containerSatisfiedBy(~, actVal, expVal)
            bool = ...
                haveSameClass(actVal, expVal) && ...
                haveSameSize(actVal, expVal) && ...
                areEqual(actVal, expVal);
        end
    end
end

function bool = haveSameSize(actVal, expVal)
bool = isequal(safeSize(actVal), safeSize(expVal));
end

function bool = haveSameClass(actVal, expVal)
bool = strcmp(safeClass(actVal), safeClass(expVal));
end

function bool = areEqual(actVal, expVal)
% Compare the objects using
%   - eq for handles
%   - isequaln for values unless the class defines an isequal method
%     but no isequaln method. In that case, use isequal.

if safeIsa(expVal, 'handle')
    mask = expVal == actVal;
    bool = all(mask(:));
elseif shouldUseIsequaln(expVal)
    bool = isequaln(expVal, actVal);
else
    bool = isequal(expVal, actVal);
end
end

function bool = shouldUseIsequaln(obj)
mc = builtin('metaclass',obj);
if ~isempty(mc)
    methodList = mc.MethodList;
    bool = isempty(methodList.findobj('Name','isequal')) || ...
        ~isempty(methodList.findobj('Name','isequaln'));
else
    % Fall back to ismethod to support java, udd, and oops objects
    className = safeClass(obj);
    bool = ~ismethod(className,'isequal') || ismethod(className,'isequaln');
end
end

function sz = safeSize(obj)
sz = builtin('size',obj);
end

function cls = safeClass(obj)
cls = builtin('class',obj);
end

function bool = safeIsa(obj, cls)
bool = builtin('isa', obj, cls);
end

% LocalWords:  sz cls
