function [Time,startDate]=tsAnalyzeAbsTime(timeArray,Units,varargin)
%
% tstool utility function
% TSANALYZEABSTIME interprets absolute date/time string and returns
% information needed
%
% [Time,Format,Startdate]=TSANALYZEABSTIME(timeArray, Unit, varargin) check
% the string content in the timeArray, which can be either a cell array of
% strings or a char array.  Unit should be one of 'weeks', 'days', 'hours',
% 'minutes', 'seconds', 'milliseconds', 'microseconds', 'nanoseconds'.
% Varargin, if supplied, should be a string containing a valid absolute
% start date, e.g. '10-Oct-2004 12:34:56', which is used as the reference
% date for generating the relative time value.
%
% Time is the numeric value (in the given unit) of TimeArray relative to
% either the reference date (if supplied) or the first time point in
% TimeArray. However, if TimeArray contains only hour/minute/second (e.g.
% 'HH:MM:SS'), Time is the numeric value (in the given unit) of TimeArray
% relative to the '00:00:00' time point.
%
% Format returns the default display format, which is either the Standard
%   % Revision % % Date %
%
% Startdate returns the first value in TimeArray if no reference date is
% supplied.  Otherwise, it returns the reference date.
%

%   Copyright 2004-2016 The MathWorks, Inc.

% Convert scalar strings to char arrays
if isstring(timeArray) && isscalar(timeArray)
    timeArray = char(timeArray);
% Convert string arrays and cell arrays of strings to cellstrs
elseif isstring(timeArray) || (iscell(timeArray) && ~iscellstr(timeArray))
    timeArray = cellstr(timeArray);
end

if nargin == 4
    try
        % get abs time in [year month day hour min sec] format and sort them
        dateVec = sortrows(round(datevec(timeArray,char(varargin{2}))));
    catch %#ok<*CTCH>
        error(message('MATLAB:tsAnalyzeAbsTime:invalidformat'));
    end
else
    try
        % get abs time in [year month day hour min sec] format and sort them
        dateVec = sortrows(round(datevec(timeArray)));
    catch
        error(message('MATLAB:tsAnalyzeAbsTime:invalidformat'));
    end
end

% get time difference and convert it into date number format
YMD_half=dateVec;
YMD_half(:,4:6)=0;
HMS_half=dateVec;
HMS_half(:,1:3)=0;
YMD_dateNum=datenum(YMD_half);
HMS_dateNum=datenum(HMS_half);

% get the first time point string
if iscell(timeArray)
    refPoint=timeArray{1};
else
    refPoint=timeArray(1,:);
end

% start date is supplied by user
if ~isempty(varargin) && ~isempty(varargin{1})
    % reference time point is provided
    
    % Convert single string startDate to a char vector
    startDate = varargin{1};
    if isstring(startDate) && isscalar(startDate)
        startDate = char(startDate);
    end
    if ~(ischar(startDate) && isvector(startDate))
        error(message('MATLAB:tsAnalyzeAbsTime:invalidrefpoint'));
    end
    if length(refPoint)<=11 && contains(refPoint,':')
        % contains only hour/minute/second information
        % ignore the reference time point
        Time = tsunitconv(Units,'days')*(YMD_dateNum-datenum('00:00:00')) + tsunitconv(Units,'days')*HMS_dateNum;
        % set format
        % Format = 'HH:MM:SS';
        % set start date empty
        startDate = '';
    else
        try
            dateVecStart = round(datevec(startDate));
        catch
            error(message('MATLAB:tsAnalyzeAbsTime:invalidstartdateformat'));
        end
        % get time difference and convert it into date number format
        YMD_halfStart=dateVecStart;
        YMD_halfStart(:,4:6)=0;
        HMS_halfStart=dateVecStart;
        HMS_halfStart(:,1:3)=0;
        YMD_dateNumStart=datenum(YMD_halfStart);
        HMS_dateNumStart=datenum(HMS_halfStart);
        % contains absolute date information
        Time = tsunitconv(Units,'days')*(YMD_dateNum-YMD_dateNumStart) + tsunitconv(Units,'days')*(HMS_dateNum-HMS_dateNumStart);
        % set format
        % Format = 'dd-mmm-yyyy HH:MM:SS';
    end
else
    % use string length and ':' to identify whether it contains date or not
    if length(refPoint)<=11 && contains(refPoint,':')
        % contains only hour/minute/second information
        Time = tsunitconv(Units,'days')*(YMD_dateNum-datenum('00:00:00')) + tsunitconv(Units,'days')*HMS_dateNum;
        % set format
        % Format = 'HH:MM:SS';
        % set start date empty
        startDate = '';
    else
        % contains absolute date information
        Time = tsunitconv(Units,'days')*(YMD_dateNum-YMD_dateNum(1)) + tsunitconv(Units,'days')*(HMS_dateNum-HMS_dateNum(1));
        % set format
        % Format = 'dd-mmm-yyyy HH:MM:SS';
        % set start date and force it to be the desired format: 'dd-mmm-yyyy HH:MM:SS'
        startDate = datestr(datenum(dateVec(1,:)),0);
    end
end
