function out = strcmp(s1, s2)
%STRCMP Compare strings.
%   TF = STRCMP(S1,S2)
%
%   See also: tall/STRCMPI, tall/STRNCMP, tall/STRNCMPI, 
%             tall/STRREP, tall/STR2DOUBLE.

%   Copyright 2015 The MathWorks, Inc.

narginchk(2,2);

out = strcmpCommon(@strcmp, s1, s2);

end