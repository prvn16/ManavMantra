function this = resample(this,timevec,varargin)
%RESAMPLE  Redefine a tscollection object on a new time vector.
%
%   TSC = RESAMPLE(TSC,TIMEVEC) resamples the tscollection object TSC on the new
%   time vector TIMEVEC. When TIMEVEC is numeric, it is assumed to be
%   specified relative to the TSC.TimeInfo.StartDate property and in the
%   same units as the tscollection TSC uses. When TIMEVEC is an array of
%   date strings, then it is used directly.  
%
%   TSC = RESAMPLE(TSC,TIMEVEC,INTERP_METHOD) resamples tscollection TSC using the
%   interpolation method given by the string INTERP_METHOD. Valid
%   interpolation methods are 'linear' and 'zoh'. 
%
%   TSC = RESAMPLE(TSC,TIMEVEC,INTERP_METHOD,CODE) resamples tscollection TSC
%   using the interpolation method given by the string INTERP_METHOD. The
%   integer CODE is a user-defined quality code for resampling and it will
%   be applied to all the samples.  
%
%   See also TSCOLLECTION/SYNCHRONIZE, TSCOLLECTION/TSCOLLECTION

%   Copyright 2005-2016 The MathWorks, Inc.

%% Get abs time reference and convert datastrs to a relative numeric
%% time vector
if iscell(timevec) || ischar(timevec) || isstring(timevec)
    try
        t = tsgetrelativetime(timevec,this.TimeInfo.StartDate,this.TimeInfo.Units);        
    catch
        error(message('MATLAB:tscollection:resample:norel'))
    end
elseif isnumeric(timevec)
    t = timevec;
else
    error(message('MATLAB:tscollection:resample:badtime'))
end
% Make sure t is a column vector, which is important when calling interp1 function
t = t(:);

%% Parse additional inputs
% Get a list of timeseries members
tsnames = gettimeseriesnames(this);
if nargin>=3 && ~isempty(varargin{1})
    if ischar(varargin{1}) || (isstring(varargin{1}) && isscalar(varargin{1})) % Interpolation method specified by a string
        varargin{1} = tsdata.interpolation(varargin{1});
    elseif ~isa(varargin{1},'tsdata.interpolation')
        error(message('MATLAB:tscollection:resample:invinterp'))
    end
end
if nargin>=4 && ~isempty(varargin{2})
    if isnumeric(varargin{2}) && isscalar(varargin{2})
        if floor(varargin{2})-varargin{2}<0
            warning(message('MATLAB:tscollection:resample:round'))
        end
    else
        error(message('MATLAB:tscollection:resample:invcode'))
    end
    modcode = floor(varargin{2});    
    for i=1:length(tsnames)
        thists = getts(this,tsnames{i});
        if isempty(thists.Quality)
            error(message('MATLAB:tscollection:resample:noqual'))
        end
        %% Check that the specified quality code is valid
        if ~isempty(modcode) && ~any(modcode==thists.QualityInfo.Code)
            error(message('MATLAB:tscollection:resample:absentcode'))
        end
    end
end

% Apply resample on each timeseries member
tsList = cell(length(tsnames),1);
for i=1:length(tsnames)
    tsList{i} = resample(getts(this,tsnames{i}),t,varargin{:});
end

% Set the new time vector
this.TimeInfo = setlength(this.TimeInfo,length(t));
this.Time = t;

% Write the resamples list back
for i=1:length(tsnames)
     this = setts(this,tsList{i},tsnames{i});
end
