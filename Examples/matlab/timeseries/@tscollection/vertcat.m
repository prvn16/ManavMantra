function tscout = vertcat(tsc1,varargin)
%VERTCAT  Overloaded vertical concatenation for tscollection object 
%
%   TSC = VERTCAT(TSC1, TSC2, ...) performs
%
%         TSC = [TSC1 ; TSC2 ; ...]
% 
%   This operation appends tscollection objects.  The time vectors must not
%   overlap.  The last time in TSC1 must be earlier than the first time in
%   TSC2.  All the tscollection objects to be combined must have the same
%   time series members.      

%   Copyright 2005-2017 The MathWorks, Inc.

if nargin==1
    tscout = tsc1;
    return
else
    tsc{1} = tsc1;
    for i=2:length(varargin)+1
        if isa(varargin{i-1},'tscollection')
            tsc{i} = varargin{i-1}; %#ok<AGROW>
        else
            error(message('MATLAB:tscollection:vertcat:badtype'))
        end
    end
end

tscout = tsc{1};
mismatchedTimeseriesNameOrder = false;
for i=1:length(varargin)
    [tscout, ordermismatch] = utdualvertcat(tscout,tsc{i+1});
    if ordermismatch
        mismatchedTimeseriesNameOrder = true;
    end
end

if mismatchedTimeseriesNameOrder
    warning(message('MATLAB:tscollection:vertcat:ordermismatch'))
end

function [tscout, ordermismatch] = utdualvertcat(tsc1,tsc2)
%UTDUALHORZCAT vertical concatenation on two tscollection object

% Check that the members match
memberVars1 = gettimeseriesnames(tsc1);
memberVars2 = gettimeseriesnames(tsc2);
if length(memberVars1) ~= length(memberVars2)  
    error(message('MATLAB:tscollection:utdualvertcat:badmembernumber'))
end
if ~isequal(sort(memberVars1),sort(memberVars2))
    error(message('MATLAB:tscollection:utdualvertcat:badmembername'))
end
ordermismatch = ~isequal(memberVars1,memberVars2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE The following code is in common with @timeseries/vertcat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec,outprops] = ...
    timemerge(tsc1.TimeInfo, tsc2.TimeInfo,tsc1.Time,tsc2.Time);

% Concatenate time and ordinate data
if ts1timevec(end)>ts2timevec(1)
    error(message('MATLAB:tscollection:utdualvertcat:overlaptime'))
end
time = [ts1timevec;ts2timevec];

% Build output tscollection
tscout = tscollection(time);
tscout.timeInfo = reset(tsc1.TimeInfo,time);
tscout.TimeInfo.Startdate  = outprops.ref;
tscout.TimeInfo.Units = outprops.outunits;
tscout.TimeInfo.Format = outprops.outformat;

% Add concatenated timeseries one at a time
for k=1:length(memberVars1)
    % Concatenate ordinate data
    timeseries1 = getts(tsc1,memberVars1{k});
    timeseries2 = getts(tsc2,memberVars1{k});
    try
        ts = append(timeseries1,timeseries2);
    catch %#ok<*CTCH>
        error(message('MATLAB:tscollection:utdualvertcat:badsamplesize', memberVars1{ k }));
    end
    tscout = tscout.addts(ts,memberVars1{k});
end
  