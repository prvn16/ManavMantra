function hh = stem(varargin)
    %STEM   Discrete sequence or "stem" plot.
    %   STEM(Y) plots the data sequence Y as stems from the x axis
    %   terminated with circles for the data value. If Y is a matrix then
    %   each column is plotted as a separate series.
    %
    %   STEM(X,Y) plots the data sequence Y at the values specified
    %   in X.
    %
    %   STEM(...,'filled') produces a stem plot with filled markers.
    %
    %   STEM(...,'LINESPEC') uses the linetype specified for the stems and
    %   markers.  See PLOT for possibilities.
    %
    %   STEM(AX,...) plots into axes with handle AX. Use GCA to get the
    %   handle to the current axes or to create one if none exist.
    %
    %   H = STEM(...) returns a vector of stemseries handles in H, one handle
    %   per column of data in Y.
    %
    %   See also PLOT, BAR, STAIRS.
    
    %   Copyright 1984-2017 MathWorks, Inc.
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    
    nargs = length(args);
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    end
    [pvpairs,args,nargs,msg] = parseargs(args);
    if ~isempty(msg), error(msg); end
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 2
        error(message('MATLAB:narginchk:tooManyInputs'));
    end

    allowNonNumeric = true;
    args = getRealData(args,allowNonNumeric); % get the real component if data is complex
       
    [msg,x,y] = xychk(args{1:nargs},'plot');
    if ~isempty(msg), error(msg); end
    hasXData = nargs ~= 1;
    if min(size(x))==1, x = x(:); end
    if min(size(y))==1, y = y(:); end
    n = size(y,2);
    
    % handle vectorized data sources and display names
    extrapairs = cell(n,0);
    if ~isempty(pvpairs) && (n > 1)
        [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
            {'XDataSource','YDataSource','DisplayName'});
    end
    
    if isempty(cax) || ishghandle(cax,'axes')
        cax = newplot(cax);
        parax = cax;
        NextPlotReplace = any(strcmpi(cax.NextPlot,{'replaceall','replace'}));
    else
        parax = cax;
        cax = ancestor(cax,'axes');
        NextPlotReplace = false;
    end

    matlab.graphics.internal.configureAxes(cax,x,y);
    [x,y] = matlab.graphics.internal.makeNumeric(cax,x,y);

    h = repmat(matlab.graphics.GraphicsPlaceholder,n,1);  % preallocate stem array
    autoColor = ~any(strcmpi('Color',pvpairs(1:2:end)));
    if autoColor
        colorProp = 'Color_I';
    else
        colorProp = 'Color';
    end
    autoStyle = ~any(strcmpi('LineStyle',pvpairs(1:2:end)));
    if autoStyle
        styleProp = 'LineStyle_I';
    else
        styleProp = 'LineStyle';
    end
    origpvpairs = pvpairs;
    xdata = {};
    for k=1:n
        % extract data from vectorizing over columns
        if hasXData
            xdata = {'XData', datachk(x(:,k))};
        end
        [l,c,m] = nextstyle(cax,autoColor,autoStyle);
        if ~isempty(m) && ~strcmpi(m,'none')
            pvpairs = [{'Marker_I',m},origpvpairs];
        end
        if k==1
            h = matlab.graphics.chart.primitive.Stem('Parent', parax, 'YData',datachk(y(:,k)), xdata{:},...
                colorProp,c,styleProp,l,...
                pvpairs{:},extrapairs{k,:});
        else
            h(k) = matlab.graphics.chart.primitive.Stem('Parent', parax, 'YData',datachk(y(:,k)), xdata{:},...
                colorProp,c,styleProp,l,...
                pvpairs{:},extrapairs{k,:});
        end
    end
    
    if NextPlotReplace
        cax.Box = 'on';
        if(isprop(cax,'XAxis'))
            set(cax.XAxis,'AxesLayer','top')
        end
    end
    if nargout>0, hh = h; end
end

function [pvpairs,args,nargs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
    n = 1;
    extrapv = {};
    % check for 'filled' or LINESPEC
    while length(pvpairs) >= 1 && n < 3 && matlab.graphics.internal.isCharOrString(pvpairs{1})
        arg = lower(pvpairs{1});
        argn = length(arg);
        if strncmp(arg, 'filled', argn)
            pvpairs(1) = [];
            extrapv = [{'MarkerFaceColor','auto'},extrapv];
        else
            [l,c,m,tmsg]=colstyle(pvpairs{1});
            if isempty(tmsg)
                pvpairs(1) = [];
                if ~isempty(l)
                    extrapv = [{'LineStyle',l},extrapv];
                end
                if ~isempty(c)
                    extrapv = [{'Color',c},extrapv];
                end
                if ~isempty(m)
                    extrapv = [{'Marker',m},extrapv];
                end
            end
        end
        n = n+1;
    end
    pvpairs = [extrapv pvpairs];
    msg = checkpvpairs(pvpairs);
    nargs = length(args);
end
