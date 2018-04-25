%LOG1P  Compute LOG(1+X) accurately.
%   LOG1P(X) computes LOG(1+X), without computing 1+X for small X.
%   Complex results are produced if X < -1.
%
%   For small real X, LOG1P(X) should be approximately X, whereas the
%   computed value of LOG(1+X) can be zero or have high relative error.
%
%   See also LOG, EXPM1.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.

