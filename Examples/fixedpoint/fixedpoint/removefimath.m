function y = removefimath(x)
%REMOVEFIMATH Remove FIMATH object from output
%
%   Y = REMOVEFIMATH(X) returns FI object Y with X's numeric type and value and
%   with no attached FIMATH object when X is a FI object.  If X is not a FI
%   object, then Y = X.
%
%   A common pattern for using this function is Y = REMOVEFIMATH(Y), which gives
%   you more localized control over the FIMATH settings without making a data
%   copy in the generated code.
%
%   Examples:
%
%   %% Example 1
%   a = fi(pi);
%   F = fimath('RoundingMethod','Floor','OverflowAction','Wrap');
%   a = setfimath(a,F)
%   b = removefimath(a)
%   
%   %% Example 2
%   % Use the pattern X=SETFIMATH(X,F) to set FIMATH on function inputs
%   % and Y=REMOVEFIMATH(Y) to remove FIMATH from function outputs to
%   % insulate variables from FIMATH settings outside the function.
%   % This pattern does not create copies of the data in the generated code.
%   %
%   function y = fixed_point_32bit_KeepLSB_plus_example(a,b)
%       F = fimath('RoundingMethod','Floor',...
%                  'OverflowAction','Wrap',...
%                  'SumMode','KeepLSB',...
%                  'SumWordLength',32);
%       a = setfimath(a,F);
%       b = setfimath(b,F);
%       y = a + b;
%       y = removefimath(y);
%   end
%
%   %% You can generate C code from this example if you have MATLAB Coder. 
%   a = fi(0,1,16,15);
%   b = fi(0,1,16,15);
%   codegen fixed_point_32bit_KeepLSB_plus_example -args {a,b} -launchreport
%
%   %% Which generates this C code on a computer with 32-bit native integer type.
%   int32_T fixed_point_32bit_KeepLSB_plus_example(int16_T a, int16_T b)
%   {
%       return a + b;
%   }
%
%   See also FI, FIMATH, SETFIMATH.

%   Copyright 2011-2012 The MathWorks, Inc.
    nargoutchk(1,1);
    y = x;
end
