function ind = checkInputName(actualName,expectedNames,minLength)
%checkInputName Check name of input argument
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
% Check name of input argument. expectedNames must be a char vector, or a
% cell array of char vectors. Return false if actualName is '' or [].

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin < 3
    minLength = 1;
end
if (ischar(actualName) && isrow(actualName)) || ...
   (isstring(actualName) && isscalar(actualName))
    ind = strncmpi(actualName, expectedNames, ...
        max(minLength,strlength(actualName)));
else
    ind = false(size(expectedNames));
end