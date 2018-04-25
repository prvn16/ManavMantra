%SQRT   Square root of fi object, computed using a bisection algorithm
%   C = SQRT(A) returns the square root of fi object A. Intermediate
%   quantities are calculated using the fimath associated with A.
%   The numerictype object of C is determined automatically for you using
%   an internal rule (see below).
%
%   C = SQRT(A,T) returns the square root of fi object A with numerictype 
%   object T. Intermediate quantities are calculated using the fimath 
%   associated with A. Data Type Propagation Rules (see below) are followed.
%
%   C = SQRT(A,F) returns the square root of fi object A.  
%   Intermediate quantities are calculated using fimath object F. 
%   The numerictype object of C is determined automatically for you using 
%   an internal rule. When A is a built-in double or single data type,
%   this syntax is equivalent to C = SQRT(A) and the fimath object F is
%   ignored.
%
%   C = SQRT(A,T,F) returns the square root fi object A with numerictype 
%   object T. Intermediate quantities are calculated using fimath object F.
%   SQRT does not support complex, negative-valued, or Slope-Bias inputs.
%
%   Internal Rule:
%   For syntaxes where the numerictype object of the output is not 
%   specified as an input to the sqrt function, it is automatically 
%   calculated according to the following internal rule:
%     sign(C) = sign(A)
%     word-length(C) = ceil((word-length(A)/2))
%     fraction-length(C) = word-length(C) - 
%                           ceil(((word-length(A) - fraction-length(A))/2))
%   Data Type Propagation Rules:
%     For syntaxes for which you specify a numerictype object T, the sqrt 
%     function follows the data type propagation rules listed in the 
%     following table. In general, these rules can be summarized as
%     "floating-point data types are propagated." This allows you to write 
%     code that can be used with both fixed-point and floating-point 
%     inputs.
%     Data Type of Input|Data Type of numerictype| Data Type of 
%        fi Object A    |       object T         |    Output C
%
%       Built-in double |        Any             |   Built-in double
%       Built-in single |        Any             |   Built-in single
%         fiFixed       |        fiFixed         |    Data type of  
%                       |                        | numerictype object T
%      fiScaledDouble   |       fiFixed          |   ScaledDouble with 
%                       |                        |properties of numerictype 
%                       |                        |      object T
%         fidouble      |       fiFixed          |      fidouble
%         fisingle      |       fiFixed          |      fisingle
%     Any fi data type  |       fidouble         |      fidouble
%     Any fi data type  |       fisingle         |      fisingle

%   Copyright 1999-2012 The MathWorks, Inc.

