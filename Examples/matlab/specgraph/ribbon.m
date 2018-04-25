function hh = ribbon(varargin)
%RIBBON Draw 2-D lines as ribbons in 3-D.
%   RIBBON(X,Y) is the same as PLOT(X,Y) except that the columns of
%   Y are plotted as separated ribbons in 3-D.  RIBBON(Y) uses the
%   default value of X=1:SIZE(Y,1).
%
%   RIBBON(X,Y,WIDTH) specifies the width of the ribbons to be
%   WIDTH.  The default value is WIDTH = 0.75;  
%
%   RIBBON(AX,...) plots into AX instead of GCA.
%
%   H = RIBBON(...) returns a vector of handles to surface objects.
%
%   See also PLOT.

%   Clay M. Thompson 2-8-94
%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,inf);
[cax,args,nargs] = axescheck(varargin{:});

% Parse input arguments.
if nargs<3 
  width = .75;
  [msg,x,y] = xychk(args{1:nargs},'plot');
else
  width = args{3};
  [msg,x,y] = xychk(args{1:2},'plot');
end

if ~isempty(msg)
    error(msg);
end
if isscalar(x) || isscalar(y)
  error(message('MATLAB:ribbon:ScalarInputs'));
end

cax = newplot(cax);
nextPlot = cax.NextPlot;

m = size(y,1);
zz = [-ones(m,1) ones(m,1)]/2;
cc = ones(size(y,1),2);

n = size(y,2);
h = gobjects(n,1);
for n=1:size(y,2)
  h(n) = surface(zz*width+n,[x(:,n) x(:,n)],[y(:,n) y(:,n)],n*cc,'parent',cax);
end

switch nextPlot
    case {'replaceall','replace'}
        view(cax,3);
        grid(cax,'on');
    case {'replacechildren'}
        view(cax,3);
end

if nargout>0, hh = h; end

