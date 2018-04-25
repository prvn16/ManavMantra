function ts = idealfilter(ts,intervals,type,varargin) 

% tstool utility function

% Applies an ideal filter of type "pass" or "notch" to the specified
% frequency intervals. If necessary, the time series is re-sampled
% to be uniform and NaNs are interpolated. 

% Copyright 2004-2012 The MathWorks, Inc.

if numel(ts)~=1
    error(message('MATLAB:timeseries:idealfilter:singletimeseriesobject'));
end
if ts.Length==0
    return
end
try
    % Intervals are an nx2 array of frequencies where n = number of intervals
    dataContent = ts.Data;
    if ~isnumeric(dataContent) && ~islogical(dataContent)
        error(message('MATLAB:timeseries:idealfilter:nonnumeric'));
    end
    s = size(dataContent);
    if (length(s)>2 && ts.IsTimeFirst) || ...
       (s(2)>1 && ~ts.IsTimeFirst) || ...
       length(s)>3
        error(message('MATLAB:timeseries:idealfilter:noarray'))
    end

    if nargin<=3
        if ts.IsTimeFirst
            colind = 1:s(end);
        else
            colind = 1:s(1);
        end
    else
        colind = varargin{1};
    end

    % N0-op for scalars
    if ts.Length<=1
        return
    end

    % If the time series is non-uniformly sampled or has NaN values
    % then resample
    if ts.IsTimeFirst
        nandata = isnan(dataContent(:,colind));
    else
        nandata = isnan(dataContent(colind,1,:));
    end
    if isnan(ts.TimeInfo.Increment) || any(nandata(:))
        time = ts.Time;    
        tuniform = linspace(time(1),time(end),length(time));
        ts = ts.resample(tuniform);
        Ts = tuniform(2)-tuniform(1);
    else
        Ts = ts.TimeInfo.Increment;
    end

    % Detrend the ordinate data
    ts = ts.detrend('constant',colind);
    dataContent = ts.Data;
    
    % Temporarily transpose data if istimefirst is false
    if ts.IsTimeFirst
        data = dataContent;
    else
        data = permute(dataContent,[3 1 2]);
    end
    s = size(data);

    % Find the fft
    idata = fft(data(:,colind));
    fdata = (0:(s(1)-1))/(s(1)*Ts);
    if floor(s(1)/2)-s(1)/2==0 && s(1)>=4
        fdata(end:-1:end/2+2) = fdata(2:end/2);
    elseif floor(s(1)/2)-s(1)/2<0 && s(1)>=3
        fdata(end:-1:(end+1)/2+1) = fdata(2:(end+1)/2);
    end

    % Null out excluded frequencies
    if strcmpi(type,'pass')
       I = true(size(fdata));
    else
       I = false(size(fdata));
    end
    for ct=1:size(intervals,1)
       if strcmpi(type,'pass')
           I = I & (fdata<=min(intervals(ct,:)) | fdata>max(intervals(ct,:)));   
       else
           I = I | (fdata>min(intervals(ct,:)) & fdata<=max(intervals(ct,:)));
       end
    end
    idata(I,:) = 0;

    % Reset the time series data
    if ts.IsTimeFirst
        ts.Data(:,colind) = ifft(idata);
    else
        ts.Data(colind,1,:) = reshape((ifft(idata))',[colind 1 s(1)]);
    end
catch me
    rethrow(me);
end 