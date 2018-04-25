function tf = ismatrix(tv)
%ISMATRIX True if input is a matrix.
%   TF = ISMATRIX(TV)
%
%   See also: ISMATRIX.

% Copyright 2016 The MathWorks, Inc.

tf = (ndims(tv)==2); %#ok<ISMAT>
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();