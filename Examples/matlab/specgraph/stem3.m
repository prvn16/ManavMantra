function hh = stem3(varargin)
    %STEM3  3-D stem plot.
    %   STEM3(Z) plots the discrete surface Z as stems from the xy-plane
    %   terminated with circles for the data value.
    %
    %   STEM3(X,Y,Z) plots the surface Z at the values specified
    %   in X and Y.
    %
    %   STEM3(...,'filled') produces a stem plot with filled markers.
    %
    %   STEM3(...,LINESPEC) uses the linetype specified for the stems and
    %   markers.  See PLOT for possibilities.
    %
    %   STEM3(AX,...) plots into AX instead of GCA.
    %
    %   H = STEM3(...) returns a stem object.
    %
    %   See also STEM, QUIVER3.
    
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    narginchk(1, inf);
    [pvpairs,args,nargs,msg] = parseargs(args);
    if ~isempty(msg), error(msg); end
    assert(nargs == 1 || nargs == 3, message('MATLAB:stem3:InvalidDataInputs'))
    
    args = getRealData(args);  % get the real component if data is complex
    
    % create xdata,ydata if necessary
    [msg,x,y,z] = xyzchk(args{1:nargs});
    if ~isempty(msg), error(msg); end
    
    % Create plot
    if isempty(cax) || ishghandle(cax,'axes')
        cax = newplot(cax);
        parax = cax;
        nextPlot = cax.NextPlot;
    else
        parax = cax;
        cax = ancestor(cax,'Axes');
        nextPlot = 'add';
    end
    
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
    
    % Reshape to vectors
    x = reshape(x,[1,numel(x)]);
    y = reshape(y,[1,numel(y)]);
    z = reshape(z,[1,numel(z)]);
    datapairs = {'XData',datachk(x),'YData',datachk(y),'ZData',datachk(z)};
    
    [l,c,m] = nextstyle(cax,autoColor,autoStyle);
    if ~isempty(m) && ~strcmpi(m,'none')
        pvpairs =  [{'Marker_I',m},pvpairs];
    end
    h = matlab.graphics.chart.primitive.Stem('Parent',parax,...
         datapairs{:},...
         colorProp,c,styleProp,l,...
         pvpairs{:});
    
    % 3-D view
    switch nextPlot
        case {'replaceall','replace'}
            view(cax,3);
            grid(cax,'on');
        case {'replacechildren'}
            view(cax,3);
    end
    
    if nargout>0, hh = h; end
end

function [pvpairs,args,nargs,msg] = parseargs(args)
    % separate pv-pairs from opening arguments
    [args,pvpairs] = parseparams(args);
    pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
    n = 1;
    extrapv = {};
    
    % Loop through args, check for 'filled' or LINESPEC
    while length(pvpairs) >= 1 && n < 4 && matlab.graphics.internal.isCharOrString(pvpairs{1})
        arg = lower(pvpairs{1});
        argn = length(arg);
        if strncmp(arg, 'filled', argn)
            pvpairs(1) = [];
            extrapv = [{'MarkerFaceColor','auto'},extrapv];
            
            % LINESPEC (i.e. 'r*')
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
