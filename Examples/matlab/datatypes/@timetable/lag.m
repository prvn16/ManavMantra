function tt = lag(tt, n)
%LAG Lag or lead data in a timetable.
%   TT2 = LAG(TT1) shifts the data in each variable in the timetable TT1 forward
%   in time (a "lag") by one time step. TT must be regular.
%
%   TT2 = LAG(TT1,N) shifts the data in the timetable TT1 by N timesteps.
%   Positive values of N shift the data forward in time (a "lag"), negative
%   values shift the data backwards (a "lead").
%
%   TT2 = LAG(TT1,DT) shifts the data by the amount of time DT. DT is a duration
%   or calendarDuration, and must be a multiple of TT's regular time step.
%   Positive values of DT shift the data forward in time (a "lag"), negative
%   values shift the data backwards (a "lead").
%
%   Examples:
%
%   % Lag a monthly series of values, and combine with the unlagged values.
%   monthly = timetable(datetime(2016,1:5,3)', [1:5]')
%   lagged = lag(monthly,calmonths(2))
%   combined = synchronize(monthly,lagged)
%
%   % LAG shifts the data and leaves the times alone. An alternative is to
%   % add the lag to the time vector, and leave the data alone.
%   lagged = monthly
%   lagged.Time = lagged.Time + calmonths(2)
%   combined = synchronize(monthly,lagged)
%
%   See also RETIME, SYNCHRONIZE, ISREGULAR.

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isScalarInt
import matlab.internal.datatypes.defaultarrayLike

% Parse inputs
if nargin == 1 || isnumeric(n)
    if nargin == 1
        n = 1;
    elseif ~isScalarInt(n) 
        error(message('MATLAB:timetable:lag:InvalidLagType'));
    end
    
    % Timetable must be regular either in absolute time or with respect to a single
    % unit calendarDuration.
    if ~isregularTimeDaysMonths(tt)
        error(message('MATLAB:timetable:lag:MustBeRegular'));
    end
    
    % Lag by +/- N rows: get the sign of time difference for correct lead/lag
    % direction with both ascending and descending times. Only need the sign, no
    % concern for variation due to round-off in "almost regular" time vectors.
    n = sign(seconds(diff(tt.rowDim.labels(1:2)))) * n;
    
else % lag by a specified duration or calendarDuration time step
    lagStep = n;
    if ~isscalar(lagStep) 
        error(message('MATLAB:timetable:lag:InvalidLagType'));
    end
    
    if isduration(lagStep)
        % Timetable must be regular with respective to absolute time.
        [ttIsRegular,ttStep] = tt.rowDim.isregular();
        if ~ttIsRegular
            error(message('MATLAB:timetable:lag:MustBeRegularInUnits','Time'));
        end
        % Leave lagStep and ttStep as durations
    elseif iscalendarduration(lagStep)
        % calendarDuration lag is invalid on a duration timetable.
        if isduration(tt.rowDim.labels)
            error(message('MATLAB:timetable:lag:calDurLagDurationTimetable'));
        end
        
        % Split the specified lag step into number of months, days, and ms. It
        % must be pure w.r.t. exactly one of those units. Get that unit and the
        % magnitude of the step.
        calUnits = {'months' 'days' 'time'};
        [nMonthsLag,nDaysLag,timeLag] = split(lagStep, calUnits);
        lagComponents = [nMonthsLag nDaysLag milliseconds(timeLag)];
        if nnz(lagComponents) > 1
            error(message('MATLAB:timetable:lag:InvalidCaldurationLag'));
        end
        lagUnit = calUnits{lagComponents~=0};
        lagStep = lagComponents(lagComponents~=0);
        
        % Input timetable must be regular w.r.t. the specified lag's unit. If
        % that's true, then its time step is pure w.r.t. the specified lag's
        % unit. Split the time step into number of that unit.
        [ttIsRegular,ttStep] = tt.rowDim.isregular(lagUnit);
        if ~ttIsRegular
            error(message('MATLAB:timetable:lag:MustBeRegularInUnits',lagUnit));
        end
        if isduration(ttStep)
            ttStep = milliseconds(ttStep);
        else
            ttStep = split(ttStep,lagUnit);
        end
    else
        error(message('MATLAB:timetable:lag:InvalidLagType'));
    end
    
    % Compute number of timetable time steps in the specified lag.
    n = lagStep / ttStep;
    
    % The lag must be a whole multiple of the timetable's time step. Use a very
    % tight tolerance in that check: there is no round-off for calendarDuration
    % lags, and for duration lags n will be an integer in most cases when the
    % lag step is consistent with how the timetable's row times were created.
    if ~isfinite(n) || (abs(n-round(n)) > eps(n))
        error(message('MATLAB:timetable:lag:LagMustBeTimeStepMultiple'));
    end
    n = round(n);
end

% lagSteps _IS_ whole number multiple of timetable intervals at this point. Cap
% lead/lag steps by number of rows, and perform the lag/lead operation.
n = sign(n) * min(abs(n),tt.rowDim.length); 
tt_data = tt.data;
for iVar = 1:tt.varDim.length
    if n >= 0
        tt_data{iVar}(1+n:end,:) = tt_data{iVar}(1:end-n,:);
        tt_data{iVar}(1:n,:) = defaultarrayLike(size(tt_data{iVar}(1:n,:)), 'Like', tt_data{iVar});
    else % negative lag => lead
        tt_data{iVar}(1:end+n    ,:) = tt_data{iVar}(1-n:end,:);
        tt_data{iVar}(end+n+1:end,:) = defaultarrayLike(size(tt_data{iVar}(end+n+1:end,:)), 'Like', tt_data{iVar});
    end
end
tt.data = tt_data;
end
        
function tf = isregularTimeDaysMonths(tt)    
    tf = tt.rowDim.isregular('Time') ...
      || tt.rowDim.isregular('Days') ...
      || tt.rowDim.isregular('Months');
end