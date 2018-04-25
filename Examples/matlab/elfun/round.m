%ROUND  rounds towards nearest decimal or integer
%
%   ROUND(X) rounds each element of X to the nearest integer.
%   
%   ROUND(X, N), for positive integers N, rounds to N digits to the right
%   of the decimal point. If N is zero, X is rounded to the nearest integer.
%   If N is less than zero, X is rounded to the left of the decimal point.
%   N must be a scalar integer.
%
%   ROUND(X, N, 'significant') rounds each element to its N most significant
%   digits, counting from the most-significant or left side of the number. 
%   N must be a positive integer scalar.
%
%   ROUND(X, N, 'decimals') is equivalent to ROUND(X, N).
%
%   For complex X, the imaginary and real parts are rounded independently.
%
%   Examples
%   --------
%   % Round pi to the nearest hundredth
%   >> round(pi, 2)
%        3.14
%
%   % Round the equatorial radius of the Earth, 6378137 meters,
%   % to the nearest kilometer.
%   round(6378137, -3)
%        6378000
%
%   % Round to 3 significant digits
%   format shortg;
%   round([pi, 6378137], 3, 'significant')
%        3.14     6.38e+06
%
%   If you only need to display a rounded version of X,
%   consider using fprintf or num2str:
%
%   fprintf('%.3f\n', 12.3456)
%        12.346 
%   fprintf('%.3e\n', 12.3456)
%        1.235e+01
%
%  See also FLOOR, CEIL, FPRINTF.

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.

