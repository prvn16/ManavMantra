function [cout, hand, cf] = contourf(varargin)
    %CONTOURF Filled contour plot.
    %   CONTOURF(...) is the same as CONTOUR(...) except that CONTOURF
    %   fills the regions between the contour lines with color. 
    %
    %   Each color corresponds to a different contour interval. The
    %   intermediate contour intervals are defined by pairs of adjacent
    %   elements in the strictly increasing vector of contour levels.
    %   There are N-1 intermediate intervals when N contour levels have
    %   been specified. There are also two semi-infinite intervals, above
    %   and below the highest and lowest contour levels, respectively, for
    %   a total of N+1 intervals. The color at each point in the plot
    %   thus indicates which interval the data at that point falls into.
    %
    %   Areas in which the data are undefined, as indicated by NaN-valued
    %   elements in the input matrix Z, are left unfilled.
    %
    %   When you use the CONTOURF(Z,V) syntax to specify a vector of
    %   (strictly increasing) contour levels, regions in which Z is less
    %   than V(1) are treated as a special case and are left unfilled, even
    %   though the data is defined there. In other words, the contour
    %   interval [-Inf V(1)] is treated as exception and is not assigned a
    %   color. You can avoid this behavior by ensuring that V(1) is smaller
    %   than the minimum finite value in Z.
    %
    %   [C,H] = CONTOUR3(...) returns contour matrix C and a handle, H, to
    %   a contour object.
    %
    %   Examples:
    %       z = peaks;
    %       [c,h] = contourf(z);
    %       clabel(c,h)
    %       colorbar
    %
    %       z = peaks;
    %       v = [min(z(:)) -6:8];
    %       contourf(z,v)
    %
    %   See also CONTOUR, CONTOUR3, CLABEL, COLORBAR.
    
    % Copyright 1984-2014 The MathWorks, Inc.
    
    % Determine the number of outputs
    nout = nargout;

    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    if (nout == 3)
        warning(message('MATLAB:contourf:EmptyV6OutputArgument', upper( mfilename )));
    end

    cf = [];

    % Parse possible Axes input
    narginchk(1, Inf);
    [pvpairs, ~, ~, errmsg, warnmsg] = contourobjHelper('parseargs', true, args{:});
    if ~isempty(errmsg)
        error(errmsg);
    end
    if ~isempty(warnmsg)
        warning(warnmsg);
    end
    
    % Prepend pvpairs specific to contour
    pvpairs = [ ...
        {'LineColor_I'}, {[0, 0, 0]}, ...
        {'Fill_I'}, {'on'}, ...
        {'ShowText_I'}, {'off'}, ...
        {'Is3D_I'}, {'off'}, ...
        pvpairs];
    
    % Construct Contour Object before Axes.
    h = matlab.graphics.chart.primitive.Contour(pvpairs{:});
    
    if isempty(cax) || ishghandle(cax, 'axes')
        cax = newplot(cax);
        parax = cax;
        nextPlot = cax.NextPlot;
    else
        parax = cax;
        cax = ancestor(cax, 'axes');
        nextPlot = 'add';
    end
    
    h.Parent = parax;
    
    if ismember(nextPlot, {'replace','replaceall'})
        view(cax, 2);
        cax.Box = 'on';
        cax.BoxStyle = 'full';
        cax.Layer = 'top';
        grid(cax,'off');
    end
    
    set(cax, 'XLimSpec', 'tight');
    set(cax, 'YLimSpec', 'tight');
    set(cax, 'ZLimSpec', 'tight');

    contourobjHelper('addListeners', cax, h);
    
    if nout > 0
        cout = h.ContourMatrix;
    end
    if nout > 1
        hand = h;
    end
end
