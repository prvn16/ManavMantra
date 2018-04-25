%% Perform Binary-Point Scaling
% This example shows how to perform binary point scaling in |FI|.
%
% Copyright 1999-2012 The MathWorks, Inc.

%% FI Construction
% |a = fi(v,s,w,f)| returns a |fi| with value |v|, signedness |s|, word length |w|,
% and fraction length |f|.
%
% If |s| is true (signed) the leading or most significant bit (MSB) in the
% resulting fi is always the sign bit.
%
% Fraction length |f| is the scaling |2^(-f)|.
%
% For example, create a signed 8-bit long |fi| with a value of 0.5 and a
% scaling of 2^(-7):
%
a = fi(0.5,true,8,7)

%% Fraction Length and the Position of the Binary Point
% The fraction length or the scaling determines the position of the binary
% point in the |fi| object.

%% The Fraction Length is Positive and Less than the Word Length
% When the fraction length |f| is positive and less than the word length, the
% binary point lies |f| places to the left of the least significant bit (LSB)
% and within the word.
%
% For example, in a signed 3-bit |fi| with fraction length of 1 and value
% -0.5, the binary point lies 1 place to the left of the LSB. In this case
% each bit is set to |1| and the binary equivalent of the |fi| with its binary
% point is |11.1| .
%
% The real world value of -0.5 is obtained by multiplying each bit by its 
% scaling factor, starting with the LSB and working up to the signed MSB.
%
% |(1*2^-1) + (1*2^0) +(-1*2^1) = -0.5|
%
% |storedInteger(a)| returns the stored signed, unscaled integer value |-1|.
%
% |(1*2^0) + (1*2^1) +(-1*2^2) = -1|
%
a = fi(-0.5,true,3,1)
bin(a)
storedInteger(a)

%% The Fraction Length is Positive and Greater than the Word Length
% When the fraction length |f| is positive and greater than the word
% length, the binary point lies |f| places to the left of the LSB and outside
% the word.
%
% For example the binary equivalent of a signed 3-bit word with fraction
% length of 4 and value of -0.0625 is |._111|
% Here |_| in the |._111| denotes an unused bit that is not a part of the
% 3-bit word. The first |1| after the |_| is the MSB or the sign bit.
%
% The real world value of -0.0625 is computed as follows (LSB to MSB).
%
% |(1*2^-4) + (1*2^-3) + (-1*2^-2) = -0.0625|
%
% bin(b) will return |111| at the MATLAB(R) prompt and |storedInteger(b) = -1|

b = fi(-0.0625,true,3,4)
bin(b)
storedInteger(b)

%% The Fraction Length is a Negative Integer and Less than the Word Length
% When the fraction length |f| is negative the binary point lies |f| places to
% the right of LSB and is outside the physical word.
%
% For instance in |c = fi(-4,true,3,-2)| the binary point lies 2 places to
% the right of the LSB |111__.|. Here the two right most spaces are unused bits
% that are not part of the 3-bit word. The right most |1| is the LSB and the 
% leading |1| is the sign bit.
%
% The real world value of -4 is obtained by multiplying each bit by its
% scaling factor |2^(-f)|,  i.e. |2(-(-2)) = 2^(2)| for the LSB, and then
% adding the products together.
%
% |(1*2^2) + (1*2^3) +(-1*2^4) = -4|
%
% |bin(c)| and |storedInteger(c)| will still give |111| and |-1| as in the previous two
% examples.

c = fi(-4,true,3,-2)
bin(c)
storedInteger(c)

%% The Fraction Length is Set Automatically to the Best Precision Possible and is Negative
% In this example we create a signed 3-bit |fi| where the fraction length is set automatically
% depending on the value that the |fi| is supposed to contain. The resulting |fi| has a
% value of 6, with a wordlength of 3 bits and a fraction length of -1.
% Here the binary point is 1 place to the right of the LSB: |011_.|.
% The |_| is again an unused bit and the first |1| before the |_| is the
% LSB. The leading |1| is the sign bit.
%
% The real world value (6) is obtained as follows:
%
% |(1*2^1) + (1*2^2) + (-0*2^3) = 6|
%
% |bin(d)| and |storedInteger(d)| will give |011| and |3| respectively.

d = fi(5,true,3)
bin(d)
storedInteger(d)

%% Interactive FI Binary Point Scaling Example
% This is an interactive example that allows the user to change the fraction
% length of a 3-bit fixed-point number by moving the binary point using a
% slider. The fraction length can be varied from -3 to 5 and the user can 
% change the value of the 3 bits to '0' or '1' for either signed or
% unsigned numbers.
%
% The "Scaling factors" above the 3 bits display the scaling or weight that
% each bit is given for the specified signedness and fraction length.
% The |fi| code, the double precision real-world value and the fixed-point
% attributes are also displayed.
%
% Type fibinscaling at the MATLAB prompt to run this example.


displayEndOfDemoMessage(mfilename)
