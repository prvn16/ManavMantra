function [xo,yo] = stairs(varargin)
    %STAIRS Stairstep plot.
    %   STAIRS(Y) draws a stairstep graph of the elements of vector Y.
    %
    %   STAIRS(X,Y) draws a stairstep graph of the elements in vector Y at
    %   the locations specified in X.
    %
    %   STAIRS(...,STYLE) uses the plot linestyle specified by the
    %   string STYLE.
    %
    %   STAIRS(AX,...) plots into AX instead of GCA.
    %
    %   H = STAIRS(X,Y) returns a vector of stairseries handles.
    %
    %   [XX,YY] = STAIRS(X,Y) does not draw a graph, but returns vectors
    %   X and Y such that PLOT(XX,YY) is the stairstep graph.
    %
    %   The above inputs to STAIRS can be followed by property/value
    %   pairs to specify additional properties of the stairseries object.
    %
    %   Stairstep plots are useful for drawing time history plots of
    %   zero-order-hold digital sampled-data systems.
    %
    %   See also BAR, HISTOGRAM, STEM.
    
    %   L. Shure, 12-22-88.
    %   Revised A.Grace and C.Thompson 8-22-90.
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    % Check for back compatible version:
    if (nargout == 2)
        [xo,yo] = Lstairsv6(cax,args{:});
        return;
    end
    
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
    
    h = [];
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
    xdata = {};
    for k=1:n
        % extract data from vectorizing over columns
        if hasXData
            xdata = {'XData', datachk(x(:,k))};
        end
        [l,c,m] = nextstyle(cax,autoColor,autoStyle);
        if k==1
            h = matlab.graphics.chart.primitive.Stair('YData',datachk(y(:,k)),xdata{:},...
                colorProp,c,styleProp,l,'Marker_I',m,...
                pvpairs{:},extrapairs{k,:},'Parent',parax);
        else
            h(k) = matlab.graphics.chart.primitive.Stair('YData',datachk(y(:,k)),xdata{:},...
                colorProp,c,styleProp,l,'Marker_I',m,...
                pvpairs{:},extrapairs{k,:},'Parent',parax);
        end
    end
    
    if NextPlotReplace
        cax.Box = 'on';
    end
    
    if nargout==1, xo = h(:); end
    
end

function [pvpairs,args,nargs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
    % check for LINESPEC
    if ~isempty(pvpairs)
        [l,c,m,tmsg]=colstyle(pvpairs{1},'plot');
        if isempty(tmsg)
            pvpairs = pvpairs(2:end);
            if ~isempty(l)
                pvpairs = [{'LineStyle',l},pvpairs];
            end
            if ~isempty(c)
                pvpairs = [{'Color',c},pvpairs];
            end
            if ~isempty(m)
                pvpairs = [{'Marker',m},pvpairs];
            end
        end
    end
    msg = checkpvpairs(pvpairs);
    nargs = length(args);
end

function [xo,yo] = Lstairsv6(cax,varargin)
    args = varargin;
    nargs = length(args);
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 3
        error(message('MATLAB:narginchk:tooManyInputs'));
    end
    
    sym = [];
    
    % Parse the inputs
    if matlab.graphics.internal.isCharOrString(args{nargs})  % stairs(y,'style') or stairs(x,y,'style')
        sym = args{nargs};
        [msg,x,y] = xychk(args{1:nargs-1},'plot');
        if ~isempty(msg), error(msg); end
    else % stairs(y), or stairs(x,y)
        [msg,x,y] = xychk(args{1:nargs},'plot');
        if ~isempty(msg), error(msg); end
    end
    
    if min(size(x))==1, x = x(:); end
    if min(size(y))==1, y = y(:); end
    
    [n,nc] = size(y);
    ndx = [1:n;1:n];
    y2 = y(ndx(1:2*n-1),:);
    if size(x,2)==1
        x2 = x(ndx(2:2*n),ones(1,nc));
    else
        x2 = x(ndx(2:2*n),:);
    end
    
    if (nargout < 2)
        % Create the plot
        cax = newplot(cax);
        if isempty(sym)
            h = plot(x2,y2,'Parent',cax);
        else
            h = plot(x2,y2,sym,'Parent',cax);
        end
        if nargout==1, xo = h; end
    else
        xo = x2;
        yo = y2;
    end
end
