function y = fixed_point_32bit_KeepLSB_plus_example(a,b) %#codegen
%FIXED_POINT_32BIT_KEEPLSB_PLUS_EXAMPLE  Example of 32-bit Keep Least-Significant Bit Plus.
%
%   Y = FIXED_POINT_32BIT_KEEPLSB_PLUS_EXAMPLE(A,B) Performs Y = A + B using
%   a 32-bit accumulator, keeping the least-significant bits, with wrap
%   overflow and floor rounding.
%
%   Use the pattern U=SETFIMATH(U,F) to set FIMATH on function inputs
%   and Y=REMOVEFIMATH(Y) to remove FIMATH from function outputs to
%   insulate variables from FIMATH settings outside the function.
%
%   See also FI, FIMATH, REMOVEFIMATH, SETFIMATH.

%   Copyright 2011-2012 The MathWorks, Inc.
    F = fimath('RoundingMethod','Floor',...
               'OverflowAction','Wrap',...
               'SumMode',       'KeepLSB',...
               'SumWordLength', 32);
    a = setfimath(a,F);
    b = setfimath(b,F);
    y = a + b;
    y = removefimath(y);
end
