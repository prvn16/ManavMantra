function h = setTimeseriesName(h,oldname,newname)
%SETTIMESERIESNAMES  Change the name of the selected time series object.
%
% TSC = SETTIMESERIESNAME(TSC,OLD,NEW) replaces the name of time series OLD with
% name NEW in the tscollection object TSC. 
%

%   Copyright 2005-2011 The MathWorks, Inc.
%

warning(message('MATLAB:clg:ObsoleteFunction'))
h = settimeseriesnames(h,oldname,newname);
