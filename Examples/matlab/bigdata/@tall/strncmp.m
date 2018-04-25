function out = strncmp(s1, s2, n)
%STRNCMP compare first N characters of strings.
%   TF = STRNCMP(S1,S2,N)
%
%   See also: tall/STRCMP, tall/STRCMPI, tall/STRNCMPI, 
%             tall/STRREP, tall/STR2DOUBLE.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(3,3);

if istall(n) || ~isscalar(n) || ~isnumeric(n) || n<1 || n~=round(n)
    error(message('MATLAB:strcmp:SizeMustBeInt'));
end

% Use the common helper for most of the work
out = strcmpCommon(@strncmp, s1, s2, n);