%BASE2NUM Convert string to numeric value 
%   This function is for internal use only. A list of supported functions
%   can be found in the "SEE ALSO" section.
%
%   See also FI, EMBEDDED.QUANTIZER/BASE2NUM, EMBEDDED.QUANTIZER/BIN2NUM,
%            EMBEDDED.QUANTIZER/HEX2NUM, EMBEDDED.QUANTIZER/NUM2BIN, 
%            EMBEDDED.QUANTIZER/NUM2HEX       

%   BASE2NUM(A,S,C) initializes the value of fi object A to the numeric value
%   of S, where S is assumed to be a base-C number.
%
%   Examples:
%     a = fi(0,1,4,3);
%     sb = '0111';
%     sh = '6';
%     base2num(a,sb,2);
%     a
%     % value of a is 0.8750
%     base2num(a,sh,16);
%     a
%     % value of a is 0.750

%   Copyright 1999-2012 The MathWorks, Inc.

% LocalWords:  sb
