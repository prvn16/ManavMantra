function property = bfitFindProp(obj, propname)
%BFITFINDPROP  Find a property 
%
%   PROPERTY = BFITFINDPROP(OBJ, PROPNAME)

%   Copyright 2008-2012 The MathWorks, Inc.

% Need to convert obj to a handle since in some cases, it was 
% previously converted to a double. For instance Java is expecting 
% "figures" to be doubles.

if isempty(obj)
    property = [];
else
    property = findprop(handle(obj), propname);
end

end
