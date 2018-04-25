function bfitAddProp(obj, propName, serialize)
%BFITADDPROP Adds an instance property to a BasicFit/DataStats object 
%
%   BFITADDPROP(OBJ, PROPNAME) BFITADDPROP(OBJ, PROPNAME, SERIALIZE)
%
%   Note: This function creates a instance property with the following
%   properties:
%       Hidden = true; 
%  SERIALIZE, if specified, should be 'on' or 'off', which is translated to
%  false or true. If SERIALIZE is not specified, Transient is true.

%   Copyright 2008-2014 The MathWorks, Inc.
    
    if nargin < 3
        transient = true;
    else
        transient = strcmp(serialize, 'off');
    end
    obj = handle(obj);
    p = addprop(obj, propName);
    p.Transient = transient;
    p.Hidden = true;
end
