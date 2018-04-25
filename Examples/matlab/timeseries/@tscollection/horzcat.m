function tscout = horzcat(tsc1,varargin)
%HORZCAT  Overloaded horizontal concatenation for tscollection object
%
%   TSC = HORZCAT(TSC1, TSC2, ...) performs
%
%         TSC = [TSC1 TSC2 ...]
% 
%   This operation combines multiple tscollection objects, which must have
%   common times, into one tscollection object containing time series from
%   all the concatenated objects. 

%   Copyright 2005-2011 The MathWorks, Inc.

if nargin==1
    tscout = tsc1;
    return
else
    tsc = cell(1,length(varargin)+1);
    tsc{1} = tsc1;
    for i=2:length(varargin)+1
        if isa(varargin{i-1},'tscollection')
            tsc{i} = varargin{i-1};
        else
            error(message('MATLAB:tscollection:horzcat:badtype'))
        end
    end
end

tscout = tsc{1};
for i=1:length(varargin)
    tscout  = utdualhorzcat(tscout,tsc{i+1});
end

function tscout = utdualhorzcat(tsc1,tsc2)
%UTDUALHORZCAT horizontal concatenation on two tscollection object

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec,outprops] = ...
    timemerge(tsc1.TimeInfo,tsc2.TimeInfo,tsc1.Time,tsc2.Time);
if ~tsIsSameTime(ts1timevec,ts2timevec)
    error(message('MATLAB:tscollection:utdualhorzcat:badtime'))
end

tsc1Members = gettimeseriesnames(tsc1);
tsc2Members = gettimeseriesnames(tsc2);
% Check for collisions
commonts = intersect(tsc1Members,tsc2Members);
for k=1:length(commonts)
   ts1_ = getts(tsc1,commonts{k});
   ts2_ = getts(tsc2,commonts{k});
   if ~isequal(ts1_.Data,ts2_.Data)
      error(message('MATLAB:tscollection:utdualhorzcat:baddata', commonts{ k }));
   end
end

% Build output tscollection
tscout = tscollection(ts1timevec);
tscout.timeInfo = reset(tsc1.TimeInfo,ts1timevec);
tscout.TimeInfo.Startdate = outprops.ref;
tscout.TimeInfo.Units = outprops.outunits;
tscout.TimeInfo.Format  =outprops.outformat;

% Create the following table
%    Name      index (tsc1 or tsc2)
%   
%    uniquets  J => timeseries  = intimeseries(J(k))
J = [ones(1,length(tsc1Members)) 2*ones(1,length(tsc2Members))];
[uniquets, I] = unique([tsc1Members,tsc2Members]);
intimeseries = {tsc1, tsc2};

% Add concatenated timeseries one at a time
for k=1:length(uniquets)
    tscout = addts(tscout,get(intimeseries{J(I(k))},uniquets{k}));
end

