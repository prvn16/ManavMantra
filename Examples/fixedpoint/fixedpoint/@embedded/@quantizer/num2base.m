%NUM2BASE Convert numeric array to strings
%   S = NUM2BASE(Q,X,C) converts the elements of a numeric array of built-in 
%   doubles X to an array of strings S using quantizer Q. The elements of S 
%   are assumed to be base-C numbers.
%
%   NUM2BASE and BASE2NUM are inverses of one another, differing in that 
%   NUM2BASE returns the strings in a column.
%
%   Examples:
%     q = quantizer([4 3]);
%     x = 0.875;
%     sb = num2base(q,x,2)
%     % returns '0111'
%     % note that this is the same as sb = num2bin(q,x)
%     sh = num2base(q,x,16)
%     % returns '7'
%     % note that this is the same as sh = num2hex(q,x)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/BASE2NUM, 
%            EMBEDDED.QUANTIZER/BIN2NUM, EMBEDDED.QUANTIZER/HEX2NUM,
%            EMBEDDED.QUANTIZER/NUM2BIN, EMBEDDED.QUANTIZER/NUM2HEX

%   Copyright 1999-2007 The MathWorks, Inc.
