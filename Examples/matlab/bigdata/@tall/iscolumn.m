function tf = iscolumn(tv)
%ISCOLUMN True if input is a column vector.
%   TF = ISCOLUMN(TV)
%
%   See also: ISCOLUMN.

% Copyright 2016 The MathWorks, Inc.

tf = ismatrix(tv) & (size(tv,2)==1);
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();