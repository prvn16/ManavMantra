function memberVarNames = gettimeseriesnames(h)
%GETTIMESERIESNAMES  Return a cell array of names of time series in tscollection.

%   Copyright 2005-2006 The MathWorks, Inc.

if ~isempty(h.Members_)
    memberVarNames = {h.Members_.('Name')};
else
    memberVarNames = {};
    return
end


