function this = resample(this,timevec,varargin)
%RESAMPLE  Redefine a time series based on a new time vector.
%
%   TS = RESAMPLE(TS,TIMEVEC) resamples the time series object TS on the
%   new
%   time vector TIMEVEC. When TIMEVEC is numeric, it is assumed to be
%   specified relative to the TS.TimeInfo.StartDate property and in the same
%   units as the time series TS uses. When TIMEVEC is an array of date
%   strings, then it is used directly.  
%
%   TS = RESAMPLE(TS,TIMEVEC,INTERP_METHOD) resamples time series TS using the
%   interpolation method given by the string INTERP_METHOD. Valid
%   interpolation methods are 'linear' and 'zoh'. 
%
%   TS = RESAMPLE(TS,TIMEVEC,INTERP_METHOD,CODE) resamples time series TS
%   using the interpolation method given by the string INTERP_METHOD. The
%   integer CODE is a user-defined quality code for resampling and it will
%   be applied to all the samples.  
%
%   See also TIMESERIES/SYNCHRONIZE, TIMESERIES/TIMESERIES

%   Copyright 2005-2016 The MathWorks, Inc.

narginchk(2,4);
if numel(this)~=1
    error(message('MATLAB:timeseries:resample:noarray'));
end
if this.Length==0
    return
end

% Get abs time reference and convert datastrs to a relative numeric
% time vector
if iscell(timevec) || ischar(timevec) || isstring(timevec)
    try
        t = timeseries.tsgetrelativetime(timevec,this.TimeInfo.StartDate,...
            this.TimeInfo.Units);
    catch %#ok<CTCH>
        error(message('MATLAB:timeseries:resample:norel'))
    end
% Numeric time vector
elseif isnumeric(timevec)
    t = timevec;
else
    error(message('MATLAB:timeseries:resample:badtime'))
end
% Make sure t is a column vector, which is important when calling
% interp1 function
t = t(:);

%% Parse additional inputs
if nargin>=3 && ~isempty(varargin{1})
    if ischar(varargin{1}) || isstring(varargin{1}) % Interpolation method specified by a string
        interpobj = tsdata.interpolation(varargin{1});
    elseif isa(varargin{1},'tsdata.interpolation')
        interpobj = varargin{1};
    else
        error(message('MATLAB:timeseries:resample:invinterp'))
    end
else
    interpobj = this.DataInfo.Interpolation;
end
if nargin>=4 && ~isempty(varargin{2})
    if isempty(this.Quality)
        error(message('MATLAB:timeseries:resample:noqual'))
    end
    if isnumeric(varargin{2}) && isscalar(varargin{2})
        if floor(varargin{2})-varargin{2}<0
            warning(message('MATLAB:timeseries:resample:round'))
        end
        modcode = floor(varargin{2});
    else
        error(message('MATLAB:timeseries:resample:invcode'))
    end
else
    modcode = [];
end

% Check that the specified quality code is valid
if ~isempty(modcode) && ~any(modcode==this.QualityInfo.Code)
    error(message('MATLAB:timeseries:resample:absentcode'))
end

% Cast data as doubles to avoid non-double arithmetic
thisData = this.Data;
if ~isnumeric(thisData) && ~islogical(thisData)
    error(message('MATLAB:timeseries:resample:nonnumeric'));
end
thisTime = this.Time;
thisQual = this.Quality;

% deal with empty timeseries
if this.Length==0
    return
% deal with timeseries with single sample
elseif this.Length==1
    if isscalar(t) && diff([thisTime;t])==0
        return
    else
        error(message('MATLAB:timeseries:resample:scalar'))
    end        
end

% Interpolate, taking into account the dimension aligned with time
if this.IsTimeFirst
    dataout = interpobj.interpolate(thisTime,thisData,t,[],~this.hasduplicatetimes);
else
    dataout = interpobj.interpolate(thisTime,thisData,t,ndims(thisData),~this.hasduplicatetimes);
end
 
% Update the quality vector
newqual = [];
if ~isempty(thisQual)
    if ~isempty(modcode)
        newqual = utQualityVector(this,dataout,t,modcode);
    else
        newqual = utQualityVector(this,dataout,t);
    end
end

% Build output time series of whatever class
this = this.init(dataout,t,newqual);


function newqual = utQualityVector(tsin,dataout,t,varargin)
%UTQUALITYVACTOR (used by resample function)

% Utility method which generates a modified quality vector for methods
% which modify the data and/or time vectors. The 4th optional argument is
% a quality code which will be used to denote any observations which have
% been modified. Observations are considered modified if either the data is
% changed or if a new point is added. If no 4th argument is specified 
% any sample added or who's time has been changed will be assigned the 
% quality of their nearest neighbor.


% Has a modified quality code been specified
if nargin>=4
    modcode = varargin{1};
else
    modcode = [];
end

% New time points
[commonT,indout,indin] = intersect(t,tsin.Time);

% Since the time vector has changed the quality vector needs to be
% updated. 
newqual = [];
if ~isempty(tsin.Quality)
    % If new time points have been created, delete the quality vector
    if isempty(modcode) 
        if tsin.IsTimeFirst
            newqual = interp1(tsin.Time,tsin.Quality,t,'nearest');
        else
            n = ndims(tsin.Quality);
            tmpQual = permute(tsin.Quality,[n 1:n-1]);
            modQuality = interp1(tsin.Time,tmpQual,t,'nearest');
            newqual = permute(modQuality,[2:n 1]);
        end     
    % If new time points have been created, set the quality vector to
    % modified code
    else
        newqual = modcode*ones([length(t) 1]);
        newqual(indout) = tsin.Quality(indin);
    end
end

% Update the quality vector 
if ~isempty(modcode)    
    % Find the observation indices of data at unmodified times which has
    % changed
    if ~isempty(commonT)
        % Get the modified and original data as a 2d matrix
        sout = size(dataout);
        sin = size(tsin.Data);
        % dataout and data have the same # of columns
        if tsin.IsTimeFirst || ndims(tsin.Data)<=2
            yout = dataout(indout,:);
            yin = tsin.Data(indin,:);
        else
            yout = reshape(dataout,[prod(sout(1:end-1)) sout(end)]);
            yin = reshape(tsin.Data,[prod(sin(1:end-1)) sin(end)]);
            yout = yout(:,indout);
            yin = yin(:,indin);
        end

        % Find which observations have changed
        if isvector(yout)
            I = isnan(yin) | abs(yout-yin)>eps;
        else
            if tsin.IsTimeFirst
                I = any((isnan(yin) | abs(yout-yin)>eps )');
            else
                I = any(isnan(yin) | abs(yout-yin)>eps);
            end
        end
        
        % Find observations that have either had the data has changed
        newqual(indout(I)) = modcode;
    end
end