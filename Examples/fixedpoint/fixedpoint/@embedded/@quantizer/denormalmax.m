function x = denormalmax(q)
%DENORMALMAX Largest denormalized quantized number
%   X = DENORMALMAX(Q) is the largest positive denormalized
%   quantized number where Q is a QUANTIZER object.  Anything
%   larger is a normalized number.  Denormalized numbers are only
%   applicable to floating-point.  If Q represents a fixed-point
%   number, then DENORMALMAX(Q) = EPS(Q).
%
%   Example:
%     q = quantizer('float',[6 3]);
%     denormalmax(q)
%   returns 0.1875 = 3/16
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/DENORMALMIN, 
%            EMBEDDED.QUANTIZER/EPS

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

x = q.denormalmax;
