%NUM2SDEC Convert stored integers of array of fi objects to signed decimal representation
%   S = NUM2SDEC(A) converts stored integers of array of fi objects in A to
%   strings containing equivalent signed decimal representation returned 
%   in S.
%
%   Examples:
%   a = fi([-1 1],1,8,7);
%   sd = num2sdec(a)
%   % returns '-128' '127'
%
%   See also FI, EMBEDDED.FI/DEC, EMBEDDED.QUANTIZER/BASE2NUM,
%            EMBEDDED.QUANTIZER/BIN2NUM, EMBEDDED.QUANTIZER/HEX2NUM,
%            EMBEDDED.QUANTIZER/NUM2BIN, EMBEDDED.QUANTIZER/NUM2HEX

%   Copyright 1999-2012 The MathWorks, Inc.
