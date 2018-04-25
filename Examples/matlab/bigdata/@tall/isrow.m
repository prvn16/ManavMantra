function tf = isrow(tv)
%ISROW True if input is a row vector.
%   TF = ISROW(TV)
%
%   See also: ISROW.

% Copyright 2016 The MathWorks, Inc.

tf = ismatrix(tv) & (size(tv,1)==1);
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();