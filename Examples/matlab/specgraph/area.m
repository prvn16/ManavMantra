function hh = area(varargin)
    %AREA  Filled area 2-D plot.
    %   AREA(Y) plots the vector Y or plots each column in matrix Y as a
    %   separate curve and stacks the curves. The x-axis automatically
    %   scales to 1:size(Y,1). The values in Y can be numeric or duration
    %   values.
    %
    %   AREA(X,Y) plots Y versus X and fills the area between 0 and Y. The
    %   values in X can be numeric, datetime, duration or categorical
    %   values.
    %
    %       If Y is a vector, then specify X as a vector of increasing
    %       values with length equal to Y. If the values in X are not
    %       increasing, then AREA sorts the values before plotting.
    %
    %       If Y is a matrix, then specify X as a vector of increasing
    %       values with length equal to the number of rows in Y. AREA plots
    %       the columns of Y as filled areas. For each X, the net result is
    %       the sum of corresponding values from the rows of Y. You also
    %       can specify X as a matrix with size equal to Y. To avoid
    %       unexpected output when X is a matrix, specify X so that the
    %       columns repeat.
    %
    %   AREA( ___ ,BASEVALUE) specifies the base value for the area fill.
    %   The default BASEVALUE is 0. Specify the base value as a numeric
    %   value.
    %
    %   AREA( ___ ,Name,Value) modifies the appearance of the area chart
    %   using one or more name-value pair arguments.
    %
    %   AREA(AX, ___ ) plots into the axes specified by AX instead of the
    %   current axes.
    %
    %   H = AREA( ___ ) returns one or more Area objects. AREA creates one
    %   object for vector input arguments and one object per column for
    %   matrix input arguments.
    %
    %   See also PLOT, BAR.
    
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    
    [args,pvpairs,msg] = parseargs(args);
    if ~isempty(msg), error(msg); end
    nargs = length(args);
    
    allowNonNumeric = true;
    args = getRealData(args,allowNonNumeric); % get the real component if data is complex

    [msg,x,y] = xychk(args{1:nargs},'plot');
    if ~isempty(msg), error(msg); end
    hasXData = nargs ~= 1;
    if min(size(x))==1, x = x(:); end
    if min(size(y))==1, y = y(:); end
    n = size(y,2);
    if isa(y,'datetime') || isa(y,'categorical')
        error(message('MATLAB:specgraph:private:specgraph:DatetimeDependent'));
    end

    % handle vectorized data sources and display names
    extrapairs = cell(n,0);
    if ~isempty(pvpairs) && (n > 1)
        [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
            {'XDataSource','YDataSource','DisplayName'});
    end
    
    % Create plot
    if isempty(cax) || ishghandle(cax,'axes')
        cax = newplot(cax);
        parax = cax;
    else
        parax = cax;
        cax = ancestor(cax,'axes');
    end

    matlab.graphics.internal.configureAxes(cax,x,y);
    [x,y] = matlab.graphics.internal.makeNumeric(cax,x,y);
    
    h = gobjects(1,n);  % preallocate area array
    xData = {};
    
    autoColor = ~any(strcmpi('FaceColor',pvpairs(1:2:end)));
    if autoColor
        colorProp = 'FaceColor_I';
    else
        colorProp = 'FaceColor';
    end

    for k=1:n
        % extract data from vectorizing over columns
        if hasXData
            xData = {'XData', datachk(x(:,k))};
        end
        [~,c] = nextstyle(cax,autoColor,false);
        h(k) = matlab.graphics.chart.primitive.Area('Parent', parax, ...
            'YData', datachk(y(:,k)), xData{:}, 'CData_I', k, colorProp, c,...
            pvpairs{:}, extrapairs{k,:});
    end
    
    matlab.graphics.chart.primitive.Area.groupAreas(h);
    
    switch cax.NextPlot
        case {'replaceall','replace'}
            cax.Box = 'on';
            matlab.graphics.internal.setRulerLayerTop(cax);
        case 'replacechildren'
            matlab.graphics.internal.setRulerLayerTop(cax);
    end
    
    if nargout>0, hh = h; end
end

function [args,pvpairs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
    % check for base value
    if length(args) > 1 && length(args{end}) == 1 && ...
            ~((length(args) == 2) && (length(args{1}) == 1) && (length(args{2}) == 1))
        lvl = args{end};
        if (~isscalar(lvl) || ~isfinite(lvl)) 
            error(message('MATLAB:area:InvalidLevel'));
        end
        pvpairs = [{'BaseValue',lvl},pvpairs];
        args(end) = [];
    end
    if isempty(args)
        msg.message = getString(message('MATLAB:area:NoDataInputs'));
        msg.identifier = 'MATLAB:area:NoDataInputs';
    else
        msg = checkpvpairs(pvpairs,false);
    end
end
