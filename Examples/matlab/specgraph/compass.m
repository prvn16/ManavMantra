function hc = compass(varargin)
%COMPASS Compass plot.
%   COMPASS(U,V) draws a graph that displays the vectors with
%   components (U,V) as arrows emanating from the origin.
%
%   COMPASS(Z) is equivalent to COMPASS(REAL(Z),IMAG(Z)). 
%
%   COMPASS(U,V,LINESPEC) and COMPASS(Z,LINESPEC) uses the line
%   specification LINESPEC (see PLOT for possibilities).
%
%   COMPASS(AX,...) plots into AX instead of GCA.
%
%   H = COMPASS(...) returns handles to line objects in H.
%
%   Example:
%      Z = eig(randn(20,20));
%      compass(Z)
%
%   See also ROSE, FEATHER, QUIVER.

%   Charles R. Denham, MathWorks 3-20-89
%   Modified, 1-2-92, LS.
%   Modified, 12-12-94, cmt.
%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
narginchk(1,4);
[cax,args,nargs] = axescheck(varargin{:});

xx = [0 1 .8 1 .8].';
yy = [0 0 .08 0 -.08].';
arrow = xx + yy.*sqrt(-1);

if nargs == 2
    x = args{1};
    y = args{2};
    if ischar(y)
        s = y;
        x = datachk(x);
        y = imag(x); x = real(x);
    else
        s = [];
    end
elseif nargs == 1
    x = args{1}; 
    s = [];
    x = datachk(x);
    y = imag(x); x = real(x);
else % nargs == 3
    [x,y,s] = deal(args{1:3});
end

x = x(:);
y = y(:);
if length(x) ~= length(y)
    error(message('MATLAB:compass:LengthMismatch'));
end
x = datachk(x);
y = datachk(y);

z = (x + y.*sqrt(-1)).';
a = arrow * z;

% Create plot
cax = newplot(cax);

next = lower(get(cax,'NextPlot'));
isholdon = ishold(cax);
[th,r] = cart2pol(real(a),imag(a));

if isempty(s)
    h = polar(cax,th,r);
    co = get(cax,'colororder');
    set(h,'color',co(1,:))
else
    h = polar(cax,th,r,s);
end
if ~isholdon, set(cax,'NextPlot',next); end

if nargout == 1
    hc = h;
end

% Register handles with MATLAB code generator
if ~isempty(h)
    if ~isdeployed
        makemcode('RegisterHandle',h,'IgnoreHandle',h(1),'FunctionName','compass');
    end
end

