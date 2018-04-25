%UNIQUETOL  Set unique within a tolerance.
%   UNIQUETOL is similar to unique. Whereas unique performs exact
%   comparisons, UNIQUETOL performs comparisons using a tolerance.
% 
%   C = UNIQUETOL(A,TOL) returns the unique values in A using tolerance
%   TOL. Each value of C is within tolerance of one value of A, but no two
%   elements in C are within tolerance of each other. C is sorted in
%   ascending order. UNIQUETOL scales the TOL input based on that magnitude
%   of the data, so that two values u and v are within tolerance if:
%     abs(u-v) <= TOL*max(abs(A(:)))
%
%   C = UNIQUETOL(A) uses a default tolerance of 1e-6 for single
%   precision inputs and 1e-12 for double precision inputs.
% 
%   [C,IA,IC] = UNIQUETOL(A) returns index vectors IA and IC such that:
%       C = A(IA) 
%       A ~ C(IC) (or A(:) ~ C(IC), if A is a matrix) 
%   where ~ means the values are within tolerance of each other.
%
%   [...] = UNIQUETOL(...,'Name1',Value1,'Name2',Value2,...)
%   specifies one or more of the following Name/Value pair arguments using
%   any of the previous syntaxes:
%
%   OutputAllIndices - When true, this returns a cell-array IALL
%                      (instead of IA) as the second output, indicating all
%                      the indices for elements in A that are within
%                      tolerance of a value in C. The default value is
%                      false.
%
%             ByRows - When true, this returns a matrix C of the same size
%                      as A such that every row of A is within tolerance of
%                      a row in C. For the rows case, two rows u and v are
%                      within tolerance if:
%                          all(abs(u-v) <= TOL*max(abs(A),[],1))
%                      Use this to find rows that are the same, within
%                      tolerance. For two rows to be within tolerance each
%                      column has to be within tolerance. The default value
%                      is false.
%
%          DataScale - A scalar which changes the tolerance test to be:
%                          abs(u-v) <= TOL*DS
%                      Specify a value DS if you want to specify an
%                      absolute tolerance. When used together with the
%                      ByRows option, the DataScale value may also be a
%                      vector. In that case, each element of the vector
%                      specifies DS for a corresponding column in A. If a
%                      value in the DataScale vector is Inf, then UNIQUETOL
%                      ignores the corresponding column in A.
%
% Example:
%   % A is a matrix of real values
%   A = [0.05, 0.11, 0.18;
%        0.18, 0.21, 0.29;
%        0.34, 0.36, 0.41;
%        0.46, 0.52, 0.76;
%        0.82, 0.91, 1.00];
%   % The entries of B are the same as the entries of A within round-off error.
%   B = log10(10.^A);
%   % A and B differ by small amounts
%   A-B
%   % unique uses exact equality, most of the rows in A are not matched
%   % with rows in B
%   unique([A;B],'rows')
%   % By default UNIQUETOL uses a small tolerance and the rows will be matched
%   uniquetol([A;B],'ByRows',true)
%
% See also: UNIQUE, ISMEMBERTOL

%  Copyright 2014-2016 The MathWorks, Inc.

