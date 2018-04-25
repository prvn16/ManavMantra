%NUM2BASE Convert stored integers to strings
%   This function is for internal use only. A list of supported functions
%   can be found in the "SEE ALSO" section.
%
%   See also FI, EMBEDDED.FI/BIN, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX,
%            EMBEDDED.FI/OCT, EMBEDDED.FI/SDEC, EMBEDDED.FI/storedInteger,
%            EMBEDDED.QUANTIZER/BASE2NUM, EMBEDDED.QUANTIZER/BIN2NUM,
%            EMBEDDED.QUANTIZER/HEX2NUM, EMBEDDED.QUANTIZER/NUM2BIN,
%            EMBEDDED.QUANTIZER/NUM2HEX

%   S = NUM2BASE(A,C) converts the stored integers of an array of fi objects A  
%   to an array of strings S, where the members of S are assumed to be base-C 
%   numbers.
%
%
%   Examples:
%     a = fi(0.875,1,4,3);
%     sb = num2base(a,2)
%     % returns '0111'
%     sh = num2base(a,16)
%     % returns '7'

%   Copyright 1999-2012 The MathWorks, Inc.
