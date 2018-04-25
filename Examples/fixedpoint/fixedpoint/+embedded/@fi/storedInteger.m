%storedInteger  Smallest built-in integer into which fi objects stored integer value fits
%   storedInteger(A) returns the integer representation of the stored integer
%   of fi object A. The integer representation is the smallest built-in integer that 
%   can hold the FI value and type. 
%
%   Fixed-point numbers can be represented as:
%
%      real_world_value = 2^(-fraction_length)*(stored_integer)
%
%   or, equivalently,
%
%      real_world_value = (slope * stored_integer) + (bias)
%   
%   The stored integer is the raw binary number, where the binary point
%   is assumed to be at the far right of the word.
%
%   Example:
%     x = fi([0.2 0.3 0.5 0.3 0.2]);
%     in_x = storedInteger(x);
%     class(in_x)
%     % returns int16
%     numtp = numerictype('wordlength',17)
%     x_n = fi([0.2 0.3 0.5 0.3 0.2],'numerictype',numtp);
%     % force word-length to 17 bits
%     in_xn = storedInteger(x_n);
%     class(in_xn)
%     % returns int32
%
%   Note: The function errors when the word length is greater than 64 bits, 
%         For bit-true integer representation of very large word lengths,
%         use BIN, OCT, DEC, HEX or SDEC.
%
%   See also EMBEDDED.FI/storedIntegerToDouble

%   Copyright 2011-2012 The MathWorks, Inc.

