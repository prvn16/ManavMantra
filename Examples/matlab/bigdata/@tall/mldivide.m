function Z = mldivide(X,Y)
%\   Backslash or left matrix divide.
%   Z = X\Y
%
%   X must be a scalar or a tall matrix with the same number of rows as Y.
%
%   See also: mldivide, tall.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,2);
[X, Y] = tall.validateType(X, Y, mfilename, ...
    {'numeric', 'logical', 'duration', 'char'}, 1:2);
% Denominator must be 2D. Numerator can be >2D if scalar denominator.
X = tall.validateMatrix(X,'MATLAB:mldivide:inputsMustBe2D');

adapX = matlab.bigdata.internal.adaptors.getAdaptor(X);

if adapX.isKnownScalar()
    % Denominator is known to be scalar so use element-wise divide
    Z = ldivide(X, Y);
    % We know the output size is the same as the numerator (no dimension
    % expansion) because we divided by a scalar.
    adapY = matlab.bigdata.internal.adaptors.getAdaptor(Y);
    Z.Adaptor = copySizeInformation(Z.Adaptor, adapY);
    
else
    % Not scalar or unknown. Use the QR solver.
    [~,Z] = qrLeftSolve(X,Y);
    % TODO: maybe check conditioning?
    
end