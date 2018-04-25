function tf = isvector(tv)
%ISVECTOR True if input is a vector.
%   TF = ISVECTOR(TV)
%
%   See also: ISVECTOR.

% Copyright 2016 The MathWorks, Inc.

tf = isrow(tv) | iscolumn(tv);
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();