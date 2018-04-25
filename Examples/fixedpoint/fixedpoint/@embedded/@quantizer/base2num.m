%BASE2NUM Convert string to numeric value 
%   X = BASE2NUM(Q,S,C) returns the value of string S as a built-in double 
%   using quantizer Q. S is assumed to be a base-C number.
%
%   BASE2NUM and NUM2BASE are inverses of one another, differing in that 
%   NUM2BASE returns the strings in a column.
%
%   Examples:
%     q = quantizer([4 3]);
%     sb = '0111';
%     sh = '7';
%     x1 = base2num(q,sb,2)
%     % returns x1 = 0.8750
%     % note that this is the same as x1 = bin2num(q,sb)
%     x2 = base2num(q,sh,16)
%     % returns x2 = 0.8750
%     % note that this is the same as x2 = hex2num(q,sh)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/BIN2NUM, 
%            EMBEDDED.QUANTIZER/HEX2NUM, EMBEDDED.QUANTIZER/NUM2BASE,
%            EMBEDDED.QUANTIZER/NUM2BIN, EMBEDDED.QUANTIZER/NUM2HEX

%   Copyright 1999-2007 The MathWorks, Inc.
