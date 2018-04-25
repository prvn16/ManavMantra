function [tb, edges] = discretize(tx, edges, varargin)
%DISCRETIZE Group tall data into bins or categories.
%   [BINS,EDGES] = discretize(X,EDGES)
%   [BINS,EDGES] = discretize(X,N)
%   [BINS,EDGES] = discretize(X,EDGES,VALUES)
%   [C,EDGES] = discretize(X,EDGES,'categorical')
%   [C,EDGES] = discretize(X,EDGES,'categorical',CATEGORYNAMES)
%   [BINS,EDGES] = discretize(...,'IncludedEdge',SIDE)
%
%   See also DISCRETIZE.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,6);
tall.checkNotTall(upper(mfilename), 1, edges);
tall.checkNotTall(upper(mfilename), 2, varargin{:});
if isscalar(edges) || isdatetimeOption(edges)
    % Need to work out actual edges
    [xmin, xmax] = reducefun(@finiteMinMax, tx, tx);
    tcl = tall.getClass(tx);
    xmin.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(tcl);
    xmax.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(tcl);
    edges = clientfun(@(x,y)dummyDiscretize(x,y,edges,varargin{:}),xmin,xmax);
    edges.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(tcl);
    % Now we can discretize.
    tb = elementfun(@(x,y)discretize(x,y,varargin{:}), tx, matlab.bigdata.internal.broadcast(edges));
else
    if issparse(edges)
        edges = full(edges);
    end
    tb = elementfun(@(x,y)discretize(x,edges,varargin{:}), tx);
end
% Assign appropriate type to output
cmpFunc = @(x)iIsScalarString(x) && strncmpi('categorical', x, max(strlength(x), 1)); 
if any(cellfun(cmpFunc,varargin))
    tbType = 'categorical';
elseif nargin > 2 && ~iIsScalarString(varargin{1})
    % We have a VALUES input
    tbType = class(varargin{1});
else
    tbType = 'double';
end
tb = setKnownType(tb, tbType);
end

function edges = dummyDiscretize(xmin,xmax,edges,varargin)
% Call the correct overloaded DISCRETIZE to get EDGES
[~, edges] = discretize([xmin;xmax], edges, varargin{:});
end

function [xmin, xmax] = finiteMinMax(x, y)
% Find max and min over all finite values of X and Y. Results are scalars.
xfinite = x(isfinite(x));
yfinite = y(isfinite(y));
xmin = min(xfinite(:),[],1);
xmax = max(yfinite(:),[],1);
end

function tf = isdatetimeOption(x)
option = {'second', 'minute', 'hour', 'day', 'week', 'month', 'quarter', ...
    'year', 'decade', 'century'};
a = strncmpi(option, x, max(length(x), 1));
tf = sum(a) == 1; % match only 1
end


function tf = iIsScalarString(arg)
tf = (ischar(arg) && isrow(arg)) || (isstring(arg) && isscalar(arg));
end
