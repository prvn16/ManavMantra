function aObjH = getobj(HG)
%GETOBJ  Retrieve Scribe Object from Handle Graphics handle.

%   Copyright 1984-2002 The MathWorks, Inc. 

ud = getscribeobjectdata(HG);
if isfield(ud, 'HandleStore') 
    aObjH = ud.HandleStore;
else  % if ud is [] or not a struct, isfield returns 0
    aObjH = [];
end

