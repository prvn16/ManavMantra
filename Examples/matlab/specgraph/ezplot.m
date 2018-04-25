function hh = ezplot(varargin)
    %EZPLOT   (NOT RECOMMENDED) Easy to use function plotter
    %
    % ==========================================================
    % EZPLOT is not recommended. Use FPLOT or FIMPLICIT instead.
    % ==========================================================
    %
    %   EZPLOT(FUN) plots the function FUN(X) over the default domain
    %   -2*PI < X < 2*PI, where FUN(X) is an explicitly defined function of X.
    %
    %   EZPLOT(FUN2) plots the implicitly defined function FUN2(X,Y) = 0 over
    %   the default domain -2*PI < X < 2*PI and -2*PI < Y < 2*PI.
    %
    %   EZPLOT(FUN,[A,B]) plots FUN(X) over A < X < B.
    %   EZPLOT(FUN2,[A,B]) plots FUN2(X,Y) = 0 over A < X < B and A < Y < B.
    %
    %   EZPLOT(FUN2,[XMIN,XMAX,YMIN,YMAX]) plots FUN2(X,Y) = 0 over
    %   XMIN < X < XMAX and YMIN < Y < YMAX.
    %
    %   EZPLOT(FUNX,FUNY) plots the parametrically defined planar curve FUNX(T)
    %   and FUNY(T) over the default domain 0 < T < 2*PI.
    %
    %   EZPLOT(FUNX,FUNY,[TMIN,TMAX]) plots FUNX(T) and FUNY(T) over
    %   TMIN < T < TMAX.
    %
    %   EZPLOT(FUN,[A,B],FIG), EZPLOT(FUN2,[XMIN,XMAX,YMIN,YMAX],FIG), or
    %   EZPLOT(FUNX,FUNY,[TMIN,TMAX],FIG) plots the function over the
    %   specified domain in the figure window FIG.
    %
    %   EZPLOT(AX,...) plots into AX instead of GCA or FIG.
    %
    %   H = EZPLOT(...) returns handles to the plotted objects in H.
    %
    %   Examples:
    %   The easiest way to express a function is via a string:
    %      ezplot('x^2 - 2*x + 1')
    %
    %   One programming technique is to vectorize the string expression using
    %   the array operators .* (TIMES), ./ (RDIVIDE), .\ (LDIVIDE), .^ (POWER).
    %   This makes the algorithm more efficient since it can perform multiple
    %   function evaluations at once.
    %      ezplot('x.*y + x.^2 - y.^2 - 1')
    %
    %   You may also use a function handle to an existing function. Function
    %   handles are more powerful and efficient than string expressions.
    %      ezplot(@humps)
    %      ezplot(@cos,@sin)
    %
    %   EZPLOT plots the variables in string expressions alphabetically.
    %      subplot(1,2,1), ezplot('1./z - log(z) + log(-1+z) + t - 1')
    %   To avoid this ambiguity, specify the order with an anonymous function:
    %      subplot(1,2,2), ezplot(@(z,t)1./z - log(z) + log(-1+z) + t - 1)
    %
    %   If your function has additional parameters, for example k in myfun:
    %      %-----------------------%
    %      function z = myfun(x,y,k)
    %      z = x.^k - y.^k - 1;
    %      %-----------------------%
    %   then you may use an anonymous function to specify that parameter:
    %      ezplot(@(x,y)myfun(x,y,2))
    %
    %   See also EZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT3, EZPOLAR,
    %            EZSURF, EZSURFC, PLOT, VECTORIZE, FUNCTION_HANDLE.
    
    %   Copyright 1984-2017 The MathWorks, Inc.
    
    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    % Parse possible Axes input
    [cax, args, nargs] = axescheck(varargin{:});
    
    if isa(cax,'matlab.ui.control.UIAxes')
        % Error if given uiaxes
        error(message('MATLAB:ui:uiaxes:general'));
    end
    
    f = args{1};
    args = args(2:end);
    
    if ~ischar(f) && ~isa(f, 'inline') && ~isa(f, 'function_handle')
        error(message('MATLAB:ezplot:InvalidExpression'));
    end
    twofuns = 0;
    if (nargs > 1)
        twofuns = (ischar(args{1}) || isa(args{1}, 'inline') ...
            || isa(args{1}, 'function_handle'));
        if (length(args) > 1 && length(args{2}) <= 1)
            twofuns = 0;
        end
    end
    
    % Place f into "function" form (inline).
    if (twofuns)
        [f, fx0, varx] = ezfcnchk(f, 0, 't');
    else
        [f, fx0, varx] = ezfcnchk(f);
    end
    
    vars = varx;
    nvars = length(vars);
    if isa(f, 'function_handle') && nvars == 0
        nvars = nargin(f);  % can determine #args without knowing their names
    end
    labels = {fx0};
    if ~iscell(f)
        f = {f};
    end
    
    if (twofuns)
        % Determine whether the two input functions have the same
        % independent variable.  That is, in the case of ezplot(x,y),
        % check that x = x(t) and y = y(t).  If not (x = x(p) and
        % y = y(q)), reject the plot.
        [fy, fy0, vary] = ezfcnchk(args{1}, 0, 't');
        nvars = max(nvars, length(vary));
        if isa(fy, 'function_handle') && isempty(vary)
            nvars = max(nvars, nargin(fy));
        end
        f{2} = fy;
        labels{2} = fy0;
        
        % This is the case of ezplot('2','f(q)') or ezplot('f(p)','3').
        if isempty(varx) || isempty(vary)
            vars = union(varx, vary);
        end
    end
    
    vars = vars(~cellfun('isempty', vars));
    if isempty(vars)
        if (twofuns)
            vars = {'t'};
        else
            if (nvars == 2)
                vars = {'x' 'y'};
            else
                vars = {'x'};
            end
        end
    end
    nvars = max(nvars, length(vars));
    ninputs = length(args);
    
    if (ninputs == 1 && ~twofuns)
        if length(args{1}) == 4 && nvars == 2
            V = args;
            args{1} = [V{1}(1), V{1}(2)];
            args{2} = [V{1}(3), V{1}(4)];
        end
        % ezplot(f,[xmin,ymin]) covered in the default setting.
    end
    
    if ~twofuns
        switch nvars
            case 1
                % Account for variables of [char] length > 1
                [hp, cax] = ezplot1(cax, f{1}, vars, labels, args{:});
                title(cax, texlabel(labels), 'interpreter', 'tex');
                if ninputs > 0 && isa(args{1}, 'double') && length(args{1}) == 4
                    axis(cax, args{1});
                elseif ninputs > 1 && isa(args{2}, 'double') && ...
                        length(args{2}) == 4
                    axis(cax, args{2});
                end
            case 2
                hp = ezimplicit(cax, f{1}, vars, labels, args{:});
            otherwise
                if ischar(varargin{1}) 
                    fmsg = varargin{1};
                elseif (isa(f, 'function_handle'))
                    fmsg = func2str(f);
                else 
                    fmsg = char(f);                        
                end
                error(message('MATLAB:ezplot:NonXYPlot', fmsg));
        end
    else
        hp = ezparam(cax, f{1}, f{2}, vars, labels, args{2:end});
    end
    
    if nargout > 0
        hh = hp;
    end
end

function [hp, newcax] = ezimplicit(cax, f, vars, labels, varargin)
    % EZIMPLICIT Plot of an implicit function in 2-D.
    %    EZIMPLICIT(cax,f,vars) plots in cax the string expression f
    %    that defines an implicit function f(x,y) = 0 for x0 < x < x1
    %    and y0 < y < y1, whose default values are x0 = -2*pi = y0
    %    and x1 = 2*pi = y1.  The arguments of f are listed in vars and
    %    a non-vector version of the function expression is in labels.
    %
    %   EZIMPLICIT(cax,f,vars,labels,[x0,x1]) plots the implicit function
    %   f(x,y) = 0 for x0 < x < x1, x0 < y < x1.
    %
    %   EZIMPLICIT(cax,f,vars,labels,[x0,x1],[y0,y1]) plots the implicit
    %   function f(x,y) = 0 for x0 < x < x1, y0 < y < y1.
    %   In the case that f is not a function of x and y
    %   (rather, say u and v), then the domain endpoints [u0,u1]
    %   [v0,v1] are given alphabetically.
    %
    %   [HP,NEWCAX] = EZIMPLICIT(...) returns the handles to the plotted
    %   objects in HP, and the axes used to plot the function in NEWCAX.
    
    % If f is created from a string equation f(x,y) = g(x,y), change
    % the equal sign '=' to a minus sign '-'
    eqnHasEqualSign = false;
    if (isa(f, 'inline') && contains(char(f), '='))
        symvars = argnames(f);
        f = char(f);
        f = [strrep(f, '=', '-(') ')'];
        f = inline(f, symvars{:});
        eqnHasEqualSign = true;
    end
    
    % Choose the number of points in the plot
    npts = 251; %odd # gives a chance to have point at origin for default limits
    
    fig = [];
    switch length(vars)
        case 0
            x = 'x';
            y = 'y';
        case 1
            x = vars{1};
            y = 'y';
        case 2
            x = vars{1};
            y = vars{2};
        otherwise
            % If there are more than 2 variables, send an error message
            W = {vars{1}, vars{2}};
            error(message('MATLAB:ezplot:NumericValues', setdiff( vars, W )));
    end
    % Define the computational space
    switch (nargin - 3)
        case 1
            X = linspace(-2*pi, 2*pi, npts);
            Y = X;
        case 2
            if length(varargin{1}) == 1
                fig = varargin{1};
                X = linspace(-2*pi, 2*pi, npts);
                Y = X;
            else
                X = linspace(varargin{1}(1), varargin{1}(2), npts);
                Y = X;
            end
        case 3
            if length(varargin{1}) == 1
                fig = varargin{1};
                X = linspace(varargin{2}(1), varargin{2}(2), npts);
                Y = X;
            elseif length(varargin{2}) == 1 && length(varargin{1}) == 2
                fig = varargin{2};
                X = linspace(varargin{1}(1), varargin{1}(2), npts);
                Y = X;
            elseif length(varargin{2}) == 1 && length(varargin{1}) == 4
                fig = varargin{2};
                X = linspace(varargin{1}(1), varargin{1}(2), npts);
                Y = linspace(varargin{1}(3), varargin{1}(4), npts);
            else
                X = linspace(varargin{1}(1), varargin{1}(2), npts);
                Y = linspace(varargin{2}(1), varargin{2}(2), npts);
            end
    end
    
    [X, Y] = meshgrid(X, Y);
    u = ezplotfeval(f, X, Y);
    
    % Determine u scale so that "most" of the u values
    % are in range, but singularities are off scale.
    
    %remove imaginary parts
    u(imag(u) ~= 0) = NaN;

    uu = sort(u(isfinite(u)));
    N = length(uu);
    if N > 16
        del = uu(fix(15 * N / 16)) - uu(fix(N / 16));
        umin = max(uu(1) - del / 16, uu(fix(N / 16)) - del);
        umax = min(uu(N) + del / 16, uu(fix(15 * N / 16)) + del);
    elseif N > 0
        umin = uu(1);
        umax = uu(N);
    else
        umin = 0;
        umax = 0;
    end
    if umin == umax
        umin = umin - 1;
        umax = umax + 1;
    end
    
    % Eliminate vertical lines at discontinuities.
    
    ud = (0.5) * (umax - umin);
    umean = (umax + umin) / 2;
    [nr, nc] = size(u);
    % First, search along the rows . . .
    for j = 1:nr
        k = 2:nc;
        kc = find(abs(u(j, k) - u(j, k-1)) > ud);
        ki = find(max(abs(u(j, k(kc)) - umean), abs(u(j, k(kc) - 1) - umean)));
        if any(ki)
            u(j, k(kc(ki))) = NaN;
        end
    end
    % . . . then search along the columns.
    for j = 1:nc
        k = 2:nr;
        kr = find(abs(u(k, j) - u(k - 1, j)) > ud );
        kj = find(max(abs(u(k(kr), j) - umean), abs(u(k(kr) - 1, j) - umean)));
        if any(kj)
            u(k(kr(kj)), j) = NaN;
        end
    end
    
    % First check if cax was specified (strongest specification for plot axes)
    if isempty(cax)
        % Now allow the fig input to be honored
        cax = determineAxes(fig);
    end
    

    
    [~, hp] = contour(cax, X(1, :), Y(:, 1), u, [0, 0], '-');
    
    if (isa(x, 'function_handle'))
        xmsg = func2str(x);
    else
        xmsg = char(x);
    end
    if (isa(y, 'function_handle'))
        ymsg = func2str(y);
    else
        ymsg = char(y);
    end
    xlabel(cax, texlabel(xmsg));
    ylabel(cax, texlabel(ymsg));
    if eqnHasEqualSign
        title(cax, texlabel(labels{1}));
    else
        title(cax, texlabel([labels{1}, ' = 0']));
    end
    
    newcax = cax;
end

function [hp, newcax] = ezparam(cax, x, y, vars, labels, varargin)
    % EZPARAM Easy to use 2-d parametric curve plotter.
    %   EZPARAM(cax,x,y,vars,labels) plots the planar curves r(t) = (x(t),y(t))
    %   in cax.  The default domain in t [0,2*pi].  vars contains the common
    %   argument of x and y, and labels contains non-vector versions of the
    %   x and y expressions.
    %
    %   EZPARAM(cax,x,y,vars,labels,[tmin,tmax]) plots r(t) = (x(t),y(t)) for
    %   tmin < t < tmax.
    %
    %   [HP,NEWCAX] = EZPARAM(...) returns the handles to the plotted
    %   objects in HP, and the axes used to plot the function in NEWCAX.
    
    fig = [];
    N = length(vars);
    
    Npts = 300;
    
    % Determine the domains in t:
    switch (nargin - 3)
        case 2
            T = linspace(0, 2*pi, Npts);
        case 3
            if length(varargin{1}) == 1
                fig = varargin{1};
                T = linspace(0, 2 * pi, Npts);
            else
                T = linspace(varargin{1}(1), varargin{1}(2), Npts);
            end
        case 4
            if length(varargin{2}) == 1
                fig = varargin{2};
                T = linspace(varargin{1}(1), varargin{1}(2), Npts);
            elseif length(varargin{1}) == 1
                fig = varargin{1};
                T = linspace(varargin{2}(1), varargin{2}(2), Npts);
            else
                T = linspace(varargin{1}, varargin{2}, Npts);
            end
    end
    
    % First check if cax was specified (strongest specification for plot axes)
    if isempty(cax)
        % Now allow the fig input to be honored
        cax = determineAxes(fig);
    end
    
    % Create plot
    cax = newplot(cax);
    
    switch N
        case 1 % planar curve
            X = ezplotfeval(x, T);
            Y = ezplotfeval(y, T);
            hp = plot(X, Y, 'parent', cax);
            xlabel(cax, 'x');
            ylabel(cax, 'y');
            axis(cax, 'equal');
            title(cax, ['x = ' texlabel(labels{1}), ', y = ' texlabel(labels{2})]);
        otherwise
            error(message('MATLAB:ezplot:ParametrizedSurface'))
    end
    
    newcax = cax;
end

function [hp, newcax] = ezplot1(cax, f, vars, labels, xrange, fig)
    %EZPLOT1 Easy to use function plotter.
    %   EZPLOT1(cax,f,vars,labels) plots a graph of f(x) into cax
    %   where f is a string or a symbolic expression representing a
    %   mathematical expression involving a single symbolic variable,
    %   say 'x'.
    %   vars is the name of the variable and labels is a non-vector
    %   version of the function expression.
    %   The range of the x-axis is approximately  [-2*pi, 2*pi]
    %
    %   EZPLOT1(cax,f,vars,labels,xmin,xmax) or EZPLOT(f,[xmin,xmax])
    %   uses the specified x-range instead of the default [-2*pi, 2*pi].
    %
    %   EZPLOT1(cax,f,vars,labels,[xmin xmax],fig) uses the specified
    %   figure number, fig, instead of cax.
    %
    %   [HP,NEWCAX] = EZPLOT1(...) returns the handles to the plotted
    %   objects in HP, and the axes used to plot the function in NEWCAX.
    
    % Set defaults
    narginchk(4,6);
    if nargin < 5
        xrange = [-2*pi 2*pi];
    end
    if ischar(xrange)
        xrange = eval(xrange);
    end
    if nargin < 6
        fig = ancestor(cax, 'figure');
    end
    if nargin == 6
        if length(xrange) == 1
            xrange = [xrange fig];
        elseif ischar(fig)
            xrange = [xrange eval(fig)];
        elseif ~isempty(cax)
            fig = ancestor(cax, 'figure');
        end
    end
    
    % Check for equations of the form "x=2"
    if (isa(f, 'inline') && contains(char(f), '='))
        error(message('MATLAB:ezplot:NonExplicitFunction'));
    end
    
    % First check if cax was specified (strongest specification for plot axes)
    if isempty(cax)
        % Now allow the fig input to be honored
        cax = determineAxes(fig);
    end
    
    % Create plot
    cax = newplot(cax);
    
    cleaner = doWarnSetup();
    
    % Sample on initial interval.
    fig = ancestor(cax, 'figure');
    pixpos = hgconvertunits(fig, get(cax, 'Position'), get(cax, 'Units'), ...
        'pixels', get(cax, 'Parent'));
    % npts = # of pixels in the axis width.
    npts = pixpos * [0;0;1;0];
    t = (0:npts-1)/(npts-1);
    xmin = min(xrange);
    xmax = max(xrange);
    x = xmin + t * (xmax - xmin);
    
    % Get y values, and possibly also change f to be vectorized
    [y, f, loopflag] = ezplotfeval(f, x);
    
    k = find(abs(imag(y)) > 1.e-6*abs(real(y)));
    if any(k)
        x(k) = [];
        y(k) = [];
    end
    npts = length(y);
    if isempty(y) && npts == 0
        delete(cleaner); %destroy cleaner object to restore warning state
        warning(message('MATLAB:ezplot:NoRealValues', labels{ 1 }));
        return
    elseif loopflag
        % Warnings are off, so turn them on temporarily and issue a warning
        % message similar to what would have come from ezplotfeval.
        delete(cleaner); %destroy cleaner object to restore warning state
        warning(message('MATLAB:ezplot:NotVectorized'));
        doWarnSetup(); %disable warnings again
    end
    % Reduce to an "interesting" x interval.
    
    if (npts > 1) && (nargin < 5)
        dx = x(2) - x(1);
        dy = diff(y) / dx;
        dy(npts) = dy(npts - 1);
        k = find(abs(dy) > .01);
        if isempty(k)
            k = 1:npts;
        end
        xmin = x(min(k));
        xmax = x(max(k));
        if xmin < floor(4 * xmin) / 4 + dx
            xmin = floor(4 * xmin) / 4;
        end
        if xmax > ceil(4 * xmax) / 4 - dx
            xmax = ceil(4 * xmax) / 4;
        end
        x = xmin + t * (xmax - xmin);
        y = ezplotfeval(f, x);
        k = find(abs(imag(y)) > 1.e-6*abs(real(y)));
        if any(k)
            y(k) = NaN;
        end
    end
    
    % Determine y scale so that "most" of the y values
    % are in range, but singularities are off scale.
    
    y = real(y);
    u = sort(y(isfinite(y)));
    npts = length(u);
    if isempty(u)
        u = nan(size(x));
        npts = numel(x);
    end
    ymin = u(1);
    ymax = u(npts);
    if npts > 4
        del = u(fix(7 * npts / 8)) - u(fix(npts / 8));
        ymin = max(u(1) - del / 8, u(fix(npts / 8)) - del);
        ymax = min(u(npts) + del / 8, u(fix(7 * npts / 8)) + del);
    end
    
    % Eliminate vertical lines at discontinuities.
    
    k = 2:length(y);
    k = find(((y(k) > ymax / 2) & (y(k - 1) < ymin / 2)) | ...
        ((y(k) < ymin / 2) & (y(k - 1) > ymax / 2)));
    if any(k)
        y(k) = NaN;
    end
    
    % Plot the function
    
    hp = plot(x, y, 'parent', cax);
    if ymax > ymin
        axis(cax, [xmin xmax ymin ymax]);
    else
        axis(cax, [xmin xmax get(cax, 'ylim')]);
    end
    
    xlabel(cax, texlabel(vars{1}));
    title(cax, texlabel(labels{1}), 'Interpreter', 'none');
    
    newcax = cax;
end

function cax = determineAxes(fig)
    % Helper function that takes the specified figure handle.  If the handle is
    % not empty, find its current axes.  If it is empty, use the current axes.
    if ~isempty(fig)
        % In case a figure handle was specified, but the figure does not exist,
        % create one.
        figure(fig);
        cax = gca(fig);
    else
        % Neither cax nor fig was specified, so use gca
        cax = gca;
    end
end

function cleaner = doWarnSetup
[ state.lastWarnMsg, state.lastWarnId ] = lastwarn;
state.warnStates = warning('off');
cleaner = onCleanup(@()restoreWarningState(state));
end

function restoreWarningState(oldstate)
warning(oldstate.warnStates);
lastwarn(oldstate.lastWarnMsg, oldstate.lastWarnId);
end
