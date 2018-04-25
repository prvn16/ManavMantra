function out = MapAssign(obj,subs,m)
%MAPASSIGN   
% Copyright 2016 The MathWorks, Inc.

    if isempty(obj) && strcmp(class(obj),'double') %#ok<STISA>
        % the LHS is a new array.
        x = []; %#ok<NASGU>
        % validate the subs assignment on an empty double
        try 
            x = subsasgn([],subs,0);
        catch ME
            throwAsCaller(ME);
        end
        if isequal(x,0)
            out = m;
            return
        end
    end
    
    if isobject(obj)
        % this may be unhittable; defensive coding.
        error(message('MATLAB:Containers:Map:subsasgn:NonScalarAssign',class(obj)))    
    end
    
    % Otherwise, try the builtin subsasn
    try
        out = builtin('subsasgn',obj,subs,m);
    catch ME
        throwAsCaller(ME)
    end
    
end

