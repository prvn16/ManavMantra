function out = strcmpi(s1, s2)
%STRCMPI Compare strings ignoring case.
%   TF = STRCMPI(S1,S2)
%
%
%   See also: tall/STRCMPI, tall/STRNCMP, tall/STRNCMPI, 
%             tall/STRREP, tall/STR2DOUBLE.

%   Copyright 2015 The MathWorks, Inc.

narginchk(2,2);

% Use the common helper for most of the work
out = strcmpCommon(@strcmpi, s1, s2);