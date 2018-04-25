function Z = mrdivide(X,Y)
%/   Slash or right matrix divide.
%   Z = X/Y
%
%   Y must be a scalar.
%
%   See also: mldivide, tall.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,2);
[X, Y] = tall.validateType(X, Y, mfilename, ...
    {'numeric', 'logical', 'duration', 'char'}, 1:2);
% Denominator must be 2D. Numerator can be >2D if scalar denominator.
Y = tall.validateMatrix(Y,'MATLAB:mrdivide:inputsMustBe2D');

adapY = matlab.bigdata.internal.adaptors.getAdaptor(Y);

if adapY.isKnownScalar()
    % Denominator is known to be scalar so use element-wise divide
    Z = iScalarDivide(X, Y);
    
elseif adapY.isKnownNotScalar()
    error(message('MATLAB:bigdata:array:MrdivideYNotScalar'));
    
else
    % Unknown denominator size. We need to lazily check for scalar
    % denominator and error if not.
    isYscalar = clientfun(@(x) isequal([1 1], x), size(Y));
    
    % Force a single row so that the subsequent elementfun doesn't throw an
    % incompatible dimensions error. This will usually be fused with the
    % reduction used to calculate the size.
    Y = head(Y,1);
    
    % Insert the error condition into the op-tree
    Y = elementfun(@(tf,x) iErrorIfNotScalar(tf,x), isYscalar, Y);
    
    % Perform the rdivide
    Z = iScalarDivide(X, Y);
    
end

end


function Z = iScalarDivide(X, Y)
% Call the element-wise divide function
Z = rdivide(X, Y);
% We know the output size is the same as the numerator (no dimension
% expansion) because we divided by a scalar.
adapX = matlab.bigdata.internal.adaptors.getAdaptor(X);
Z.Adaptor = copySizeInformation(Z.Adaptor, adapX);
end


function X = iErrorIfNotScalar(isscalar,X)
% Helper to error if the divisor is not scalar. Other arguments just
% pass-through.
if ~isscalar
    error(message('MATLAB:bigdata:array:MrdivideYNotScalar'));
end
end
