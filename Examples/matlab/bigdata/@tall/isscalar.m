function tf = isscalar(tv)
%ISSCALAR True if input is a scalar.
%   TF = ISSCALAR(TV)
%
%   See also: ISSCALAR.

% Copyright 2016 The MathWorks, Inc.

tf = ismatrix(tv) & (numel(tv)==1);
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();