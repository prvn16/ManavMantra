function [outflag,absflag] = tsIsDateFormat(thisstr)
%
% tstool utility function

%   Copyright 2004-2008 The MathWorks, Inc.

% TSISDATEFORMAT Utility to detect if a string is a valid data format

%% Initialize outputs
outflag = false;
absflag = false;

%% Find datastr
[strs,absstat] = tsgetDateFormat;
% cae insensitive
I = find(strcmpi(thisstr,strs));

%% Return status'
if length(I)>0
    outflag = true;
    absflag = absstat{I(1)};
end