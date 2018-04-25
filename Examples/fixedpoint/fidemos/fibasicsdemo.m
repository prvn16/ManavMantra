%% Create Fixed-Point Data
% This example shows the basics of how to use the fixed-point numeric object |fi|.
%
% Copyright 2004-2012 The MathWorks, Inc.

%% Notation
% The fixed-point numeric object is called *|fi|* because J.H. Wilkinson
% used *|fi|* to denote fixed-point computations in his classic texts
% Rounding Errors in Algebraic Processes (1963), and The Algebraic
% Eigenvalue Problem (1965).

%% Setup
% This example may use display settings or preferences that are different from
% what you are currently using. To ensure that your current display
% settings and preferences are not changed by running this example, the example
% automatically saves and restores them. The following code captures the
% current states for any display settings or properties that the example
% changes.
originalFormat = get(0, 'format');
format loose
format long g
% Capture the current state of and reset the fi display and logging
% preferences to the factory settings.
fiprefAtStartOfThisExample = get(fipref);
reset(fipref);


%% Default Fixed-Point Attributes
% To assign a fixed-point data type to a number or variable with the
% default fixed-point parameters, use the |fi| constructor. The resulting
% fixed-point value is called a |fi| object.
%
% For example, the following creates |fi| objects |a| and |b| with
% attributes shown in the display, all of which we can specify when the
% variables are constructed.  Note that when the |FractionLength| property
% is not specified, it is set automatically to "best precision" for the
% given word length, keeping the most-significant bits of the value. When
% the |WordLength| property is not specified it defaults to 16 bits.

a = fi(pi)
%%
b = fi(0.1)

%% Specifying Signed and WordLength Properties
% The second and third numeric arguments specify |Signed| (|true| or 1 =
% |signed|, |false| or 0 = |unsigned|), and |WordLength| in bits,
% respectively.

% Signed 8-bit
a = fi(pi, 1, 8)
%%
% The |sfi| constructor may also be used to construct a signed |fi| object
a1 = sfi(pi,8)
%%

% Unsigned 20-bit
b = fi(exp(1), 0, 20)
%%
% The |ufi| constructor may be used to construct an unsigned |fi| object
b1 = ufi(exp(1), 20)

%% Precision
% The data is stored internally with as much precision as is specified.
% However, it is important to be aware that initializing high precision
% fixed-point variables with double-precision floating-point variables may
% not give you the resolution that you might expect at first glance.  For
% example, let's initialize an unsigned 100-bit fixed-point variable with
% 0.1, and then examine its binary expansion:
a = ufi(0.1, 100);
%%
bin(a)

%%
% Note that the infinite repeating binary expansion of 0.1 gets cut off at
% the 52nd bit (in fact, the 53rd bit is significant and it is rounded up
% into the 52nd bit). This is because double-precision floating-point
% variables (the default MATLAB(R) data type), are stored in 64-bit
% floating-point format, with 1 bit for the sign, 11 bits for the exponent,
% and 52 bits for the mantissa plus one "hidden" bit for an effective 53
% bits of precision.  Even though double-precision floating-point has a
% very large range, its precision is limited to 53 bits.  For more
% information on floating-point arithmetic, refer to Chapter 1 of Cleve
% Moler's book, Numerical Computing with MATLAB.  The pdf version can be
% found here:
% <https://www.mathworks.com/company/aboutus/founders/clevemoler.html>
%
% So, why have more precision than floating-point?  Because most fixed-point
% processors have data stored in a smaller precision, and then compute with
% larger precisions.  For example, let's initialize a 40-bit unsigned |fi|
% and multiply using full-precision for products.
%
% Note that the full-precision product of 40-bit operands is 80 bits, which
% is greater precision than standard double-precision floating-point.
a = fi(0.1, 0, 40);
bin(a)

%%

b = a*a

%%

bin(b)

%% Access to Data
% The data can be accessed in a number of ways which map to built-in data
% types and binary strings.  For example, 
%% DOUBLE(A)
a = fi(pi);
double(a)
%% 
% returns the double-precision floating-point "real-world" value of |a|,
% quantized to the precision of |a|.
%% A.DOUBLE = ...
% We can also set the real-world value in a double.
a.double = exp(1)
%%
% sets the real-world value of |a| to |e|, quantized to |a|'s numeric type.
%% STOREDINTEGER(A)
storedInteger(a)
%%
% returns the "stored integer" in the smallest built-in integer type
% available, up to 64 bits.
% 

%% Relationship Between Stored Integer Value and Real-World Value
% In |BinaryPoint| scaling, the relationship between the stored integer
% value and the real-world value is
%
% $$ \mbox{Real-world value} = (\mbox{Stored integer})\cdot
% 2^{-\mbox{Fraction length}}.$$
%
% There is also |SlopeBias| scaling, which has the relationship
%
% $$ \mbox{Real-world value} = (\mbox{Stored integer})\cdot
% \mbox{Slope}+ \mbox{Bias}$$
%
% where
%
% $$ \mbox{Slope} = (\mbox{Slope adjustment factor})\cdot
% 2^{\mbox{Fixed exponent}}.$$
%
% and
%
% $$\mbox{Fixed exponent} = -\mbox{Fraction length}.$$
%
% The math operators of |fi| work with |BinaryPoint| scaling and real-valued 
% |SlopeBias| scaled |fi| objects.


%% BIN(A), OCT(A), DEC(A), HEX(A)
% return the stored integer in binary, octal, unsigned decimal, and
% hexadecimal strings, respectively.
bin(a)
%%
oct(a)
%%
dec(a)
%%
hex(a)

%% A.BIN = ..., A.OCT = ..., A.DEC = ..., A.HEX = ...
% set the stored integer from  binary, octal, unsigned decimal, and
% hexadecimal strings, respectively.
%
% $$\mbox{\texttt{fi}}(\pi)$$
a.bin = '0110010010001000'
%%
% $$\mbox{\texttt{fi}}(\phi)$$
a.oct = '031707'
%%
% $$\mbox{\texttt{fi}}(e)$$
a.dec = '22268'
%%
% $$\mbox{\texttt{fi}}(0.1)$$
a.hex = '0333'

%% Specifying FractionLength 
% When the |FractionLength| property is not specified, it is computed to be
% the best precision for the magnitude of the value and given word length.
% You may also specify the fraction length directly as the fourth numeric
% argument in the |fi| constructor or the third numeric argument in the |sfi| or |ufi|
% constructor. In the following, compare the fraction length of |a|, which
% was explicitly set to 0, to the fraction length of |b|, which was set to
% best precision for the magnitude of the value.
a = sfi(10,16,0)
%%
b = sfi(10,16)

%%
% Note that the stored integer values of |a| and |b| are different, even
% though their real-world values are the same.  This is because the
% real-world value of |a| is the stored integer scaled by 2^0 = 1, while
% the real-world value of |b| is the stored integer scaled by 2^-11 =
% 0.00048828125.
%%
storedInteger(a)
%%
storedInteger(b)

%% Specifying Properties with Parameter/Value Pairs
% Thus far, we have been specifying the numeric type properties by passing
% numeric arguments to the |fi| constructor.  We can also specify
% properties by giving the name of the property as a string followed by the
% value of the property:
a = fi(pi,'WordLength',20)
%%
% For more information on |fi| properties, type
%
%   help fi
%
% or
%
%   doc fi
%
% at the MATLAB command line.

%% Numeric Type Properties
% All of the numeric type properties of |fi| are encapsulated in an object
% named |numerictype|:
T = numerictype
%%
% The numeric type properties can be modified either when the object is
% created by passing in parameter/value arguments
T = numerictype('WordLength',40,'FractionLength',37)
%%
% or they may be assigned by using the dot notation
T.Signed = false
%%
% All of the numeric type properties of a |fi| may be set at once by
% passing in the |numerictype| object.  This is handy, for example, when
% creating more than one |fi| object that share the same numeric type.
a = fi(pi,'numerictype',T)
%%
b = fi(exp(1),'numerictype',T)
%%
% The |numerictype| object may also be passed directly to the |fi| constructor
a1 = fi(pi,T)
%%
% For more information on |numerictype| properties, type
%
%   help numerictype
%
% or
%
%   doc numerictype
%
% at the MATLAB command line.

%% Display Preferences
% The display preferences for |fi| can be set with the |fipref| object.
% They can be saved between MATLAB sessions with the |savefipref| command.

%% Display of Real-World Values
%
% When displaying real-world values, the closest double-precision
% floating-point value is displayed.  As we have seen, double-precision
% floating-point may not always be able to represent the exact value of
% high-precision fixed-point number.  For example, an 8-bit fractional
% number can be represented exactly in doubles
a = sfi(1,8,7)
%%
bin(a)
%%
% while a 100-bit fractional number cannot (1 is displayed, when
% the exact value is 1 - 2^-99):
b = sfi(1,100,99)
%%
% Note, however, that the full precision is preserved in the internal
% representation of |fi|
bin(b)
%%
% The display of the |fi| object is also affected by MATLAB's |format|
% command.  In particular, when displaying real-world values, it is
% handy to use
%
%   format long g
%
% so that as much precision as is possible will be displayed.

%%
% There are also other display options to make a more shorthand display of
% the numeric type properties, and options to control the display of the
% value (as real-world value, binary, octal, decimal integer, or hex).
%
% For more information on display preferences, type
%
%   help fipref
%   help savefipref
%   help format
%
% or
%
%   doc fipref
%   doc savefipref
%   doc format
%
% at the MATLAB command line.

%% Cleanup
% The following code sets any display settings or preferences that the example
% changed back to their original states.

% Reset the fi display and logging preferences
fipref(fiprefAtStartOfThisExample);
set(0, 'format', originalFormat);
displayEndOfDemoMessage(mfilename)

