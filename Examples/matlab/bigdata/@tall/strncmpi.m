function out = strncmpi(s1, s2, n)
%STRNCMPI Compare first N characters of strings ignoring case.
%   TF = STRNCMPI(S1,S2,N)
%
%   See also: tall/STRCMP, tall/STRCMPI, tall/STRNCMP, 
%             tall/STRREP, tall/STR2DOUBLE.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(3,3);

if istall(n) || ~isscalar(n) || ~isnumeric(n) || n<1 || n~=round(n)
    error(message('MATLAB:strcmp:SizeMustBeInt'));
end

% Use the common helper for most of the work
out = strcmpCommon(@strncmpi, s1, s2, n);