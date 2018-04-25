function q = assignmentquantizer(this)
%ASSIGNMENTQUANTIZER  Assignment quantizer for this fi object.  
%    Q = ASSIGNMENTQUANTIZER(A) returns the quantizer object Q that is
%    used in assignment operations for fi object A.

%   Thomas A. Bryan
%   Copyright 2003-2012 The MathWorks, Inc.

q = quantizer;
setQuantizerFromFi(this,q);
