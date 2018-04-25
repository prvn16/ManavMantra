function Y = psi(varargin)
%PSI  Psi (polygamma) function.
%   Y = psi(X)
%   Y = psi(K,X) K must be a non-tall scalar.
%
%   See also: psi, tall.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);

if nargin>1
    % K should be a scalar, so broadcast it to all workers
    K = varargin{1};
    tall.checkNotTall(upper(mfilename), 0, K);
    X = varargin{2};
    fcn = @(a) psi(K,a);
else
    X = varargin{1};
    fcn = @psi;
end

Y = elementfun(fcn, X);
% Output is always same size and type as second input
Y.Adaptor = X.Adaptor;

end
