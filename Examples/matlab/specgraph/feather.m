function hh = feather(varargin)
    %FEATHER Feather plot.
    %   FEATHER(U,V) plots the velocity vectors with components U and V as
    %   arrows emanating from equally spaced points along a horizontal axis.
    %   FEATHER is useful for displaying direction and magnitude data that
    %   is collected along a path.
    %
    %   FEATHER(Z) for complex Z is the same as FEATHER(REAL(Z),IMAG(Z)).
    %   FEATHER(...,'LineSpec') uses the color and linestyle specification
    %   from 'LineSpec' (see PLOT for possibilities).
    %
    %   FEATHER(AX,...) plots into AX instead of GCA.
    %
    %   H = FEATHER(...) returns a vector of line handles.
    %
    %   Example:
    %      theta = (-90:10:90)*pi/180; r = 2*ones(size(theta));
    %      [u,v] = pol2cart(theta,r);
    %      feather(u,v), axis equal
    %
    %   See also COMPASS, ROSE, QUIVER.
    
    %   Charles R. Denham, MathWorks 3-20-89
    %   Copyright 1984-2017 MathWorks, Inc.
    
    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    % Parse possible Axes input
    [cax, args, nargs] = axescheck(varargin{:});
    if nargs < 1
        error(message('MATLAB:narginchk:notEnoughInputs'));
    elseif nargs > 3
        error(message('MATLAB:narginchk:tooManyInputs'));
    end
    
    if nargs > 0
        x = args{1};
    end
    if nargs > 1
        y = args{2};
    end
    if nargs > 2
        s = args{3};
    end
    
    if ischar(x)
        error(message('MATLAB:feather:FirstNumericInput'));
    end
    xx = [0 1 NaN .8 1 .8]';
    yy = [0 0 NaN .08 0 -.08].';
    arrow = xx + yy .* sqrt(-1);
    
    if nargs == 2
        if ischar(y)
            s = y;
            x = datachk(x);
            y = imag(x);
            x = real(x);
        else
            s = '-';
        end
    elseif nargs == 1
        s = '-';
        x = datachk(x);
        y = imag(x);
        x = real(x);
    end
    if ischar(x) || ischar(y)
        error(message('MATLAB:feather:LeadingNumericInputs'))
    end
    x = datachk(x);
    y = datachk(y);
    [st, co, mark, msg] = colstyle(s);
    error(msg);
    
    x = x(:);
    y = y(:);
    if length(x) ~= length(y)
        error(message('MATLAB:feather:LengthMismatch'));
    end
    m = size(x, 1);
    
    z = (x + y .* sqrt(-1)).';
    a = arrow * z + ones(6, 1) * (1:m);
    
    % Create plot
    if isempty(cax) || ishghandle(cax, 'axes')
        cax = newplot(cax);
        parax = cax;
    else
        parax = cax;
        cax = ancestor(cax, 'axes');
    end
    
    h = plot(real(a), imag(a), [st co mark], [1 m], [0 0], [st co mark], ...
        'parent', parax);
    
    if isempty(co)
        co = get(cax, 'colororder');
        set(h, 'color', co(1,:))
    end
    
    if nargout > 0
        hh = h; 
    end
end
