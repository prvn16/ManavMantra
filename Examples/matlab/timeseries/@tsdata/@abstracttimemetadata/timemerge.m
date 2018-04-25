function [ts1timevec, ts2timevec, outprops, outtrans] = ...
    timemerge(timeInfo1, timeInfo2, time1, time2)
%TIMEMERGE Returns two time vectors with numeric values used by overloaded
%arithmetic operations and concatenations.
%
%   timeInfo1: @timemetadata object from ts1
%   timeInfo2: @timemetadata object from ts2
%   time1: from ts1.time
%   time2: from ts2.time
%
%   ts1timevec: a relative time vector to be compared with ts2timevec
%   ts2timevec: a relative time vector to be compared with ts1timevec
%   outprops: returns a struct with 'ref','outformat','outunits'
%       ref: from one of the two StartDate properties
%       outformat: from one of the two Format properties
%       outunits: from one of the two Units properties
%   outtrans: returns a struct with 'delta','deltaTS','scale'
%       delta: the difference between two 'StartDate' properties
%       deltaTS: '1' means StartDate from ts1 is later than StartDate from ts2
%                '2' means StartDate from ts2 is later than StartDate from ts1
%       scale: unit conversion factors

%   Copyright 2004-2011 The MathWorks, Inc.

% TO DO: Consider making into a @timeseries static method

% Get available units. TO DO: Restore enumeration
%myEnumHandle = findtype('TimeUnits');
%availableUnits = myEnumHandle.Strings;
availableUnits = {'seconds','minutes','hours','days','weeks'};

% Convert time units to the smaller units and get new time vectors
outunits = availableUnits{max(find(strcmp(timeInfo1.Units,availableUnits)), ...
        find(strcmp(timeInfo2.Units,availableUnits)))}; 
unitconv1 = localUnitConv(outunits,timeInfo1.Units);
unitconv2 = localUnitConv(outunits,timeInfo2.Units);
ts1timevec = unitconv1*time1;
ts2timevec = unitconv2*time2;

% If time vectors are both absolute then convert them to the output units
% and apply the converted difference between the startdates
ref = '';
delta = 0;
deltaTS = [];
if ~isempty(timeInfo1.Startdate) && ~isempty(timeInfo2.Startdate)        
    delta = localUnitConv(outunits,'days')*...
        (datenum(timeInfo1.Startdate)-datenum(timeInfo2.Startdate));
    if delta>0
        ref = timeInfo2.Startdate;
        ts1timevec = ts1timevec+delta;
        deltaTS = 1;
    else
        ref = timeInfo1.Startdate;
        delta = -delta;
        ts2timevec = ts2timevec+delta;
        deltaTS = 2;
    end
else
    if ~(isempty(timeInfo1.StartDate) || ~isempty(timeInfo2.StartDate))
       warning(message('MATLAB:tsdata:abstracttimemetadata:timemerge:mismatchTimeVecs'))
    end
end

% Merge time formats
outformat = '';
if strcmp(timeInfo1.Format,timeInfo2.Format)
    outformat = timeInfo1.Format;
end

outprops = struct('ref',ref,'outformat',outformat,'outunits',outunits);
outtrans = struct('delta',delta,'deltaTS', deltaTS,'scale',{{unitconv1,unitconv2}});


function convFactor = localUnitConv(outunits,inunits)

convFactor = 1; % Return 1 if error or unknown units
try %#ok<TRYNC>
    % Get available units
    %myEnumHandle = findtype('TimeUnits');
    %availableUnits = myEnumHandle.Strings;
    availableUnits = {'seconds','minutes','hours','days','weeks'};
    
    % Factors are based on {'weeks', 'days', 'hours', 'minutes', 'seconds',
    % 'milliseconds', 'microseconds', 'nanoseconds'}
    factors = [604800 86400 3600 60 1 1e-3 1e-6 1e-9];  
    indIn = find(strcmp(inunits,availableUnits));
    if isempty(indIn)
        return
    end
    factIn = factors(indIn);
    indOut = find(strcmp(outunits,availableUnits));
    if isempty(indOut)
        return
    end
    factOut = factors(indOut);
    convFactor = factIn/factOut;
end
    