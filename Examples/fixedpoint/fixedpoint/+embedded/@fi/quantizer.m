function q = quantizer(this)
%QUANTIZER Assignment quantizer for this fi object  
%   Q = QUANTIZER(A) returns the quantizer object Q that is
%   used in assignment operations for fi object A.
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 2003-2012 The MathWorks, Inc.

q = assignmentquantizer(this);
