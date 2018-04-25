%ISMEMBERTOL Set ismember within a tolerance
%   ISMEMBERTOL is similar to ismember. Whereas ismember performs exact
%   comparisons, ISMEMBERTOL performs comparisons using a tolerance.
%
%   LIA = ISMEMBERTOL(A,B,TOL) returns an array of the same size as A
%   containing logical 1 (true) where the elements of A are within the
%   tolerance TOL of the elements in B; otherwise, it contains logical 0
%   (false). ISMEMBERTOL scales the TOL input based on the magnitude of the
%   data, so that two values u and v are within tolerance if:
%     abs(u-v) <= TOL*max(abs([A(:);B(:)]))
%
%   LIA = ISMEMBERTOL(A,B) uses a default tolerance of 1e-6 for single
%   precision inputs and 1e-12 for double precision inputs.
% 
%   [LIA,LOCB] = ISMEMBERTOL(A,B) also returns an array, LOCB, which
%   contains an index location in B for each element in A which is
%   a member of B.
%
%   [...] = ISMEMBERTOL(...,'Name1',Value1,'Name2',Value2,...)
%   specifies one or more of the following Name/Value pair arguments using
%   any of the previous syntaxes:
%
%   OutputAllIndices - When true, this returns a cell-array LOCAllB
%                      (instead of LOCB) as the second output, indicating
%                      all the indices in B that are within tolerance of
%                      a value in A. The default value is false.
%
%             ByRows - When true, this returns an array LIA indicating
%                      whether each row of A is within tolerance of a row
%                      in B. Two rows u and v are within tolerance if:
%                          all(abs(u-v) <= TOL*max(abs([A;B])))
%                      Use this to find rows that are within tolerance of
%                      each other. Each column is considered separately. 
%                      The default value is false.
%
%          DataScale - A scalar which changes the tolerance test to be:
%                          abs(u-v) <= TOL*DS
%                      Specify a value DS if you want to specify an
%                      absolute tolerance. When used together with the
%                      ByRows option, the DataScale value may also be a
%                      vector. In that case, each element of the vector
%                      specifies DS for a corresponding column in A. If a
%                      value in the DataScale vector is Inf, then
%                      ISMEMBERTOL ignores the corresponding column in A.
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
%   % ismember uses exact equality, most of the rows in A do not get matched
%   % with rows in B
%   ismember(A,B,'rows')
%   % By default ISMEMBERTOL uses a small tolerance and the rows will be matched
%   ismembertol(A,B,'ByRows',true)
%
% See also: ISMEMBER, UNIQUETOL

%  Copyright 2014-2016 The MathWorks, Inc.