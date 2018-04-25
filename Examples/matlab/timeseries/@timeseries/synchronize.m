function [ts1,ts2] = synchronize(ts1,ts2,method,varargin)
%SYNCHRONIZE  Synchronize two time series objects onto a common time
%vector.
%
%   [TS1 TS2] = SYNCHRONIZE(TS1, TS2, 'SYNCHRONIZEMETHOD') creates a new
%   time series
%   object by synchronizing the time series objects TS1 and TS2 onto a
%   common time vector. SYNCHRONIZE replaces both of the original time
%   series objects TS1 and TS2 with the new synchronized time series
%   objects. The string 'SYNCHRONIZEMETHOD' defines the method for
%   synchronizing the time series and can be one of the following: 
%
%   'Union' - Resamples time series on a time vector that is a union of the
%   time vectors of TS1 and TS2 on the time interval where the two
%   time vectors overlap.
%
%   'Intersection' - Resamples time series on a time vector that is the
%   intersection of the time vectors of TS1 and TS2.
%
%   'Uniform' - this method requires an additional argument as follows:
%   [TS1 TS2] = SYNCHRONIZE(TS1, TS2, 'UNIFORM', 'interval',VALUE) resamples time
%   series on a uniform time vector, where VALUE specifies the time
%   interval. The range of the uniform time vector is equal to the overlap
%   of the time vectors of TS1 and TS2. The interval units are assumed to
%   be the larger units of TS1 and TS2.
%
%   You can specify additional arguments by using Property-Value pairs:
%
%       'interpmethod',VALUE: forces the specified interpolation method
%       (over the default method) for this SYNCHRONIZE operation. VALUE can
%       be either a string, 'linear' or 'zoh', or a tsdata.interpolation
%       object that contains a user-defined interpolation method.
%
%       'qualitycode',VALUE: an integer (between -128 to 127) you specify
%       by VALUE is used as the quality for both time series after the
%       synchronization.
%
%       'keepOriginalTimes',VALUE: a logical value (TRUE or FALSE) you specify
%       by VALUE is used to indicate whether the new time series should
%       keep the original time values. For example, 
%           ts1 = timeseries([1 2],[datestr(now); datestr(now+1)]);
%           ts2 = timeseries([1 2],[datestr(now-1); datestr(now)]);
%       Note that ts1.Timeinfo.StartDate is one day after ts2.Timeinfo.StartDate.
%       if you use
%           [ts1 ts2] = synchronize(ts1,ts2,'union');
%       then the ts1.Timeinfo.StartDate is changed to be the same as
%       ts2.Timeinfo.StartDate. But, if you use
%           [ts1 ts2] = synchronize(ts1,ts2,'union','KeepOriginalTimes',true);
%       then the ts1.Timeinfo.StartDate is not changed.
%
%       'tolerance',VALUE: a real number you specify by VALUE is used
%       as the tolerance for differentiating two time values when comparing
%       the TS1 and TS2 time vectors.  The default tolerance is 1e-10.  For
%       example, if the sixth time value in TS1 is 5+(1e-12) and the sixth
%       time value in TS2 is 5-(1e-13), by default, they will both be
%       treated as 5.  To differentiate those two times, you can set
%       'tolerance' to a smaller value, for example 1e-15. 
%
%   See also TIMESERIES/TIMESERIES, TSDATA.INTERPOLATION/INTERPOLATION

%   Copyright 2005-2016 The MathWorks, Inc.


narginchk(3,inf);
if ~isa(ts2,'timeseries')
    error(message('MATLAB:timeseries:synchronize:type', class( ts1 )))    
end        
if numel(ts1)~=1 || numel(ts2)~=1
    error(message('MATLAB:timeseries:synchronize:noarray'));
end        
        
%% Parse inputs
% convert the input pv pair into a struct if necessary
ni = nargin-3;
increment = 1;
interpobj1 = ts1.DataInfo.Interpolation;
interpobj2 = ts2.DataInfo.Interpolation;
modcode = [];
tol = [1e-10 1e-10];
KeepOriginalTimes = false;
if nargin>3
    % PV pair case
    for i=1:2:ni
        % Set each Property Name/Value pair in turn. 
        Property = varargin{i};
        if i+1>ni
            error(message('MATLAB:timeseries:synchronize:pvsetNoValue'))
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        if ~ischar(Property) && ~isstring(Property)
            error(message('MATLAB:timeseries:synchronize:pvsetStringPropertyName'))
        end
        switch lower(char(Property))
            case 'interval'
                if ~isnumeric(Value) || ~isscalar(Value)
                    error(message('MATLAB:timeseries:synchronize:pvsetNumInterval'))
                else
                    increment = Value;
                end
            case 'interpmethod'
                [interpobj1, interpobj2] = localParseInterp(Value);
            case 'qualitycode'
                modcode = localParseQuality(Value,ts1,ts2);
            case 'tolerance'
                tol = localParseTolerance(Value);
            case 'keeporiginaltimes'
                if ~islogical(Value) || ~isscalar(Value)
                    error(message('MATLAB:timeseries:synchronize:pvsetLogicalKeepOriginalTimes'))
                else
                    KeepOriginalTimes = Value;
                end
            otherwise
                error(message('MATLAB:timeseries:synchronize:pvsetInvalid'))
       end % switch
    end % for
end

% Extract time
t1 = ts1.Time;
t2 = ts2.Time;
if isempty(t1) || isempty(t2)
    error(message('MATLAB:timeseries:synchronize:noemptytime'))
end

% Merge time vectors onto a common basis
[ts1timevec_original, ts2timevec_original,~,outtrans] = ...
    timemerge(ts1.TimeInfo,ts2.TimeInfo,t1,t2);

% Pre-process the time vector to work around the numeric error problem
% by using relative threshold.  Note: user can adjust the tolerance if the
% output is not satisfied
% Calculate threshold based on the specified tolerance. The actual
% tolerance is the minimum of 10^-6*round10(minimum deltaT) and the
% specified tolerance, where round10 suggests rounding to the nearest whole
% positive or negative power of 10.
if length(ts1timevec_original)==1
    hasDuplicateTimes1 = false;
    if ts1timevec_original==0
        threshold1 = tol(1);        
    else
        minimum_diff_ts1 = power(10,round(log10(min(abs(ts1timevec_original)))));
        threshold1 = min(minimum_diff_ts1*1e-6,tol(1));        
    end    
else
    diffT = diff(ts1timevec_original);
    minDiffT = min(diffT); 
    hasDuplicateTimes1 = (min(diffT)==0);
    if ~hasDuplicateTimes1
        minimum_diff_ts1 = power(10,round(log10(minDiffT)));
    else
        diffT = diffT(diffT>0);
        if isempty(diffT)
            minimum_diff_ts1 = 0;
        else
            minimum_diff_ts1 = power(10,round(log10(min(diffT))));
        end
    end
    threshold1 = min(minimum_diff_ts1*1e-6,tol(1));
end
if length(ts2timevec_original)==1
    hasDuplicateTimes2 = false;
    if ts2timevec_original==0
        threshold2 = tol(2);            
    else
        minimum_diff_ts2 = power(10,round(log10(min(abs(ts2timevec_original)))));
        threshold2 = min(minimum_diff_ts2*1e-6,tol(2));        
    end  
else    
    diffT = diff(ts2timevec_original);
    minDiffT = min(diffT); 
    hasDuplicateTimes2 = (minDiffT==0);
    if ~hasDuplicateTimes2
        minimum_diff_ts2 = power(10,round(log10(minDiffT)));
    else
        diffT = diffT(diffT>0);
        if isempty(diffT)
            minimum_diff_ts2 = 0;
        else
            minimum_diff_ts2 = power(10,round(log10(min(diffT))));
        end
    end
    threshold2 = min(minimum_diff_ts2*1e-6,tol(2));
end

% Round off the time vectors based on relative tolerance if they are not
% equal
if ~KeepOriginalTimes && ~isequal(ts1timevec_original,ts2timevec_original)
    ts1timevec = round(ts1timevec_original/threshold1)*threshold1;
    ts2timevec = round(ts2timevec_original/threshold2)*threshold2;
else
    ts1timevec = ts1timevec_original;
    ts2timevec = ts2timevec_original;
end

    
% Find overlapping time interval
interval = [max(ts1timevec(1),ts2timevec(1)) min(ts1timevec(end),ts2timevec(end))];
% Changed from <= to < to allow a single sample
if interval(2)<interval(1)
    ts1 = delsample(ts1,'index',1:ts1.Length);
    ts2 = delsample(ts2,'index',1:ts2.Length);
    return
end
% Find output time interval
ts1timevec_CutVersion = ts1timevec(ts1timevec>=interval(1) & ts1timevec<=interval(end));
ts2timevec_CutVersion = ts2timevec(ts2timevec>=interval(1) & ts2timevec<=interval(end));

% Merge the time vectors
switch lower(char(method))

    case 'union'
        if ~hasDuplicateTimes1 && ~hasDuplicateTimes2
            tout  = union(ts2timevec_CutVersion, ts1timevec_CutVersion); 
        else

            % Count the number of occurrences of each time in
            % ts1timevec_CutVersion and ts2timevec_CutVersion. The
            % number of repeated values in the union time vector should
            % be the maximum.
            tunique = unique([ts2timevec_CutVersion(:); ts1timevec_CutVersion(:)]);
            elementCount1 = histc(ts1timevec_CutVersion(:),tunique);
            elementCount2 = histc(ts2timevec_CutVersion(:),tunique);
            elementCount = max(elementCount1,elementCount2);

            % Re-assemble repeated elements from tunique
            I = false(sum(elementCount),1);
            I(cumsum(elementCount)) = true;
            tout = tunique([1;cumsum(I(1:end-1))+1]);   
        end

    
    case 'intersection'
        if ~hasDuplicateTimes1 && ~hasDuplicateTimes2
            tout = intersect(ts2timevec_CutVersion, ts1timevec_CutVersion);
        else
            % Count the number of occurrences of each time in
            % ts1timevec_CutVersion and ts2timevec_CutVersion. The
            % number of repeated values in the intersection time vector should
            % be the minimum (not less than 1).
            tunique = unique([ts2timevec_CutVersion(:); ts1timevec_CutVersion(:)]);
            elementCount1 = histc(ts1timevec_CutVersion(:),tunique);
            elementCount2 = histc(ts2timevec_CutVersion(:),tunique);
            elementCount = min(elementCount1,elementCount2);
            elementCount = max(elementCount,1);
            
            % Re-assemble repeated elements from tunique
            I = false(sum(elementCount),1);
            I(cumsum(elementCount)) = true;
            tout = tunique([1;cumsum(I(1:end-1))+1]);  
            
        end 
    
    case 'uniform'
        tout = interval(1)+increment*(0:1:(interval(end)/increment-interval(1)/increment)); 
        tout = round(tout/max(threshold2,threshold1))*max(threshold2,threshold1);       
    otherwise
          error(message('MATLAB:timeseries:synchronize:interpsyntax'))
end

% If tout isempty, return empty timeseries objects
if isempty(tout)
    ts1 = delsample(ts1,'index',1:ts1.Length);
    ts2 = delsample(ts2,'index',1:ts2.Length);
    return
end

% Prevent accidental extrapolation due to rounding
tout = max(tout,ts1timevec_original(1));
tout = max(tout,ts2timevec_original(1));
tout = min(tout,ts1timevec_original(end));
tout = min(tout,ts2timevec_original(end));


% Map the output time interval back into the units and offsets of the input
% time series so that the resampling operation is performed in the right
% frame of reference.
if outtrans.deltaTS==1 % deltaTS==1 means the first time series has been shifted 
    ts1 = ts1.resample((tout-outtrans.delta)/outtrans.scale{1},interpobj1,modcode);
    ts2 = ts2.resample(tout/outtrans.scale{2},interpobj2,modcode);  
elseif outtrans.deltaTS==2 % deltaTS==1 means the second time series has been shifted 
    ts1 = ts1.resample(tout/outtrans.scale{1},interpobj1,modcode);
    ts2 = ts2.resample((tout-outtrans.delta)/outtrans.scale{2},interpobj2,modcode);  
else
    ts1 = ts1.resample(tout/outtrans.scale{1},interpobj1,modcode);
    ts2 = ts2.resample(tout/outtrans.scale{2},interpobj2,modcode);
end

% If KeepOriginalTimes is false the numeric Time vectors and the
% timemetadata StartTime and Units are the same.
if ~KeepOriginalTimes
    if outtrans.deltaTS==1 % deltaTS==1 means the first time series has been shifted 
        ts1.Time = ts2.Time;
        ts1.Timeinfo.StartDate = ts2.Timeinfo.StartDate;
        ts1.Timeinfo.Units = ts2.Timeinfo.Units;
    elseif outtrans.deltaTS==2 % deltaTS==1 means the second time series has been shifted 
        ts2.Time = ts1.Time;
        ts2.Timeinfo.StartDate = ts1.Timeinfo.StartDate;
        ts2.Timeinfo.Units = ts1.Timeinfo.Units;
    end
end


function [interpobj1,interpobj2] = localParseInterp(method)

%% Has a custom interpolation method been defined?
if ischar(method) || isstring(method) % Interpolation method specified by a string
    interpobj1 = tsdata.interpolation(method);
    interpobj2 = tsdata.interpolation(method);
elseif isa(method,'tsdata.interpolation')
    interpobj1 = method;
    interpobj2 = method;
else
    error(message('MATLAB:timeseries:synchronize:invinterp'))
end


function modcode = localParseQuality(Value,ts1,ts2)

%% Has a modified quality code been defined?
if isempty(ts1.Quality) || isempty(ts2.Quality)
    error(message('MATLAB:timeseries:synchronize:noqual'))
end
if isnumeric(Value) && isscalar(Value)
    if floor(Value)-Value<0
        warning(message('MATLAB:timeseries:synchronize:round'))
    end
    modcode = floor(Value);
else
    error(message('MATLAB:timeseries:synchronize:invcode'))
end


function tol = localParseTolerance(Value)

% Parse user-defined tolerance
if ~isempty(Value) && isreal(Value) && isvector(Value)
    if length(Value)==2
        tol = Value;
    else
        tol(1:2) = Value;
    end
else
    tol = [1e-10 1e-10];
end