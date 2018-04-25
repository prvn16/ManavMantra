%INT    Smallest built-in integer where fi objects stored integer value fits
%   INT(A) returns integer representation of stored integer of 
%   fi object A in the smallest built-in integer capable of accommodating
%   this value. 
%
%   Fixed-point numbers can be represented as:
%
%      real_world_value = 2^(-fraction_length)*(stored_integer)
%
%   or, equivalently,
%
%      real_world_value = (slope * stored_integer) + (bias)
%   
%   The stored integer is the raw binary number, in which the binary point
%   is assumed to be at the far right of the word.
%   INT(A) returns the stored integer of fi object A in hexadecimal 
%   format as the smallest built-in integer capable of accommodating
%   this value.
%
%   Example:
%     x = fi([0.2 0.3 0.5 0.3 0.2]);
%     in_x = int(x);
%     class(in_x)
%     % returns int16
%     numtp = numerictype('WordLength',17)
%     x_n = fi([0.2 0.3 0.5 0.3 0.2],'numerictype',numtp);
%     % force word-length to 17 bits
%     in_xn = int(x_n);
%     class(in_xn)
%     % returns int32
%
%   Note: When the word length is greater than 52 bits, the return value 
%   can have quantization error. For bit-true integer representation of 
%   very large word lengths, use BIN, OCT, DEC, HEX, or SDEC.
%
%   See also EMBEDDED.FI/storedInteger

%   Copyright 1999-2012 The MathWorks, Inc.
