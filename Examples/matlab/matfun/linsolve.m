%LINSOLVE Solve linear system A*X=B.
%   X = LINSOLVE(A,B) solves the linear system A*X=B using LU factorization 
%   with partial pivoting when A is square, and QR factorization with 
%   column pivoting otherwise. LINSOLVE warns if A is ill conditioned (for 
%   square matrices) or rank deficient (for rectangular matrices). 
% 
%   X = LINSOLVE(A,B,OPTS) solves the linear system A*X=B using an
%   appropriate solver as determined by the options structure OPTS. The
%   fields in OPTS are logical values describing properties of the matrix
%   A (see table below). By default, all fields in OPTS are false. LINSOLVE
%   does not test to verify that A has the properties specified in OPTS.
%
%   [X,R] = LINSOLVE(...) also returns R, which is the reciprocal of the
%   condition number of A (for square matrices) or the rank of A (for
%   rectangular matrices). If OPTS is specified, then R is the reciprocal
%   of the condition number of A unless RECT is true and both LT and UT are
%   false, in which case, R gives the rank of A. LINSOLVE does not warn if
%   A is ill conditioned or rank deficient.
%
%   The possible field names in OPTS and their corresponding matrix
%   properties are:
%
%   Field Name : Matrix Property
%   ------------------------------------------------
%   LT         : Lower Triangular
%   UT         : Upper Triangular
%   UHESS      : Upper Hessenberg
%   SYM        : Real Symmetric or Complex Hermitian
%   POSDEF     : Positive Definite
%   RECT       : General Rectangular
%   TRANSA     : (Conjugate) Transpose of A
%
%   The following describes which fields can be specified together:
%
%   If LT is true, then UT, UHESS, and SYM must be false.
%   If UT is true, then LT, UHESS, and SYM must be false.
%   If UHESS is true, then LT, UT, SYM, and RECT must be false.
%   If SYM is true, then LT, UT, UHESS, and RECT must be false.
%   POSDEF can only be true if SYM is true.
%
%   Example:
%     A = triu(rand(5,3)); 
%     x = [1 1 1 0 0]'; 
%     b = A'*x;
%     y1 = (A')\b
%     opts.UT = true; 
%     opts.TRANSA = true;
%     y2 = linsolve(A,b,opts)
%
%   See also MLDIVIDE, SLASH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.