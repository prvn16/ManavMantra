function [labels,outForm] = dateTickPicker(ruler,limits,dateform,dateChoice,ax)
%DATETICKPICKER Helper function for datetick
%  This is an internal helper function. It might be changed or removed in a future release.

% Copyright 2007-2017 The MathWorks, Inc.

if nargin<4, dateChoice = 'yqmwdHMS'; end
if nargin<3, dateform = []; end

% The last entry in this array is a place-holder for custom date strings.
formlen = [20 12 8 3 1 2 5 2 3 1 4 2 5 8 11 5 8 5 2 5 8 20 11 10 10 8 10 7 7 10 15 19 0];

xmin = limits(1);
xmax = limits(2);

% "Good" spacing between dates
if xmin==xmax
    xmin = xmin-1;
    xmax = xmax+1;
end

axh = ruler;

% Get axis width/height in pixels
axPos = get(axh,'position');
hFig = ancestor(axh,'Figure');
axPos = hgconvertunits(hFig,axPos,get(axh,'Units'),'Pixels',hFig);
dateInd = dateform;

if ~isempty(dateform)
    switch dateform
        case 'dd-mmm-yyyy HH:MM:SS', dateChoice = 'yqmwdHMS'; dateInd = 0;
        case 'dd-mmm-yyyy', dateChoice = 'yqmwd'; dateInd = 1;
        case 'mm/dd/yy', dateChoice = 'yqmwd'; dateInd = 2;
        case 'mmm', dateChoice = 'yqm'; dateInd = 3;
        case 'm', dateChoice = 'yqm'; dateInd = 4;
        case 'mm', dateChoice = 'yqm'; dateInd = 5;
        case 'mm/dd', dateChoice = 'yqmwd'; dateInd = 6;
        case 'dd', dateChoice = 'yqmwd'; dateInd = 7;
        case 'ddd', dateChoice = 'yqmwd'; dateInd = 8;
        case 'd', dateChoice = 'yqmwd'; dateInd = 9;
        case 'yyyy', dateChoice = 'y'; dateInd = 10;
        case 'yy', dateChoice = 'y'; dateInd = 11;
        case 'mmmyy', dateChoice = 'yqm'; dateInd = 12;
        case 'HH:MM:SS', dateChoice = 'yqmwdHMS'; dateInd = 13;
        case 'HH:MM:SS PM', dateChoice = 'yqmwdHMS'; dateInd = 14;
        case 'HH:MM', dateChoice = 'yqmwdHMS'; dateInd = 15;
        case 'HH:MM PM', dateChoice = 'yqmwdHMS'; dateInd = 16;
        case 'QQ-YY', dateChoice = 'yq'; dateInd = 17;
        case 'QQ', dateChoice = 'yq'; dateInd = 18;
        case 'dd/mm', dateChoice = 'yqmwd'; dateInd = 19;
        case 'dd/mm/yy', dateChoice = 'yqmwd'; dateInd = 20;
        case 'mmm.dd,yyyy HH:MM:SS', dateChoice = 'yqmwdHMS'; dateInd = 21;
        case 'mmm.dd,yyyy', dateChoice = 'yqmwd'; dateInd = 22;
        case 'mm/dd/yyyy', dateChoice = 'yqmwd'; dateInd = 23;
        case 'dd/mm/yyyy', dateChoice = 'yqmwd'; dateInd = 24;
        case 'yy/mm/dd', dateChoice = 'yqmwd'; dateInd = 25;
        case 'yyyy/mm/dd', dateChoice = 'yqmwd'; dateInd = 26;
        case 'QQ-YYYY', dateChoice = 'yq'; dateInd = 27;
        case 'mmmyyyy', dateChoice = 'yqm'; dateInd = 28;
        case 'yyyy-mm-dd', dateChoice = 'yqmwd'; dateInd = 29;
        case 'yyyymmddTHHMMSS', dateChoice = 'yqmwdHMS'; dateInd = 30;
        case 'yyyy-mm-dd HH:MM:SS', dateChoice = 'yqmwdHMS'; dateInd = 31;
        otherwise
            [dateChoice, formlen(end)] = localParseCustomDateForm(dateform);
            dateInd = 32;
    end

end

yearDelta = 10.^(max(0,round(log10(xmax-xmin)-3)))* ...
    [ .1 .2 .25 .5 1 2 2.5 5 10 20 25 50];
yearDelta(yearDelta<1)= []; % Make sure we use integer years.
quarterDelta = 3;
monthDelta = 1;
weekDelta = 1;
dayDelta = 1;
hourDelta = [1 3 6];
minuteDelta = [1 5 10 15 30 60];
secondDelta = min(1,10.^(round(log10(xmax-xmin)-1))* ...
    [ .1 .2 .25 .5 1 2 2.5 5 10 20 25 50 ]);
secondDelta = [secondDelta 1 5 10 15 30 60];

x = [xmin xmax];
[y,m,d] = datevec(x);

% Compute continuous variables for the various time scales.
year = y + (m-1)/12 + (d-1)/12/32;
qtr = (y-y(1))*12 + m + d/32 - 1;
mon = (y-y(1))*12 + m + d/32;
day = x;
week = (x-2)/7;
hour = (x-floor(x(1)))*24;
minute = (x-floor(x(1)))*24*60;
second = (x-floor(x(1)))*24*3600;

% Compute possible low, high and ticks
if any(dateChoice=='y')
    yearHigh = yearDelta.*ceil(year(2)./yearDelta);
    yearLow = yearDelta.*floor(year(1)./yearDelta);
    yrTicks = round((yearHigh-yearLow)./yearDelta);
    yrHigh = datenum(yearHigh,1,1);
    yrLow = datenum(yearLow,1,1);
    % Encode location of year tick locations in format
    yrFormat = 10 + (1:length(yearDelta))/10;
else
    yrHigh=[]; yrLow=[]; yrTicks=[]; yrFormat = 10;
end

if any(dateChoice=='q')
    quarterHigh = quarterDelta.*ceil(qtr(2)./quarterDelta);
    quarterLow = quarterDelta.*floor(qtr(1)./quarterDelta);
    qtrTicks = round((quarterHigh-quarterLow)./quarterDelta);
    qtrHigh = datenum(y(1),quarterHigh+1,1);
    qtrLow = datenum(y(1),quarterLow+1,1);
    % Encode location of qtr tick locations in format
    qtrFormat = 17 + (1:length(quarterDelta))/10;
else
    qtrHigh=[]; qtrLow=[]; qtrTicks=[]; qtrFormat = [];
end

if any(dateChoice=='m')
    monthHigh = monthDelta.*ceil(mon(2)./monthDelta);
    monthLow = monthDelta.*floor(mon(1)./monthDelta);
    monTicks = round((monthHigh-monthLow)./monthDelta);
    monHigh = datenum(y(1),monthHigh,1);
    monLow = datenum(y(1),monthLow,1);
    % Encode location of month tick locations in format
    monFormat = 3 + (1:length(monthDelta))/10;
else
    monHigh=[]; monLow=[]; monTicks=[]; monFormat = [];
end

if any(dateChoice=='w')
    weekHigh = weekDelta.*ceil(week(2)./weekDelta);
    weekLow = weekDelta.*floor(week(1)./weekDelta);
    weekTicks = round((weekHigh-weekLow)./weekDelta);
    weekHigh = weekHigh*7+2;
    weekLow = weekLow*7+2;
    weekFormat = 6*ones(size(weekDelta));
else
    weekHigh=[]; weekLow=[]; weekTicks=[]; weekFormat=[];
end

if any(dateChoice=='d')
    dayHigh = dayDelta.*ceil(day(2)./dayDelta);
    dayLow = dayDelta.*floor(day(1)./dayDelta);
    dayTicks = round((dayHigh-dayLow)./dayDelta);
    dayFormat = 6*ones(size(dayDelta));
else
    dayHigh=[]; dayLow=[]; dayTicks=[]; dayFormat = [];
end

if any(dateChoice=='H')
    hourHigh = hourDelta.*ceil(hour(2)./hourDelta);
    hourLow = hourDelta.*floor(hour(1)./hourDelta);
    hourTicks = round((hourHigh-hourLow)./hourDelta);
    hourHigh = datenum(y(1),m(1),d(1),hourHigh,0,0);
    hourLow = datenum(y(1),m(1),d(1),hourLow,0,0);
    hourFormat = 15*ones(size(hourDelta));
else
    hourHigh=[]; hourLow=[]; hourTicks=[]; hourFormat=[];
end

if any(dateChoice=='M')
    minHigh = minuteDelta.*ceil(minute(2)./minuteDelta);
    minLow = minuteDelta.*floor(minute(1)./minuteDelta);
    minTicks = round((minHigh-minLow)./minuteDelta);
    minHigh = datenum(y(1),m(1),d(1),0,minHigh,0);
    minLow = datenum(y(1),m(1),d(1),0,minLow,0);
    minFormat = 15*ones(size(minuteDelta));
else
    minHigh=[]; minLow=[]; minTicks=[]; minFormat=[];
end

if any(dateChoice=='S')
    secHigh = secondDelta.*ceil(second(2)./secondDelta);
    secLow = secondDelta.*floor(second(1)./secondDelta);
    secTicks = round((secHigh-secLow)./secondDelta);
    secHigh = datenum(y(1),m(1),d(1),0,0,secHigh);
    secLow = datenum(y(1),m(1),d(1),0,0,secLow);
    secFormat = 13*ones(size(secondDelta));
else
    secHigh=[]; secLow=[]; secTicks=[]; secFormat=[];
end

% Concatenate all the date formats together to determine
% the best spacing.
high =  [yrHigh   qtrHigh   monHigh   dayHigh   weekHigh   hourHigh   minHigh   secHigh];
low =   [yrLow    qtrLow    monLow    dayLow    weekLow    hourLow    minLow    secLow];
ticks = [yrTicks  qtrTicks  monTicks  dayTicks  weekTicks  hourTicks  minTicks  secTicks];
format =[yrFormat qtrFormat monFormat dayFormat weekFormat hourFormat minFormat secFormat];

% sort the formats by number of ticks.
[ticks,ndx] = sort(ticks);
high = high(ndx);
low = low(ndx);
format = format(ndx);

% Estimate the extent of each format as a fraction of the axes width or height
extent = localGetExtent(formlen,format,ax,axh,dateInd,axPos);

% Chose the best fit. The best fit has the least slop without overlap and
% the most ticks.
fit = (abs(xmin-low) + abs(high-xmax))./(high-low) + max(0,extent.*ticks-1);
i = find(fit == min(fit));
[dum,j] = max(ticks(i));%#ok
i = i(j);
low = low(i); high = high(i); ticks = ticks(i); format = format(i);

if floor(format) == 3  % Month format
    i = round(rem(format,1)*10); % Retrieve encoded value
    labels = datenum(y(1),linspace(monthLow(i),monthHigh(i),ticks+1),1);
    format = 3;
elseif floor(format) == 17  % Quarter format
    i = round(rem(format,1)*10); % Retrieve encoded value
    labels = datenum(y(1),linspace(quarterLow(i)+1,quarterHigh(i)+1,ticks+1),1);
    format = 17;
elseif floor(format) == 10  % Year format
    i = round(rem(format,1)*10); % Retrieve encoded value
    labels = datenum(linspace(yearLow(i),yearHigh(i),ticks+1),1,1);
    format= 10;
else
    labels = linspace(low,high,ticks+1);
end
labels = unique(labels);
outForm = localDateFormToEnum(format);

%---------------------------------------------------------------%
function extent = localGetExtent(formlen,format,ax,axh,dateInd,axPos)
fsize = get(axh,'FontSize')*get(0,'ScreenPixelsPerInch')/72;
if ax == 0 %0 is the X-axis
    if isempty(dateInd)
        len = formlen(floor(format)+1);
    else
        len = formlen(dateInd+1)+zeros(size(format));
    end
    % estimate that the width is .5 of the font size * length of format
    extent = 2*fsize/3*len/axPos(3);
else
    % estimate a height of 2*fsize so that there is plenty of space between labels
    extent = repmat(2*fsize,size(format))/axPos(4);
end

%---------------------------------------------------------------%
function [dateChoice, formLen] = localParseCustomDateForm(dateform)
% Returns the size of a custom date form and the corresponding date choice.

formLen = numel(datestr(0,dateform));
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
% If we get here, it means we likely have a garbage string, but it is still
% valid. Return the maximum granularity in this case:
dateChoice = 'yqmwdHMS';

%---------------------------------------------------------------%
function dateform = localDateFormToEnum(dateform)

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
end
