function B = saveObjectArray(obj)

%    Copyright 2001-2017 The MathWorks, Inc. 

if isvalid(obj)
    B.version = 3;  %Version to be used in 9a and forward.  Version will be 
        % incremented only if loadobj is no longer able to read the new format.
    vals = getSettableValues(obj);
    for i = 1:length(vals)
        B.(vals{i}) = get(obj, vals{i});
    end
elseif isempty(obj)
    B = [];    
end
