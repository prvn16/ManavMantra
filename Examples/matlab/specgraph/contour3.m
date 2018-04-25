function [cout, h, msg] = contour3(varargin)
    %CONTOUR3 3-D contour plot.
    %   CONTOUR3(...) is the same as CONTOUR(...) except the contour lines
    %   are drawn in multiple planes. Each line is drawn in a horizontal
    %   plane at a height equal to the corresponding contour level.
    %
    %   [C,H] = CONTOUR3(...) returns contour matrix C and a handle, H, to
    %   a contour object.
    %
    %   Example:
    %      contour3(peaks)
    %
    %   See also CONTOUR, CONTOURF, CLABEL.
    
    %   Additional details:
    %
    %   Unless a linestyle is specified, CONTOUR3 will draw PATCH objects
    %   with edge color taken from the current colormap.  When a linestyle
    %   is specified, LINE objects are drawn.  To produce the same results
    %   as v4, use CONTOUR3(..., '-').
    %
    %   The order of the handles h relative to the values in cout is used
    %   in CLABEL to create rotated inline labels.  If you change this
    %   order, you may have to change CLABEL also.
    
    %   Clay M. Thompson 3-20-91, 8-18-95
    %   Modified 1-17-92, LS
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    % Determine the number of outputs
    nout = nargout;
    
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    if (nout == 3)
        warning(message('MATLAB:contour3:EmptyErrorOutputArgument', upper( mfilename )));
    end

    msg = [];
    
    % Parse possible Axes input
    narginchk(1, Inf);
    [pvpairs, ~, ~, errmsg, warnmsg] = contourobjHelper('parseargs', false, args{:});
    if ~isempty(errmsg)
        error(errmsg);
    end
    if ~isempty(warnmsg)
        warning(warnmsg);
    end
    
    % Prepend pvpairs specific to contour
    pvpairs = [ ...
        {'LineColor_I'}, {'flat'}, ...
        {'Fill_I'}, {'off'}, ...
        {'ShowText_I'}, {'off'}, ...
        {'Is3D_I'}, {'on'}, ...
        pvpairs];
    
    % Construct Contour Object before Axes.
    hand = matlab.graphics.chart.primitive.Contour(pvpairs{:});
    
    if isempty(cax) || ishghandle(cax, 'axes')
        cax = newplot(cax);
        parax = cax;
        nextPlot = cax.NextPlot;
    else
        parax = cax;
        cax = ancestor(cax, 'axes');
        nextPlot = 'add';
    end
    
    hand.Parent = parax;
    
    switch nextPlot
        case {'replaceall','replace'}
            cax.Box = 'on';
            cax.BoxStyle = 'back';
            cax.Layer = 'top';
            view(cax,3);
            grid(cax,'on');
        case {'replacechildren'}
            view(cax,3);
    end

    set(cax, 'XLimSpec', 'tight');
    set(cax, 'YLimSpec', 'tight');
    set(cax, 'ZLimSpec', 'tight');

    contourobjHelper('addListeners', cax, hand);
    
    if nout > 0
        cout = hand.ContourMatrix;
    end
    if nout > 1
        h = hand;
    end
end
