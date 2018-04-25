function setRemovalPermissions(hArg,status,hFunc)
% Specify that the variable that it may or may not optionally be removed when
% the last function that output it is generated

% Copyright 2006 The MathWorks, Inc.

if status
    hArg.FunctionList =[hArg.FunctionList hFunc];
    hArg.AllowRemovalList(end+1) = true;
else
    if ~isempty(hArg.AllowRemovalList)
        hArg.AllowRemovalList(end) = false;
    end
end