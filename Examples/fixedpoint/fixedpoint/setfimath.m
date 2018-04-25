function y = setfimath(x,F) %#codegen
%SETFIMATH Attach fimath object to output
%
%   Y = SETFIMATH(X,F) returns FI object Y with X's numeric type and value and
%   attached FIMATH object F when X is a FI object or integer data type.  If
%   X is not a FI object or integer data type, then Y = X.
%
%   A common pattern for using this function is X = SETFIMATH(X,F), which gives
%   you more localized control over the FIMATH settings without making a data
%   copy in the generated code.
%
%   Examples:
%
%   %% Example 1
%   a = fi(pi);
%   F = fimath('OverflowAction','Wrap','RoundingMethod','Floor');
%   b = setfimath(a,F)
%   
%   %% Example 2
%   % Use the pattern X=SETFIMATH(X,F) to set FIMATH on function inputs
%   % and Y=REMOVEFIMATH(Y) to remove FIMATH from function outputs to
%   % insulate variables from FIMATH settings outside the function.
%   % This pattern does not create copies of the data in the generated code.
%   %
%   function y = fixed_point_32bit_KeepLSB_plus_example(a,b)
%       F = fimath('OverflowAction','Wrap',...
%                  'RoundingMethod','Floor',...
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
%   See also FI, FIMATH, REMOVEFIMATH.

%   Copyright 2011-2012 The MathWorks, Inc.
    nargoutchk(1,1);
    if isempty(F)
        y = removefimath(x);
    else
        if ~isfimath(F)
            error(message('fixed:fimath:parameterNotFimath'));
        end
        if isinteger(x)
            y = fi(x,F);
        else
            y = x;
        end
    end
end
