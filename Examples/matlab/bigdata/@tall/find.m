function varargout = find(tX, varargin)
%FIND Find indices of nonzero elements.
%   I = find(X)
%   I = find(X,K)
%   I = find(X,K,'first')
%   I = find(X,K,'last')
%   [I,J] = find(X,...)
%   [I,J,V] = find(X,...)
%
%   Limitations:
%   X must be a tall column vector.
%
%   See also FIND

%   Copyright 2017 The MathWorks, Inc.

nargoutchk(0, 3);
narginchk(1, 3);

nOut = max(nargout, 1);
varargout = cell(1, nOut);

% Check data is tall but non-data is not
tall.checkNotTall(upper(mfilename), 1, varargin{:});
tall.checkIsTall(upper(mfilename), 1, tX);

% Data needs to be numeric, logical, or char
tX = tall.validateType(tX, mfilename, {'numeric', 'logical', 'char'}, 1);

% Data needs to be a column vector.
tX = tall.validateColumn(tX, 'MATLAB:bigdata:array:FindFirstArgNotColumnVector');

% Check syntax of additional inputs
tall.validateSyntax(@find, [{tX}, varargin], 'DefaultType', 'double')

% Extract information from additional inputs
useLastK = nargin==3 && strcmpi(varargin{2}, 'last');
useFirstK = nargin>1 && ~useLastK;
if useLastK || useFirstK
    K = varargin{1};
    % If K is Inf, we ignore K and find everything
    if K==Inf
        useFirstK = false;
        useLastK = false;
    end
end

tAbsoluteIndices = getAbsoluteSliceIndices(tX);

% This is used over direct conversion to logical as this supports both
% NaN values and complex values in the way that find requires.
tLX = (tX ~= false);

% We use filterslice to create all requested outputs
varargout{1} = filterslices(tLX, tAbsoluteIndices);

% Second output if requested, will be all ones because we only accept
% column vectors
if nOut>1
    varargout{2} = filterslices(tLX, double(tLX));
end

% Get actual values if third output is requested
if nOut==3
    varargout{3} = filterslices(tLX, tX);
end

% If the input might be scalar we have to guard against [], otherwise we
% know the size
if ~tX.Adaptor.isKnownNotScalar()
    % In case of a zero scalar, we need to modify the result lazily in
    % order to be consistent with core MATLAB
    h = head(tLX, 2);
    isScalarFalseEdgeCase = clientfun(@(x)(isscalar(x) && ~x), h);
    
    % Handle scalar false edge case
    [varargout{:}] = chunkfun(@iHandleScalarFalseEdgecase, isScalarFalseEdgeCase, varargout{:});
    
    % Might be a scalar input which returns [], so set output size unknown
    adOutputs = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
    for i=1:nOut
        varargout{i}.Adaptor = adOutputs;
    end
    
    % Third output if requested is of same class as input
    if nOut==3
        varargout{3} = setKnownType(varargout{3}, tX.Adaptor.Class);
    end
end

% Truncate result if K is specified
if useFirstK
    truncateFcn = @(x)head(x, K);
elseif useLastK
    truncateFcn = @(x)tail(x, K);
else
    return;
end
varargout = cellfun(truncateFcn, varargout, 'UniformOutput', false);
end

function varargout = iHandleScalarFalseEdgecase(scalarEdgeCase, varargin)
% Helper that creates [] for scalar false edge case and does nothing
% otherwise

if scalarEdgeCase
    varargout = cellfun(@(x)(zeros(0,0)), varargin, 'UniformOutput', false);
else
    varargout = varargin;
end
end
