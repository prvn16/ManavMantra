function x = denormalmin(q)
%DENORMALMIN Smallest denormalized quantized number
%   X = DENORMALMIN(Q) is the smallest positive denormalized quantized
%   number where Q is a QUANTIZER object.  Anything smaller underflows
%   to zero with respect to the quantizer Q.  Denormalized numbers are
%   only applicable to floating-point.  If Q represents a fixed-point
%   number, then DENORMALMIN(Q) = EPS(Q).
%
%   Example:
%     q = quantizer('float',[6 3]);
%     denormalmin(q)
%   returns 0.0625 = 1/16
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/DENORMALMAX, 
%            EMBEDDED.QUANTIZER/EPS

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

x = q.denormalmin;
