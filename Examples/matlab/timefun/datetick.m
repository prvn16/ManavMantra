function datetick(varargin)
%DATETICK Date formatted tick labels.
%   DATETICK(TICKAXIS,DATEFORM) annotates the specified tick axis with
%   date formatted tick labels. TICKAXIS must be one of the character vectors
%   'x','y', or 'z'. The default is 'x'.  The labels are formatted
%   according to the format number or character vector DATEFORM (see tables
%   below).  If no DATEFORM argument is entered, DATETICK makes a
%   guess based on the data for the objects within the specified axis.
%   To produce correct results, the data for the specified axis must
%   be serial date numbers (as produced by DATENUM) or datetime 
%   values. If the data is datetime, the tick labels are computed
%   from the corresponding serial date numbers. To set the tick format 
%   for plots containing datetime values while preserving the datetime 
%   precision and property modes, see XTICKFORMAT, YTICKFORMAT and ZTICKFORMAT.
%
%	Table 1: Standard MATLAB Date format definitions
%
%   DATEFORM number   DATEFORM character vector         Example
%   ===========================================================================
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17
%      1             'dd-mmm-yyyy'            01-Mar-2000
%      2             'mm/dd/yy'               03/01/00
%      3             'mmm'                    Mar
%      4             'm'                      M
%      5             'mm'                     03
%      6             'mm/dd'                  03/01
%      7             'dd'                     01
%      8             'ddd'                    Wed
%      9             'd'                      W
%     10             'yyyy'                   2000
%     11             'yy'                     00
%     12             'mmmyy'                  Mar00
%     13             'HH:MM:SS'               15:45:17
%     14             'HH:MM:SS PM'             3:45:17 PM
%     15             'HH:MM'                  15:45
%     16             'HH:MM PM'                3:45 PM
%     17             'QQ-YY'                  Q1-96
%     18             'QQ'                     Q1
%     19             'dd/mm'                  01/03
%     20             'dd/mm/yy'               01/03/00
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17
%     22             'mmm.dd,yyyy'            Mar.01,2000
%     23             'mm/dd/yyyy'             03/01/2000
%     24             'dd/mm/yyyy'             01/03/2000
%     25             'yy/mm/dd'               00/03/01
%     26             'yyyy/mm/dd'             2000/03/01
%     27             'QQ-YYYY'                Q1-1996
%     28             'mmmyyyy'                Mar2000
%     29 (ISO 8601)  'yyyy-mm-dd'             2000-03-01
%     30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
%     31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17
%
%   Table 2: Free-form date format symbols
%
%   Symbol  Interpretation of format symbol
%   ===========================================================================
%   yyyy    full year, e.g. 1990, 2000, 2002
%   yy      partial year, e.g. 90, 00, 02
%   mmmm    full name of the month, according to the calendar locale, e.g.
%           "March", "April" in the UK and USA English locales.
%   mmm     first three letters of the month, according to the calendar
%           locale, e.g. "Mar", "Apr" in the UK and USA English locales.
%   mm      numeric month of year, padded with leading zeros, e.g. ../03/..
%           or ../12/..
%   m       capitalized first letter of the month, according to the
%           calendar locale; for backwards compatibility.
%   dddd    full name of the weekday, according to the calendar locale,
%           e.g. "Monday", "Tuesday", for the UK and USA calendar locales.
%   ddd     first three letters of the weekday, according to the calendar
%           locale, e.g. "Mon", "Tue", for the UK and USA calendar locales.
%   dd      numeric day of the month, padded with leading zeros, e.g.
%           05/../.. or 20/../..
%   d       capitalized first letter of the weekday; for backwards
%           compatibility
%   HH      hour of the day, according to the time format. In case the time
%           format AM | PM is set, HH does not pad with leading zeros. In
%           case AM | PM is not set, display the hour of the day, padded
%           with leading zeros. e.g 10:20 PM, which is equivalent to 22:20;
%           9:00 AM, which is equivalent to 09:00.
%   MM      minutes of the hour, padded with leading zeros, e.g. 10:15,
%           10:05, 10:05 AM.
%   SS      second of the minute, padded with leading zeros, e.g. 10:15:30,
%           10:05:30, 10:05:30 AM.
%   FFF     milliseconds field, padded with leading zeros, e.g.
%           10:15:30.015.
%   PM      AM or PM is appended as appropriate.
%
%   DATETICK(...,'keeplimits') changes the tick labels into date-based
%   labels while preserving the axis limits.
%
%   DATETICK(....'keepticks') changes the tick labels into date-based labels
%   without changing their locations. Both 'keepticks' and 'keeplimits' can
%   be used at the same time.
%
%   DATETICK(AX,...) uses the specified axes, rather than the current axes.
%
%   DATETICK relies on DATESTR to convert date numbers to character vectors.
%
%   Example (based on the 1990 U.S. census):
%      t = (1900:10:1990)'; % Time interval
%      p = [75.995 91.972 105.711 123.203 131.669 ...
%          150.697 179.323 203.212 226.505 249.633]';  % Population
%      plot(datenum(t,1,1),p) % Convert years to date numbers and plot
%      datetick('x','yyyy') % Replace x-axis ticks with 4 digit year labels.
%
%   See also DATESTR, DATENUM, DATETIME, XTICKFORMAT, YTICKFORMAT, ZTICKFORMAT.

%   Copyright 1984-2016 The MathWorks, Inc.

[axh,nin,ax,dateform,keep_ticks,keep_limits] = parseinputs(varargin);

if nin==2 && isnumeric(dateform) % Determine dateformat from character vector.
    switch dateform
        case 0, dateform = 'dd-mmm-yyyy HH:MM:SS';
        case 1, dateform = 'dd-mmm-yyyy';
        case 2, dateform = 'mm/dd/yy';
        case 3, dateform = 'mmm';
        case 4, dateform = 'm';
        case 5, dateform = 'mm';
        case 6, dateform = 'mm/dd';
        case 7, dateform = 'dd';
        case 8, dateform = 'ddd';
        case 9, dateform = 'd';
        case 10, dateform = 'yyyy';
        case 11, dateform = 'yy';
        case 12, dateform = 'mmmyy';
        case 13, dateform = 'HH:MM:SS';
        case 14, dateform = 'HH:MM:SS PM';
        case 15, dateform = 'HH:MM';
        case 16, dateform = 'HH:MM PM';
        case 17, dateform = 'QQ-YY';
        case 18, dateform = 'QQ';
        case 19, dateform = 'dd/mm';
        case 20, dateform = 'dd/mm/yy';
        case 21, dateform = 'mmm.dd,yyyy HH:MM:SS';
        case 22, dateform = 'mmm.dd,yyyy';
        case 23, dateform = 'mm/dd/yyyy';
        case 24, dateform = 'dd/mm/yyyy';
        case 25, dateform = 'yy/mm/dd';
        case 26, dateform = 'yyyy/mm/dd';
        case 27, dateform = 'QQ-YYYY';
        case 28, dateform = 'mmmyyyy';
        case 29, dateform = 'yyyy-mm-dd';
        case 30, dateform = 'yyyymmddTHHMMSS';
        case 31, dateform = 'yyyy-mm-dd HH:MM:SS';
        otherwise
            error(message('MATLAB:datetick:UnknownFormatType'))
    end
end

% Check to see if the date form is valid:
if nin==2
    try
        datestr(0,dateform);
    catch E
        error(message('MATLAB:datetick:UnknownDateFormat', dateform));
    end
end
isDateRuler = isa(axh,'matlab.graphics.axis.Axes') && isa(axh.(['Active' upper(ax) 'Ruler']), 'matlab.graphics.axis.decorator.DatetimeRuler');
% Compute data limits.
if keep_limits || isempty(get(axh,'children')) || isDateRuler
    lim = get(axh,[ax 'lim']);
    vmin = lim(1);
    vmax = lim(2);
    if isDateRuler
        timezone = lim.TimeZone;
    end
else
    h = findobj(axh);
    vmin = inf; vmax = -inf;
    for i=1:length(h)
        vdata = [];
        try
            t = get(h(i),'type');
        catch exception
            if (strcmp(exception.identifier, 'MATLAB:class:PropertyNotFound') && ...
                (ismethod(h(i),'getXYZDataExtents')))
                pos = h(i).getXYZDataExtents();
                switch ax
                    case 'x'
                        vdata = pos(1,:);
                    case 'y'
                        vdata = pos(2,:);
                    case 'z'
                        vdata = pos(3,:);
                end
            end
            t = '';
        end
    
        if strcmp(t,'surface') || strcmp(t,'patch') || ...
                strcmp(t,'line') || strcmp(t,'image')
            vdata = get(h(i),[ax,'data']);
        elseif strcmp(t,'text')
            pos = get(h(i),'position');
            switch ax
                case 'x'
                    vdata = pos(1);
                case 'y'
                    vdata = pos(2);
                case 'z'
                    vdata = pos(3);
            end
        end

        if ~isempty(vdata)
            vmin = min(vmin,min(vdata(:)));
            vmax = max(vmax,max(vdata(:)));
        end
    end
    %If we did not set limits above, set them now.
    if (vmin > vmax)
        lim = get(axh,[ax 'lim']);
        vmin = lim(1);
        vmax = lim(2);
    end
end
if isa(vmin, 'datetime')
    vmin = datenum(vmin);
    vmax = datenum(vmax);
end
if ~keep_ticks
    if nin==2
        switch dateform
            case 'dd-mmm-yyyy HH:MM:SS', dateChoice = 'yqmwdHMS';
            case 'dd-mmm-yyyy', dateChoice = 'yqmwd';
            case 'mm/dd/yy', dateChoice = 'yqmwd';
            case 'mmm', dateChoice = 'yqm';
            case 'm', dateChoice = 'yqm';
            case 'mm', dateChoice = 'yqm';
            case 'mm/dd', dateChoice = 'yqmwd';
            case 'dd', dateChoice = 'yqmwd';
            case 'ddd', dateChoice = 'yqmwd';
            case 'd', dateChoice = 'yqmwd';
            case 'yyyy', dateChoice = 'y';
            case 'yy', dateChoice = 'y';
            case 'mmmyy', dateChoice = 'yqm';
            case 'HH:MM:SS', dateChoice = 'yqmwdHMS';
            case 'HH:MM:SS PM', dateChoice = 'yqmwdHMS';
            case 'HH:MM', dateChoice = 'yqmwdHMS';
            case 'HH:MM PM', dateChoice = 'yqmwdHMS';
            case 'QQ-YY', dateChoice = 'yq';
            case 'QQ', dateChoice = 'yq';
            case 'dd/mm', dateChoice = 'yqmwd';
            case 'dd/mm/yy', dateChoice = 'yqmwd';
            case 'mmm.dd,yyyy HH:MM:SS', dateChoice = 'yqmwdHMS';
            case 'mmm.dd,yyyy', dateChoice = 'yqmwd';
            case 'mm/dd/yyyy', dateChoice = 'yqmwd';
            case 'dd/mm/yyyy', dateChoice = 'yqmwd';
            case 'yy/mm/dd', dateChoice = 'yqmwd';
            case 'yyyy/mm/dd', dateChoice = 'yqmwd';
            case 'QQ-YYYY', dateChoice = 'yq';
            case 'mmmyyyy', dateChoice = 'yqm';
            case 'yyyy-mm-dd', dateChoice = 'yqmwd';
            case 'yyyymmddTHHMMSS', dateChoice = 'yqmwdHMS';
            case 'yyyy-mm-dd HH:MM:SS', dateChoice = 'yqmwdHMS';
            otherwise
                dateChoice = localParseCustomDateForm(dateform);
        end
        ticks = bestscale(axh,ax,vmin,vmax,dateform,dateChoice);
    else
        [ticks,dateform] = bestscale(axh,ax,vmin,vmax);
    end
else
    ticks = get(axh,[ax,'tick']);
    if isa(ticks, 'datetime')
        ticks = datenum(ticks);
    end
    if nin~=2
        % Use dateform from bestscale
        [dum,dateform] = bestscale(axh,ax,min(ticks),max(ticks));%#ok
    end
end

% Set axis tick labels
labels = datestr(ticks,dateform);
if isDateRuler
    ticks = datetime(ticks,'convertFrom','datenum','TimeZone',timezone);
end
if keep_limits
    set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels)
else
    set(axh,[ax,'tick'],ticks,[ax,'ticklabel'],labels, ...
        [ax,'lim'],[min(ticks) max(ticks)])
end

%--------------------------------------------------
function [labels,format] = bestscale(axh,ax,xmin,xmax,dateform,dateChoice)
%BESTSCALE Returns ticks for "best" scale.
%   [TICKS,FORMAT] = BESTSCALE(XMIN,XMAX) returns the tick
%   locations in the vector TICKS that span the interval (XMIN,XMAX)
%   with "nice" tick spacing.  The dateform FORMAT is also returned.

if nargin<6, dateChoice = 'yqmwdHMS'; end
if nargin<5, dateform = []; end

axVal = 0;
switch(ax)
    case 'x'
        axVal = 0;
    case 'y'
        axVal = 1;
    case 'z'
        axVal = 2;
end

[labels,format] = dateTickPicker(axh,[xmin,xmax],dateform,dateChoice,axVal);

%-------------------------------------------------
function [axh,nin,ax,dateform,keep_ticks,keep_limits] = parseinputs(v)
import matlab.internal.datatypes.stringToLegacyText;
for i = 1:length(v)
	v{i} = stringToLegacyText(v{i}); 
end
% Parse Inputs
% Defaults;
dateform = [];
keep_ticks = 0;
keep_limits = 0;
nin = length(v);

% check to see if an axes was specified
if nin > 0 && isscalar(v{1}) && (isgraphics(v{1},'axes') || isgraphics(v{1},'colorbar'))
    % use the axes passed in
    axh = v{1};
    v(1)=[];
    nin=nin-1;
else
    % use gca
    axh = gca;
end

% check for too many input arguments
if nin < 0
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nin > 4
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% check for incorrect arguments
% if the input args is more than two - it should be either
% 'keeplimits' or 'keepticks' or both.
if nin > 2
    for i = nin:-1:3
        if ~(strcmpi(v{i},'keeplimits') || strcmpi(v{i},'keepticks'))
            error(message('MATLAB:datetick:IncorrectArgs'));
        end
    end
end


% Look for 'keeplimits'
for i=nin:-1:max(1,nin-2)
    if strcmpi(v{i},'keeplimits')
        keep_limits = 1;
        v(i) = [];
        nin = nin-1;
    end
end

% Look for 'keepticks'
for i=nin:-1:max(1,nin-1)
    if strcmpi(v{i},'keepticks')
        keep_ticks = 1;
        v(i) = [];
        nin = nin-1;
    end
end

if nin==0
    ax = 'x';
else
    switch v{1}
        case {'x','y','z'}
            ax = v{1};
        otherwise
            error(message('MATLAB:datetick:InvalidAxis'));
    end
end


if nin > 1
    % The dateform (Date Format) value should be a scalar or character vector
    % check this out
    dateform = v{2};
    if (isnumeric(dateform) && length(dateform) ~= 1) && ~ischar(dateform)
        error(message('MATLAB:datetick:InvalidInput'));
    end
end

%---------------------------------------------------------------%
function dateChoice = localParseCustomDateForm(dateform)
% Returns the size of a custom date form and the corresponding date choice.

% If the date form contains second information:
if ~isempty(regexp(dateform,'HH|MM|SS|FFFF', 'once' ))
    dateChoice = 'yqmwdHMS';
    return;
end
% If the date form contains day information:
if any(dateform == 'd')
    dateChoice = 'yqmwd';
    return;
end
% If the date form contains month information:
if any(dateform == 'm')
    dateChoice = 'yqm';
    return;
end
% If the date form contains year information:
if ~isempty(regexp(dateform,'yy','once'))
    dateChoice = 'y';
    return;
end
% If we get here, it means we likely have a garbage format, but it is still
% valid. Return the maximum granularity in this case:
dateChoice = 'yqmwdHMS';
