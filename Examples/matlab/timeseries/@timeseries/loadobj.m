function h = loadobj(s)
% LOADOBJ  Overloaded load command

%   Copyright 2006 The MathWorks, Inc.


%% When attempting to load sp2 time series objects, reconstruct the time
%% series (for Sys Bio)
if isstruct(s)
    % <=2006a @timeseries objects always include a wrapped tsata.timeseries in objH
    % This will have been converted to a valid 2006b tsdata.timeseries obj by 
    % its loadobj
    h = s.objH.TsValue;  
elseif isa(s,'timeseries')
    h = s;
else 
    h = [];
end

