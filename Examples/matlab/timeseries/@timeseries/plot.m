function varargout = plot(h,varargin)
%PLOT  Plot time series data
%
%   PLOT(TS) plot the timeseries data against its time using either
%   zero-order-hold or linear interpolation. If the interpolation behavior
%   of the timeseries data is 'zoh', a stair plot is generated, otherwise a
%   regular plot is created.
%
%   Timeseries events, if present, are marked in the plot using a red
%   circular marker.  
%
%   PLOT accepts the modifiers used by MATLAB's PLOT utility for numerical
%   arrays. These modifiers can be specified as auxiliary inputs for
%   modifying the appearance of the plot.
%
%   Examples:
%   plot(ts,'-r*') plots using a regular line with color red and marker '*'.
%   plot(ts,'ko','MarkerSize',3) uses black circular markers of size 3 to
%   render the plot.
%
%   See also PLOT, TIMESERIES, TIMESERIES/ADDEVENT
%

%   Copyright 2005-2016 The MathWorks, Inc.

if numel(h)~=1
    error(message('MATLAB:timeseries:plot:noarray'));
end

% Define variables
if isempty(h)
   error(message('MATLAB:timeseries:plot:emptyplot'))
end
%Throw error if you plot timeseries without any data but has time 
if isempty(h.time) 
    if ~isempty(h.data)
        error(message('MATLAB:timeseries:plot:notimeseriestime'))
    end
else
%Throw error if you plot timeseries without any time but has data 
    if isempty(h.data)
        error(message('MATLAB:timeseries:plot:notimeseriesdata'))
    end
end
dataContent = h.Data;
if ~isnumeric(dataContent) && ~islogical(dataContent)
    error(message('MATLAB:timeseries:plot:nonnumeric'));
end

if ~h.IsTimeFirst
    dataContent = h.Data;
    n = ndims(dataContent);
    if h.TimeInfo.Length>1
        dataContent = permute(dataContent,[n 1:n-1]);
        dataContent = dataContent(:,:);
    else
        dataContent = reshape(dataContent,[1 numel(dataContent)]);
    end        
end
Time = h.Time;
Data = squeeze(dataContent);
if isempty(Time) || isempty(Data)
    return
end

% 2d data only
if (~isnumeric(Data) && ~islogical(Data)) || ~ismatrix(Data)
    error(message('MATLAB:timeseries:plot:invaliddata'))
end

% Check for a specified axes
ax = [];
if nargin>=3
    paramNameI = find(cellfun('isclass',varargin(1:end-1),'char') | cellfun('isclass',varargin(1:end-1),'string'));
    for k=1:length(paramNameI)
        if strcmpi(varargin{paramNameI(k)},'parent')
            if ishandle(varargin{paramNameI(k)+1}) && ...
                    strcmpi(get(varargin{paramNameI(k)+1},'Type'),'axes')
                ax = varargin{paramNameI(k)+1};
            end
            break;
        end
        
        % Convert all strings to chars so that the graphics or datetime
        % plot function does not error
        varargin{paramNameI(k)} = char(varargin{paramNameI(k)});
    end
end
    

% Get current figure/axes
if isempty(ax)    
    f = gcf;
    if strcmp(get(f,'NextPlot'),'add')
        if isempty(get(f,'CurrentAxes'))
            set(f,'DefaultTextInterpreter','none');
            ax = axes('parent',f);        
        else
            ax = get(f,'CurrentAxes');
        end
    else
        set(f,'nextplot','replace','DefaultTextInterpreter','none');
        ax = axes('parent',f);
    end
end

% Use datetime for the X axis if this is an absolute time timeseries
% being plotted into a new axes or an existing axes which contained a 
% absolute time plot
absTimeFlag = ~isempty(h.TimeInfo.StartDate) && ...
    ( ~strcmpi(ax.NextPlot,'add') || isa(ax.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler') );

% Enable the plot to show dates if this timeseries has an absolute time
% vector and if hold is on, all previous plotted timeseries had absolute 
% time vectors.
if absTimeFlag
    % Create a datetime array representing the absolute time vector
    if isempty(h.TimeInfo.Format)
        refdatenum = localDateNum(h.TimeInfo.StartDate);
    else
        try
            refdatenum = localDateNum(h.TimeInfo.StartDate,h.TimeInfo.Format);
        catch
            refdatenum = localDateNum(h.TimeInfo.StartDate);
        end
    end
    Time = localGetdatetime(refdatenum, h.Time, h.TimeInfo.Units);
end

% Show stairs when interp method is zoh  
if strcmpi(h.getinterpmethod,'zoh') && length(Time)>1 %stairs for single time sample errors out
    p = stairs(ax,Time,Data,varargin{:});
else
    p = plot(ax,Time,Data,varargin{:});
end

% Set datetime tick format when showing dates for absolute time vector
if absTimeFlag
    if ~isempty(h.TimeInfo.Format)
        try
            % Convert string-valued h.TimeInfo.Format to char for cnv2icudf
            datetimeTickFormat = matlab.internal.datetime.cnv2icudf(char(h.TimeInfo.Format));
        catch me
            if strcmp('MATLAB:formatdate:dayFormat',me.identifier)
                datetimeTickFormat = 'dd-MMM-uuuu HH:mm:ss';
            else
                rethrow(me);
            end
        end
    else
        datetimeTickFormat = 'dd-MMM-uuuu HH:mm:ss';
    end
    % g1583088
    xtickformat(ax,datetimeTickFormat);
end
        
% If possible, set the data sources for linked plots
tsInVarName = inputname(1);
if ~isempty(tsInVarName)   
    for k=1:length(p)
        % Use the hidden timeseries Datenums property for datetime plot
        % XDataSource. This allows linked plots and data brushing to
        % convert to and from datenums when translating between 
        % the axes X values and the timeseries Time vector.
        if absTimeFlag
            set(p(k),'XDataSource',[tsInVarName '.Datenums'],'YDataSource',...
                getcolumn([tsInVarName '.Data'],k,'expression','caller'));
        else
            set(p(k),'XDataSource',[tsInVarName '.Time'],'YDataSource',...
                getcolumn([tsInVarName '.Data'],k,'expression','caller'));
        end
    end
end

% Add xlabel, if one has not been specified
existingXLabelStr = get(get(ax,'xlabel'),'String');
if isempty(existingXLabelStr)
    if ~absTimeFlag
        try 
            stringTime = getString(message('MATLAB:timeseries:plot:Time'));
            xlabel(ax,sprintf('%s (%s)', stringTime, h.TimeInfo.getUnitsDisplayStr));
        catch me
            if strcmp(me.identifier,'MATLAB:noSuchMethodOrField') || strcmp(me.identifier,'MATLAB:UndefinedFunction') 
                % Convert string-valued h.TimeInfo.Units to char for xlabel
                xlabel(ax,sprintf('%s (%s)', stringTime, char(h.TimeInfo.Units)));
            else
                rethrow(me);
            end
        end  
    end   
else
    xlabel(ax,' ');
end

% If h.Name is 'unnamed', use the message catalog version, so that it will
% be translated in the ylabel and title.
if strcmp(h.Name, 'unnamed')
    name = getString(message('MATLAB:timeseries:plot:unnamed'));
else
    name = h.Name;
end

% Add y label if one has not be specified
dataUnits = h.DataInfo.Units; 
if isempty(dataUnits)
    ystr = name;
    if isempty(ystr)
        ystr = 'data';
    end
else
    if ischar(dataUnits) || isstring(dataUnits)
        ystr = sprintf('%s (%s)',name,dataUnits);
    else
        ystr = sprintf('%s (%s)',name,dataUnits.Name);
    end
end
existingYLabelStr = get(get(ax,'ylabel'),'String');
if isempty(existingYLabelStr)
    ylabel(ax,ystr);
else
    ylabel(ax,' ');
end

% Add a title if one has not be specified
existingTitle = get(get(ax,'title'),'String');
if isempty(existingTitle)
    strTimeSeriesPlot = getString(message('MATLAB:timeseries:plot:TimeSeriesPlot'));
    title(ax,sprintf('%s:%s', strTimeSeriesPlot, name))
else
    title(ax,' ')
end
    
% Annotate events
if absTimeFlag 
    ev = datetime.empty;
else
   ev = [];
end
evnames = {};
E = h.Events;

if ~isempty(E)
    for k = 1:length(E)
        evtime = [];
        
        if absTimeFlag && ~isempty(E(k).StartDate)
            evtime = localGetdatetime(localDateNum(E(k).StartDate),E(k).Time,E(k).Units);
        elseif ~absTimeFlag && isempty(E(k).StartDate)
            evtime = E(k).Time*tsunitconv(h.TimeInfo.Units,E(k).Units);
        end
        if ~isempty(evtime) && evtime>=Time(1) && evtime<=Time(end)
              ev(end+1) = evtime; %#ok<AGROW>
              evnames{end+1} = E(k).Name; %#ok<AGROW>
        end        
    end
    if ~isempty(ev)
        cachedNextPlot = get(ax,'NextPlot');
        set(ax,'NextPlot','add');
        Inp = h.DataInfo.Interpolation;
        try % Object Data arrays (e.g.fi) may not support interpolation
            if absTimeFlag
                evdata = Inp.interpolate(localDateNum(Time),Data,localDateNum(ev),[],~h.hasduplicatetimes);
            else
                evdata = Inp.interpolate(Time,Data,ev,[],~h.hasduplicatetimes);
            end
        catch %#ok<CTCH>
            if absTimeFlag
                evdata = Inp.interpolate(localDateNum(Time),double(Data),localDateNum(ev),[],~h.hasduplicatetimes);
            else
                evdata = Inp.interpolate(Time,double(Data),ev,[],~h.hasduplicatetimes);
            end
        end
        if isscalar(ev)
            ev = repmat(ev,size(evdata'));
        end
        if absTimeFlag   
            if ~isempty(h.TimeInfo.Format)
                evMarkers = plot(ax,ev,evdata,'ro',...
                   'MarkerEdgeColor','k',...
                   'MarkerFaceColor','r','DatetimeTickFormat',matlab.internal.datetime.cnv2icudf(char(h.TimeInfo.Format)));
            else
                evMarkers = plot(ax,ev,evdata,'ro',...
                   'MarkerEdgeColor','k',...
                   'MarkerFaceColor','r','DatetimeTickFormat','dd-MMM-uuuu HH:mm:ss');
            end
        else
             evMarkers = plot(ax,ev,evdata,'ro',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r');
        end

        p = [p;evMarkers];
        % Create the behavior object using hgbehaviorfactory rather
        % than hggetbehavior since for datetime plots hggetbehavior
        % will retrieve the datetime plot's datacursor behavior. 
        bh = hgbehaviorfactory('datacursor',evMarkers(1));
        bh.UpdateFcn = @eventtipfcn;
        bhstruct = struct('datacursor',bh);
        for k=1:numel(evMarkers)
            evMarkers(k).Behavior = bhstruct;
            hasbehavior(double(evMarkers(k)),'legend',false)
            setappdata(evMarkers(k),'EventNames',evnames);
            setappdata(evMarkers(k),'EventTimes',ev);
            setappdata(evMarkers(k),'EventDataTipCache',bh);
        end       
        set(ax,'NextPlot',cachedNextPlot);      
    end
end

if nargout>0
    varargout{1} = p;
end


function output_txt = eventtipfcn(obj,event_obj) %#ok<INUSL>
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = event_obj.Position;
evnames = getappdata(event_obj.Target,'EventNames');
evtimes = getappdata(event_obj.Target,'EventTimes');
strEvent=[getString(message('MATLAB:timeseries:plot:Event')) ':'];
strTime=[getString(message('MATLAB:timeseries:plot:Time')) ':'];
if isa(evtimes,'datetime')
    % Find the closest event
    [~,ind] = min(abs(evtimes-datetime(pos(1),'ConvertFrom','datenum')));
    output_txt = {[strEvent ' ' evnames{ind(1)}],[strTime,' ',datestr(evtimes(ind(1)))]};
else
    [~,ind] = min(abs(evtimes-pos(1))); 
    output_txt = {[strEvent ' ' evnames{ind(1)}],[strTime,' ',num2str(evtimes(ind(1)))]};
end

function result = localGetdatetime(referenceDatenum, offset, offsetunits)

result = datetime(referenceDatenum,'ConvertFrom','datenum');
switch char(offsetunits)
    case 'hours'
        result = result+duration(offset,zeros(size(offset)),zeros(size(offset)));
    case 'minutes'
        result = result+duration(zeros(size(offset)),offset,zeros(size(offset)));
    case 'seconds'
        result = result+duration(zeros(size(offset)),zeros(size(offset)),offset);
    case {'milliseconds', 'microseconds', 'nanoseconds'}
        result = result+duration(zeros(size(offset)),zeros(size(offset)),tsunitconv('seconds',offsetunits)*offset);
    otherwise
        result = result+duration(tsunitconv('hours',offsetunits)*offset,...
            zeros(size(offset)),zeros(size(offset)));
end

function dateNum = localDateNum(datestr, format)

% Return datenums for string arrays or cellstrs
if nargin==1
    if isstring(datestr)
        dateNum = datenum(char(datestr));
    else
        dateNum = datenum(datestr);
    end
else
    if isstring(datestr)
        dateNum = datenum(char(datestr), char(format));
    else
        dateNum = datenum(datestr, char(format));
    end
end
