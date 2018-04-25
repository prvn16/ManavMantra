function h = removets(h, tsname)
%REMOVETS  Remove time series object(s) from a tscollection object.
%
% REMOVETS(TSC,NAME) removes a time series object, whose name is specified
% in string NAME, from the tscollection TSC. 
%
% REMOVETS(TSC,NAMES) removes time series objects, whose names are stored
% in a cell array NAME, from the tscollection TSC.
%

%   Copyright 2005-2016 The MathWorks, Inc.
%

if iscellstr(tsname) || ischar(tsname) 
    I = ismember(gettimeseriesnames(h),strtrim(tsname));
    h.Members_(I) = [];    
elseif isstring(tsname) && isscalar(tsname)
    % Convert to string tsname to char array
    I = ismember(gettimeseriesnames(h),char(strtrim(tsname)));
    h.Members_(I) = [];
elseif isstring(tsname) || (iscell(tsname) && all(cellfun('isclass',tsname,'string')))
    % Convert true string arrays of cell arrays of strings to cellstr
    I = ismember(gettimeseriesnames(h),cellstr(strtrim(tsname)));
    h.Members_(I) = [];    
else
    error(message('MATLAB:tscollection:removets:invalidname'))
end
