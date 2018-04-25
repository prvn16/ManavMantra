function ret = isMethod(obj, methname)
%isMethod  Check whether a method name exists on an object
%
%  codegen.isMethod(h, method) tests whether a method exists and is public
%  in an object.  This function returns true for hidden methods.  The
%  function returns false for all other datatypes.

%  Copyright 2014 The MathWorks, Inc.

% Default answer for cases where we can't find a class in the first case.
ret = false;

if isobject(obj)
    cls = metaclass(obj);
    if ~isempty(cls)
        % Modern matlab class.  Old struct-based classes return an empty.
        % Find a callable method that matches the given name
        callableMeths = findobj(cls.MethodList, ...
            'Access', 'public', ...
            'Abstract', false, ...
            'Name', methname);
        ret = ~isempty(callableMeths);
    else
        % Old-style object doesn't have hidden or private methods, so the
        % standard ismethod works fine
        ret = ismethod(obj, methname);
    end
    
elseif ishandle(obj)
    % Matlab handle.handle subclass.  These objects do not have access
    % restriction or visibility flags on methods, so the standard ismethod
    % works fine
    ret = ismethod(obj, methname);
    
else
    % Not an object, so no methods
end
