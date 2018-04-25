%KEYS Return keys of containers.Map object
%   K = KEYS(mapObj) returns a cell array containing all of the keys stored
%   in mapObj.
%
%   Examples:
%
%     myKeys = {'a','b','c'};
%     myValues = [1,2,3];
%     mapObj = containers.Map(myKeys,myValues);
% 
%     keySet = keys(mapObj)
% 
%   See Also containers.Map, values, isKey, remove

%   Copyright 2008 The MathWorks, Inc.
%   Built-in function.